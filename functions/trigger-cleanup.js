// This file calls the cleanupOldFoodItems function via Firebase Admin SDK
// Run with: node trigger-cleanup.js

const { initializeApp } = require('firebase-admin/app');
const { getFunctions } = require('firebase-admin/functions');
const admin = require('firebase-admin');

// Initialize
initializeApp({
    storageBucket: 'napurisapuska.firebasestorage.app'
});

async function triggerCleanup() {
    console.log('🔥 Triggering cleanupOldFoodItems function...\n');

    try {
        // Get the function
        const functions = getFunctions();

        // For PubSub functions, we need to publish a message to trigger them
        // OR we can directly call the cleanup logic here

        const db = admin.firestore();
        const storage = admin.storage().bucket();
        const now = admin.firestore.Timestamp.now();

        // Calculate date thresholds
        const fiveDaysAgo = admin.firestore.Timestamp.fromMillis(
            now.toMillis() - (5 * 24 * 60 * 60 * 1000)
        );
        const sevenDaysAgo = admin.firestore.Timestamp.fromMillis(
            now.toMillis() - (7 * 24 * 60 * 60 * 1000)
        );

        let deletedCount = 0;

        // Helper function
        function extractStoragePathFromUrl(url) {
            try {
                const match = url.match(/\/o\/(.+?)\?/);
                if (match && match[1]) {
                    return decodeURIComponent(match[1]);
                }
            } catch (error) {
                console.error("Error extracting storage path:", error);
            }
            return null;
        }

        async function deleteItemAndImages(doc) {
            const data = doc.data();
            const itemId = doc.id;

            console.log(`  🗑️  Deleting: ${data.title || itemId}`);

            // Delete images
            const imagesToDelete = [];
            if (data.imageUrl) imagesToDelete.push(data.imageUrl);
            if (data.imageUrls && Array.isArray(data.imageUrls)) {
                imagesToDelete.push(...data.imageUrls);
            }

            for (const imageUrl of imagesToDelete) {
                if (!imageUrl) continue;
                try {
                    const path = extractStoragePathFromUrl(imageUrl);
                    if (path) {
                        await storage.file(path).delete();
                        console.log(`     ✓ Image deleted`);
                    }
                } catch (error) {
                    console.warn(`     ⚠ Image error: ${error.message}`);
                }
            }

            await doc.ref.delete();
            console.log(`     ✓ Document deleted\n`);
        }

        // Query 1: Available items >5 days
        console.log('📋 Checking available items (>5 days old)...');
        const availableQuery = await db.collection("food_items")
            .where("status", "==", "available")
            .where("timestamp", "<=", fiveDaysAgo)
            .get();

        console.log(`Found ${availableQuery.size} items\n`);
        for (const doc of availableQuery.docs) {
            await deleteItemAndImages(doc);
            deletedCount++;
        }

        // Query 2: Reserved items >7 days
        console.log('📋 Checking reserved items (>7 days old)...');
        const reservedQuery = await db.collection("food_items")
            .where("status", "==", "reserved")
            .where("timestamp", "<=", sevenDaysAgo)
            .get();

        console.log(`Found ${reservedQuery.size} items\n`);
        for (const doc of reservedQuery.docs) {
            await deleteItemAndImages(doc);
            deletedCount++;
        }

        // Query 3: PickedUp items (all)
        console.log('📋 Checking pickedUp items...');
        const pickedUpQuery = await db.collection("food_items")
            .where("status", "==", "pickedUp")
            .get();

        console.log(`Found ${pickedUpQuery.size} items\n`);
        for (const doc of pickedUpQuery.docs) {
            await deleteItemAndImages(doc);
            deletedCount++;
        }

        console.log(`\n✅ Cleanup complete! Deleted ${deletedCount} items total.\n`);

    } catch (error) {
        console.error('❌ Error:', error);
    }

    process.exit(0);
}

triggerCleanup();
