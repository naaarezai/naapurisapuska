import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/screens/food_list_screen.dart';
import 'package:naapurisapuska/models/food_item.dart';
import 'package:naapurisapuska/services/user_service.dart';
import 'package:naapurisapuska/services/database_service.dart';
import 'package:naapurisapuska/services/rating_service.dart';
import 'package:naapurisapuska/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockUserService extends Fake implements UserService {
  @override
  Stream<List<DocumentSnapshot>> getUserFoodItems(String userId) =>
      Stream.value([]);
  @override
  Future<void> toggleFavorite(String userId, String foodId) async {}
}

class MockDatabaseService extends Fake implements DatabaseService {
  @override
  Stream<FoodItem> getFoodItemStream(String itemId) => Stream.value(_testItem);
}

class MockRatingService extends Fake implements RatingService {
  @override
  Future<double> getAverageRating(String foodItemId) async => 4.5;
  @override
  Future<int> getRatingCount(String foodItemId) async => 10;
}

class MockAuth extends Fake implements FirebaseAuth {
  @override
  User? get currentUser => null;
}

final _testItem = FoodItem(
  id: 'test-1',
  title: 'Testi Omena',
  description: 'Todella hyvä omena kauas kotoa.',
  imageUrl: 'https://example.com/image.jpg',
  latitude: 60.1699,
  longitude: 24.9384,
  timestamp: DateTime.now(),
  category: FoodCategory.hedelmat,
  userId: 'user-1',
  userName: 'Matti',
  status: ReservationStatus.available,
);

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fi')],
      home: child,
    );
  }

  testWidgets('Navigation from FoodList to FoodDetail works and displays data',
      (WidgetTester tester) async {
    final mockUser = MockUserService();
    final mockDb = MockDatabaseService();
    final mockRating = MockRatingService();
    final mockAuth = MockAuth();

    // 1. Build the FoodListScreen with injected mocks
    await tester.pumpWidget(createTestWidget(FoodListScreen(
      title: 'Hae Ruokaa',
      items: [_testItem],
      emptyMessage: 'Ei ruokaa',
      userService: mockUser,
      databaseService: mockDb,
      ratingService: mockRating,
      auth: mockAuth,
    )));

    // 2. Verify item is displayed
    expect(find.text('Testi Omena'), findsOneWidget);

    // 3. Tap on the item to navigate
    await tester.tap(find.text('Testi Omena'));
    await tester.pumpAndSettle();

    // 4. Verify we are on the Detail Screen
    expect(find.text('Todella hyvä omena kauas kotoa.'), findsOneWidget);
    expect(find.text('Matti'), findsOneWidget);
  });
}
