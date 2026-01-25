/**
 * Simple cleanup script - Run with: node simple-cleanup.js
 * This will show you what items would be deleted and ask for confirmation
 */
const admin = require('firebase-admin');

// Initialize Firebase
admin.initializeApp({
    storageBucket: 'napurisapuska.firebasestorage.app'
});

const db = admin.firestore();

async function findOldItems() {
    console.log('🔍 Searching for old food items...\n');

    const now = new Date();
    const fiveDaysAgo = new Date(now.getTime() - (5 * 24 * 60 * 60 * 1000));
    const sevenDaysAgo = new Date(now.getTime() - (7 * 24 * 60 * 60 * 1000));

    try {
        // Get all items to check manually (safer)
        const allItems = await db.collection('food_items').get();

        console.log(`📊 Total food items in database: ${allItems.size}\n`);

        const toDelete = {
            available: [],
            reserved: [],
            pickedUp: []
        };

        allItems.forEach(doc => {
            const data = doc.data();
            const timestamp = data.timestamp?.toDate();
            const status = data.status || 'available';
            const title = data.title || 'No title';

            if (!timestamp) return;

            const age = Math.floor((now - timestamp) / (1000 * 60 * 60 * 24));

            // Check if should be deleted
            if (status === 'available' && timestamp < fiveDaysAgo) {
                toDelete.available.push({ id: doc.id, title, age });
            } else if (status === 'reserved' && timestamp < sevenDaysAgo) {
                toDelete.reserved.push({ id: doc.id, title, age });
            } else if (status === 'pickedUp') {
                toDelete.pickedUp.push({ id: doc.id, title, age });
            }
        });

        // Display results
        console.log('📋 Items to be deleted:\n');

        if (toDelete.available.length > 0) {
            console.log(`🟢 Available items (>5 days old): ${toDelete.available.length}`);
            toDelete.available.forEach(item => {
                console.log(`   - ${item.title} (${item.age} days old)`);
            });
            console.log('');
        }

        if (toDelete.reserved.length > 0) {
            console.log(`🟡 Reserved items (>7 days old): ${toDelete.reserved.length}`);
            toDelete.reserved.forEach(item => {
                console.log(`   - ${item.title} (${item.age} days old)`);
            });
            console.log('');
        }

        if (toDelete.pickedUp.length > 0) {
            console.log(`✅ Picked up items (all): ${toDelete.pickedUp.length}`);
            toDelete.pickedUp.forEach(item => {
                console.log(`   - ${item.title} (${item.age} days old)`);
            });
            console.log('');
        }

        const total = toDelete.available.length + toDelete.reserved.length + toDelete.pickedUp.length;

        console.log(`📊 TOTAL TO DELETE: ${total} items\n`);

        if (total === 0) {
            console.log('✅ No old items found! Your database is clean.\n');
        } else {
            console.log('To delete these items, you have 2 options:\n');
            console.log('1. Wait for the scheduled function to run at midnight');
            console.log('2. Delete manually in Firebase Console:');
            console.log('   https://console.firebase.google.com/project/napurisapuska/firestore\n');
        }

    } catch (error) {
        console.error('❌ Error:', error.message);
    }

    process.exit(0);
}

findOldItems();
