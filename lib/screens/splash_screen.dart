import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart'; // Muista importata tämä!

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // 1. Visuaalinen viive (logo näkyy hetken)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 2. Tarkista onko käyttäjä nähnyt Onboardingin
    final prefs = await SharedPreferences.getInstance();
    final bool showOnboarding = prefs.getBool('showOnboarding') ?? true;

    // 3. Tarkista kirjautuminen
    User? user = FirebaseAuth.instance.currentUser;

    if (mounted) {
      if (showOnboarding) {
        // UUSI KÄYTTÄJÄ -> Näytä Onboarding (diat + ehdot)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      } else if (user != null) {
        // VANHA KÄYTTÄJÄ, KIRJAUTUNUT -> Etusivulle (Luvat kysytään siellä)
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        // VANHA KÄYTTÄJÄ, EI KIRJAUTUNUT -> Login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF388E3C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.soup_kitchen, size: 80, color: Color(0xFF388E3C));
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'NaapuriSapuska',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Jakamassa ruokaa naapureille', 
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 60),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}