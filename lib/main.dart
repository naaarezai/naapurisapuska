import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const NaapurisapuskaApp());
}

class NaapurisapuskaApp extends StatelessWidget {
  const NaapurisapuskaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Naapurisapuska',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light, // Pakotetaan vaalea teema
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF388E3C), 
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF388E3C),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        // KORJATTU: CardThemeData (uudemmille Flutter-versioille)
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}