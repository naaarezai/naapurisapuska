const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");
const ngeohash = require("ngeohash");

admin.initializeApp();

// Tämä funktio herää AINA kun uusi ruoka lisätään
exports.sendNewFoodNotification = functions.firestore
  .document("food_items/{itemId}")
  .onCreate(async (snapshot, context) => {
    const foodData = snapshot.data();

    // Jos sijaintia ei ole, lopeta
    if (!foodData.latitude || !foodData.longitude) {
      console.log("Ei koordinaatteja, ei lähetetä ilmoitusta.");
      return null;
    }

    const foodLat = foodData.latitude;
    const foodLng = foodData.longitude;
    const foodTitle = foodData.title || "Ruokaa";
    let foodGeohash = foodData.geohash;

    // Jos geohashia ei ole, lasketaan se lennossa
    if (!foodGeohash) {
      foodGeohash = ngeohash.encode(foodLat, foodLng, 6);
    }

    // Käytetään pituutta 5 (~5km x 5km tarkkuus)
    const searchHash = foodGeohash.substring(0, 5);
    const neighbors = ngeohash.neighbors(searchHash);
    const searchHashes = [searchHash, ...neighbors];

    console.log(`Etsitään käyttäjiä geohasheilla: ${searchHashes.join(", ")}`);

    // Hae vain käyttäjät, jotka ovat samoilla alueilla
    const usersSnapshot = await admin.firestore()
      .collection("users")
      .where("geohash", "in", searchHashes)
      .get();

    const tokensToSend = [];

    // Käy läpi vain lähellä olevat käyttäjät ja laske tarkka etäisyys
    usersSnapshot.forEach((userDoc) => {
      const userData = userDoc.data();

      if (userData.fcmToken && userData.location) {
        const userLat = userData.location.lat;
        const userLng = userData.location.lng;

        const distanceInKm = calculateDistance(foodLat, foodLng, userLat, userLng);

        if (distanceInKm < 5 && userDoc.id !== foodData.userId) {
          tokensToSend.push(userData.fcmToken);
        }
      }
    });

    if (tokensToSend.length === 0) {
      console.log("Ei käyttäjiä lähellä.");
      return null;
    }

    // Lähetä ilmoitus
    const message = {
      notification: {
        title: "Uutta ruokaa lähellä! 🍌",
        body: `${foodTitle} on lisätty 5 km säteellä sinusta.`,
      },
      data: {
        type: "new_food",
        creatorId: foodData.userId || "",
        itemId: snapshot.id
      },
      tokens: tokensToSend,
    };

    try {
      // KORJATTU KOHTA: Käytetään 'sendEachForMulticast' vanhan 'sendMulticast' sijaan
      const response = await admin.messaging().sendEachForMulticast(message);
      console.log("Ilmoitukset lähetetty:", response.successCount);

      if (response.failureCount > 0) {
        console.log("Epäonnistuneet:", response.failureCount);
        response.responses.forEach((resp, idx) => {
          if (!resp.success) {
            console.log(`Virhe tokenille ${tokensToSend[idx]}:`, resp.error);
          }
        });
      }
    } catch (error) {
      console.error("Virhe lähetyksessä:", error);
    }
  });

// Apufunktio etäisyyden laskemiseen (km)
function calculateDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Maapallon säde km
  const dLat = deg2rad(lat2 - lat1);
  const dLon = deg2rad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function deg2rad(deg) {
  return deg * (Math.PI / 180);
}

// --- CHAT-ILMOITUS ---

exports.sendChatNotification = functions.firestore
  .document("chats/{chatId}/messages/{messageId}")
  .onCreate(async (snapshot, context) => {
    const messageData = snapshot.data();
    const chatId = context.params.chatId;
    const senderId = messageData.senderId;
    const senderName = messageData.senderName || "Joku";
    const text = messageData.text || "Uusi viesti";

    // 1. Hae chatin tiedot, jotta tiedetään osallistujat
    const chatDoc = await admin.firestore().collection("chats").doc(chatId).get();
    const chatData = chatDoc.data();

    if (!chatData || !chatData.participants) {
      console.log("Chat-tietoja ei löytynyt.");
      return null;
    }

    // 2. Etsi vastaanottajan ID (se osallistuja, joka EI ole lähettäjä)
    const recipientId = chatData.participants.find((uid) => uid !== senderId);

    if (!recipientId) {
      console.log("Vastaanottajaa ei löytynyt.");
      return null;
    }

    // 3. Hae vastaanottajan token
    const userDoc = await admin.firestore().collection("users").doc(recipientId).get();
    const userData = userDoc.data();

    if (!userData || !userData.fcmToken) {
      console.log("Käyttäjällä ei ole tokenia (ilmoituslupaa).");
      return null;
    }

    // 4. Laske lukemattomien viestien kokonaismäärä merkkiä (badge) varten
    let badgeCount = 1; // Oletus jos laskenta epäonnistuu
    try {
      const chatsSnapshot = await admin.firestore()
        .collection('chats')
        .where('participants', 'array-contains', recipientId)
        .get();

      let totalUnread = 0;
      chatsSnapshot.forEach(doc => {
        const d = doc.data();
        const unread = d[`unreadCount_${recipientId}`] || 0;
        totalUnread += Number(unread);
      });
      // Varmistetaan että nykyinen viesti on mukana laskussa (jos client ei ehtinyt päivittää)
      // Huom: Client päivittää 'unreadCount' kentän yleensä samaan aikaan.
      // Jos luotamme siihen että client on nopea, totalUnread on oikein. 
      // Varmuuden vuoksi, jos totalUnread on 0, asetetaan 1.
      badgeCount = totalUnread > 0 ? totalUnread : 1;
    } catch (e) {
      console.error("Virhe badge-laskennassa:", e);
    }

    // 5. Lähetä ilmoitus
    const message = {
      notification: {
        title: senderName,
        body: text,
      },
      token: userData.fcmToken,
      data: {
        type: "chat",
        chatId: chatId
      },
      apns: {
        payload: {
          aps: {
            badge: badgeCount,
            sound: "default"
          }
        }
      },
      android: {
        notification: {
          sound: "default",
          notificationCount: badgeCount
        }
      }
    };

    try {
      await admin.messaging().send(message);
      console.log(`Chat-ilmoitus lähetetty käyttäjälle ${recipientId}, badge: ${badgeCount}`);
    } catch (error) {
      console.error("Virhe chat-ilmoituksen lähetyksessä:", error);
    }
  });

// ============================================================
// AUTO-DELETE: Poistaa vanhat ruokailmoitukset automaattisesti
// ============================================================

/**
 * Scheduled function: Runs daily at midnight (Helsinki time)
 * Deletes food items based on status:
 *  - available: 5 days old
 *  - reserved: 7 days old
 *  - pickedUp: any age (immediate deletion)
 */
exports.cleanupOldFoodItems = functions.pubsub
  .schedule("0 0 * * *")  // Run at 00:00 UTC daily
  .timeZone("Europe/Helsinki")
  .onRun(async (context) => {
    console.log("Starting automatic cleanup of old food items...");

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
    const oneDayAgo = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - (1 * 24 * 60 * 60 * 1000)
    );

    let deletedCount = 0;
    let errorCount = 0;

    try {
      // Query 1: Delete available items older than 5 days
      const availableQuery = await db.collection("food_items")
        .where("status", "==", "available")
        .where("timestamp", "<=", fiveDaysAgo)
        .get();

      console.log(`Found ${availableQuery.size} available items to delete (>5 days)`);

      for (const doc of availableQuery.docs) {
        try {
          await deleteItemAndImages(doc, storage, db);
          deletedCount++;
        } catch (error) {
          console.error(`Error deleting available item ${doc.id}:`, error);
          errorCount++;
        }
      }

      // Query 2: Delete reserved items older than 7 days (from reservation)
      const reservedQuery = await db.collection("food_items")
        .where("status", "==", "reserved")
        .where("reservedAt", "<=", sevenDaysAgo)
        .get();

      console.log(`Found ${reservedQuery.size} reserved items to delete (>7 days)`);

      for (const doc of reservedQuery.docs) {
        try {
          await deleteItemAndImages(doc, storage, db);
          deletedCount++;
        } catch (error) {
          console.error(`Error deleting reserved item ${doc.id}:`, error);
          errorCount++;
        }
      }

      // Query 3: Delete pickedUp items older than 1 day (from pickup)
      const pickedUpQuery = await db.collection("food_items")
        .where("status", "==", "pickedUp")
        .where("pickedUpAt", "<=", oneDayAgo)
        .get();

      console.log(`Found ${pickedUpQuery.size} pickedUp items to delete (>1 day)`);

      for (const doc of pickedUpQuery.docs) {
        try {
          await deleteItemAndImages(doc, storage, db);
          deletedCount++;
        } catch (error) {
          console.error(`Error deleting pickedUp item ${doc.id}:`, error);
          errorCount++;
        }
      }

      console.log(`Cleanup complete! Deleted: ${deletedCount}, Errors: ${errorCount}`);
      return { success: true, deleted: deletedCount, errors: errorCount };

    } catch (error) {
      console.error("Fatal error during cleanup:", error);
      return { success: false, error: error.message };
    }
  });

// ============================================================
// TEST FUNCTION: Manual cleanup trigger (for testing)
// ============================================================

/**
 * HTTP function: Runs cleanup logic immediately (for testing)
 * Call this via URL to test deletion without waiting for midnight
 * URL: https://YOUR-REGION-YOUR-PROJECT.cloudfunctions.net/testCleanupNow
 */
exports.testCleanupNow = functions.https.onRequest(async (req, res) => {
  // Simple security check
  const apiKey = req.query.key || req.headers['x-api-key'];
  if (apiKey !== process.env.NAPSU_API_KEY) {
    console.warn("🔐 Luvaton pääsy testCleanupNow-funktioon!");
    return res.status(403).send("Forbidden: Invalid API Key");
  }

  console.log("🧪 TEST: Running manual cleanup NOW...");

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
  const oneDayAgo = admin.firestore.Timestamp.fromMillis(
    now.toMillis() - (1 * 24 * 60 * 60 * 1000)
  );

  let deletedCount = 0;
  let errorCount = 0;
  const report = {
    availableFound: 0,
    reservedFound: 0,
    pickedUpFound: 0,
    deleted: [],
    errors: []
  };

  try {
    // Query 1: available items older than 5 days
    const availableQuery = await db.collection("food_items")
      .where("status", "==", "available")
      .where("timestamp", "<=", fiveDaysAgo)
      .get();

    report.availableFound = availableQuery.size;
    console.log(`Found ${availableQuery.size} available items to delete (>5 days)`);

    for (const doc of availableQuery.docs) {
      try {
        await deleteItemAndImages(doc, storage, db);
        deletedCount++;
        report.deleted.push({ id: doc.id, reason: "available >5 days" });
      } catch (error) {
        console.error(`Error deleting available item ${doc.id}:`, error);
        errorCount++;
        report.errors.push({ id: doc.id, error: error.message });
      }
    }

    // Query 2: reserved items older than 7 days (from reservation)
    const reservedQuery = await db.collection("food_items")
      .where("status", "==", "reserved")
      .where("reservedAt", "<=", sevenDaysAgo)
      .get();

    report.reservedFound = reservedQuery.size;
    console.log(`Found ${reservedQuery.size} reserved items to delete (>7 days)`);

    for (const doc of reservedQuery.docs) {
      try {
        await deleteItemAndImages(doc, storage, db);
        deletedCount++;
        report.deleted.push({ id: doc.id, reason: "reserved >7 days" });
      } catch (error) {
        console.error(`Error deleting reserved item ${doc.id}:`, error);
        errorCount++;
        report.errors.push({ id: doc.id, error: error.message });
      }
    }

    // Query 3: pickedUp items older than 1 day (from pickup)
    const pickedUpQuery = await db.collection("food_items")
      .where("status", "==", "pickedUp")
      .where("pickedUpAt", "<=", oneDayAgo)
      .get();

    report.pickedUpFound = pickedUpQuery.size;
    console.log(`Found ${pickedUpQuery.size} pickedUp items to delete (>1 day)`);

    for (const doc of pickedUpQuery.docs) {
      try {
        await deleteItemAndImages(doc, storage, db);
        deletedCount++;
        report.deleted.push({ id: doc.id, reason: "pickedUp >1 day" });
      } catch (error) {
        console.error(`Error deleting pickedUp item ${doc.id}:`, error);
        errorCount++;
        report.errors.push({ id: doc.id, error: error.message });
      }
    }

    console.log(`✅ Test cleanup complete! Deleted: ${deletedCount}, Errors: ${errorCount}`);

    // Return detailed report
    res.status(200).json({
      success: true,
      timestamp: new Date().toISOString(),
      summary: {
        availableFound: report.availableFound,
        reservedFound: report.reservedFound,
        pickedUpFound: report.pickedUpFound,
        totalDeleted: deletedCount,
        totalErrors: errorCount
      },
      deleted: report.deleted,
      errors: report.errors
    });

  } catch (error) {
    console.error("Fatal error during test cleanup:", error);
    res.status(500).json({
      success: false,
      error: error.message,
      stack: error.stack
    });
  }
});

/**
 * Scheduled function: Sends 24-hour warning notifications
 * Runs daily at midnight (Helsinki time)
 */
exports.sendExpirationWarnings = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("Europe/Helsinki")
  .onRun(async (context) => {
    console.log("Starting expiration warning notifications...");

    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    // Calculate tomorrow's threshold (items expiring in ~24 hours)
    const fourDaysAgo = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - (4 * 24 * 60 * 60 * 1000)
    );
    const sixDaysAgo = admin.firestore.Timestamp.fromMillis(
      now.toMillis() - (6 * 24 * 60 * 60 * 1000)
    );

    let notificationsSent = 0;

    try {
      // Find available items that will expire tomorrow (created 4 days ago)
      const expiringAvailableQuery = await db.collection("food_items")
        .where("status", "==", "available")
        .where("timestamp", "<=", fourDaysAgo)
        .get();

      console.log(`Found ${expiringAvailableQuery.size} available items expiring soon`);

      for (const doc of expiringAvailableQuery.docs) {
        const data = doc.data();

        // Skip if already sent warning (optional: track in a field)
        try {
          await sendExpirationNotification(doc.id, data, "available", 1);
          notificationsSent++;
        } catch (error) {
          console.error(`Error sending notification for ${doc.id}:`, error);
        }
      }

      // Find reserved items that will expire tomorrow (reserved 6 days ago)
      const expiringReservedQuery = await db.collection("food_items")
        .where("status", "==", "reserved")
        .where("reservedAt", "<=", sixDaysAgo)
        .get();

      console.log(`Found ${expiringReservedQuery.size} reserved items expiring soon`);

      for (const doc of expiringReservedQuery.docs) {
        const data = doc.data();

        try {
          await sendExpirationNotification(doc.id, data, "reserved", 1);
          notificationsSent++;
        } catch (error) {
          console.error(`Error sending notification for ${doc.id}:`, error);
        }
      }

      console.log(`Expiration warnings sent: ${notificationsSent}`);
      return { success: true, sent: notificationsSent };

    } catch (error) {
      console.error("Fatal error during expiration warnings:", error);
      return { success: false, error: error.message };
    }
  });

// ============================================================
// HELPER FUNCTIONS
// ============================================================

/**
 * Deletes a food item document and all associated images
 */
async function deleteItemAndImages(docSnapshot, storage, db) {
  const data = docSnapshot.data();
  const itemId = docSnapshot.id;

  // Send deletion notification to owner
  if (data.userId) {
    await sendDeletionNotification(itemId, data);
  }

  // Delete images from Storage
  const imagesToDelete = [];

  // Main image
  if (data.imageUrl) {
    imagesToDelete.push(data.imageUrl);
  }

  // Additional images
  if (data.imageUrls && Array.isArray(data.imageUrls)) {
    imagesToDelete.push(...data.imageUrls);
  }

  // Delete each image
  for (const imageUrl of imagesToDelete) {
    if (!imageUrl) continue;

    try {
      // Extract storage path from URL
      const path = extractStoragePathFromUrl(imageUrl);
      if (path) {
        await storage.file(path).delete();
        console.log(`Deleted image: ${path}`);
      }
    } catch (error) {
      // Image might already be deleted or path invalid
      console.warn(`Could not delete image ${imageUrl}:`, error.message);
    }
  }

  // Delete Firestore document
  await docSnapshot.ref.delete();
  console.log(`Deleted food item: ${itemId}`);
}

/**
 * Extracts storage path from Firebase Storage URL
 */
function extractStoragePathFromUrl(url) {
  try {
    // Firebase Storage URLs contain the path after /o/
    const match = url.match(/\/o\/(.+?)\?/);
    if (match && match[1]) {
      return decodeURIComponent(match[1]);
    }
  } catch (error) {
    console.error("Error extracting storage path:", error);
  }
  return null;
}

/**
 * Sends expiration warning notification to item owner
 */
async function sendExpirationNotification(itemId, itemData, status, daysLeft) {
  const db = admin.firestore();
  const userId = itemData.userId;
  const title = itemData.title || "Ruokailmoitus";

  if (!userId) return;

  try {
    // Create notification document
    await db.collection("notifications").add({
      userId: userId,
      type: "item_expiring",
      title: "Ilmoituksesi vanhenee pian",
      message: `Ilmoituksesi "${title}" vanhenee ${daysLeft} päivän kuluttua. Jos ruoka on vielä saatavilla, voit pidentää aikaa.`,
      timestamp: admin.firestore.Timestamp.now(),
      isRead: false,
      relatedItemId: itemId,
      actionType: "extend_listing"
    });

    // Try to send FCM push notification
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    if (userData && userData.fcmToken) {
      const message = {
        notification: {
          title: "Ilmoituksesi vanhenee",
          body: `"${title}" vanhenee ${daysLeft} päivän kuluttua ⏰`,
        },
        token: userData.fcmToken,
        data: {
          type: "item_expiring",
          itemId: itemId
        }
      };

      await admin.messaging().send(message);
      console.log(`Sent expiration warning to user ${userId}`);
    }
  } catch (error) {
    console.error(`Error sending expiration notification:`, error);
  }
}

/**
 * Sends deletion notification to item owner
 */
async function sendDeletionNotification(itemId, itemData) {
  const db = admin.firestore();
  const userId = itemData.userId;
  const title = itemData.title || "Ruokailmoitus";

  if (!userId) return;

  try {
    // Create notification document
    await db.collection("notifications").add({
      userId: userId,
      type: "item_deleted",
      title: "Ilmoituksesi poistettiin",
      message: `Ilmoituksesi "${title}" on poistettu automaattisesti vanhentumisen vuoksi.`,
      timestamp: admin.firestore.Timestamp.now(),
      isRead: false,
      relatedItemId: itemId
    });

    // Try to send FCM push notification
    const userDoc = await db.collection("users").doc(userId).get();
    const userData = userDoc.data();

    if (userData && userData.fcmToken) {
      const message = {
        notification: {
          title: "Ilmoitus poistettu",
          body: `"${title}" poistettiin automaattisesti`,
        },
        token: userData.fcmToken,
        data: {
          type: "item_deleted",
          itemId: itemId
        }
      };

      await admin.messaging().send(message);
      console.log(`Sent deletion notification to user ${userId}`);
    }
  } catch (error) {
    console.error(`Error sending deletion notification:`, error);
  }
}

// ============================================================
// TEST DATA GENERATOR (for repopulating database)
// ============================================================

exports.createTestData = functions.https.onRequest(async (req, res) => {
  // Simple security check
  const apiKey = req.query.key || req.headers['x-api-key'];
  if (apiKey !== process.env.NAPSU_API_KEY) {
    console.warn("🔐 Luvaton pääsy createTestData-funktioon!");
    return res.status(403).send("Forbidden: Invalid API Key");
  }

  console.log('🌱 Creating test food items...');

  const db = admin.firestore();

  // Test food items around Kouvola
  const testItems = [
    { title: "Tuoreet Omenat", description: "5 kg luomu omenoita.", category: "hedelmat", lat: 60.8685, lng: 26.7042, status: "available" },
    { title: "Leivonnaisia", description: "Pullia ja sämpylöitä.", category: "leivonnaiset", lat: 60.8721, lng: 26.7091, status: "available" },
    { title: "Porkkanoita", description: "Luomu porkkanoita.", category: "vihannekset", lat: 60.8650, lng: 26.7150, status: "available" },
    { title: "Banaaneja", description: "Kypsyivät nopeasti.", category: "hedelmat", lat: 60.8700, lng: 26.7000, status: "reserved", reserved: true },
    { title: "Riisiä ja Pastaa", description: "Avatut pakkaukset.", category: "muut", lat: 60.8690, lng: 26.7080, status: "available" },
    { title: "Perunoita", description: "Kotimaisia perunoita.", category: "vihannekset", lat: 60.8710, lng: 26.7120, status: "available" },
    { title: "Leivän Paloja", description: "Hyvää paahtoleipään.", category: "leivonnaiset", lat: 60.8675, lng: 26.7055, status: "available" },
    { title: "Salaattia", description: "Tuore jäävuorisalaatti.", category: "vihannekset", lat: 60.8695, lng: 26.7070, status: "available" }
  ];

  try {
    let created = 0;

    for (let i = 0; i < testItems.length; i++) {
      const item = testItems[i];
      const itemId = `${Date.now()}_${i}`;

      const foodItem = {
        id: itemId,
        title: item.title,
        description: item.description,
        category: item.category,
        latitude: item.lat,
        longitude: item.lng,
        status: item.status,
        timestamp: admin.firestore.Timestamp.now(),
        price: null,
        quantity: null,
        quantityUnit: null,
        userId: `test_user_${i + 1}`,
        userName: `Testi ${i + 1}`,
        imageUrl: "",
        imageUrls: [],
        isReserved: item.reserved || false,
        reservedByUserId: item.reserved ? "test_user_x" : null,
        reservedAt: item.reserved ? admin.firestore.Timestamp.now() : null,
        dietaryTags: []
      };

      await db.collection('food_items').doc(itemId).set(foodItem);
      console.log(`✅ Created: ${item.title}`);
      created++;

      await new Promise(resolve => setTimeout(resolve, 100));
    }

    res.status(200).json({
      success: true,
      created: created,
      message: `Created ${created} test food items!`
    });

  } catch (error) {
    console.error('❌ Error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});