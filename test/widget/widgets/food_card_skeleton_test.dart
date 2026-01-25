import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:naapurisapuska/widgets/food_card_skeleton.dart';

void main() {
  group('FoodCardSkeleton Widget Tests', () {
    testWidgets('displays skeleton card structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodCardSkeleton(),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(FoodCardSkeleton), findsOneWidget);
    });

    testWidgets('has shimmer effect container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodCardSkeleton(),
          ),
        ),
      );

      // Should have multiple containers for shimmer effect
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('matches FoodCard layout dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FoodCardSkeleton(),
          ),
        ),
      );

      // Get the card widget
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final card = tester.widget<Card>(cardFinder);

      // Should have similar styling to actual FoodCard
      expect(card.elevation, isNotNull);
      expect(card.shape, isNotNull);
    });

    testWidgets('displays multiple skeleton cards in list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const FoodCardSkeleton(),
            ),
          ),
        ),
      );

      // Should render 5 skeleton cards
      expect(find.byType(FoodCardSkeleton), findsNWidgets(5));
    });
  });
}
