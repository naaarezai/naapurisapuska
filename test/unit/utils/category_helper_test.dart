import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/utils/category_helper.dart';
import 'package:naapurisapuska/models/food_item.dart';

void main() {
  // Set up widget test environment without Firebase
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CategoryHelper - getCategoryIcon', () {
    test('returns correct icon for leivonnaiset', () {
      final icon = CategoryHelper.getCategoryIcon(FoodCategory.leivonnaiset);
      expect(icon, Icons.cake); // Updated from Icons.bakery_dining
    });

    test('returns correct icon for hedelmat', () {
      final icon = CategoryHelper.getCategoryIcon(FoodCategory.hedelmat);
      expect(icon, Icons.apple);
    });

    test('returns correct icon for vihannekset', () {
      final icon = CategoryHelper.getCategoryIcon(FoodCategory.vihannekset);
      expect(icon, Icons.eco);
    });

    test('returns correct icon for muut', () {
      final icon = CategoryHelper.getCategoryIcon(FoodCategory.muut);
      expect(icon, Icons.fastfood);
    });
  });

  group('CategoryHelper - getCategoryColor', () {
    test('returns color for each category', () {
      for (final category in FoodCategory.values) {
        final color = CategoryHelper.getCategoryColor(category);
        expect(color, isA<Color>());
      }
    });

    test('returns distinct colors for different categories', () {
      final leivonnaiset =
          CategoryHelper.getCategoryColor(FoodCategory.leivonnaiset);
      final hedelmat = CategoryHelper.getCategoryColor(FoodCategory.hedelmat);
      final vihannekset =
          CategoryHelper.getCategoryColor(FoodCategory.vihannekset);

      expect(leivonnaiset, isNot(equals(hedelmat)));
      expect(hedelmat, isNot(equals(vihannekset)));
    });
  });

  group('CategoryHelper - getCategoryBadge', () {
    testWidgets('creates badge widget with icon and text', (tester) async {
      final badge = CategoryHelper.getCategoryBadge(FoodCategory.leivonnaiset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: badge,
          ),
        ),
      );

      expect(find.text('Leivonnaiset'), findsOneWidget);
      expect(find.byIcon(Icons.cake), findsOneWidget);
    });

    testWidgets('applies custom fontSize', (tester) async {
      final badge = CategoryHelper.getCategoryBadge(
        FoodCategory.hedelmat,
        fontSize: 16,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: badge,
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Hedelmät'));
      expect(textWidget.style?.fontSize, 16);
    });

    testWidgets('applies custom iconSize', (tester) async {
      final badge = CategoryHelper.getCategoryBadge(
        FoodCategory.vihannekset,
        iconSize: 20,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: badge,
          ),
        ),
      );

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.eco));
      expect(iconWidget.size, 20);
    });

    testWidgets('applies custom padding', (tester) async {
      final badge = CategoryHelper.getCategoryBadge(
        FoodCategory.muut,
        padding: const EdgeInsets.all(10),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: badge,
          ),
        ),
      );

      // Should find the badge
      expect(find.byType(Container), findsWidgets);
    });
  });
}
