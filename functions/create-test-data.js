const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
    credential: admin.credential.applicationDefault()
});

const db = admin.firestore();

// Test food items - Located around Kouvola, Finland
const testFoodItems = [
    {
        title: "Tuoreet Omenat",
        description: "5 kg luomu omenoita. Hyvässä kunnossa, muutama pieni kolhu.",
        category: "hedelmat",
        latitude: 60.8685,
        longitude: 26.7042,
        status: "available",
        price: null,
        quantity: 5,
        quantityUnit: "kg",
        userId: "test_user_1",
        userName: "Matti M.",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: ["luomu"]
    },
    {
        title: "Leivonnaisia",
        description: "Pullia ja sämpylöitä jäänyt yli kahvilasta. Tuoreita!",
        category: "leivonnaiset",
        latitude: 60.8721,
        longitude: 26.7091,
        status: "available",
        price: null,
        quantity: 12,
        quantityUnit: "kpl",
        userId: "test_user_2",
        userName: "Cafe Keskusta",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: []
    },
    {
        title: "Porkkanoita",
        description: "Luomu porkkanoita pihalta. Pesu tarvitaan.",
        category: "vihannekset",
        latitude: 60.8650,
        longitude: 26.7150,
        status: "available",
        price: null,
        quantity: 3,
        quantityUnit: "kg",
        userId: "test_user_3",
        userName: "Anna K.",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: ["luomu", "vegaaninen"]
    },
    {
        title: "Banaaneja",
        description: "Banaanit kypsyivät liian nopeasti. Täysin syötäviä!",
        category: "hedelmat",
        latitude: 60.8700,
        longitude: 26.7000,
        status: "reserved",
        price: null,
        quantity: 2,
        quantityUnit: "kg",
        userId: "test_user_4",
        userName: "Kauppa XYZ",
        imageUrl: "",
        imageUrls: [],
        isReserved: true,
        reservedByUserId: "test_user_5",
        reservedAt: admin.firestore.Timestamp.now(),
        dietaryTags: ["vegaaninen"]
    },
    {
        title: "Riisiä ja Pastaa",
        description: "Avatut pakkaukset, puhdas ja kuiva. Noin 2 kg yhteensä.",
        category: "muut",
        latitude: 60.8690,
        longitude: 26.7080,
        status: "available",
        price: null,
        quantity: 2,
        quantityUnit: "kg",
        userId: "test_user_6",
        userName: "Mikko P.",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: ["vegaaninen"]
    },
    {
        title: "Perunoita",
        description: "Kotimaisia perunoita. Sovelias kaikenlaiseen.",
        category: "vihannekset",
        latitude: 60.8710,
        longitude: 26.7120,
        status: "available",
        price: null,
        quantity: 10,
        quantityUnit: "kg",
        userId: "test_user_7",
        userName: "Maija L.",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: ["vegaaninen"]
    },
    {
        title: "Leivän Paloja",
        description: "Leipää jäänyt yli. Hyvää paahtoleipään!",
        category: "leivonnaiset",
        latitude: 60.8675,
        longitude: 26.7055,
        status: "available",
        price: null,
        quantity: 1,
        quantityUnit: "pussi",
        userId: "test_user_8",
        userName: "Pekka T.",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: []
    },
    {
        title: "Salaattia",
        description: "Tuore jäävuorisalaatti. Käyttämätön.",
        category: "vihannekset",
        latitude: 60.8695,
        longitude: 26.7070,
        status: "available",
        price: null,
        quantity: 1,
        quantityUnit: "kpl",
        userId: "test_user_9",
        userName: "Sari H.",
        imageUrl: "",
        imageUrls: [],
        isReserved: false,
        reservedByUserId: null,
        reservedAt: null,
        dietaryTags: ["vegaaninen"]
    }
];

async function createTestData() {
    console.log('🌱 Creating test food items...\n');

    try {
        for (let i = 0; i < testFoodItems.length; i++) {
            const item = testFoodItems[i];

            // Generate unique ID based on timestamp
            const itemId = `${Date.now()}_${i}`;

            // Add timestamp
            item.timestamp = admin.firestore.Timestamp.now();
            item.id = itemId;

            // Add to Firestore
            await db.collection('food_items').doc(itemId).set(item);

            console.log(`✅ Created: ${item.title} (${item.category}, ${item.status})`);

            // Small delay to ensure unique timestamps
            await new Promise(resolve => setTimeout(resolve, 100));
        }

        console.log(`\n🎉 Successfully created ${testFoodItems.length} test items!`);
        console.log('\n📍 All items located around Kouvola, Finland');
        console.log('🗺️ Open your app to see them on the map!\n');

    } catch (error) {
        console.error('❌ Error creating test data:', error);
    } finally {
        process.exit(0);
    }
}

// Run it
createTestData();
