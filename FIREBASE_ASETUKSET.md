# 🔥 Firebase-asetukset ja -säännöt

## 📋 Yhteenveto

Tämä dokumentti kertoo mitä pitää tehdä Firebase-konsolissa, jotta sovellus toimii oikein.

---

## ✅ Mitä on jo tehty

### 1. **Firestore Rules** (`firestore.rules`)
- ✅ Ruokailmoitukset (`food_items`) - kaikki voivat lukea/kirjoittaa
- ✅ Käyttäjätiedot (`users`) - kaikki voivat lukea/kirjoittaa
- ✅ Chatit (`chats`) - kaikki voivat lukea/kirjoittaa
- ✅ Viestit (`messages`) - kaikki voivat lukea/kirjoittaa
- ✅ Ilmoitukset (`notifications`) - kaikki voivat lukea/kirjoittaa

### 2. **Storage Rules** (`storage.rules`)
- ✅ Ruokakuvat (`food_images`) - kaikki voivat lukea/kirjoittaa
- ✅ Profiilikuvat (`profile_images`) - kaikki voivat lukea/kirjoittaa

---

## 🚀 Mitä pitää tehdä Firebase-konsolissa

### Vaihe 1: Deploy Firestore Rules

1. Avaa [Firebase Console](https://console.firebase.google.com/)
2. Valitse projekti
3. Mene **Firestore Database** → **Rules**
4. Kopioi sisältö `firestore.rules`-tiedostosta
5. Liitä se Firebase-konsoliin
6. Klikkaa **Publish**

### Vaihe 2: Deploy Storage Rules

1. Firebase-konsolissa, mene **Storage** → **Rules**
2. Kopioi sisältö `storage.rules`-tiedostosta
3. Liitä se Firebase-konsoliin
4. Klikkaa **Publish**

### Vaihe 3: Tarkista Collections

Varmista että Firestore:ssa on seuraavat kokoelmat:
- ✅ `food_items` - Ruokailmoitukset
- ✅ `users` - Käyttäjätiedot
- ✅ `chats` - Chatit (luodaan automaattisesti kun viestejä lähetetään)
- ✅ `notifications` - Ilmoitukset (luodaan automaattisesti)

**Huom**: `chats` ja `notifications` luodaan automaattisesti kun sovellus käyttää niitä. Ei tarvitse luoda manuaalisesti!

---

## 📊 Tietokantarakenne

### `food_items` Collection
```
food_items/
  {itemId}/
    - title: string
    - description: string
    - imageUrl: string
    - latitude: number
    - longitude: number
    - category: string (leivonnaiset, hedelmat, vihannekset, muut)
    - price: number? (null jos ilmainen)
    - userId: string
    - userName: string?
    - userProfileImageUrl: string?
    - timestamp: timestamp
    - isReserved: boolean
    - reservedBy: string? (userId)
```

### `users` Collection
```
users/
  {userId}/
    - name: string
    - phoneNumber: string
    - profileImageUrl: string?
    - createdAt: timestamp
```

### `chats` Collection
```
chats/
  {chatId}/  (esim. "userId1_userId2")
    - participants: array [userId1, userId2]
    - lastMessage: string
    - lastMessageTime: timestamp
    - messages/
      {messageId}/
        - senderId: string
        - senderName: string
        - senderProfileImageUrl: string?
        - text: string
        - timestamp: timestamp
        - isRead: boolean
```

### `notifications` Collection
```
notifications/
  {notificationId}/
    - userId: string
    - type: string (esim. "new_message", "food_reserved")
    - title: string
    - body: string
    - timestamp: timestamp
    - isRead: boolean
```

---

## 🔒 Tietoturva (Tulevaisuudessa)

**HUOM**: Tällä hetkellä kaikki säännöt ovat auki (kehitysvaiheessa). Tuotannossa pitää:

1. **Firestore Rules**:
   - Vain kirjautuneet käyttäjät voivat luoda/päivittää ilmoituksia
   - Käyttäjät voivat päivittää vain omia tietojaan
   - Chatit näkyvät vain osallistujille

2. **Storage Rules**:
   - Vain kirjautuneet käyttäjät voivat ladata kuvia
   - Käyttäjät voivat poistaa vain omia kuviaan

---

## ✅ Testaus

Kun olet deployannut säännöt:

1. **Testaa ilmoituksen lisääminen**:
   - Lisää ilmoitus sovelluksessa
   - Tarkista että se näkyy Firestore:ssa `food_items`-kokoelmassa

2. **Testaa chat**:
   - Lähetä viesti toiselle käyttäjälle
   - Tarkista että chat luodaan `chats`-kokoelmaan
   - Tarkista että viesti näkyy `chats/{chatId}/messages`-kokoelmassa

3. **Testaa kartan markkerit**:
   - Tarkista että ilmoitukset näkyvät kartalla
   - Klikkaa markkeria → avautuu ilmoituksen yksityiskohtasivu

---

## 🐛 Ongelmatilanteet

### Markkerit eivät näy kartalla
- Tarkista että `food_items`-kokoelmassa on ilmoituksia
- Tarkista että ilmoituksilla on `latitude` ja `longitude` (ei 0.0)
- Tarkista konsoli-lokista: näkyykö "🗺️ Päivitetään X markkeria"

### Chat ei toimi
- Tarkista että `chats`-kokoelma on olemassa
- Tarkista että käyttäjät ovat kirjautuneena
- Tarkista Firestore Rules on deployattu

### Kuvat eivät lataudu
- Tarkista että `food_images` ja `profile_images` bucketit ovat olemassa
- Tarkista Storage Rules on deployattu

---

**Päivitetty**: 2024
