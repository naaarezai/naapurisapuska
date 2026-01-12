import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart'; // Varmistetaan että tämä on olemassa

// Tämä funktio pitää olla MAIN-funktion ULKOPUOLELLA
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tänne tulee koodi joka ajetaan kun sovellus on kiinni ja viesti tulee
  print("Taustaviesti vastaanotettu: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Alustetaan Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Asetetaan taustakuuntelija
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaapuriSapuska',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF388E3C)),
        useMaterial3: true,
        
        // TÄMÄ KORJAA VIHREÄN YLÄPALKIN TAKAISIN:
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF388E3C), // Asetetaan tausta vihreäksi
          foregroundColor: Colors.white,      // Asetetaan teksti ja ikonit valkoisiksi
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}