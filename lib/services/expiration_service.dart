import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for handling food item expiration logic
class ExpirationService {
  final FirebaseFirestore? _firestore;

  ExpirationService({FirebaseFirestore? firestore}) : _firestore = firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  /// Get user's expiring items (within 48 hours)
  Stream<List<Map<String, dynamic>>> getExpiringItems(String userId) {
    final twoDaysFromNow = DateTime.now().add(const Duration(days: 2));

    return _db
        .collection('food_items')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['available', 'reserved'])
        .snapshots()
        .map((snapshot) {
          // Filter items that expire within 48 hours
          return snapshot.docs
              .where((doc) {
                final data = doc.data();
                final DateTime timestamp = _parse(data['timestamp']);
                final status = data['status'] as String?;

                DateTime expiresAt;
                if (status == 'reserved') {
                  final DateTime reservedAt =
                      _parse(data['reservedAt'], fallback: timestamp);
                  expiresAt = reservedAt.add(const Duration(days: 7));
                } else {
                  expiresAt = timestamp.add(const Duration(days: 5));
                }

                return expiresAt.isBefore(twoDaysFromNow);
              })
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList();
        });
  }

  /// Extend item expiration by resetting the timestamp
  /// This effectively gives the item a fresh 5 or 7 day window
  Future<void> extendItemExpiration(String itemId) async {
    try {
      await _db.collection('food_items').doc(itemId).update({
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Virhe ilmoituksen pidentämisessä: $e');
    }
  }

  /// Get days until expiration for an item
  int getDaysUntilExpiration(Map<String, dynamic> itemData) {
    final DateTime timestamp = _parse(itemData['timestamp']);
    final status = itemData['status'] as String?;

    DateTime expiresAt;
    if (status == 'reserved') {
      final DateTime reservedAt =
          _parse(itemData['reservedAt'], fallback: timestamp);
      expiresAt = reservedAt.add(const Duration(days: 7));
    } else {
      expiresAt = timestamp.add(const Duration(days: 5));
    }

    final duration = expiresAt.difference(DateTime.now());
    return duration.inDays;
  }

  /// Get formatted expiration string
  String getExpirationText(Map<String, dynamic> itemData) {
    final days = getDaysUntilExpiration(itemData);

    if (days < 0) {
      return 'Vanhentunut';
    } else if (days == 0) {
      final DateTime timestamp = _parse(itemData['timestamp']);
      final status = itemData['status'] as String?;

      DateTime expiresAt;
      if (status == 'reserved') {
        final DateTime reservedAt =
            _parse(itemData['reservedAt'], fallback: timestamp);
        expiresAt = reservedAt.add(const Duration(days: 7));
      } else {
        expiresAt = timestamp.add(const Duration(days: 5));
      }

      final hours = expiresAt.difference(DateTime.now()).inHours;
      return 'Vanhenee $hours tunnin kuluttua';
    } else if (days == 1) {
      return 'Vanhenee huomenna';
    } else {
      return 'Vanhenee $days päivän kuluttua';
    }
  }

  static DateTime _parse(dynamic value, {DateTime? fallback}) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return fallback ?? DateTime.now();
  }
}
