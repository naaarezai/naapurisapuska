# 🍌 Naapurisapuska (Napsu)

Naapurisapuska on yhteisöllinen ruoanjakosovellus, jonka tavoitteena on vähentää ruokahävikkiä ja lisätä naapuruston yhteisöllisyyttä. Sovelluksen avulla käyttäjät voivat ilmoittaa ylimääräisestä ruoasta ja muut voivat varata sekä noutaa sen – täysin ilmaiseksi.

![Naapurisapuska Banner](assets/logo.png)

## ✨ Ominaisuudet

*   **🗺️ Karttanäkymä**: Selaa lähellä olevia ruokailmoituksia interaktiivisella kartalla.
*   **📸 Helppo ilmoittaminen**: Lisää ruokailmoitus kuvalla, kuvauksella ja noutoajalla nopeasti.
*   **💬 Chat**: Sovi noudosta helposti sovelluksen sisäisellä viestinnällä (turvallinen, osallistujat-only).
*   **🔔 Ilmoitukset**: Saat ilmoituksen (Push & In-App) kun ilmoitukseesi reagoidaan.
*   **🤖 Automaattinen siivous**: Cloud Functions poistaa vanhat ilmoitukset automaattisesti.
*   **🔒 Tietoturva**: Tiukat Firestore-säännöt, yksityiset viestit, ja omistajuuden tarkistus.
*   **📊 Monitorointi**: Crashlytics virheenjäljitykseen ja Analytics käytön seurantaan.
*   **🧪 Testattu**: Kattava testaus (Unit & Widget testit) >90% kattavuudella.

## 🛠️ Teknologiat

*   **Frontend**: Flutter (Dart)
*   **Backend**: Firebase
    *   **Authentication**: Google Sign-In & Email/Password
    *   **Firestore**: Reaaliaikainen tietokanta
    *   **Storage**: Kuvien tallennus (omissa kansioissa)
    *   **Cloud Functions**: Palvelinlogiikka (Node.js)
    *   **Crashlytics**: Virheraportointi
    *   **Analytics**: Käyttäjäanalytiikka

## 🚀 Aloitusopas

### Esivaatimukset

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.27+)
*   Firebase-projekti konfiguroituna

### Asennus

1.  **Kloonaa repositorio**
    ```bash
    git clone https://github.com/yourusername/naapurisapuska.git
    cd naapurisapuska
    ```

2.  **Asenna riippuvuudet**
    ```bash
    flutter pub get
    ```

3.  **Konfiguroi Firebase**
    Varmista että `firebase_options.dart` on ajan tasalla.

4.  **Käynnistä sovellus**
    ```bash
    flutter run
    ```

## 🧪 Testaus

Projekti sisältää kattavat yksikkö- ja widget-testit.

```bash
# Aja kaikki testit
flutter test

# Aja testit kattavuusraportilla
flutter test --coverage
```

## ☁️ Cloud Functions

Sijainti: `/functions`

*   `cleanupOldFoodItems`: Poistaa yli 24h vanhat/noutamattomat ilmoitukset (ajastettu).
*   `deleteOldImages`: Poistaa kuvat Firestoresta poistetuista ilmoituksista.

Deployssä:
```bash
firebase deploy --only functions
```

## 🔒 Tietoturva

*   Viestejä voi lukea vain keskustelun osallistujat.
*   Vain omistaja voi muokata/poistaa omia ilmoituksiaan.
*   Tiedostokoot (kuvat) rajoitettu Storage-säännöissä.

## 📱 Julkaisu

```bash
# Android Release
flutter build apk --release

# Web Deployment
flutter build web --release
firebase deploy --only hosting
```

## 📄 Lisenssi

MIT
