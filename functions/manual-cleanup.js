const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./serviceAccountKey.json'); // You'll need to download this from Firebase Console

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    storageBucket: 'napurisapuska.firebasestorage.app'
});

const db = admin.firestore();
const storage = admin.storage().bucket();

// Helper function to extract storage path from URL
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

// Delete item and images
async function deleteItemAndImages(doc) {
    const data = doc.data();
    const itemId = doc.id;

    console.log(`Deleting item: ${itemId} - ${data.title}`);

    // Delete images from Storage
    const imagesToDelete = [];

    if (data.imageUrl) {
        imagesToDelete.push(data.imageUrl);
    }

    if (data.imageUrls && Array.isArray(data.imageUrls)) {
        imagesToDelete.push(...data.imageUrls);
    }

    // Delete each image
    for (const imageUrl of imagesToDelete) {
        if (!imageUrl) continue;

        try {
            const path = extractStoragePathFromUrl(imageUrl);
            if (path) {
                await storage.file(path).delete();
                console.log(`  ✓ Deleted image: ${path}`);
            }
        } catch (error) {
            console.warn(`  ⚠ Could not delete image ${imageUrl}:`, error.message);
        }
    }

    // Delete Firestore document
    await doc.ref.delete();
    console.log(`  ✓ Deleted document: ${itemId}`);
}

// Main cleanup function
async function cleanupOldItems() {
    console.log('🧹 Starting manual cleanup of old food items...\n');

    const now = admin.firestore.Timestamp.now();

    const fiveDaysAgo = admin.firestore.Timestamp.fromMillis(
        now.toMillis() - (5 * 24 * 60 * 60 * 1000)
    );
    const sevenDaysAgo = admin.firestore.Timestamp.fromMillis(
        now.toMillis() - (7 * 24 * 60 * 60 * 1000)
    );

    let deletedCount = 0;
    let errorCount = 0;

    try {
        // Query 1: Delete available items older than 5 days
        console.log('📋 Checking available items (>5 days old)...');
        const availableQuery = await db.collection("food_items")
            .where("status", "==", "available")
            .where("timestamp", "<=", fiveDaysAgo)
            .get();

        console.log(`Found ${availableQuery.size} available items to delete\n`);

        for (const doc of availableQuery.docs) {
            try {
                await deleteItemAndImages(doc);
                deletedCount++;
            } catch (error) {
                console.error(`❌ Error deleting ${doc.id}:`, error);
                errorCount++;
            }
        }

        // Query 2: Delete reserved items older than 7 days
        console.log('\n📋 Checking reserved items (>7 days old)...');
        const reservedQuery = await db.collection("food_items")
            .where("status", "==", "reserved")
            .where("timestamp", "<=", sevenDaysAgo)
            .get();

        console.log(`Found ${reservedQuery.size} reserved items to delete\n`);

        for (const doc of reservedQuery.docs) {
            try {
                await deleteItemAndImages(doc);
                deletedCount++;
            } catch (error) {
                console.error(`❌ Error deleting ${doc.id}:`, error);
                errorCount++;
            }
        }

        // Query 3: Delete all pickedUp items
        console.log('\n📋 Checking pickedUp items (all)...');
        const pickedUpQuery = await db.collection("food_items")
            .where("status", "==", "pickedUp")
            .get();

        console.log(`Found ${pickedUpQuery.size} pickedUp items to delete\n`);

        for (const doc of pickedUpQuery.docs) {
            try {
                await deleteItemAndImages(doc);
                deletedCount++;
            } catch (error) {
                console.error(`❌ Error deleting ${doc.id}:`, error);
                errorCount++;
            }
        }

        console.log('\n✅ Cleanup complete!');
        console.log(`   Deleted: ${deletedCount} items`);
        console.log(`   Errors: ${errorCount}`);

    } catch (error) {
        console.error('❌ Fatal error during cleanup:', error);
    }

    process.exit(0);
}

// Run the cleanup
cleanupOldItems();
