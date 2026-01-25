import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/main.dart';
import 'package:firebase_core/firebase_core.dart';
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

  testWidgets('App smoke test - verifies app builds without crashing',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: Since main() has async initialization, we just test the MyApp widget here
    await tester.pumpWidget(const MyApp());

    // Basic verification that the app structure exists
    expect(find.byType(MyApp), findsOneWidget);
  });
}
