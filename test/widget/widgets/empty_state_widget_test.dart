import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget Tests', () {
    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Test Title',
              message: 'Test message',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('displays title and message text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Ei ruokailmoituksia',
              message: 'Lisää ensimmäinen ilmoitus',
            ),
          ),
        ),
      );

      expect(find.text('Ei ruokailmoituksia'), findsOneWidget);
      expect(find.text('Lisää ensimmäinen ilmoitus'), findsOneWidget);
    });

    testWidgets('displays action button when provided', (tester) async {
      var buttonTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Ei ruokailmoituksia',
              message: 'Lisää ensimmäinen ilmoitus',
              actionLabel: 'Lisää ruokaa',
              onAction: () {
                buttonTapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Lisää ruokaa'), findsOneWidget);

      await tester.tap(find.text('Lisää ruokaa'));
      await tester.pumpAndSettle();

      expect(buttonTapped, true);
    });

    testWidgets('does not display button when action is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Test Title',
              message: 'Ei ruokailmoituksia',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('animates on build', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              icon: Icons.inbox,
              title: 'Test Title',
              message: 'Test message',
            ),
          ),
        ),
      );

      // Pump a few frames to let animations run
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 300));

      // Should still find the widgets after animations
      expect(find.byIcon(Icons.inbox), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
    });
  });
}
