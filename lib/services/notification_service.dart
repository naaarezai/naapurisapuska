import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Alusta notifikaatiot ja päivitä käyttäjän sijainti
  Future<void> initialize() async {
    // 1. Pyydä lupa notifikaatioihin
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('✅ Käyttäjä antoi luvan notifikaatioihin');
      
      // 2. Päivitä tiedot heti kun sovellus aukeaa
      await _updateUserTokenAndLocation();

      // 3. Kuuntele tokenin päivityksiä
      _messaging.onTokenRefresh.listen((newToken) {
        _saveTokenToUser(newToken);
      });

      // Kuuntele notifikaatioita
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } else {
      if (kDebugMode) print('⚠️ Käyttäjä ei antanut lupaa notifikaatioihin');
    }
  }

  /// Julkinen metodi sijainnin päivittämiseen (tätä HomeScreen kutsuu)
  Future<void> updateUserLocation(Position position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      if (kDebugMode) print('✅ Sijainti päivitetty: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      if (kDebugMode) print('❌ Virhe sijainnin päivityksessä: $e');
    }
  }

  /// Päivittää sekä FCM-tokenin että sijainnin Firestoreen (sisäinen käyttö)
  Future<void> _updateUserTokenAndLocation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String? token = await _messaging.getToken();
      
      Position? position;
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.denied && permission != LocationPermission.deniedForever) {
          position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        }
      } catch (e) {
        // Sijaintia ei saatu, ei hätää
      }

      Map<String, dynamic> updateData = {
        'lastActive': FieldValue.serverTimestamp(),
      };

      if (token != null) updateData['fcmToken'] = token;
      
      if (position != null) {
        updateData['location'] = {
          'lat': position.latitude,
          'lng': position.longitude,
        };
      }

      await _firestore.collection('users').doc(user.uid).set(
        updateData, 
        SetOptions(merge: true)
      );
      
    } catch (e) {
      if (kDebugMode) print('❌ Virhe käyttäjätietojen päivityksessä: $e');
    }
  }

  Future<void> _saveTokenToUser(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print('📬 Notifikaatio vastaanotettu (etualalla): ${message.notification?.title}');
    }
  }
}

// Top-level funktio taustalle
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📬 Taustanotifikaatio: ${message.messageId}');
  }
}