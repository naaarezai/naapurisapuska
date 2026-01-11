import 'package:cloud_firestore/cloud_firestore.dart';

enum FoodCategory {
  leivonnaiset,
  hedelmat,
  vihannekset,
  muut;

  String get displayName {
    switch (this) {
      case FoodCategory.leivonnaiset:
        return 'Leivonnaiset';
      case FoodCategory.hedelmat:
        return 'Hedelmät';
      case FoodCategory.vihannekset:
        return 'Vihannekset';
      case FoodCategory.muut:
        return 'Muut';
    }
  }
}

class FoodItem {
  final String id;
  final String title;
  final String description;
  final String imageUrl; // Yksittäinen kuva (takaisin yhteensopivuus)
  final List<String> imageUrls; // Useita kuvia
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final FoodCategory category;
  final String? userId; // Käyttäjän ID joka jakoi ruoan
  final String? userName; // Käyttäjän nimi
  final String? userProfileImageUrl; // Käyttäjän profiilikuva
  final double? price; // Hinta (euroina, null = ilmainen)
  final double? quantity; // Määrä (esim. 2.5)
  final String? quantityUnit; // Yksikkö (kg, kpl, litra)
  final bool isReserved; // Onko varattu
  final String? reservedByUserId; // Kuka varasi (käyttäjän ID)

  FoodItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.category = FoodCategory.muut,
    this.userId,
    this.userName,
    this.userProfileImageUrl,
    this.price,
    this.quantity,
    this.quantityUnit,
    this.isReserved = false,
    this.reservedByUserId,
  });
  
  /// Palauttaa kaikki kuvat (imageUrl + imageUrls)
  List<String> get allImages {
    final List<String> images = [];
    if (imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }
    images.addAll(imageUrls.where((url) => url.isNotEmpty && !images.contains(url)));
    return images;
  }

  // Muuttaa olion Map-muotoon Firebase-tallennusta varten
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'category': category.name,
      'userId': userId,
      'userName': userName,
      'userProfileImageUrl': userProfileImageUrl,
      'price': price,
      'quantity': quantity,
      'quantityUnit': quantityUnit,
      'isReserved': isReserved,
      'reservedByUserId': reservedByUserId,
    };
  }

  // Luo olion Firebasesta haetusta datasta
  factory FoodItem.fromMap(Map<String, dynamic> map, String docId) {
    FoodCategory category = FoodCategory.muut;
    if (map['category'] != null) {
      try {
        category = FoodCategory.values.firstWhere(
          (e) => e.name == map['category'],
          orElse: () => FoodCategory.muut,
        );
      } catch (e) {
        category = FoodCategory.muut;
      }
    }
    
    // Käsittele imageUrls (takaisin yhteensopivuus)
    List<String> imageUrlsList = [];
    if (map['imageUrls'] != null) {
      if (map['imageUrls'] is List) {
        imageUrlsList = List<String>.from(map['imageUrls']);
      }
    }
    
    return FoodItem(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      imageUrls: imageUrlsList,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      category: category,
      userId: map['userId'] as String?,
      userName: map['userName'] as String?,
      userProfileImageUrl: map['userProfileImageUrl'] as String?,
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      quantity: map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
      quantityUnit: map['quantityUnit'] as String?,
      isReserved: map['isReserved'] as bool? ?? false,
      reservedByUserId: map['reservedByUserId'] as String?,
    );
  }
}