// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NaapuriSapuska';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Settings';

  @override
  String get profile => 'Profile';

  @override
  String get myProfile => 'My Profile';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get searchHint => 'What are you craving...';

  @override
  String get filter => 'Filter';

  @override
  String get notifications => 'New Notifications';

  @override
  String get messages => 'Messages';

  @override
  String get shareFood => 'Share food';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get darkModeDescription => 'Use dark theme in the app';

  @override
  String get themeMode => 'Theme';

  @override
  String get themeModeSystem => 'System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageFinnish => 'Suomi';

  @override
  String get languageEnglish => 'English';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get close => 'Close';

  @override
  String get deleteAccountTitle => 'Delete account?';

  @override
  String get deleteAccountMessage =>
      'This action will permanently delete your account and all your listings. This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete Account';

  @override
  String get deleteAccountError =>
      'Error deleting account. Please log in again and try immediately.';

  @override
  String get locationPermissionTitle => 'Location permission required';

  @override
  String get locationPermissionMessage =>
      'The app needs location data to show nearby food. Please allow location access in settings.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get locationError =>
      'Could not get location. Showing Helsinki city center.';

  @override
  String get available => 'Available';

  @override
  String get reserved => 'Reserved';

  @override
  String get pickedUp => 'Picked Up';

  @override
  String get vegetables => 'Vegetables';

  @override
  String get fruits => 'Fruits';

  @override
  String get bread => 'Bread';

  @override
  String get dairy => 'Dairy';

  @override
  String get meat => 'Meat';

  @override
  String get fish => 'Fish';

  @override
  String get prepared => 'Prepared Food';

  @override
  String get other => 'Other';

  @override
  String get vegan => 'Vegan';

  @override
  String get vegetarian => 'Vegetarian';

  @override
  String get glutenFree => 'Gluten Free';

  @override
  String get lactoseFree => 'Lactose Free';

  @override
  String get nutFree => 'Nut Free';

  @override
  String get freePrice => 'Free';

  @override
  String get paidPrice => 'Paid';

  @override
  String get lowPrice => 'Low Price';

  @override
  String get negotiable => 'Negotiable';

  @override
  String get reserveFood => 'Reserve Food';

  @override
  String get reserve => 'Reserve';

  @override
  String get cancelReservation => 'Cancel Reservation';

  @override
  String get cancelReservationMessage =>
      'Are you sure you want to cancel the reservation?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get yesCancelReservation => 'Yes, cancel';

  @override
  String get markAsPickedUp => 'Mark as Picked Up';

  @override
  String get markAsPickedUpMessage =>
      'Has the food been picked up successfully?';

  @override
  String get yesPickedUp => 'Yes, picked up';

  @override
  String get deleteListing => 'Delete Listing';

  @override
  String get deleteListingMessage =>
      'Are you sure you want to delete this listing?';

  @override
  String get deleteListingButton => 'DELETE LISTING';

  @override
  String get cancelButton => 'CANCEL';

  @override
  String get pickedUpButton => 'PICKED UP';

  @override
  String get eventEnded => 'EVENT ENDED';

  @override
  String get addNewListing => 'Add New Listing';

  @override
  String get editListing => 'Edit Listing';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get noNewNotifications => 'No new notifications';

  @override
  String get fetchingLocation => 'Fetching location...';

  @override
  String get loginToReserve => 'Log in to reserve';

  @override
  String get cannotReserveOwn => 'You cannot reserve your own listing!';

  @override
  String get foodReserved => 'Food reserved!';

  @override
  String get reservationCancelled => 'Reservation cancelled';

  @override
  String get markedAsPickedUpSuccess => 'Marked as picked up!';

  @override
  String get loginToChat => 'Log in to use chat';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String errorUpdatingProfile(Object error) {
    return 'Error updating profile: $error';
  }

  @override
  String get invalidPrice => 'Invalid price. Use e.g. 5.00';

  @override
  String get maxImagesError => 'You can add up to 5 images';

  @override
  String get selectImageError =>
      'Please select at least one image before sharing';

  @override
  String messageSendError(Object error) {
    return 'Failed to send message: $error';
  }

  @override
  String get unitKg => 'kg';

  @override
  String get unitPcs => 'pcs';

  @override
  String get unitL => 'l';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get retryButton => 'Retry';

  @override
  String get skipIntro => 'Skip Intro';

  @override
  String get acceptAndContinue => 'Accept and Continue';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get writeMessage => 'Type a message...';

  @override
  String get unknown => 'Unknown';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversation => 'Start a conversation!';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get loading => 'Loading...';

  @override
  String get signUp => 'Sign Up';

  @override
  String get createAccount => 'Create New Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get name => 'Name';

  @override
  String get password => 'Password';

  @override
  String get checkPhoneNumber => 'Check phone number';

  @override
  String get enterName => 'Enter name';

  @override
  String get passwordLength => 'At least 6 characters';

  @override
  String get haveAccount => 'Already have an account? Login';

  @override
  String get noAccount => 'Don\'t have an account? Sign Up';

  @override
  String get appSlogan => 'Sharing food with neighbors';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithMicrosoft => 'Continue with Microsoft';

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get continueAsGuest => 'Browse Without Account';

  @override
  String socialLoginError(Object error) {
    return 'Login failed: $error';
  }

  @override
  String get categoryBakedGoods => 'Baked Goods';

  @override
  String get categoryFruits => 'Fruits';

  @override
  String get categoryVegetables => 'Vegetables';

  @override
  String get categoryOther => 'Other';

  @override
  String get categoryAll => 'All';

  @override
  String get dietVegan => 'Vegan';

  @override
  String get dietGlutenFree => 'Gluten Free';

  @override
  String get dietLactoseFree => 'Lactose Free';

  @override
  String get dietMilkFree => 'Dairy Free';

  @override
  String get dietNutFree => 'Nut Free';

  @override
  String get dietDomestic => 'Domestic';

  @override
  String get dietLocal => 'Local Food';

  @override
  String get newBadge => 'NEW';

  @override
  String get dayShort => 'd';

  @override
  String get hourShort => 'h';

  @override
  String get noDescription => 'No description';

  @override
  String get noLimit => 'No limit';

  @override
  String get showResults => 'Show Results';

  @override
  String get clear => 'Clear';

  @override
  String get specialDiets => 'Dietary';

  @override
  String get free => 'Free';

  @override
  String get distanceUnitKm => 'km';

  @override
  String get distanceUnitM => 'm';

  @override
  String errorGenericWithDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get errorNetwork => 'No internet connection. Check your connection.';

  @override
  String get errorPermission => 'Permission error. Contact support.';

  @override
  String get errorTimeout => 'Operation took too long. Try again.';

  @override
  String get errorNotFound => 'Data not found.';

  @override
  String get errorUnavailable => 'Service unavailable. Try again later.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterDistance => 'Distance';

  @override
  String get filterDiets => 'Dietary Restrictions';

  @override
  String get privacyPolicyDate => 'Updated: 19.1.2026';

  @override
  String get privacyPolicySection1Title => '1. Controller';

  @override
  String get privacyPolicySection1Content =>
      'The administrator of this service and register is the developer.\n\nEmail: nasratollah.rezai@gmail.com (Hereinafter \"We\" or \"Service Provider\").';

  @override
  String get privacyPolicySection2Title => '2. What information do we collect?';

  @override
  String get privacyPolicySection2Content =>
      'To ensure Naapurisapuska works as intended, we collect the following information:\n\nA. Information provided by the user\n\nAccount information: Email address, username, and profile picture (upon registration).\n\nUser-generated content: Images of food you upload, descriptions, and chat messages sent to other users to arrange pickups.\n\nB. Automatically collected information\n\nLocation data: We collect your precise location (GPS) only when you use the app to show nearby food listings on the map. We do not track your location in the background when the app is closed.\n\nDevice information: Information about phone model and operating system for bug fixing.';

  @override
  String get privacyPolicySection3Title => '3. How do we use your information?';

  @override
  String get privacyPolicySection3Content =>
      'We use collected information only for:\n\nService provision: To show food listings on the map and allow contact with other users.\n\nSecurity: Protecting user accounts and preventing misuse.\n\nCommunication: To notify you (e.g., Push notifications) when someone is interested in your listing.\n\nAI: We use on-device AI (Machine Learning) to recognize food categories from images to speed up listing creation.';

  @override
  String get privacyPolicySection4Title =>
      '4. Sharing information with third parties';

  @override
  String get privacyPolicySection4Content =>
      'We do not sell, rent, or share your data with advertisers (\"No Tracking\"). We only share data with trusted partners required for technical implementation:\n\nGoogle Firebase: Used as database, authentication, and image storage. Data is stored on Google\'s secure servers (mainly in EU or per Privacy Shield).\n\nMap Services (Google Maps / Mapbox): Location data is processed to draw the map and show distances. These services do not permanently store individual user movement history.';

  @override
  String get privacyPolicySection5Title => '5. User Rights (GDPR)';

  @override
  String get privacyPolicySection5Content =>
      'Under EU GDPR you have the right to:\n\nInspect: What data is stored about you.\n\nCorrect: Request correction of incorrect data.\n\nDelete (\"Right to be forgotten\"): You can delete your account and all related data at any time from app settings (\"Delete Account\" button) or by contacting us via email. When an account is deleted, chat history and images are permanently removed.';

  @override
  String get privacyPolicySection6Title => '6. Data Retention';

  @override
  String get privacyPolicySection6Content =>
      'We retain your data as long as your account is active. If you delete your account, data is removed from backups within a reasonable time (usually 30 days).';

  @override
  String get privacyPolicySection7Title => '7. Children\'s Privacy';

  @override
  String get privacyPolicySection7Content =>
      'The service is not directed at children under 13. We do not knowingly collect information from children under 13.';

  @override
  String get privacyPolicySection8Title => '8. Changes';

  @override
  String get privacyPolicySection8Content =>
      'We reserve the right to update this privacy policy. Significant changes will be notified within the application.';

  @override
  String get termsOfUseTitle => 'Terms of Use';

  @override
  String get termsOfUseDate => 'Last updated: 19.1.2026';

  @override
  String get termsOfUseSection1Title => '1. General';

  @override
  String get termsOfUseSection1Content =>
      'Welcome to the Naapurisapuska app (\"Service\"). These terms govern the use of the Service. By downloading the app, registering, or using the Service, you agree to these terms.\n\nThe Service Provider (\"We\") maintains a platform that allows individuals to list and share surplus food with other users. We are not a food seller, manufacturer, or distributor. We act only as a technical intermediary.';

  @override
  String get termsOfUseSection2Title =>
      '2. Nature of Service and Limitation of Liability (IMPORTANT!)';

  @override
  String get termsOfUseSection2Content =>
      'Naapurisapuska is a peer-to-peer sharing platform.\n\nFood Safety: The Service Provider does not check, monitor, or guarantee the quality, safety, hygiene, or edibility of food listed in the Service.\n\nUser Responsibility:\n\nGiver: You are responsible for ensuring that the food you give away is edible, properly stored, and that product descriptions/allergens are disclosed where possible.\n\nReceiver: You pick up and consume the food entirely at your own risk. You must evaluate the sensory quality of the food (smell, appearance) before consuming it.\n\nRelease from Liability: Naapurisapuska and its developers are not liable for any health issues, illnesses, or damages caused by food shared via the Service.';

  @override
  String get termsOfUseSection3Title => '3. User Account and Registration';

  @override
  String get termsOfUseSection3Content =>
      'You must be at least 13 years old to use the Service.\n\nYou are responsible for the security of your password and account.\n\nYou agree to provide truthful information about yourself. Creating fake profiles is prohibited.';

  @override
  String get termsOfUseSection4Title => '4. Rules of Conduct';

  @override
  String get termsOfUseSection4Content =>
      'As a user, you agree to follow these rules:\n\nRespect: Treat other users appropriately in chat and pickup situations. Harassment is strictly prohibited.\n\nReliability: If you agree to a pickup (reserve food), you commit to showing up at the agreed time. Repeated \"no-shows\" may lead to account suspension.\n\nLegality: You may not share alcohol, tobacco products, medicines, or illegal substances in the Service.\n\nNo Sales: The Service is primarily intended for sharing food for free or for a nominal fee to reduce waste, not for professional business without permission.';

  @override
  String get termsOfUseSection5Title => '5. Content and Rights';

  @override
  String get termsOfUseSection5Content =>
      'By uploading an image of food to the Service, you warrant that you have the right to the image.\n\nYou grant Naapurisapuska the right to use, modify, and display the content you upload (e.g., food images) within the scope of Service operation and marketing.\n\nWe do not allow 18+ material or inappropriate content in images.';

  @override
  String get termsOfUseSection6Title => '6. Service Availability and Changes';

  @override
  String get termsOfUseSection6Content =>
      'We strive to keep the Service operational 24/7, but we do not guarantee uninterrupted service. We have the right to change, suspend, or terminate the Service or part of it at any time without separate notice (e.g., maintenance breaks or technical updates).';

  @override
  String get termsOfUseSection7Title => '7. Termination';

  @override
  String get termsOfUseSection7Content =>
      'We have the right to close your account and prevent access to the Service immediately if:\n\nYou violate these terms.\n\nYour behavior is threatening or disturbing to others.\n\nYou repeatedly share spoiled food or fail to pick up reservations.';

  @override
  String get termsOfUseSection8Title => '8. Applicable Law';

  @override
  String get termsOfUseSection8Content =>
      'These terms are governed by Finnish law. Any disputes will ideally be resolved through negotiation.';

  @override
  String get myListings => 'My Listings';

  @override
  String get myReservations => 'My Reservations';

  @override
  String get favorites => 'Favorites';

  @override
  String get noListings => 'You haven\'t added any listings.';

  @override
  String get noReservations => 'You haven\'t reserved anything.';

  @override
  String get noFavorites => 'No favorites.';

  @override
  String get loginToViewProfile => 'Log in to view profile';

  @override
  String get anonymous => 'Anonymous';

  @override
  String get beginner => 'Beginner';

  @override
  String sharedPortions(int count) {
    return '$count shared portions';
  }

  @override
  String get maxLevelReached => 'Max level reached! 🎉';

  @override
  String get progressToNextLevel => 'Progress to next level';

  @override
  String get statShared => 'Shared';

  @override
  String get statRating => 'Rating';

  @override
  String get statReviews => 'Reviews';

  @override
  String get notYet => 'Not yet';

  @override
  String get onboardingPage1Title => 'Save money by saving food';

  @override
  String get onboardingPage1Description =>
      'Buy delicious food from neighbors and stores at a heavily discounted price.';

  @override
  String get onboardingPage2Title => 'Say goodbye to food waste';

  @override
  String get onboardingPage2Description =>
      'Find deals near you! Easily browse daily changing listings.';

  @override
  String get onboardingPage3Title => 'Pick up and enjoy';

  @override
  String get onboardingPage3Description =>
      'Reserve food in the app, pick it up as agreed, and enjoy good food.';

  @override
  String get welcomeToApp => 'Welcome to NaapuriSapuska!';

  @override
  String get onboardingTermsMessage =>
      'Before you continue, please review your privacy settings and terms of use.';

  @override
  String get onboardingAcceptMessage => 'By using the service, you accept:';

  @override
  String get locationUsageForNotifications =>
      'Use of location for showing notifications';

  @override
  String get newNotificationsTooltip => 'New notifications';

  @override
  String get nearbyFood => 'Nearby food';

  @override
  String get distanceAway => 'away';

  @override
  String get seeMore => 'See more:';

  @override
  String get confirmReservation =>
      'Do you really want to reserve this food?\n\nThis will open a chat with the poster.';

  @override
  String get anonymousUser => 'Anonymous user';

  @override
  String get newUser => 'New user';

  @override
  String get listingUpdatedSuccess => 'Listing updated successfully!';

  @override
  String get whatFood => 'What food?';

  @override
  String get foodPlaceholder => 'E.g., Bread, fruits, vegetables...';

  @override
  String get additionalInfo => 'Additional info';

  @override
  String get additionalInfoPlaceholder =>
      'Quantity, date, special instructions...';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get errorLoadingMessages => 'Error loading messages';

  @override
  String get foodInfoHeader => 'About the food';

  @override
  String get locationHeader => 'Location';

  @override
  String get posterLabel => 'Poster';

  @override
  String get freeLabel => 'Free';

  @override
  String get categoryLabel => 'Category';

  @override
  String get priceLabel => 'Price';

  @override
  String get imagesLabel => 'Images';

  @override
  String get selectImageLabel => 'Select image';

  @override
  String get shareListingButton => 'Share listing';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String hoursAgoShort(int count) {
    return '${count}h ago';
  }

  @override
  String minutesAgoShort(int count) {
    return '${count}min ago';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get reserveFoodButton => 'RESERVE FOOD';

  @override
  String get reservedForYou => 'RESERVED FOR YOU';

  @override
  String get userLevelBeginner => 'Beginner';

  @override
  String get userLevelActive => 'Active';

  @override
  String get userLevelVeteran => 'Veteran';

  @override
  String get noResults => 'No results';

  @override
  String get noFoodNearby => 'No food nearby';

  @override
  String get beFirstToShare => 'Be the first to share\nfood with neighbors!';

  @override
  String get tryExpandDistance =>
      'Try expanding the distance or\nchange the category';

  @override
  String get editFilters => 'Edit filters';

  @override
  String get newListingBanner => 'NEW LISTING';

  @override
  String get nearbyYou => 'Near You';

  @override
  String listingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count listings',
      one: '1 listing',
      zero: 'No listings',
    );
    return '$_temp0';
  }
}
