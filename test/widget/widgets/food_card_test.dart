import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/models/food_item.dart';
import 'package:naapurisapuska/widgets/food_card.dart';
import 'package:naapurisapuska/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/firebase_core');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'Firebase#initializeCore') {
        return [
          {
            'name': '[DEFAULT]',
            'options': {
              'apiKey': '123',
              'appId': '123',
              'messagingSenderId': '123',
              'projectId': '123'
            },
            'pluginConstants': {},
          }
        ];
      }
      return null;
    });
  });

  group('FoodCard Widget Tests', () {
    late FoodItem testItem;

    setUp(() {
      testItem = FoodItem(
        id: 'test001',
        title: 'Test Pizza',
        description: 'Hyvää pizzaa testaukseen',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now(),
        category: FoodCategory.leivonnaiset,
        price: 5.50,
      );
    });

    Widget wrapWithLocalizations(Widget child) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('fi'),
        home: Scaffold(body: child),
      );
    }

    testWidgets('displays food item title', (tester) async {
      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: testItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('Test Pizza'), findsOneWidget);
    });

    testWidgets('displays food item description', (tester) async {
      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: testItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('Hyvää pizzaa testaukseen'), findsOneWidget);
    });

    testWidgets('displays price when item has price', (tester) async {
      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: testItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('5.50 €'), findsOneWidget);
    });

    testWidgets('displays "Ilmainen" when price is null', (tester) async {
      final freeItem = FoodItem(
        id: 'test002',
        title: 'Free Bread',
        description: 'Ilmaista leipää',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now(),
        price: null,
      );

      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: freeItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('Ilmainen'), findsOneWidget);
    });

    testWidgets('shows expiration badge when expiring soon', (tester) async {
      final expiringSoonItem = FoodItem(
        id: 'test003',
        title: 'Expiring Pizza',
        description: 'Vanhenee pian',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now().subtract(const Duration(days: 4, hours: 12)),
        status: ReservationStatus.available,
      );

      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: expiringSoonItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });

    testWidgets('shows NEW badge for recent items', (tester) async {
      final recentItem = FoodItem(
        id: 'test004',
        title: 'Fresh Pizza',
        description: 'Juuri lisätty',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: recentItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      // "UUSI" is the text in fi l10n
      expect(find.text('UUSI'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: testItem,
        onTap: () => tapped = true,
      )));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FoodCard));
      await tester.pumpAndSettle();
      expect(tapped, true);
    });

    testWidgets('favorite icon toggles state', (tester) async {
      var isFavorite = false;
      await tester.pumpWidget(wrapWithLocalizations(StatefulBuilder(
        builder: (context, setState) {
          return FoodCard(
            foodItem: testItem,
            onTap: () {},
            isFavorite: isFavorite,
            onFavoriteToggle: () => setState(() => isFavorite = !isFavorite),
          );
        },
      )));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays category badge', (tester) async {
      await tester.pumpWidget(wrapWithLocalizations(FoodCard(
        foodItem: testItem,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      // "Leivonnaiset" is the display name for the category
      expect(find.text('Leivonnaiset'), findsOneWidget);
    });
  });
}
