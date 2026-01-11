import 'package:cloud_firestore/cloud_firestore.dart';

/// Käyttäjämalli
class UserModel {
  final String id; // Firebase Auth UID
  final String? name;
  final String? profileImageUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    this.name,
    this.profileImageUrl,
    this.phoneNumber,
    required this.createdAt,
    this.lastSeen,
  });

  /// Muuttaa olion Map-muotoon Firebase-tallennusta varten
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
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
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
