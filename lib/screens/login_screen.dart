import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../utils/error_helper.dart';
import 'home_screen.dart'; // TÄRKEÄ: Lisää tämä import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _userService = UserService();
  bool _isLoading = false;
  bool _isSignUp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- REKISTERÖITYMINEN ---
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final phone = _phoneController.text.trim();
      final name = _nameController.text.trim();
      final password = _passwordController.text.trim();
      
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final email = '$cleanPhone@naapurisapuska.fi';
      
      // 1. Luo tili
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Tallenna tiedot
      final userModel = UserModel(
        id: userCredential.user!.uid,
        name: name,
        phoneNumber: cleanPhone,
        createdAt: DateTime.now(),
      );

      await _userService.createOrUpdateUser(userModel);

      if (mounted) {
        // KORJAUS: Siirry suoraan etusivulle, älä käytä pop()
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getUserFriendlyErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- KIRJAUTUMINEN ---
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = '${_phoneController.text.trim()}@naapurisapuska.fi';
      
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        // KORJAUS: Siirry suoraan etusivulle
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getUserFriendlyErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isSignUp ? 'Rekisteröidy' : 'Kirjaudu'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  _isSignUp ? Icons.person_add : Icons.login,
                  size: 80,
                  color: const Color(0xFF388E3C),
                ),
                const SizedBox(height: 24),
                Text(
                  _isSignUp ? 'Luo uusi tili' : 'Kirjaudu sisään',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Puhelinnumero',
                    hintText: '0501234567',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value == null || value.length < 10) ? 'Tarkista numero' : null,
                ),
                const SizedBox(height: 20),
                
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nimi',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) => (value == null || value.isEmpty) ? 'Syötä nimi' : null,
                  ),
                  const SizedBox(height: 20),
                ],
                
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Salasana',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Vähintään 6 merkkiä' : null,
                ),
                const SizedBox(height: 32),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : (_isSignUp ? _signUp : _signIn),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                      : Text(_isSignUp ? 'Rekisteröidy' : 'Kirjaudu', style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                
                TextButton(
                  onPressed: _isLoading ? null : () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? 'Onko sinulla jo tili? Kirjaudu' : 'Eikö sinulla ole tiliä? Rekisteröidy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}