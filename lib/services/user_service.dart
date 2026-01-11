import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user_model.dart';

/// Käyttäjätietojen hallintapalvelu
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Hae käyttäjän tiedot
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Käyttäjän hakeminen epäonnistui: $e');
      }
      return null;
    }
  }

  /// Hae käyttäjän tiedot ID:llä (alias getUser:lle)
  Future<UserModel?> getUserById(String userId) async {
    return getUser(userId);
  }

  /// Hae nykyisen käyttäjän tiedot
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUser(user.uid);
  }

  /// Luo tai päivitä käyttäjän tiedot
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.toMap(),
            SetOptions(merge: true),
          );
      if (kDebugMode) {
        print('✅ Käyttäjän tiedot tallennettu');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Käyttäjän tallennus epäonnistui: $e');
      }
      rethrow;
    }
  }

  /// Päivitä käyttäjän profiilikuva
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      // Pakkaa kuva (yksinkertainen, ei pakkausta tässä versiossa)
      final compressedFile = imageFile;
      
      // Lataa Firebase Storageen
      final ref = _storage.ref().child('profile_images/$userId.jpg');
      final uploadTask = ref.putFile(compressedFile);
      
      // Odota valmistumista
      await uploadTask;
      
      // Hae URL
      final url = await ref.getDownloadURL();
      if (kDebugMode) {
        print('✅ Profiilikuva ladattu: $url');
      }
      
      // Päivitä käyttäjän tiedot
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': url,
      });
      
      return url;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Profiilikuvan lataus epäonnistui: $e');
      }
      return null;
    }
  }

  /// Päivitä käyttäjän nimi
  Future<void> updateUserName(String userId, String name) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'name': name,
      });
      if (kDebugMode) {
        print('✅ Käyttäjän nimi päivitetty');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Nimen päivitys epäonnistui: $e');
      }
      rethrow;
    }
  }

  /// Hae käyttäjän ilmoitukset
  Stream<List<DocumentSnapshot>> getUserFoodItems(String userId) {
    // Korjattu: käytetään suoraan 'food_items' merkkijonoa
    return _firestore
        .collection('food_items') 
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final docs = snapshot.docs.toList();
      docs.sort((a, b) {
        final timeA = a.data()['timestamp'] as Timestamp?;
        final timeB = b.data()['timestamp'] as Timestamp?;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA); // Uusimmat ensin
      });
      return docs;
    });
  }

  // ... aiemmat koodit ...

  // Lisää tämä metodi luokkaan:
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print('Virhe käyttäjän päivityksessä: $e');
      throw e;
    }
  }

  // ... aiemmat koodit ...

  /// Poista käyttäjätili ja kaikki tiedot
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // 1. Poista käyttäjän ilmoitukset
      final foodItems = await _firestore
          .collection('food_items')
          .where('userId', isEqualTo: user.uid)
          .get();
      
      for (var doc in foodItems.docs) {
        await doc.reference.delete();
      }

      // 2. Poista profiilikuva storagesta (jos on)
      try {
        await _storage.ref().child('profile_images/${user.uid}.jpg').delete();
      } catch (e) {
        // Ei haittaa jos kuvaa ei ole
      }

      // 3. Poista käyttäjätiedot Firestoresta
      await _firestore.collection('users').doc(user.uid).delete();

      // 4. Poista itse käyttäjätunnus (Auth)
      await user.delete();
      
    } catch (e) {
      if (kDebugMode) {
        print('Virhe tilin poistossa: $e');
      }
      rethrow;
    }
  }
}