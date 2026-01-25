import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Käyttäjämalli
class UserModel {
  final String id; // Firebase Auth UID
  final String? name;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastSeen;
  final int savedFoodCount; // Montako ruokaa pelastanut (nakenut)
  final int sharedFoodCount; // Montako ruokaa jakanut (antanut)
  final List<String> favorites; // Suosikkiruokien ID:t

  // Achievement fields
  final int totalShared; // Jaettujen annosten kokonaismäärä
  final double averageRating; // Keskiarvo kaikista arvosteluista
  final int totalRatings; // Arvostelujen kokonaismäärä

  UserModel({
    required this.id,
    this.name,
    this.profileImageUrl,
    this.phoneNumber,
    required this.createdAt,
    this.lastSeen,
    this.savedFoodCount = 0,
    this.sharedFoodCount = 0,
    this.favorites = const [],
    this.totalShared = 0,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });

  // Helper: Level icon
  IconData get levelIcon {
    if (totalShared < 5) return Icons.emoji_food_beverage;
    if (totalShared < 10) return Icons.restaurant;
    return Icons.star;
  }

  // Helper: Progress to next level (0.0-1.0)
  double get levelProgress {
    if (totalShared < 5) return totalShared / 5.0;
    if (totalShared < 10) return (totalShared - 5) / 5.0;
    return 1.0; // Max level
  }

  // Helper: Level color
  Color get levelColor {
    if (totalShared < 5) return Colors.grey;
    if (totalShared < 10) return const Color(0xFF4CAF50); // Green
    return const Color(0xFFFF6F00); // Orange/Gold
  }

  /// Muuttaa olion Map-muotoon Firebase-tallennusta varten
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'savedFoodCount': savedFoodCount,
      'sharedFoodCount': sharedFoodCount,
      'favorites': favorites,
      'totalShared': totalShared,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }

  /// Luo olion Firebasesta haetusta datasta
  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      id: docId,
      name: map['name'] as String?,
      profileImageUrl: map['profileImageUrl'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
      savedFoodCount: map['savedFoodCount'] as int? ?? 0,
      sharedFoodCount: map['sharedFoodCount'] as int? ?? 0,
      favorites: List<String>.from(map['favorites'] ?? []),
      totalShared: map['totalShared'] as int? ?? 0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['totalRatings'] as int? ?? 0,
    );
  }

  /// Kopioi olion uudella datalla
  UserModel copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? lastSeen,
    int? savedFoodCount,
    int? sharedFoodCount,
    List<String>? favorites,
    int? totalShared,
    double? averageRating,
    int? totalRatings,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      savedFoodCount: savedFoodCount ?? this.savedFoodCount,
      sharedFoodCount: sharedFoodCount ?? this.sharedFoodCount,
      favorites: favorites ?? this.favorites,
      totalShared: totalShared ?? this.totalShared,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
    );
  }
}
