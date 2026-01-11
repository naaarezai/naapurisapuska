import 'package:cloud_firestore/cloud_firestore.dart';

class RatingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionFood = 'food_items'; // Määritelty nyt tässä tiedostossa

  /// Lisää arvostelun ilmoitukselle
  Future<void> addRating(String foodItemId, int rating, String comment) async {
    try {
      await _firestore
          .collection(_collectionFood)
          .doc(foodItemId)
          .collection('ratings')
          .add({
        'rating': rating,
        'comment': comment,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Virhe arvostelun lisäämisessä: $e');
    }
  }

  /// Hae ilmoituksen keskiarvio
  Future<double> getAverageRating(String foodItemId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionFood)
          .doc(foodItemId)
          .collection('ratings')
          .get();

      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      double sum = 0;
      for (var doc in snapshot.docs) {
        sum += (doc.data()['rating'] as num).toDouble();
      }

      return sum / snapshot.docs.length;
    } catch (e) {
      return 0.0;
    }
  }

  /// Hae arvostelujen määrä
  Future<int> getRatingCount(String foodItemId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionFood)
          .doc(foodItemId)
          .collection('ratings')
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}