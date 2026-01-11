# 📊 Firebase `food_items` -kokoelman rakenne

## 📋 Pakolliset kentät

Jokaisella `food_items`-dokumentilla pitää olla seuraavat kentät:

### 1. **Perustiedot** (Pakolliset)
```javascript
{
  "title": "Omenoita",                    // string - Ilmoituksen otsikko
  "description": "1 kg omenoita",        // string - Kuvaus
  "imageUrl": "https://...",              // string - Kuvan URL Firebase Storagesta
  "category": "hedelmat",                 // string - Kategoria (leivonnaiset, hedelmat, vihannekset, muut)
  "latitude": 60.1699,                    // number - Leveysaste (ei voi olla 0.0!)
  "longitude": 24.9384,                   // number - Pituusaste (ei voi olla 0.0!)
  "timestamp": Timestamp,                 // Timestamp - Milloin luotu
  "userId": "abc123...",                  // string - Käyttäjän ID (Firebase Auth UID)
}
```

### 2. **Hinta** (Valinnainen)
```javascript
{
  "price": 5.50,                          // number? - Hinta euroina (null jos ilmainen)
}
```

### 3. **Käyttäjän tiedot** (Valinnainen, mutta suositeltava)
```javascript
{
  "userName": "Matti Meikäläinen",       // string? - Käyttäjän nimi
  "userProfileImageUrl": "https://...",   // string? - Profiilikuvan URL
}
```

### 4. **Varaus** (Valinnainen)
```javascript
{
  "isReserved": false,                    // boolean - Onko varattu
  "reservedBy": null,                     // string? - Kenelle varattu (userId, null jos ei varattu)
}
```

---

## 📝 Esimerkki dokumentti

### Ilmainen ilmoitus:
```javascript
{
  "title": "Omenoita",
  "description": "1 kg punaisia omenoita, hyvässä kunnossa",
  "imageUrl": "https://firebasestorage.googleapis.com/v0/b/.../food_images/abc123.jpg",
  "category": "hedelmat",
  "latitude": 60.1699,
  "longitude": 24.9384,
  "timestamp": Timestamp(2024, 12, 17, 23, 0, 0),
  "userId": "user123abc",
  "userName": "Matti Meikäläinen",
  "userProfileImageUrl": "https://firebasestorage.googleapis.com/.../profile_images/user123.jpg",
  "price": null,                          // null = ilmainen
  "isReserved": false,
  "reservedBy": null
}
```

### Maksullinen ilmoitus:
```javascript
{
  "title": "Kotileipää",
  "description": "Tuoretta ruisleipää, leivottu tänään",
  "imageUrl": "https://firebasestorage.googleapis.com/.../food_images/def456.jpg",
  "category": "leivonnaiset",
  "latitude": 60.1700,
  "longitude": 24.9385,
  "timestamp": Timestamp(2024, 12, 17, 22, 30, 0),
  "userId": "user456def",
  "userName": "Liisa Leipuri",
  "userProfileImageUrl": null,
  "price": 3.50,                          // 3.50 €
  "isReserved": false,
  "reservedBy": null
}
```

### Varattu ilmoitus:
```javascript
{
  "title": "Porkkanoita",
  "description": "2 kg tuoreita porkkanoita",
  "imageUrl": "https://firebasestorage.googleapis.com/.../food_images/ghi789.jpg",
  "category": "vihannekset",
  "latitude": 60.1701,
  "longitude": 24.9386,
  "timestamp": Timestamp(2024, 12, 17, 21, 0, 0),
  "userId": "user789ghi",
  "userName": "Pekka Puutarhuri",
  "userProfileImageUrl": "https://...",
  "price": null,
  "isReserved": true,                     // ✅ Varattu
  "reservedBy": "user123abc"              // Varattu käyttäjälle user123abc
}
```

---

## ⚠️ TÄRKEÄT HUOMIOT

### 1. **Koordinaatit eivät saa olla 0.0!**
```javascript
// ❌ VÄÄRIN - Markkerit eivät näy
"latitude": 0.0,
"longitude": 0.0

// ✅ OIKEIN - Markkerit näkyvät
"latitude": 60.1699,
"longitude": 24.9384
```

### 2. **Kategoriat**
Vain nämä arvot ovat sallittuja:
- `"leivonnaiset"`
- `"hedelmat"`
- `"vihannekset"`
- `"muut"`

### 3. **Timestamp**
Käytä Firebase `Timestamp`-tyyppiä, ei `Date`-objektia:
```javascript
// ✅ OIKEIN
"timestamp": Timestamp.fromDate(new Date())

// ❌ VÄÄRIN
"timestamp": new Date()
```

### 4. **Hinta**
- `null` = Ilmainen
- `number` = Hinta euroina (esim. `5.50` = 5.50 €)

---

## 🔍 Tarkistuslista Firebase-konsolissa

Kun lisäät ilmoituksen sovelluksessa, tarkista että:

- [ ] Dokumentti on `food_items`-kokoelmassa
- [ ] `title` on merkkijono (ei tyhjä)
- [ ] `description` on merkkijono
- [ ] `imageUrl` on validi URL
- [ ] `category` on yksi: leivonnaiset, hedelmat, vihannekset, muut
- [ ] `latitude` on numero (ei 0.0, esim. 60.1699)
- [ ] `longitude` on numero (ei 0.0, esim. 24.9384)
- [ ] `timestamp` on Timestamp-tyyppiä
- [ ] `userId` on merkkijono (Firebase Auth UID)
- [ ] `price` on joko `null` tai numero
- [ ] `isReserved` on boolean
- [ ] `reservedBy` on joko `null` tai merkkijono (userId)

---

## 🐛 Yleiset ongelmat

### Markkerit eivät näy kartalla
**Syy**: Koordinaatit ovat 0.0
```javascript
// Tarkista Firebase-konsolista:
"latitude": 0.0  // ❌ Tämä on ongelma!
"longitude": 0.0 // ❌ Tämä on ongelma!
```

**Ratkaisu**: Varmista että ilmoituksen lisäämisessä haetaan oikea sijainti GPS:llä.

### Kategoria ei näy
**Syy**: Väärä kategoria-arvo
```javascript
"category": "hedelmät"  // ❌ Väärä (ä-kirjain)
"category": "hedelmat"  // ✅ Oikein
```

### Hinta ei näy
**Syy**: Hinta on `null` mutta pitäisi olla numero
```javascript
"price": null  // Näyttää "Ilmainen"
"price": 5.50  // Näyttää "5.50 €"
```

---

## 📱 Miten sovellus luo dokumentin

Kun käyttäjä lisää ilmoituksen sovelluksessa:

1. **Hae sijainti** → `latitude` ja `longitude` GPS:llä
2. **Lataa kuva** → `imageUrl` Firebase Storageen
3. **Luo dokumentti** → Kaikki kentät `food_items`-kokoelmaan
4. **Näytä kartalla** → Markkeri luodaan `latitude` ja `longitude` perusteella

---

## ✅ Testaus

1. **Lisää ilmoitus sovelluksessa**
2. **Avaa Firebase Console** → Firestore Database
3. **Tarkista `food_items`-kokoelma**
4. **Varmista että kaikki kentät ovat oikein**
5. **Tarkista että `latitude` ja `longitude` eivät ole 0.0**
6. **Kartalla pitäisi näkyä markkeri!**

---

**Päivitetty**: 2024-12-17
