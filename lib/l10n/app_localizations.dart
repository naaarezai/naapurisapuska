import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fi')
  ];

  /// Application title
  ///
  /// In fi, this message translates to:
  /// **'Naapurisapuska'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In fi, this message translates to:
  /// **'Koti'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In fi, this message translates to:
  /// **'Asetukset'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In fi, this message translates to:
  /// **'Profiili'**
  String get profile;

  /// No description provided for @myProfile.
  ///
  /// In fi, this message translates to:
  /// **'Oma Profiili'**
  String get myProfile;

  /// No description provided for @login.
  ///
  /// In fi, this message translates to:
  /// **'Kirjaudu'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In fi, this message translates to:
  /// **'Kirjaudu ulos'**
  String get logout;

  /// No description provided for @searchHint.
  ///
  /// In fi, this message translates to:
  /// **'Mitä tekisi mieli...'**
  String get searchHint;

  /// No description provided for @filter.
  ///
  /// In fi, this message translates to:
  /// **'Suodata'**
  String get filter;

  /// No description provided for @notifications.
  ///
  /// In fi, this message translates to:
  /// **'Uudet ilmoitukset'**
  String get notifications;

  /// No description provided for @messages.
  ///
  /// In fi, this message translates to:
  /// **'Viestit'**
  String get messages;

  /// No description provided for @shareFood.
  ///
  /// In fi, this message translates to:
  /// **'Jaa ruokaa'**
  String get shareFood;

  /// No description provided for @appearance.
  ///
  /// In fi, this message translates to:
  /// **'Ulkoasu'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In fi, this message translates to:
  /// **'Tumma tila'**
  String get darkMode;

  /// No description provided for @darkModeDescription.
  ///
  /// In fi, this message translates to:
  /// **'Käytä tummaa teemaa sovelluksessa'**
  String get darkModeDescription;

  /// No description provided for @themeMode.
  ///
  /// In fi, this message translates to:
  /// **'Teema'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In fi, this message translates to:
  /// **'Järjestelmä'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In fi, this message translates to:
  /// **'Vaalea'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In fi, this message translates to:
  /// **'Tumma'**
  String get themeModeDark;

  /// No description provided for @language.
  ///
  /// In fi, this message translates to:
  /// **'Kieli'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In fi, this message translates to:
  /// **'Järjestelmä'**
  String get languageSystem;

  /// No description provided for @languageFinnish.
  ///
  /// In fi, this message translates to:
  /// **'Suomi'**
  String get languageFinnish;

  /// No description provided for @languageEnglish.
  ///
  /// In fi, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @about.
  ///
  /// In fi, this message translates to:
  /// **'Tietoja'**
  String get about;

  /// No description provided for @version.
  ///
  /// In fi, this message translates to:
  /// **'Versio'**
  String get version;

  /// No description provided for @termsOfUse.
  ///
  /// In fi, this message translates to:
  /// **'Käyttöehdot'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In fi, this message translates to:
  /// **'Tietosuoja'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In fi, this message translates to:
  /// **'Tietosuojaseloste'**
  String get privacyPolicyTitle;

  /// No description provided for @deleteAccount.
  ///
  /// In fi, this message translates to:
  /// **'Poista tili'**
  String get deleteAccount;

  /// No description provided for @close.
  ///
  /// In fi, this message translates to:
  /// **'Sulje'**
  String get close;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In fi, this message translates to:
  /// **'Poista tili?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In fi, this message translates to:
  /// **'Tämä toiminto poistaa tilisi ja kaikki ilmoituksesi pysyvästi. Tätä ei voi perua.'**
  String get deleteAccountMessage;

  /// No description provided for @cancel.
  ///
  /// In fi, this message translates to:
  /// **'Peruuta'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In fi, this message translates to:
  /// **'Poista tili'**
  String get delete;

  /// No description provided for @deleteAccountError.
  ///
  /// In fi, this message translates to:
  /// **'Virhe tilin poistossa. Kirjaudu uudelleen ja yritä heti.'**
  String get deleteAccountError;

  /// No description provided for @locationPermissionTitle.
  ///
  /// In fi, this message translates to:
  /// **'Sijaintilupa tarvitaan'**
  String get locationPermissionTitle;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In fi, this message translates to:
  /// **'Sovellus tarvitsee sijaintitiedot näyttääkseen lähellä olevaa ruokaa. Salli sijainti asetuksista.'**
  String get locationPermissionMessage;

  /// No description provided for @openSettings.
  ///
  /// In fi, this message translates to:
  /// **'Avaa asetukset'**
  String get openSettings;

  /// No description provided for @locationError.
  ///
  /// In fi, this message translates to:
  /// **'Sijaintia ei voitu hakea. Näytetään Helsingin keskusta.'**
  String get locationError;

  /// No description provided for @available.
  ///
  /// In fi, this message translates to:
  /// **'Saatavilla'**
  String get available;

  /// No description provided for @reserved.
  ///
  /// In fi, this message translates to:
  /// **'Varattu'**
  String get reserved;

  /// No description provided for @pickedUp.
  ///
  /// In fi, this message translates to:
  /// **'Noudettu'**
  String get pickedUp;

  /// No description provided for @vegetables.
  ///
  /// In fi, this message translates to:
  /// **'Vihannekset'**
  String get vegetables;

  /// No description provided for @fruits.
  ///
  /// In fi, this message translates to:
  /// **'Hedelmät'**
  String get fruits;

  /// No description provided for @bread.
  ///
  /// In fi, this message translates to:
  /// **'Leipä'**
  String get bread;

  /// No description provided for @dairy.
  ///
  /// In fi, this message translates to:
  /// **'Maitotuotteet'**
  String get dairy;

  /// No description provided for @meat.
  ///
  /// In fi, this message translates to:
  /// **'Liha'**
  String get meat;

  /// No description provided for @fish.
  ///
  /// In fi, this message translates to:
  /// **'Kala'**
  String get fish;

  /// No description provided for @prepared.
  ///
  /// In fi, this message translates to:
  /// **'Valmisruoka'**
  String get prepared;

  /// No description provided for @other.
  ///
  /// In fi, this message translates to:
  /// **'Muu'**
  String get other;

  /// No description provided for @vegan.
  ///
  /// In fi, this message translates to:
  /// **'Vegaaninen'**
  String get vegan;

  /// No description provided for @vegetarian.
  ///
  /// In fi, this message translates to:
  /// **'Kasvisruoka'**
  String get vegetarian;

  /// No description provided for @glutenFree.
  ///
  /// In fi, this message translates to:
  /// **'Gluteeniton'**
  String get glutenFree;

  /// No description provided for @lactoseFree.
  ///
  /// In fi, this message translates to:
  /// **'Laktoositon'**
  String get lactoseFree;

  /// No description provided for @nutFree.
  ///
  /// In fi, this message translates to:
  /// **'Pähkinätön'**
  String get nutFree;

  /// No description provided for @freePrice.
  ///
  /// In fi, this message translates to:
  /// **'Ilmainen'**
  String get freePrice;

  /// No description provided for @paidPrice.
  ///
  /// In fi, this message translates to:
  /// **'Maksullinen'**
  String get paidPrice;

  /// No description provided for @lowPrice.
  ///
  /// In fi, this message translates to:
  /// **'Halpa'**
  String get lowPrice;

  /// No description provided for @negotiable.
  ///
  /// In fi, this message translates to:
  /// **'Neuvoteltavissa'**
  String get negotiable;

  /// No description provided for @reserveFood.
  ///
  /// In fi, this message translates to:
  /// **'Varaa ruoka'**
  String get reserveFood;

  /// No description provided for @reserve.
  ///
  /// In fi, this message translates to:
  /// **'Varaa'**
  String get reserve;

  /// No description provided for @cancelReservation.
  ///
  /// In fi, this message translates to:
  /// **'Peruuta varaus'**
  String get cancelReservation;

  /// No description provided for @cancelReservationMessage.
  ///
  /// In fi, this message translates to:
  /// **'Haluatko varmasti peruuttaa varauksen?'**
  String get cancelReservationMessage;

  /// No description provided for @no.
  ///
  /// In fi, this message translates to:
  /// **'Ei'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In fi, this message translates to:
  /// **'Kyllä'**
  String get yes;

  /// No description provided for @yesCancelReservation.
  ///
  /// In fi, this message translates to:
  /// **'Kyllä, peruuta'**
  String get yesCancelReservation;

  /// No description provided for @markAsPickedUp.
  ///
  /// In fi, this message translates to:
  /// **'Merkitse noudetuksi'**
  String get markAsPickedUp;

  /// No description provided for @markAsPickedUpMessage.
  ///
  /// In fi, this message translates to:
  /// **'Onko ruoka noudettu onnistuneesti?'**
  String get markAsPickedUpMessage;

  /// No description provided for @yesPickedUp.
  ///
  /// In fi, this message translates to:
  /// **'Kyllä, noudettu'**
  String get yesPickedUp;

  /// No description provided for @deleteListing.
  ///
  /// In fi, this message translates to:
  /// **'Poista ilmoitus'**
  String get deleteListing;

  /// No description provided for @deleteListingMessage.
  ///
  /// In fi, this message translates to:
  /// **'Haluatko varmasti poistaa tämän ilmoituksen?'**
  String get deleteListingMessage;

  /// No description provided for @deleteListingButton.
  ///
  /// In fi, this message translates to:
  /// **'POISTA ILMOITUS'**
  String get deleteListingButton;

  /// No description provided for @cancelButton.
  ///
  /// In fi, this message translates to:
  /// **'PERUUTA'**
  String get cancelButton;

  /// No description provided for @pickedUpButton.
  ///
  /// In fi, this message translates to:
  /// **'NOUDETTU'**
  String get pickedUpButton;

  /// No description provided for @eventEnded.
  ///
  /// In fi, this message translates to:
  /// **'TAPAHTUMA PÄÄTTYNYT'**
  String get eventEnded;

  /// No description provided for @addNewListing.
  ///
  /// In fi, this message translates to:
  /// **'Lisää uusi ilmoitus'**
  String get addNewListing;

  /// No description provided for @editListing.
  ///
  /// In fi, this message translates to:
  /// **'Muokkaa ilmoitusta'**
  String get editListing;

  /// No description provided for @saveChanges.
  ///
  /// In fi, this message translates to:
  /// **'Tallenna muutokset'**
  String get saveChanges;

  /// No description provided for @noNewNotifications.
  ///
  /// In fi, this message translates to:
  /// **'Ei uusia ilmoituksia'**
  String get noNewNotifications;

  /// No description provided for @fetchingLocation.
  ///
  /// In fi, this message translates to:
  /// **'Haetaan sijaintia...'**
  String get fetchingLocation;

  /// No description provided for @loginToReserve.
  ///
  /// In fi, this message translates to:
  /// **'Kirjaudu sisään varataksesi'**
  String get loginToReserve;

  /// No description provided for @cannotReserveOwn.
  ///
  /// In fi, this message translates to:
  /// **'Et voi varata omaa ilmoitustasi!'**
  String get cannotReserveOwn;

  /// No description provided for @foodReserved.
  ///
  /// In fi, this message translates to:
  /// **'Ruoka varattu!'**
  String get foodReserved;

  /// No description provided for @reservationCancelled.
  ///
  /// In fi, this message translates to:
  /// **'Varaus peruutettu'**
  String get reservationCancelled;

  /// No description provided for @markedAsPickedUpSuccess.
  ///
  /// In fi, this message translates to:
  /// **'Merkitty noudetuksi!'**
  String get markedAsPickedUpSuccess;

  /// No description provided for @loginToChat.
  ///
  /// In fi, this message translates to:
  /// **'Kirjaudu sisään käyttääksesi chattia'**
  String get loginToChat;

  /// No description provided for @profileUpdated.
  ///
  /// In fi, this message translates to:
  /// **'Profiili päivitetty!'**
  String get profileUpdated;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In fi, this message translates to:
  /// **'Virhe päivityksessä: {error}'**
  String errorUpdatingProfile(Object error);

  /// No description provided for @invalidPrice.
  ///
  /// In fi, this message translates to:
  /// **'Virheellinen hinta. Käytä esim. 5.00 tai 5,00'**
  String get invalidPrice;

  /// No description provided for @maxImagesError.
  ///
  /// In fi, this message translates to:
  /// **'Voit lisätä enintään 5 kuvaa'**
  String get maxImagesError;

  /// No description provided for @selectImageError.
  ///
  /// In fi, this message translates to:
  /// **'Valitse vähintään yksi kuva ennen ilmoituksen jakamista'**
  String get selectImageError;

  /// No description provided for @messageSendError.
  ///
  /// In fi, this message translates to:
  /// **'Viestin lähetys epäonnistui: {error}'**
  String messageSendError(Object error);

  /// No description provided for @unitKg.
  ///
  /// In fi, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitPcs.
  ///
  /// In fi, this message translates to:
  /// **'kpl'**
  String get unitPcs;

  /// No description provided for @unitL.
  ///
  /// In fi, this message translates to:
  /// **'litra'**
  String get unitL;

  /// No description provided for @takePhoto.
  ///
  /// In fi, this message translates to:
  /// **'Ota kuva'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In fi, this message translates to:
  /// **'Valitse galleriasta'**
  String get chooseFromGallery;

  /// No description provided for @retryButton.
  ///
  /// In fi, this message translates to:
  /// **'Yritä uudelleen'**
  String get retryButton;

  /// No description provided for @skipIntro.
  ///
  /// In fi, this message translates to:
  /// **'Ohita esittely'**
  String get skipIntro;

  /// No description provided for @acceptAndContinue.
  ///
  /// In fi, this message translates to:
  /// **'Hyväksy ja jatka'**
  String get acceptAndContinue;

  /// No description provided for @next.
  ///
  /// In fi, this message translates to:
  /// **'Seuraava'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In fi, this message translates to:
  /// **'Aloita käyttö'**
  String get getStarted;

  /// No description provided for @writeMessage.
  ///
  /// In fi, this message translates to:
  /// **'Kirjoita viesti...'**
  String get writeMessage;

  /// No description provided for @unknown.
  ///
  /// In fi, this message translates to:
  /// **'Tuntematon'**
  String get unknown;

  /// No description provided for @noMessagesYet.
  ///
  /// In fi, this message translates to:
  /// **'Ei viestejä vielä'**
  String get noMessagesYet;

  /// No description provided for @startConversation.
  ///
  /// In fi, this message translates to:
  /// **'Aloita keskustelu!'**
  String get startConversation;

  /// No description provided for @yesterday.
  ///
  /// In fi, this message translates to:
  /// **'Eilen'**
  String get yesterday;

  /// No description provided for @loading.
  ///
  /// In fi, this message translates to:
  /// **'Ladataan...'**
  String get loading;

  /// No description provided for @signUp.
  ///
  /// In fi, this message translates to:
  /// **'Rekisteröidy'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In fi, this message translates to:
  /// **'Luo uusi tili'**
  String get createAccount;

  /// No description provided for @signIn.
  ///
  /// In fi, this message translates to:
  /// **'Kirjaudu sisään'**
  String get signIn;

  /// No description provided for @phoneNumber.
  ///
  /// In fi, this message translates to:
  /// **'Puhelinnumero'**
  String get phoneNumber;

  /// No description provided for @name.
  ///
  /// In fi, this message translates to:
  /// **'Nimi'**
  String get name;

  /// No description provided for @password.
  ///
  /// In fi, this message translates to:
  /// **'Salasana'**
  String get password;

  /// No description provided for @checkPhoneNumber.
  ///
  /// In fi, this message translates to:
  /// **'Tarkista numero'**
  String get checkPhoneNumber;

  /// No description provided for @enterName.
  ///
  /// In fi, this message translates to:
  /// **'Syötä nimi'**
  String get enterName;

  /// No description provided for @passwordLength.
  ///
  /// In fi, this message translates to:
  /// **'Vähintään 6 merkkiä'**
  String get passwordLength;

  /// No description provided for @haveAccount.
  ///
  /// In fi, this message translates to:
  /// **'Onko sinulla jo tili? Kirjaudu'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In fi, this message translates to:
  /// **'Eikö sinulla ole tiliä? Rekisteröidy'**
  String get noAccount;

  /// No description provided for @appSlogan.
  ///
  /// In fi, this message translates to:
  /// **'Jakamassa ruokaa naapureille'**
  String get appSlogan;

  /// No description provided for @continueWithGoogle.
  ///
  /// In fi, this message translates to:
  /// **'Jatka Google-tilillä'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In fi, this message translates to:
  /// **'Jatka Apple-tilillä'**
  String get continueWithApple;

  /// No description provided for @continueWithMicrosoft.
  ///
  /// In fi, this message translates to:
  /// **'Jatka Microsoft-tilillä'**
  String get continueWithMicrosoft;

  /// No description provided for @orContinueWith.
  ///
  /// In fi, this message translates to:
  /// **'Tai jatka'**
  String get orContinueWith;

  /// Nappi joka vie käyttäjän selaamaan ilman kirjautumista
  ///
  /// In fi, this message translates to:
  /// **'Selaa ilman kirjautumista'**
  String get continueAsGuest;

  /// No description provided for @socialLoginError.
  ///
  /// In fi, this message translates to:
  /// **'Kirjautuminen epäonnistui: {error}'**
  String socialLoginError(Object error);

  /// No description provided for @categoryBakedGoods.
  ///
  /// In fi, this message translates to:
  /// **'Leivonnaiset'**
  String get categoryBakedGoods;

  /// No description provided for @categoryFruits.
  ///
  /// In fi, this message translates to:
  /// **'Hedelmät'**
  String get categoryFruits;

  /// No description provided for @categoryVegetables.
  ///
  /// In fi, this message translates to:
  /// **'Vihannekset'**
  String get categoryVegetables;

  /// No description provided for @categoryOther.
  ///
  /// In fi, this message translates to:
  /// **'Muut'**
  String get categoryOther;

  /// No description provided for @categoryAll.
  ///
  /// In fi, this message translates to:
  /// **'Kaikki'**
  String get categoryAll;

  /// No description provided for @dietVegan.
  ///
  /// In fi, this message translates to:
  /// **'Vegaaninen'**
  String get dietVegan;

  /// No description provided for @dietGlutenFree.
  ///
  /// In fi, this message translates to:
  /// **'Gluteeniton'**
  String get dietGlutenFree;

  /// No description provided for @dietLactoseFree.
  ///
  /// In fi, this message translates to:
  /// **'Laktoositon'**
  String get dietLactoseFree;

  /// No description provided for @dietMilkFree.
  ///
  /// In fi, this message translates to:
  /// **'Maidoton'**
  String get dietMilkFree;

  /// No description provided for @dietNutFree.
  ///
  /// In fi, this message translates to:
  /// **'Pähkinätön'**
  String get dietNutFree;

  /// No description provided for @dietDomestic.
  ///
  /// In fi, this message translates to:
  /// **'Kotimainen'**
  String get dietDomestic;

  /// No description provided for @dietLocal.
  ///
  /// In fi, this message translates to:
  /// **'Lähiruoka'**
  String get dietLocal;

  /// No description provided for @newBadge.
  ///
  /// In fi, this message translates to:
  /// **'UUSI'**
  String get newBadge;

  /// No description provided for @dayShort.
  ///
  /// In fi, this message translates to:
  /// **'pv'**
  String get dayShort;

  /// No description provided for @hourShort.
  ///
  /// In fi, this message translates to:
  /// **'h'**
  String get hourShort;

  /// No description provided for @noDescription.
  ///
  /// In fi, this message translates to:
  /// **'Ei kuvausta'**
  String get noDescription;

  /// No description provided for @noLimit.
  ///
  /// In fi, this message translates to:
  /// **'Ei rajoitusta'**
  String get noLimit;

  /// No description provided for @showResults.
  ///
  /// In fi, this message translates to:
  /// **'Näytä tulokset'**
  String get showResults;

  /// No description provided for @clear.
  ///
  /// In fi, this message translates to:
  /// **'Tyhjennä'**
  String get clear;

  /// No description provided for @specialDiets.
  ///
  /// In fi, this message translates to:
  /// **'Erityisruokavaliot'**
  String get specialDiets;

  /// No description provided for @free.
  ///
  /// In fi, this message translates to:
  /// **'Ilmainen'**
  String get free;

  /// No description provided for @distanceUnitKm.
  ///
  /// In fi, this message translates to:
  /// **'km'**
  String get distanceUnitKm;

  /// No description provided for @distanceUnitM.
  ///
  /// In fi, this message translates to:
  /// **'m'**
  String get distanceUnitM;

  /// No description provided for @errorGenericWithDetails.
  ///
  /// In fi, this message translates to:
  /// **'Virhe: {error}'**
  String errorGenericWithDetails(Object error);

  /// No description provided for @errorNetwork.
  ///
  /// In fi, this message translates to:
  /// **'Ei internetyhteyttä. Tarkista verkkoyhteys.'**
  String get errorNetwork;

  /// No description provided for @errorPermission.
  ///
  /// In fi, this message translates to:
  /// **'Käyttöoikeusvirhe. Ota yhteys tukeen.'**
  String get errorPermission;

  /// No description provided for @errorTimeout.
  ///
  /// In fi, this message translates to:
  /// **'Toiminto kesti liian kauan. Yritä uudelleen.'**
  String get errorTimeout;

  /// No description provided for @errorNotFound.
  ///
  /// In fi, this message translates to:
  /// **'Tietoja ei löytynyt.'**
  String get errorNotFound;

  /// No description provided for @errorUnavailable.
  ///
  /// In fi, this message translates to:
  /// **'Palvelu ei ole saatavilla. Yritä myöhemmin.'**
  String get errorUnavailable;

  /// No description provided for @errorGeneric.
  ///
  /// In fi, this message translates to:
  /// **'Jotain meni pieleen. Yritä uudelleen.'**
  String get errorGeneric;

  /// No description provided for @filterCategory.
  ///
  /// In fi, this message translates to:
  /// **'Kategoria'**
  String get filterCategory;

  /// No description provided for @filterDistance.
  ///
  /// In fi, this message translates to:
  /// **'Etäisyys'**
  String get filterDistance;

  /// No description provided for @filterDiets.
  ///
  /// In fi, this message translates to:
  /// **'Erityisruokavaliot'**
  String get filterDiets;

  /// No description provided for @privacyPolicyDate.
  ///
  /// In fi, this message translates to:
  /// **'Päivitetty: 19.1.2026'**
  String get privacyPolicyDate;

  /// No description provided for @privacyPolicySection1Title.
  ///
  /// In fi, this message translates to:
  /// **'1. Rekisterinpitäjä'**
  String get privacyPolicySection1Title;

  /// No description provided for @privacyPolicySection1Content.
  ///
  /// In fi, this message translates to:
  /// **'Tämän palvelun ja rekisterin ylläpitäjä on koodaaja itse.\n\nSähköposti: nasratollah.rezai@gmail.com (Myöhemmin tässä tekstissä \"Me\" tai \"Palveluntarjoaja\").'**
  String get privacyPolicySection1Content;

  /// No description provided for @privacyPolicySection2Title.
  ///
  /// In fi, this message translates to:
  /// **'2. Mitä tietoja keräämme?'**
  String get privacyPolicySection2Title;

  /// No description provided for @privacyPolicySection2Content.
  ///
  /// In fi, this message translates to:
  /// **'Jotta Naapurisapuska-sovellus toimisi tarkoitetulla tavalla, keräämme käyttäjistä seuraavia tietoja:\n\nA. Käyttäjän antamat tiedot\n\nTilitiedot: Sähköpostiosoite, nimimerkki ja profiilikuva (rekisteröitymisen yhteydessä).\n\nKäyttäjän luoma sisältö: Sovellukseen lataamasi kuvat ruoasta, ruoan kuvaustekstit sekä chat-viestit, joita lähetät muille käyttäjille noudon sopimiseksi.\n\nB. Automaattisesti kerättävät tiedot\n\nSijaintitiedot: Keräämme tarkan sijaintisi (GPS) vain silloin kun käytät sovellusta, jotta voimme näyttää sinulle lähellä olevat ruokailmoitukset kartalla. Emme seuraa sijaintiasi taustalla, kun sovellus on suljettu.\n\nLaitetiedot: Tieto puhelimen mallista ja käyttöjärjestelmästä virheiden korjaamista varten.'**
  String get privacyPolicySection2Content;

  /// No description provided for @privacyPolicySection3Title.
  ///
  /// In fi, this message translates to:
  /// **'3. Mihin käytämme tietojasi?'**
  String get privacyPolicySection3Title;

  /// No description provided for @privacyPolicySection3Content.
  ///
  /// In fi, this message translates to:
  /// **'Käytämme kerättyjä tietoja vain seuraaviin tarkoituksiin:\n\nPalvelun tarjoaminen: Jotta voit nähdä ruokailmoitukset kartalla ja ottaa yhteyttä muihin käyttäjiin.\n\nTietoturva: Käyttäjätilin suojaaminen ja väärinkäytösten estäminen.\n\nViestintä: Ilmoittaaksemme sinulle (esim. Push-ilmoituksella), kun joku on kiinnostunut ilmoittamastasi ruoasta.\n\nTekoäly (AI): Käytämme laitteessa toimivaa tekoälyä (Machine Learning) tunnistamaan kuvista ruoan kategorian (esim. hedelmä/leipä) ilmoituksen tekemisen nopeuttamiseksi.'**
  String get privacyPolicySection3Content;

  /// No description provided for @privacyPolicySection4Title.
  ///
  /// In fi, this message translates to:
  /// **'4. Tietojen jakaminen kolmansille osapuolille'**
  String get privacyPolicySection4Title;

  /// No description provided for @privacyPolicySection4Content.
  ///
  /// In fi, this message translates to:
  /// **'Emme myy, vuokraa tai jaa tietojasi mainostajille (\"No Tracking\"). Jaamme tietoja vain palvelun teknisen toteutuksen vaatimille luotettaville kumppaneille:\n\nGoogle Firebase: Käytämme Firebasea tietokantana, käyttäjien tunnistautumiseen (Authentication) ja kuvien tallennukseen. Tietoja säilytetään Googlen turvallisilla palvelimilla (pääosin EU-alueella tai Privacy Shield -sopimusten mukaisesti).\n\nKarttapalvelut (Google Maps / Mapbox): Sijaintitietojasi käsitellään, jotta voimme piirtää kartan ja näyttää etäisyydet. Nämä palvelut eivät tallenna yksittäisen käyttäjän liikehistoriaa pysyvästi.'**
  String get privacyPolicySection4Content;

  /// No description provided for @privacyPolicySection5Title.
  ///
  /// In fi, this message translates to:
  /// **'5. Käyttäjän oikeudet (GDPR)'**
  String get privacyPolicySection5Title;

  /// No description provided for @privacyPolicySection5Content.
  ///
  /// In fi, this message translates to:
  /// **'Sinulla on Euroopan unionin tietosuoja-asetuksen nojalla oikeus:\n\nTarkastaa: Mitä tietoja sinusta on tallennettu.\n\nOikaista: Pyytää virheellisen tiedon korjaamista.\n\nPoistaa (\"Oikeus tulla unohdetuksi\"): Voit milloin tahansa poistaa käyttäjätilisi ja kaikki siihen liittyvät tiedot suoraan sovelluksen asetuksista (\"Poista tili\" -painike) tai ottamalla meihin yhteyttä sähköpostitse. Kun tili poistetaan, myös chat-historia ja kuvat poistuvat järjestelmästä pysyvästi.'**
  String get privacyPolicySection5Content;

  /// No description provided for @privacyPolicySection6Title.
  ///
  /// In fi, this message translates to:
  /// **'6. Tietojen säilytys'**
  String get privacyPolicySection6Title;

  /// No description provided for @privacyPolicySection6Content.
  ///
  /// In fi, this message translates to:
  /// **'Säilytämme tietojasi niin kauan kuin käyttäjätilisi on aktiivinen. Jos poistat tilisi, tiedot poistetaan kohtuullisen ajan kuluessa (yleensä 30 päivän sisällä) varmuuskopioista.'**
  String get privacyPolicySection6Content;

  /// No description provided for @privacyPolicySection7Title.
  ///
  /// In fi, this message translates to:
  /// **'7. Lasten yksityisyys'**
  String get privacyPolicySection7Title;

  /// No description provided for @privacyPolicySection7Content.
  ///
  /// In fi, this message translates to:
  /// **'Palvelu ei ole suunnattu alle 13-vuotiaille lapsille. Emme tietoisesti kerää tietoja alle 13-vuotiailta.'**
  String get privacyPolicySection7Content;

  /// No description provided for @privacyPolicySection8Title.
  ///
  /// In fi, this message translates to:
  /// **'8. Muutokset'**
  String get privacyPolicySection8Title;

  /// No description provided for @privacyPolicySection8Content.
  ///
  /// In fi, this message translates to:
  /// **'Pidätämme oikeuden päivittää tätä tietosuojaselostetta. Merkittävistä muutoksista ilmoitetaan sovelluksessa.'**
  String get privacyPolicySection8Content;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In fi, this message translates to:
  /// **'Käyttöehdot'**
  String get termsOfUseTitle;

  /// No description provided for @termsOfUseDate.
  ///
  /// In fi, this message translates to:
  /// **'Viimeksi päivitetty: 19.1.2026'**
  String get termsOfUseDate;

  /// No description provided for @termsOfUseSection1Title.
  ///
  /// In fi, this message translates to:
  /// **'1. Yleistä'**
  String get termsOfUseSection1Title;

  /// No description provided for @termsOfUseSection1Content.
  ///
  /// In fi, this message translates to:
  /// **'Tervetuloa käyttämään Naapurisapuska-sovellusta (\"Palvelu\"). Nämä käyttöehdot säätelevät Palvelun käyttöä. Lataamalla sovelluksen, rekisteröitymällä tai käyttämällä Palvelua hyväksyt nämä ehdot sitovasti.\n\nPalvelun tarjoaja (\"Me\") ylläpitää alustaa, jonka avulla yksityishenkilöt voivat ilmoittaa ja jakaa ylijäämäruokaa muille käyttäjille. Me emme ole ruoan myyjä, valmistaja emmekä jakelija. Toimimme vain teknisenä välittäjänä.'**
  String get termsOfUseSection1Content;

  /// No description provided for @termsOfUseSection2Title.
  ///
  /// In fi, this message translates to:
  /// **'2. Palvelun luonne ja vastuunrajoitus (TÄRKEÄ!)'**
  String get termsOfUseSection2Title;

  /// No description provided for @termsOfUseSection2Content.
  ///
  /// In fi, this message translates to:
  /// **'Naapurisapuska on alusta vertaisjakamiselle (peer-to-peer).\n\nRuokaturvallisuus: Palveluntarjoaja ei tarkista, valvo tai takaa Palvelussa ilmoitetun ruoan laatua, turvallisuutta, hygieniaa tai syömäkelpoisuutta.\n\nKäyttäjän vastuu:\n\nLuovuttaja: Vastaat siitä, että luovuttamasi ruoka on syömäkelpoista, oikein säilytettyä ja että tuoteselosteet/allergeenit on mahdollisuuksien mukaan kerrottu.\n\nVastaanottaja: Noudat ja nautit ruoan täysin omalla vastuullasi. Sinun tulee arvioida ruoan aistinvarainen laatu (haju, ulkonäkö) ennen sen nauttimista.\n\nVapautus vastuusta: Naapurisapuska ja sen kehittäjät eivät ole vastuussa mistään terveyshaitoista, sairauksista tai vahingoista, jotka aiheutuvat Palvelun kautta jaetusta ruoasta.'**
  String get termsOfUseSection2Content;

  /// No description provided for @termsOfUseSection3Title.
  ///
  /// In fi, this message translates to:
  /// **'3. Käyttäjätili ja rekisteröityminen'**
  String get termsOfUseSection3Title;

  /// No description provided for @termsOfUseSection3Content.
  ///
  /// In fi, this message translates to:
  /// **'Sinun tulee olla vähintään 13-vuotias käyttääksesi palvelua.\n\nOlet vastuussa salasanasi ja tilisi turvallisuudesta.\n\nSitoudut antamaan itsestäsi totuudenmukaiset tiedot. Valeprofiilien luominen on kiellettyä.'**
  String get termsOfUseSection3Content;

  /// No description provided for @termsOfUseSection4Title.
  ///
  /// In fi, this message translates to:
  /// **'4. Käyttäytymissäännöt'**
  String get termsOfUseSection4Title;

  /// No description provided for @termsOfUseSection4Content.
  ///
  /// In fi, this message translates to:
  /// **'Käyttäjänä sitoudut noudattamaan seuraavia sääntöjä:\n\nKunnioitus: Kohtele muita käyttäjiä asiallisesti chatissa ja noutotilanteissa. Häirintä on ehdottomasti kielletty.\n\nLuotettavuus: Jos sovit noudosta (varaat ruoan), sitoudut saapumaan paikalle sovittuna aikana. Toistuvat \"oharit\" (no-show) voivat johtaa tilin sulkemiseen.\n\nLaillisuus: Palvelussa ei saa jakaa alkoholia, tupakkatuotteita, lääkkeitä tai laittomia aineita.\n\nEi myyntiä: Palvelu on tarkoitettu ensisijaisesti ruoan jakamiseen ilmaiseksi tai nimellistä korvausta vastaan hävikin vähentämiseksi, ei ammattimaiseen liiketoimintaan ilman lupaa.'**
  String get termsOfUseSection4Content;

  /// No description provided for @termsOfUseSection5Title.
  ///
  /// In fi, this message translates to:
  /// **'5. Sisältö ja oikeudet'**
  String get termsOfUseSection5Title;

  /// No description provided for @termsOfUseSection5Content.
  ///
  /// In fi, this message translates to:
  /// **'Lataamalla kuvan ruoasta palveluun vakuutat, että sinulla on oikeus kuvaan.\n\nAnnat Naapurisapuskalle oikeuden käyttää, muokata ja esittää lataamaasi sisältöä (esim. ruokakuvat) Palvelun toiminnan puitteissa ja markkinoinnissa.\n\nEmme salli K-18 materiaalia tai sopimatonta sisältöä kuvissa.'**
  String get termsOfUseSection5Content;

  /// No description provided for @termsOfUseSection6Title.
  ///
  /// In fi, this message translates to:
  /// **'6. Palvelun saatavuus ja muutokset'**
  String get termsOfUseSection6Title;

  /// No description provided for @termsOfUseSection6Content.
  ///
  /// In fi, this message translates to:
  /// **'Pyrimme pitämään Palvelun toiminnassa 24/7, mutta emme takaa sen keskeytyksettömyyttä. Meillä on oikeus muuttaa, keskeyttää tai lopettaa Palvelu tai sen osa milloin tahansa ilman erillistä ilmoitusta (esim. huoltokatkot tai tekniset päivitykset).'**
  String get termsOfUseSection6Content;

  /// No description provided for @termsOfUseSection7Title.
  ///
  /// In fi, this message translates to:
  /// **'7. Sopimuksen päättäminen'**
  String get termsOfUseSection7Title;

  /// No description provided for @termsOfUseSection7Content.
  ///
  /// In fi, this message translates to:
  /// **'Meillä on oikeus sulkea käyttäjätilisi ja estää pääsy Palveluun välittömästi, jos:\n\nRikot näitä käyttöehtoja.\n\nKäytöksesi on uhkaavaa tai häiritsevää muita kohtaan.\n\nJatkuvasti jaat pilaantunutta ruokaa tai jätät noutamatta varauksia.'**
  String get termsOfUseSection7Content;

  /// No description provided for @termsOfUseSection8Title.
  ///
  /// In fi, this message translates to:
  /// **'8. Sovellettava laki'**
  String get termsOfUseSection8Title;

  /// No description provided for @termsOfUseSection8Content.
  ///
  /// In fi, this message translates to:
  /// **'Näihin ehtoihin sovelletaan Suomen lakia. Mahdolliset riitaisuudet pyritään ensisijaisesti ratkaisemaan neuvottelemalla.'**
  String get termsOfUseSection8Content;

  /// No description provided for @myListings.
  ///
  /// In fi, this message translates to:
  /// **'Omat ilmoitukset'**
  String get myListings;

  /// No description provided for @myReservations.
  ///
  /// In fi, this message translates to:
  /// **'Omat varaukset'**
  String get myReservations;

  /// No description provided for @favorites.
  ///
  /// In fi, this message translates to:
  /// **'Suosikit'**
  String get favorites;

  /// No description provided for @noListings.
  ///
  /// In fi, this message translates to:
  /// **'Et ole lisännyt ilmoituksia.'**
  String get noListings;

  /// No description provided for @noReservations.
  ///
  /// In fi, this message translates to:
  /// **'Et ole varannut mitään.'**
  String get noReservations;

  /// No description provided for @noFavorites.
  ///
  /// In fi, this message translates to:
  /// **'Ei suosikkeja.'**
  String get noFavorites;

  /// No description provided for @loginToViewProfile.
  ///
  /// In fi, this message translates to:
  /// **'Kirjaudu sisään nähdäksesi profiilin'**
  String get loginToViewProfile;

  /// No description provided for @anonymous.
  ///
  /// In fi, this message translates to:
  /// **'Nimetön'**
  String get anonymous;

  /// No description provided for @beginner.
  ///
  /// In fi, this message translates to:
  /// **'Aloittelija'**
  String get beginner;

  /// No description provided for @sharedPortions.
  ///
  /// In fi, this message translates to:
  /// **'{count} jaettua annosta'**
  String sharedPortions(int count);

  /// No description provided for @maxLevelReached.
  ///
  /// In fi, this message translates to:
  /// **'Maksimitaso saavutettu! 🎉'**
  String get maxLevelReached;

  /// No description provided for @progressToNextLevel.
  ///
  /// In fi, this message translates to:
  /// **'Edistyminen seuraavaan tasoon'**
  String get progressToNextLevel;

  /// No description provided for @statShared.
  ///
  /// In fi, this message translates to:
  /// **'Jaettu'**
  String get statShared;

  /// No description provided for @statRating.
  ///
  /// In fi, this message translates to:
  /// **'Arvostelu'**
  String get statRating;

  /// No description provided for @statReviews.
  ///
  /// In fi, this message translates to:
  /// **'Arvioita'**
  String get statReviews;

  /// No description provided for @notYet.
  ///
  /// In fi, this message translates to:
  /// **'Ei vielä'**
  String get notYet;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In fi, this message translates to:
  /// **'Säästä rahaa pelastamalla'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In fi, this message translates to:
  /// **'Osta herkullista ruokaa naapureilta ja kaupoilta reilusti alennettuun hintaan.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In fi, this message translates to:
  /// **'Heitä hyvästit hävikille'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In fi, this message translates to:
  /// **'Löydä tarjouksia läheltäsi! Selaa helposti päivittäin vaihtuvia ilmoituksia.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In fi, this message translates to:
  /// **'Nouda ja nauti'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In fi, this message translates to:
  /// **'Varaa ruoka sovelluksessa, nouda se sovitusti ja nauti hyvästä ruoasta.'**
  String get onboardingPage3Description;

  /// No description provided for @welcomeToApp.
  ///
  /// In fi, this message translates to:
  /// **'Tervetuloa NaapuriSapuskaan!'**
  String get welcomeToApp;

  /// No description provided for @onboardingTermsMessage.
  ///
  /// In fi, this message translates to:
  /// **'Ennen kuin jatkat, tarkista tietosuoja-asetuksesi ja käyttöehdot.'**
  String get onboardingTermsMessage;

  /// No description provided for @onboardingAcceptMessage.
  ///
  /// In fi, this message translates to:
  /// **'Käyttämällä palvelua hyväksyt:'**
  String get onboardingAcceptMessage;

  /// No description provided for @locationUsageForNotifications.
  ///
  /// In fi, this message translates to:
  /// **'Sijainnin käytön ilmoitusten näyttämiseen'**
  String get locationUsageForNotifications;

  /// No description provided for @newNotificationsTooltip.
  ///
  /// In fi, this message translates to:
  /// **'Uudet ilmoitukset'**
  String get newNotificationsTooltip;

  /// No description provided for @nearbyFood.
  ///
  /// In fi, this message translates to:
  /// **'Lähellä olevat ruoat'**
  String get nearbyFood;

  /// No description provided for @distanceAway.
  ///
  /// In fi, this message translates to:
  /// **'päästä'**
  String get distanceAway;

  /// No description provided for @seeMore.
  ///
  /// In fi, this message translates to:
  /// **'Katso lisää:'**
  String get seeMore;

  /// No description provided for @confirmReservation.
  ///
  /// In fi, this message translates to:
  /// **'Haluatko varmasti varata tämän ruoan?\n\nTämä avaa chatin ilmoittajan kanssa.'**
  String get confirmReservation;

  /// No description provided for @anonymousUser.
  ///
  /// In fi, this message translates to:
  /// **'Nimetön käyttäjä'**
  String get anonymousUser;

  /// No description provided for @newUser.
  ///
  /// In fi, this message translates to:
  /// **'Uusi käyttäjä'**
  String get newUser;

  /// No description provided for @listingUpdatedSuccess.
  ///
  /// In fi, this message translates to:
  /// **'Ilmoitus päivitetty onnistuneesti!'**
  String get listingUpdatedSuccess;

  /// No description provided for @whatFood.
  ///
  /// In fi, this message translates to:
  /// **'Mitä ruokaa?'**
  String get whatFood;

  /// No description provided for @foodPlaceholder.
  ///
  /// In fi, this message translates to:
  /// **'Esim. Leipää, hedelmiä, vihanneksia...'**
  String get foodPlaceholder;

  /// No description provided for @additionalInfo.
  ///
  /// In fi, this message translates to:
  /// **'Lisätiedot'**
  String get additionalInfo;

  /// No description provided for @additionalInfoPlaceholder.
  ///
  /// In fi, this message translates to:
  /// **'Määrä, päiväys, erityisohjeet...'**
  String get additionalInfoPlaceholder;

  /// No description provided for @quantity.
  ///
  /// In fi, this message translates to:
  /// **'Määrä'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In fi, this message translates to:
  /// **'Yksikkö'**
  String get unit;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In fi, this message translates to:
  /// **'Virhe viestien lataamisessa'**
  String get errorLoadingMessages;

  /// No description provided for @foodInfoHeader.
  ///
  /// In fi, this message translates to:
  /// **'Tietoa ruoasta'**
  String get foodInfoHeader;

  /// No description provided for @locationHeader.
  ///
  /// In fi, this message translates to:
  /// **'Sijainti'**
  String get locationHeader;

  /// No description provided for @posterLabel.
  ///
  /// In fi, this message translates to:
  /// **'Ilmoittaja'**
  String get posterLabel;

  /// No description provided for @freeLabel.
  ///
  /// In fi, this message translates to:
  /// **'Ilmainen'**
  String get freeLabel;

  /// No description provided for @categoryLabel.
  ///
  /// In fi, this message translates to:
  /// **'Kategoria'**
  String get categoryLabel;

  /// No description provided for @priceLabel.
  ///
  /// In fi, this message translates to:
  /// **'Hinta'**
  String get priceLabel;

  /// No description provided for @imagesLabel.
  ///
  /// In fi, this message translates to:
  /// **'Kuvat'**
  String get imagesLabel;

  /// No description provided for @selectImageLabel.
  ///
  /// In fi, this message translates to:
  /// **'Valitse kuva'**
  String get selectImageLabel;

  /// No description provided for @shareListingButton.
  ///
  /// In fi, this message translates to:
  /// **'Jaa ilmoitus'**
  String get shareListingButton;

  /// No description provided for @daysAgo.
  ///
  /// In fi, this message translates to:
  /// **'{count} päivää sitten'**
  String daysAgo(int count);

  /// No description provided for @hoursAgoShort.
  ///
  /// In fi, this message translates to:
  /// **'{count}h sitten'**
  String hoursAgoShort(int count);

  /// No description provided for @minutesAgoShort.
  ///
  /// In fi, this message translates to:
  /// **'{count}min sitten'**
  String minutesAgoShort(int count);

  /// No description provided for @justNow.
  ///
  /// In fi, this message translates to:
  /// **'Juuri nyt'**
  String get justNow;

  /// No description provided for @reserveFoodButton.
  ///
  /// In fi, this message translates to:
  /// **'VARAA RUOKA'**
  String get reserveFoodButton;

  /// No description provided for @reservedForYou.
  ///
  /// In fi, this message translates to:
  /// **'VARATTU SINULLE'**
  String get reservedForYou;

  /// No description provided for @userLevelBeginner.
  ///
  /// In fi, this message translates to:
  /// **'Aloittelija'**
  String get userLevelBeginner;

  /// No description provided for @userLevelActive.
  ///
  /// In fi, this message translates to:
  /// **'Aktiivinen'**
  String get userLevelActive;

  /// No description provided for @userLevelVeteran.
  ///
  /// In fi, this message translates to:
  /// **'Veteraani'**
  String get userLevelVeteran;

  /// No description provided for @noResults.
  ///
  /// In fi, this message translates to:
  /// **'Ei tuloksia'**
  String get noResults;

  /// No description provided for @noFoodNearby.
  ///
  /// In fi, this message translates to:
  /// **'Ei ruokaa lähistöllä'**
  String get noFoodNearby;

  /// No description provided for @beFirstToShare.
  ///
  /// In fi, this message translates to:
  /// **'Ole ensimmäinen jakamassa\nruokaa naapureille!'**
  String get beFirstToShare;

  /// No description provided for @tryExpandDistance.
  ///
  /// In fi, this message translates to:
  /// **'Kokeile laajentaa etäisyyttä tai\nvaihda kategoriaa'**
  String get tryExpandDistance;

  /// No description provided for @editFilters.
  ///
  /// In fi, this message translates to:
  /// **'Muokkaa suodattimia'**
  String get editFilters;

  /// No description provided for @newListingBanner.
  ///
  /// In fi, this message translates to:
  /// **'UUSI ILMOITUS'**
  String get newListingBanner;

  /// No description provided for @nearbyYou.
  ///
  /// In fi, this message translates to:
  /// **'Lähellä sinua'**
  String get nearbyYou;

  /// No description provided for @listingCount.
  ///
  /// In fi, this message translates to:
  /// **'{count, plural, =0{Ei ilmoituksia} =1{1 ilmoitus} other{{count} ilmoitusta}}'**
  String listingCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fi':
      return AppLocalizationsFi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
