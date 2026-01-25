import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/models/food_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('FoodItem Expiration Logic', () {
    test('available item expires after 5 days', () {
      final fiveDaysOneHourAgo =
          DateTime.now().subtract(const Duration(days: 5, hours: 1));

      final item = FoodItem(
        id: 'test123',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: fiveDaysOneHourAgo,
        status: ReservationStatus.available,
      );

      expect(item.isExpired, true,
          reason: 'Available item should expire after 5 days');
    });

    test('available item does NOT expire before 5 days', () {
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));

      final item = FoodItem(
        id: 'test124',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: fourDaysAgo,
        status: ReservationStatus.available,
      );

      expect(item.isExpired, false,
          reason: 'Available item should NOT expire before 5 days');
    });

    test('reserved item expires after 7 days', () {
      final sevenDaysOneHourAgo =
          DateTime.now().subtract(const Duration(days: 7, hours: 1));

      final item = FoodItem(
        id: 'test125',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: sevenDaysOneHourAgo,
        status: ReservationStatus.reserved,
        reservedAt: sevenDaysOneHourAgo,
      );

      expect(item.isExpired, true,
          reason: 'Reserved item should expire after 7 days');
    });

    test('reserved item does NOT expire before 7 days', () {
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));

      final item = FoodItem(
        id: 'test126',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: sixDaysAgo,
        status: ReservationStatus.reserved,
        reservedAt: sixDaysAgo,
      );

      expect(item.isExpired, false,
          reason: 'Reserved item should NOT expire before 7 days');
    });

    test('pickedUp item has already expired', () {
      // PickedUp items expire at their timestamp (considered already consumed)
      // So we need a past timestamp to test expiration
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1));

      final item = FoodItem(
        id: 'test127',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: pastTime,
        status: ReservationStatus.pickedUp,
      );

      expect(item.isExpired, true,
          reason: 'PickedUp item with past timestamp should be expired');
    });

    test('pickedUp item created now is not yet expired', () {
      // PickedUp at current time hasn't expired yet
      final now = DateTime.now();

      final item = FoodItem(
        id: 'test128',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: now,
        status: ReservationStatus.pickedUp,
      );

      // It expires AT the timestamp, so if timestamp is now, it's not expired yet
      expect(item.isExpired, false,
          reason: 'PickedUp item at current time is not yet expired');
    });
  });

  group('FoodItem expiringSoon Logic', () {
    test('item expiring in 12 hours is expiring soon', () {
      final twelveHoursAgo =
          DateTime.now().subtract(const Duration(days: 4, hours: 12));

      final item = FoodItem(
        id: 'test129',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: twelveHoursAgo,
        status: ReservationStatus.available,
      );

      expect(item.isExpiringSoon, true,
          reason: 'Item with 12h remaining should be expiring soon');
    });

    test('item expiring in 2 days is NOT expiring soon', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

      final item = FoodItem(
        id: 'test130',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: threeDaysAgo,
        status: ReservationStatus.available,
      );

      expect(item.isExpiringSoon, false,
          reason: 'Item with 2 days remaining should NOT be expiring soon');
    });
  });

  group('FoodItem daysUntilExpiration', () {
    test('calculates correct days until expiration for available', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));

      final item = FoodItem(
        id: 'test130',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: threeDaysAgo,
        status: ReservationStatus.available,
      );

      expect(item.daysUntilExpiration, greaterThanOrEqualTo(1),
          reason: 'Should have at least 1 day remaining (5 - 3)');
    });

    test('returns negative days for expired items', () {
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));

      final item = FoodItem(
        id: 'test131',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: sixDaysAgo,
        status: ReservationStatus.available,
      );

      expect(item.daysUntilExpiration, lessThan(0),
          reason: 'Expired item should have negative days');
    });
  });

  group('FoodItem allImages getter', () {
    test('returns only imageUrl when no additional images', () {
      final item = FoodItem(
        id: 'test132',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: 'https://example.com/pizza.jpg',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now(),
      );

      expect(item.allImages.length, 1);
      expect(item.allImages.first, 'https://example.com/pizza.jpg');
    });

    test('combines imageUrl and imageUrls', () {
      final item = FoodItem(
        id: 'test133',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: 'https://example.com/pizza1.jpg',
        imageUrls: [
          'https://example.com/pizza2.jpg',
          'https://example.com/pizza3.jpg',
        ],
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now(),
      );

      expect(item.allImages.length, 3);
      expect(item.allImages[0], 'https://example.com/pizza1.jpg');
      expect(item.allImages[1], 'https://example.com/pizza2.jpg');
      expect(item.allImages[2], 'https://example.com/pizza3.jpg');
    });

    test('filters out empty URLs', () {
      final item = FoodItem(
        id: 'test134',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: '',
        imageUrls: [
          'https://example.com/pizza1.jpg',
          '',
          'https://example.com/pizza2.jpg',
        ],
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: DateTime.now(),
      );

      expect(item.allImages.length, 2);
      expect(item.allImages.contains(''), false);
    });
  });

  group('FoodItem Serialization', () {
    test('toMap includes all fields', () {
      final timestamp = DateTime.now();
      final item = FoodItem(
        id: 'test135',
        title: 'Pizza',
        description: 'Hyvää pizzaa',
        imageUrl: 'https://example.com/pizza.jpg',
        latitude: 60.1699,
        longitude: 24.9384,
        timestamp: timestamp,
        category: FoodCategory.leivonnaiset,
        status: ReservationStatus.available,
        price: 5.50,
        quantity: 2.0,
        quantityUnit: 'kpl',
      );

      final map = item.toMap();

      expect(map['id'], 'test135');
      expect(map['title'], 'Pizza');
      expect(map['description'], 'Hyvää pizzaa');
      expect(map['category'], 'leivonnaiset');
      expect(map['status'], 'available');
      expect(map['price'], 5.50);
      expect(map['quantity'], 2.0);
      expect(map['quantityUnit'], 'kpl');
    });

    test('fromMap creates correct FoodItem', () {
      final now = DateTime.now();
      final map = {
        'title': 'Pizza',
        'description': 'Hyvää pizzaa',
        'imageUrl': 'https://example.com/pizza.jpg',
        'imageUrls': [],
        'latitude': 60.1699,
        'longitude': 24.9384,
        'timestamp': Timestamp.fromDate(now), // Use Timestamp!
        'category': 'leivonnaiset',
        'status': 'available',
        'price': 5.50,
        'quantity': 2.0,
        'quantityUnit': 'kpl',
      };

      final item = FoodItem.fromMap(map, 'test136');

      expect(item.id, 'test136');
      expect(item.title, 'Pizza');
      expect(item.category, FoodCategory.leivonnaiset);
      expect(item.status, ReservationStatus.available);
      expect(item.price, 5.50);
    });
  });
}
