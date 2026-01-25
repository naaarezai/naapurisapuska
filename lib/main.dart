import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'screens/app_wrapper.dart';
import 'package:provider/provider.dart';
import 'utils/app_theme.dart';
import 'services/theme_service.dart';
import 'services/locale_service.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'l10n/app_localizations.dart';

// Tämä funktio pitää olla MAIN-funktion ULKOPUOLELLA
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tänne tulee koodi joka ajetaan kun sovellus on kiinni ja viesti tulee
  debugPrint("Taustaviesti vastaanotettu: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Custom Error Widget for production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (kReleaseMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) => Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Hups! Jotain meni vikaan.',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pahoittelut, sovelluksessa tapahtui virhe. Tiimimme on saanut ilmoituksen ja korjaamme asiaa.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Attempt to restart or just navigate back
                    },
                    child: const Text('Yritä uudelleen'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    // In debug mode, use the default error widget
    return ErrorWidget(details.exception);
  };

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Alustetaan Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⭐ CRASHLYTICS: Catch all Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // ⭐ CRASHLYTICS: Catch errors outside Flutter (async errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Asetetaan taustakuuntelija
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Poistetaan splash screen kun kaikki on valmista
  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LocaleService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeService, LocaleService>(
      builder: (context, themeService, localeService, child) {
        return MaterialApp(
          title: 'Napsu',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode, // System, Light, or Dark

          // Localization configuration
          locale: localeService.locale, // null for system, or specific locale
          supportedLocales: const [
            Locale('fi'), // Finnish
            Locale('en'), // English
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            // If user has selected a specific locale, use it
            if (localeService.locale != null) {
              return localeService.locale;
            }

            // Otherwise, try to match system locale
            if (locale != null) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode) {
                  return supportedLocale;
                }
              }
            }

            // Fallback to Finnish
            return const Locale('fi');
          },

          home: const AppWrapper(),
        );
      },
    );
  }
}
