import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('UserModel', () {
    test('creates UserModel with all fields', () {
      final user = UserModel(
        id: 'user123',
        name: 'Test User',
        profileImageUrl: 'https://example.com/photo.jpg',
        phoneNumber: '+358401234567',
        createdAt: DateTime(2026, 1, 1),
        totalShared: 10,
        averageRating: 4.5,
        totalRatings: 20,
      );

      expect(user.id, 'user123');
      expect(user.name, 'Test User');
      expect(user.profileImageUrl, 'https://example.com/photo.jpg');
      expect(user.phoneNumber, '+358401234567');
      expect(user.totalShared, 10);
      expect(user.averageRating, 4.5);
      expect(user.totalRatings, 20);
    });

    test('creates userModel with minimal fields', () {
      final user = UserModel(
        id: 'user123',
        createdAt: DateTime(2026, 1, 1),
      );

      expect(user.id, 'user123');
      expect(user.name, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.phoneNumber, isNull);
      expect(user.totalShared, 0);
      expect(user.averageRating, 0.0);
      expect(user.totalRatings, 0);
    });

    test('toMap includes all fields', () {
      final user = UserModel(
        id: 'user123',
        name: 'Test User',
        profileImageUrl: 'https://example.com/photo.jpg',
        phoneNumber: '+358401234567',
        createdAt: DateTime(2026, 1, 1),
        totalShared: 5,
        averageRating: 4.0,
        totalRatings: 10,
      );

      final map = user.toMap();

      expect(map['id'], 'user123');
      expect(map['name'], 'Test User');
      expect(map['profileImageUrl'], 'https://example.com/photo.jpg');
      expect(map['phoneNumber'], '+358401234567');
      expect(map['totalShared'], 5);
      expect(map['averageRating'], 4.0);
      expect(map['totalRatings'], 10);
      expect(map['createdAt'], isNotNull);
    });

    test('fromMap creates correct UserModel', () {
      final map = {
        'name': 'Test User',
        'profileImageUrl': 'https://example.com/photo.jpg',
        'phoneNumber': '+358401234567',
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
        'totalShared': 7,
        'averageRating': 4.2,
        'totalRatings': 15,
        'savedFoodCount': 3,
        'sharedFoodCount': 5,
        'favorites': ['item1', 'item2'],
      };

      final user = UserModel.fromMap(map, 'user123');

      expect(user.id, 'user123');
      expect(user.name, 'Test User');
      expect(user.profileImageUrl, 'https://example.com/photo.jpg');
      expect(user.totalShared, 7);
      expect(user.averageRating, 4.2);
      expect(user.totalRatings, 15);
    });

    test('fromMap handles missing optional fields', () {
      final map = {
        'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
      };

      final user = UserModel.fromMap(map, 'user123');

      expect(user.id, 'user123');
      expect(user.name, isNull);
      expect(user.profileImageUrl, isNull);
      expect(user.totalShared, 0);
      expect(user.averageRating, 0.0);
      expect(user.totalRatings, 0);
    });

    test('copyWith creates modified copy', () {
      final original = UserModel(
        id: 'user123',
        name: 'Original Name',
        createdAt: DateTime(2026, 1, 1),
        totalShared: 5,
      );

      final modified = original.copyWith(
        name: 'New Name',
        totalShared: 10,
      );

      expect(modified.id, 'user123'); // Unchanged
      expect(modified.name, 'New Name'); // Changed
      expect(modified.totalShared, 10); // Changed
    });
  });
}
