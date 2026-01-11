const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

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

      // Hae kaikki käyttäjät
      const usersSnapshot = await admin.firestore().collection("users").get();
      
      const tokensToSend = [];

      // Käy läpi käyttäjät ja laske etäisyys
      usersSnapshot.forEach((userDoc) => {
        const userData = userDoc.data();

        // Onko käyttäjällä token (lupa ilmoituksiin) ja sijainti?
        if (userData.fcmToken && userData.location) {
          const userLat = userData.location.lat;
          const userLng = userData.location.lng;

          // Laske etäisyys
          const distanceInKm = calculateDistance(foodLat, foodLng, userLat, userLng);

          // Jos alle 5 km päässä, lisätään listaan
          // (Älä lähetä ilmoitusta ruoan lisääjälle itselleen)
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

      // 4. Lähetä ilmoitus
      const message = {
        notification: {
          title: senderName,
          body: text,
        },
        token: userData.fcmToken, // Huom: Yhdelle lähetettäessä käytetään 'token', ei 'tokens'
        data: {
            type: "chat",
            chatId: chatId
        }
      };

      try {
        await admin.messaging().send(message);
        console.log("Chat-ilmoitus lähetetty käyttäjälle:", recipientId);
      } catch (error) {
        console.error("Virhe chat-ilmoituksen lähetyksessä:", error);
      }
    });