import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart'; // TÄMÄ VAIHDETTIIN (sisältää Color-luokan)
import 'package:flutter/foundation.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:app_badge_plus/app_badge_plus.dart';

// Määritellään taustakäsittelijä heti tiedoston alkuun (top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('📬 Taustanotifikaatio: ${message.messageId}');
  }
}

class NotificationService {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  NotificationService({
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Paikallisten ilmoitusten plugin
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Android-kanava "korkealle tärkeydelle"
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
    'high_importance_channel',
    'Tärkeät ilmoitukset',
    description: 'Tämä kanava on uusille ruokailmoituksille.',
    importance: Importance.max,
    playSound: true,
  );

  /// Alusta notifikaatiot
  Future<void> initialize() async {
    // 1. Pyydä lupa
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) print('✅ Käyttäjä antoi luvan notifikaatioihin');

      // 2. Alusta paikalliset ilmoitukset
      await _initLocalNotifications();

      // 3. Päivitä tiedot Firestoreen
      await _updateUserTokenAndLocation();

      // 4. Kuuntele tokenin päivityksiä
      _messaging.onTokenRefresh.listen(_saveTokenToUser);

      // 5. Kuuntele viestejä kun sovellus on AUKI
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Ignore notifications created by self (if data available)
        final currentUser = _auth.currentUser;
        if (currentUser != null &&
            message.data['creatorId'] == currentUser.uid) {
          if (kDebugMode) {
            print('👻 Ignored self-notification');
          }
          return;
        }

        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                icon: '@mipmap/launcher_icon',
                importance: Importance.max,
                priority: Priority.high,
                // KORJAUS: Poistettiin "const" ja varmistettiin oikea import
                color: Color(0xFF388E3C),
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          );
        }
      });
    } else {
      if (kDebugMode) print('⚠️ Käyttäjä ei antanut lupaa notifikaatioihin');
    }
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Clear iOS app icon badge count
  Future<void> clearBadge() async {
    try {
      // Use app_badge_plus to clear badge on both iOS and Android
      await AppBadgePlus.updateBadge(0);
      if (kDebugMode) print('✅ Badge cleared');
    } catch (e) {
      if (kDebugMode) print('❌ Error clearing badge: $e');
    }
  }

  Future<void> updateUserLocation(Position position) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final geohasher = GeoHasher();
      final geohash = geohasher.encode(position.longitude, position.latitude);

      await _firestore.collection('users').doc(user.uid).set({
        'location': {
          'lat': position.latitude,
          'lng': position.longitude,
          'geohash': geohash,
        },
        // Backend expecs 5-char geohash for exact match query
        'geohash': geohash.length >= 5 ? geohash.substring(0, 5) : geohash,
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('❌ Virhe sijainnin päivityksessä: $e');
    }
  }

  Future<void> _updateUserTokenAndLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      String? token = await _messaging.getToken();
      Position? position;

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever) {
          position = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high));
        }
      } catch (e) {
        // Sijaintia ei saatu
      }

      Map<String, dynamic> updateData = {
        'lastActive': FieldValue.serverTimestamp(),
      };

      if (token != null) updateData['fcmToken'] = token;

      if (position != null) {
        final geohasher = GeoHasher();
        final geohash = geohasher.encode(position.longitude, position.latitude);

        updateData['location'] = {
          'lat': position.latitude,
          'lng': position.longitude,
          'geohash': geohash,
        };
        // Backend expecs 5-char geohash for exact match query
        updateData['geohash'] =
            geohash.length >= 5 ? geohash.substring(0, 5) : geohash;
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('❌ Virhe käyttäjätietojen alustuksessa: $e');
    }
  }

  Future<void> _saveTokenToUser(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fcmToken': token,
      });
    }
  }
}
