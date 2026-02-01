import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naapurisapuska/main.dart';
import 'package:naapurisapuska/services/theme_service.dart';
import 'package:naapurisapuska/services/locale_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:naapurisapuska/firebase_options.dart';
import './mock_firebase.dart'; // We will create this

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  testWidgets('App initializes correctly smoke test',
      (WidgetTester tester) async {
    // Set a larger screen size to avoid overflows if they happen
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;

    // Mock SharedPreferences
    // We set showOnboarding to false to go to HomeScreen and avoid Onboarding overflow issues
    SharedPreferences.setMockInitialValues({
      'showOnboarding': false,
    });

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeService()),
          ChangeNotifierProvider(create: (_) => LocaleService()),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app builds without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Advance time to allow Splash Screen animations (3s delay) to complete.
    // We do NOT use pumpAndSettle because AppWrapper has an infinite pulse animation.
    await tester.pump(const Duration(seconds: 4));

    // One more frame to settle navigation
    await tester.pump();

    // Reset size
    addTearDown(tester.view.resetPhysicalSize);
  });
}
