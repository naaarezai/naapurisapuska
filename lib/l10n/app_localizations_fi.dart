// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Naapurisapuska';

  @override
  String get home => 'Koti';

  @override
  String get settings => 'Asetukset';

  @override
  String get profile => 'Profiili';

  @override
  String get myProfile => 'Oma Profiili';

  @override
  String get login => 'Kirjaudu';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get searchHint => 'Mitä tekisi mieli...';

  @override
  String get filter => 'Suodata';

  @override
  String get notifications => 'Uudet ilmoitukset';

  @override
  String get messages => 'Viestit';

  @override
  String get shareFood => 'Jaa ruokaa';

  @override
  String get appearance => 'Ulkoasu';

  @override
  String get darkMode => 'Tumma tila';

  @override
  String get darkModeDescription => 'Käytä tummaa teemaa sovelluksessa';

  @override
  String get themeMode => 'Teema';

  @override
  String get themeModeSystem => 'Järjestelmä';

  @override
  String get themeModeLight => 'Vaalea';

  @override
  String get themeModeDark => 'Tumma';

  @override
  String get language => 'Kieli';

  @override
  String get languageSystem => 'Järjestelmä';

  @override
  String get languageFinnish => 'Suomi';

  @override
  String get languageEnglish => 'English';

  @override
  String get about => 'Tietoja';

  @override
  String get version => 'Versio';

  @override
  String get termsOfUse => 'Käyttöehdot';

  @override
  String get privacyPolicy => 'Tietosuoja';

  @override
  String get privacyPolicyTitle => 'Tietosuojaseloste';

  @override
  String get deleteAccount => 'Poista tili';

  @override
  String get close => 'Sulje';

  @override
  String get deleteAccountTitle => 'Poista tili?';

  @override
  String get deleteAccountMessage =>
      'Tämä toiminto poistaa tilisi ja kaikki ilmoituksesi pysyvästi. Tätä ei voi perua.';

  @override
  String get cancel => 'Peruuta';

  @override
  String get delete => 'Poista tili';

  @override
  String get deleteAccountError =>
      'Virhe tilin poistossa. Kirjaudu uudelleen ja yritä heti.';

  @override
  String get locationPermissionTitle => 'Sijaintilupa tarvitaan';

  @override
  String get locationPermissionMessage =>
      'Sovellus tarvitsee sijaintitiedot näyttääkseen lähellä olevaa ruokaa. Salli sijainti asetuksista.';

  @override
  String get openSettings => 'Avaa asetukset';

  @override
  String get locationError =>
      'Sijaintia ei voitu hakea. Näytetään Helsingin keskusta.';

  @override
  String get available => 'Saatavilla';

  @override
  String get reserved => 'Varattu';

  @override
  String get pickedUp => 'Noudettu';

  @override
  String get vegetables => 'Vihannekset';

  @override
  String get fruits => 'Hedelmät';

  @override
  String get bread => 'Leipä';

  @override
  String get dairy => 'Maitotuotteet';

  @override
  String get meat => 'Liha';

  @override
  String get fish => 'Kala';

  @override
  String get prepared => 'Valmisruoka';

  @override
  String get other => 'Muu';

  @override
  String get vegan => 'Vegaaninen';

  @override
  String get vegetarian => 'Kasvisruoka';

  @override
  String get glutenFree => 'Gluteeniton';

  @override
  String get lactoseFree => 'Laktoositon';

  @override
  String get nutFree => 'Pähkinätön';

  @override
  String get freePrice => 'Ilmainen';

  @override
  String get paidPrice => 'Maksullinen';

  @override
  String get lowPrice => 'Halpa';

  @override
  String get negotiable => 'Neuvoteltavissa';

  @override
  String get reserveFood => 'Varaa ruoka';

  @override
  String get reserve => 'Varaa';

  @override
  String get cancelReservation => 'Peruuta varaus';

  @override
  String get cancelReservationMessage =>
      'Haluatko varmasti peruuttaa varauksen?';

  @override
  String get no => 'Ei';

  @override
  String get yes => 'Kyllä';

  @override
  String get yesCancelReservation => 'Kyllä, peruuta';

  @override
  String get markAsPickedUp => 'Merkitse noudetuksi';

  @override
  String get markAsPickedUpMessage => 'Onko ruoka noudettu onnistuneesti?';

  @override
  String get yesPickedUp => 'Kyllä, noudettu';

  @override
  String get deleteListing => 'Poista ilmoitus';

  @override
  String get deleteListingMessage =>
      'Haluatko varmasti poistaa tämän ilmoituksen?';

  @override
  String get deleteListingButton => 'POISTA ILMOITUS';

  @override
  String get cancelButton => 'PERUUTA';

  @override
  String get pickedUpButton => 'NOUDETTU';

  @override
  String get eventEnded => 'TAPAHTUMA PÄÄTTYNYT';

  @override
  String get addNewListing => 'Lisää uusi ilmoitus';

  @override
  String get editListing => 'Muokkaa ilmoitusta';

  @override
  String get saveChanges => 'Tallenna muutokset';

  @override
  String get noNewNotifications => 'Ei uusia ilmoituksia';

  @override
  String get fetchingLocation => 'Haetaan sijaintia...';

  @override
  String get loginToReserve => 'Kirjaudu sisään varataksesi';

  @override
  String get cannotReserveOwn => 'Et voi varata omaa ilmoitustasi!';

  @override
  String get foodReserved => 'Ruoka varattu!';

  @override
  String get reservationCancelled => 'Varaus peruutettu';

  @override
  String get markedAsPickedUpSuccess => 'Merkitty noudetuksi!';

  @override
  String get loginToChat => 'Kirjaudu sisään käyttääksesi chattia';

  @override
  String get profileUpdated => 'Profiili päivitetty!';

  @override
  String errorUpdatingProfile(Object error) {
    return 'Virhe päivityksessä: $error';
  }

  @override
  String get invalidPrice => 'Virheellinen hinta. Käytä esim. 5.00 tai 5,00';

  @override
  String get maxImagesError => 'Voit lisätä enintään 5 kuvaa';

  @override
  String get selectImageError =>
      'Valitse vähintään yksi kuva ennen ilmoituksen jakamista';

  @override
  String messageSendError(Object error) {
    return 'Viestin lähetys epäonnistui: $error';
  }

  @override
  String get unitKg => 'kg';

  @override
  String get unitPcs => 'kpl';

  @override
  String get unitL => 'litra';

  @override
  String get takePhoto => 'Ota kuva';

  @override
  String get chooseFromGallery => 'Valitse galleriasta';

  @override
  String get retryButton => 'Yritä uudelleen';

  @override
  String get skipIntro => 'Ohita esittely';

  @override
  String get acceptAndContinue => 'Hyväksy ja jatka';

  @override
  String get next => 'Seuraava';

  @override
  String get getStarted => 'Aloita käyttö';

  @override
  String get writeMessage => 'Kirjoita viesti...';

  @override
  String get unknown => 'Tuntematon';

  @override
  String get noMessagesYet => 'Ei viestejä vielä';

  @override
  String get startConversation => 'Aloita keskustelu!';

  @override
  String get yesterday => 'Eilen';

  @override
  String get loading => 'Ladataan...';

  @override
  String get signUp => 'Rekisteröidy';

  @override
  String get createAccount => 'Luo uusi tili';

  @override
  String get signIn => 'Kirjaudu sisään';

  @override
  String get phoneNumber => 'Puhelinnumero';

  @override
  String get name => 'Nimi';

  @override
  String get password => 'Salasana';

  @override
  String get checkPhoneNumber => 'Tarkista numero';

  @override
  String get enterName => 'Syötä nimi';

  @override
  String get passwordLength => 'Vähintään 6 merkkiä';

  @override
  String get haveAccount => 'Onko sinulla jo tili? Kirjaudu';

  @override
  String get noAccount => 'Eikö sinulla ole tiliä? Rekisteröidy';

  @override
  String get appSlogan => 'Jakamassa ruokaa naapureille';

  @override
  String get continueWithGoogle => 'Jatka Google-tilillä';

  @override
  String get continueWithApple => 'Jatka Apple-tilillä';

  @override
  String get continueWithMicrosoft => 'Jatka Microsoft-tilillä';

  @override
  String get orContinueWith => 'Tai jatka';

  @override
  String get continueAsGuest => 'Selaa ilman kirjautumista';

  @override
  String socialLoginError(Object error) {
    return 'Kirjautuminen epäonnistui: $error';
  }

  @override
  String get categoryBakedGoods => 'Leivonnaiset';

  @override
  String get categoryFruits => 'Hedelmät';

  @override
  String get categoryVegetables => 'Vihannekset';

  @override
  String get categoryOther => 'Muut';

  @override
  String get categoryAll => 'Kaikki';

  @override
  String get dietVegan => 'Vegaaninen';

  @override
  String get dietGlutenFree => 'Gluteeniton';

  @override
  String get dietLactoseFree => 'Laktoositon';

  @override
  String get dietMilkFree => 'Maidoton';

  @override
  String get dietNutFree => 'Pähkinätön';

  @override
  String get dietDomestic => 'Kotimainen';

  @override
  String get dietLocal => 'Lähiruoka';

  @override
  String get newBadge => 'UUSI';

  @override
  String get dayShort => 'pv';

  @override
  String get hourShort => 'h';

  @override
  String get noDescription => 'Ei kuvausta';

  @override
  String get noLimit => 'Ei rajoitusta';

  @override
  String get showResults => 'Näytä tulokset';

  @override
  String get clear => 'Tyhjennä';

  @override
  String get specialDiets => 'Erityisruokavaliot';

  @override
  String get free => 'Ilmainen';

  @override
  String get distanceUnitKm => 'km';

  @override
  String get distanceUnitM => 'm';

  @override
  String errorGenericWithDetails(Object error) {
    return 'Virhe: $error';
  }

  @override
  String get errorNetwork => 'Ei internetyhteyttä. Tarkista verkkoyhteys.';

  @override
  String get errorPermission => 'Käyttöoikeusvirhe. Ota yhteys tukeen.';

  @override
  String get errorTimeout => 'Toiminto kesti liian kauan. Yritä uudelleen.';

  @override
  String get errorNotFound => 'Tietoja ei löytynyt.';

  @override
  String get errorUnavailable => 'Palvelu ei ole saatavilla. Yritä myöhemmin.';

  @override
  String get errorGeneric => 'Jotain meni pieleen. Yritä uudelleen.';

  @override
  String get filterCategory => 'Kategoria';

  @override
  String get filterDistance => 'Etäisyys';

  @override
  String get filterDiets => 'Erityisruokavaliot';

  @override
  String get privacyPolicyDate => 'Päivitetty: 19.1.2026';

  @override
  String get privacyPolicySection1Title => '1. Rekisterinpitäjä';

  @override
  String get privacyPolicySection1Content =>
      'Tämän palvelun ja rekisterin ylläpitäjä on koodaaja itse.\n\nSähköposti: nasratollah.rezai@gmail.com (Myöhemmin tässä tekstissä \"Me\" tai \"Palveluntarjoaja\").';

  @override
  String get privacyPolicySection2Title => '2. Mitä tietoja keräämme?';

  @override
  String get privacyPolicySection2Content =>
      'Jotta Naapurisapuska-sovellus toimisi tarkoitetulla tavalla, keräämme käyttäjistä seuraavia tietoja:\n\nA. Käyttäjän antamat tiedot\n\nTilitiedot: Sähköpostiosoite, nimimerkki ja profiilikuva (rekisteröitymisen yhteydessä).\n\nKäyttäjän luoma sisältö: Sovellukseen lataamasi kuvat ruoasta, ruoan kuvaustekstit sekä chat-viestit, joita lähetät muille käyttäjille noudon sopimiseksi.\n\nB. Automaattisesti kerättävät tiedot\n\nSijaintitiedot: Keräämme tarkan sijaintisi (GPS) vain silloin kun käytät sovellusta, jotta voimme näyttää sinulle lähellä olevat ruokailmoitukset kartalla. Emme seuraa sijaintiasi taustalla, kun sovellus on suljettu.\n\nLaitetiedot: Tieto puhelimen mallista ja käyttöjärjestelmästä virheiden korjaamista varten.';

  @override
  String get privacyPolicySection3Title => '3. Mihin käytämme tietojasi?';

  @override
  String get privacyPolicySection3Content =>
      'Käytämme kerättyjä tietoja vain seuraaviin tarkoituksiin:\n\nPalvelun tarjoaminen: Jotta voit nähdä ruokailmoitukset kartalla ja ottaa yhteyttä muihin käyttäjiin.\n\nTietoturva: Käyttäjätilin suojaaminen ja väärinkäytösten estäminen.\n\nViestintä: Ilmoittaaksemme sinulle (esim. Push-ilmoituksella), kun joku on kiinnostunut ilmoittamastasi ruoasta.\n\nTekoäly (AI): Käytämme laitteessa toimivaa tekoälyä (Machine Learning) tunnistamaan kuvista ruoan kategorian (esim. hedelmä/leipä) ilmoituksen tekemisen nopeuttamiseksi.';

  @override
  String get privacyPolicySection4Title =>
      '4. Tietojen jakaminen kolmansille osapuolille';

  @override
  String get privacyPolicySection4Content =>
      'Emme myy, vuokraa tai jaa tietojasi mainostajille (\"No Tracking\"). Jaamme tietoja vain palvelun teknisen toteutuksen vaatimille luotettaville kumppaneille:\n\nGoogle Firebase: Käytämme Firebasea tietokantana, käyttäjien tunnistautumiseen (Authentication) ja kuvien tallennukseen. Tietoja säilytetään Googlen turvallisilla palvelimilla (pääosin EU-alueella tai Privacy Shield -sopimusten mukaisesti).\n\nKarttapalvelut (Google Maps / Mapbox): Sijaintitietojasi käsitellään, jotta voimme piirtää kartan ja näyttää etäisyydet. Nämä palvelut eivät tallenna yksittäisen käyttäjän liikehistoriaa pysyvästi.';

  @override
  String get privacyPolicySection5Title => '5. Käyttäjän oikeudet (GDPR)';

  @override
  String get privacyPolicySection5Content =>
      'Sinulla on Euroopan unionin tietosuoja-asetuksen nojalla oikeus:\n\nTarkastaa: Mitä tietoja sinusta on tallennettu.\n\nOikaista: Pyytää virheellisen tiedon korjaamista.\n\nPoistaa (\"Oikeus tulla unohdetuksi\"): Voit milloin tahansa poistaa käyttäjätilisi ja kaikki siihen liittyvät tiedot suoraan sovelluksen asetuksista (\"Poista tili\" -painike) tai ottamalla meihin yhteyttä sähköpostitse. Kun tili poistetaan, myös chat-historia ja kuvat poistuvat järjestelmästä pysyvästi.';

  @override
  String get privacyPolicySection6Title => '6. Tietojen säilytys';

  @override
  String get privacyPolicySection6Content =>
      'Säilytämme tietojasi niin kauan kuin käyttäjätilisi on aktiivinen. Jos poistat tilisi, tiedot poistetaan kohtuullisen ajan kuluessa (yleensä 30 päivän sisällä) varmuuskopioista.';

  @override
  String get privacyPolicySection7Title => '7. Lasten yksityisyys';

  @override
  String get privacyPolicySection7Content =>
      'Palvelu ei ole suunnattu alle 13-vuotiaille lapsille. Emme tietoisesti kerää tietoja alle 13-vuotiailta.';

  @override
  String get privacyPolicySection8Title => '8. Muutokset';

  @override
  String get privacyPolicySection8Content =>
      'Pidätämme oikeuden päivittää tätä tietosuojaselostetta. Merkittävistä muutoksista ilmoitetaan sovelluksessa.';

  @override
  String get termsOfUseTitle => 'Käyttöehdot';

  @override
  String get termsOfUseDate => 'Viimeksi päivitetty: 19.1.2026';

  @override
  String get termsOfUseSection1Title => '1. Yleistä';

  @override
  String get termsOfUseSection1Content =>
      'Tervetuloa käyttämään Naapurisapuska-sovellusta (\"Palvelu\"). Nämä käyttöehdot säätelevät Palvelun käyttöä. Lataamalla sovelluksen, rekisteröitymällä tai käyttämällä Palvelua hyväksyt nämä ehdot sitovasti.\n\nPalvelun tarjoaja (\"Me\") ylläpitää alustaa, jonka avulla yksityishenkilöt voivat ilmoittaa ja jakaa ylijäämäruokaa muille käyttäjille. Me emme ole ruoan myyjä, valmistaja emmekä jakelija. Toimimme vain teknisenä välittäjänä.';

  @override
  String get termsOfUseSection2Title =>
      '2. Palvelun luonne ja vastuunrajoitus (TÄRKEÄ!)';

  @override
  String get termsOfUseSection2Content =>
      'Naapurisapuska on alusta vertaisjakamiselle (peer-to-peer).\n\nRuokaturvallisuus: Palveluntarjoaja ei tarkista, valvo tai takaa Palvelussa ilmoitetun ruoan laatua, turvallisuutta, hygieniaa tai syömäkelpoisuutta.\n\nKäyttäjän vastuu:\n\nLuovuttaja: Vastaat siitä, että luovuttamasi ruoka on syömäkelpoista, oikein säilytettyä ja että tuoteselosteet/allergeenit on mahdollisuuksien mukaan kerrottu.\n\nVastaanottaja: Noudat ja nautit ruoan täysin omalla vastuullasi. Sinun tulee arvioida ruoan aistinvarainen laatu (haju, ulkonäkö) ennen sen nauttimista.\n\nVapautus vastuusta: Naapurisapuska ja sen kehittäjät eivät ole vastuussa mistään terveyshaitoista, sairauksista tai vahingoista, jotka aiheutuvat Palvelun kautta jaetusta ruoasta.';

  @override
  String get termsOfUseSection3Title => '3. Käyttäjätili ja rekisteröityminen';

  @override
  String get termsOfUseSection3Content =>
      'Sinun tulee olla vähintään 13-vuotias käyttääksesi palvelua.\n\nOlet vastuussa salasanasi ja tilisi turvallisuudesta.\n\nSitoudut antamaan itsestäsi totuudenmukaiset tiedot. Valeprofiilien luominen on kiellettyä.';

  @override
  String get termsOfUseSection4Title => '4. Käyttäytymissäännöt';

  @override
  String get termsOfUseSection4Content =>
      'Käyttäjänä sitoudut noudattamaan seuraavia sääntöjä:\n\nKunnioitus: Kohtele muita käyttäjiä asiallisesti chatissa ja noutotilanteissa. Häirintä on ehdottomasti kielletty.\n\nLuotettavuus: Jos sovit noudosta (varaat ruoan), sitoudut saapumaan paikalle sovittuna aikana. Toistuvat \"oharit\" (no-show) voivat johtaa tilin sulkemiseen.\n\nLaillisuus: Palvelussa ei saa jakaa alkoholia, tupakkatuotteita, lääkkeitä tai laittomia aineita.\n\nEi myyntiä: Palvelu on tarkoitettu ensisijaisesti ruoan jakamiseen ilmaiseksi tai nimellistä korvausta vastaan hävikin vähentämiseksi, ei ammattimaiseen liiketoimintaan ilman lupaa.';

  @override
  String get termsOfUseSection5Title => '5. Sisältö ja oikeudet';

  @override
  String get termsOfUseSection5Content =>
      'Lataamalla kuvan ruoasta palveluun vakuutat, että sinulla on oikeus kuvaan.\n\nAnnat Naapurisapuskalle oikeuden käyttää, muokata ja esittää lataamaasi sisältöä (esim. ruokakuvat) Palvelun toiminnan puitteissa ja markkinoinnissa.\n\nEmme salli K-18 materiaalia tai sopimatonta sisältöä kuvissa.';

  @override
  String get termsOfUseSection6Title => '6. Palvelun saatavuus ja muutokset';

  @override
  String get termsOfUseSection6Content =>
      'Pyrimme pitämään Palvelun toiminnassa 24/7, mutta emme takaa sen keskeytyksettömyyttä. Meillä on oikeus muuttaa, keskeyttää tai lopettaa Palvelu tai sen osa milloin tahansa ilman erillistä ilmoitusta (esim. huoltokatkot tai tekniset päivitykset).';

  @override
  String get termsOfUseSection7Title => '7. Sopimuksen päättäminen';

  @override
  String get termsOfUseSection7Content =>
      'Meillä on oikeus sulkea käyttäjätilisi ja estää pääsy Palveluun välittömästi, jos:\n\nRikot näitä käyttöehtoja.\n\nKäytöksesi on uhkaavaa tai häiritsevää muita kohtaan.\n\nJatkuvasti jaat pilaantunutta ruokaa tai jätät noutamatta varauksia.';

  @override
  String get termsOfUseSection8Title => '8. Sovellettava laki';

  @override
  String get termsOfUseSection8Content =>
      'Näihin ehtoihin sovelletaan Suomen lakia. Mahdolliset riitaisuudet pyritään ensisijaisesti ratkaisemaan neuvottelemalla.';

  @override
  String get myListings => 'Omat ilmoitukset';

  @override
  String get myReservations => 'Omat varaukset';

  @override
  String get favorites => 'Suosikit';

  @override
  String get noListings => 'Et ole lisännyt ilmoituksia.';

  @override
  String get noReservations => 'Et ole varannut mitään.';

  @override
  String get noFavorites => 'Ei suosikkeja.';

  @override
  String get loginToViewProfile => 'Kirjaudu sisään nähdäksesi profiilin';

  @override
  String get anonymous => 'Nimetön';

  @override
  String get beginner => 'Aloittelija';

  @override
  String sharedPortions(int count) {
    return '$count jaettua annosta';
  }

  @override
  String get maxLevelReached => 'Maksimitaso saavutettu! 🎉';

  @override
  String get progressToNextLevel => 'Edistyminen seuraavaan tasoon';

  @override
  String get statShared => 'Jaettu';

  @override
  String get statRating => 'Arvostelu';

  @override
  String get statReviews => 'Arvioita';

  @override
  String get notYet => 'Ei vielä';

  @override
  String get onboardingPage1Title => 'Säästä rahaa pelastamalla';

  @override
  String get onboardingPage1Description =>
      'Osta herkullista ruokaa naapureilta ja kaupoilta reilusti alennettuun hintaan.';

  @override
  String get onboardingPage2Title => 'Heitä hyvästit hävikille';

  @override
  String get onboardingPage2Description =>
      'Löydä tarjouksia läheltäsi! Selaa helposti päivittäin vaihtuvia ilmoituksia.';

  @override
  String get onboardingPage3Title => 'Nouda ja nauti';

  @override
  String get onboardingPage3Description =>
      'Varaa ruoka sovelluksessa, nouda se sovitusti ja nauti hyvästä ruoasta.';

  @override
  String get welcomeToApp => 'Tervetuloa NaapuriSapuskaan!';

  @override
  String get onboardingTermsMessage =>
      'Ennen kuin jatkat, tarkista tietosuoja-asetuksesi ja käyttöehdot.';

  @override
  String get onboardingAcceptMessage => 'Käyttämällä palvelua hyväksyt:';

  @override
  String get locationUsageForNotifications =>
      'Sijainnin käytön ilmoitusten näyttämiseen';

  @override
  String get newNotificationsTooltip => 'Uudet ilmoitukset';

  @override
  String get nearbyFood => 'Lähellä olevat ruoat';

  @override
  String get distanceAway => 'päästä';

  @override
  String get seeMore => 'Katso lisää:';

  @override
  String get confirmReservation =>
      'Haluatko varmasti varata tämän ruoan?\n\nTämä avaa chatin ilmoittajan kanssa.';

  @override
  String get anonymousUser => 'Nimetön käyttäjä';

  @override
  String get newUser => 'Uusi käyttäjä';

  @override
  String get listingUpdatedSuccess => 'Ilmoitus päivitetty onnistuneesti!';

  @override
  String get whatFood => 'Mitä ruokaa?';

  @override
  String get foodPlaceholder => 'Esim. Leipää, hedelmiä, vihanneksia...';

  @override
  String get additionalInfo => 'Lisätiedot';

  @override
  String get additionalInfoPlaceholder => 'Määrä, päiväys, erityisohjeet...';

  @override
  String get quantity => 'Määrä';

  @override
  String get unit => 'Yksikkö';

  @override
  String get errorLoadingMessages => 'Virhe viestien lataamisessa';

  @override
  String get foodInfoHeader => 'Tietoa ruoasta';

  @override
  String get locationHeader => 'Sijainti';

  @override
  String get posterLabel => 'Ilmoittaja';

  @override
  String get freeLabel => 'Ilmainen';

  @override
  String get categoryLabel => 'Kategoria';

  @override
  String get priceLabel => 'Hinta';

  @override
  String get imagesLabel => 'Kuvat';

  @override
  String get selectImageLabel => 'Valitse kuva';

  @override
  String get shareListingButton => 'Jaa ilmoitus';

  @override
  String daysAgo(int count) {
    return '$count päivää sitten';
  }

  @override
  String hoursAgoShort(int count) {
    return '${count}h sitten';
  }

  @override
  String minutesAgoShort(int count) {
    return '${count}min sitten';
  }

  @override
  String get justNow => 'Juuri nyt';

  @override
  String get reserveFoodButton => 'VARAA RUOKA';

  @override
  String get reservedForYou => 'VARATTU SINULLE';

  @override
  String get userLevelBeginner => 'Aloittelija';

  @override
  String get userLevelActive => 'Aktiivinen';

  @override
  String get userLevelVeteran => 'Veteraani';

  @override
  String get noResults => 'Ei tuloksia';

  @override
  String get noFoodNearby => 'Ei ruokaa lähistöllä';

  @override
  String get beFirstToShare => 'Ole ensimmäinen jakamassa\nruokaa naapureille!';

  @override
  String get tryExpandDistance =>
      'Kokeile laajentaa etäisyyttä tai\nvaihda kategoriaa';

  @override
  String get editFilters => 'Muokkaa suodattimia';

  @override
  String get newListingBanner => 'UUSI ILMOITUS';

  @override
  String get nearbyYou => 'Lähellä sinua';

  @override
  String listingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ilmoitusta',
      one: '1 ilmoitus',
      zero: 'Ei ilmoituksia',
    );
    return '$_temp0';
  }
}
