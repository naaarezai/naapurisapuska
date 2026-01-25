import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavoriteService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoriteService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // Lisää suosikki
  Future<void> addFavorite(String foodItemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(foodItemId)
          .set({
        'foodItemId': foodItemId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) print('Virhe suosikin lisäämisessä: $e');
    }
  }

  // Poista suosikki
  Future<void> removeFavorite(String foodItemId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(foodItemId)
          .delete();
    } catch (e) {
      if (kDebugMode) print('Virhe suosikin poistamisessa: $e');
    }
  }

  // Tarkista onko suosikki
  Future<bool> isFavorite(String foodItemId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(foodItemId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Tämä on se metodi, jota FoodCard ja ProfileScreen nyt käyttävät
  Stream<List<String>> getFavoriteIdsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}
