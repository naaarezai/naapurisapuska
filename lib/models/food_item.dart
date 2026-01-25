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

enum ReservationStatus {
  available,
  reserved,
  pickedUp,
}

class FoodItem {
  static const List<String> availableTags = [
    'Vegaaninen',
    'Gluteeniton',
    'Laktoositon',
    'Maidoton',
    'Pähkinätön',
    'Kotimainen',
    'Lähiruoka',
  ];

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
  final ReservationStatus status; // Varauksen tila
  final String? reservedByUserId; // Kuka varasi (käyttäjän ID)
  final DateTime? reservedAt; // Milloin varattu
  final DateTime? pickedUpAt; // Milloin noudettu
  final List<String> dietaryTags; // Ruokavaliotagit (esim. Vegaaninen)
  final String? geohash; // Geohash sijainnille

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
    this.status = ReservationStatus.available,
    this.reservedByUserId,
    this.reservedAt,
    this.pickedUpAt,
    this.dietaryTags = const [],
    this.geohash,
  });

  /// Apumääritys taaksepäin yhteensopivuudelle
  bool get isReserved => status == ReservationStatus.reserved;

  /// Laskee milloin ilmoitus vanhenee
  DateTime get expiresAt {
    switch (status) {
      case ReservationStatus.available:
        return timestamp.add(const Duration(days: 5));
      case ReservationStatus.reserved:
        return (reservedAt ?? timestamp).add(const Duration(days: 7));
      case ReservationStatus.pickedUp:
        // Picked up items should be considered expired immediately relative to pickedUpAt
        return (pickedUpAt ?? timestamp);
    }
  }

  /// Helper to convert dynamic timestamp to DateTime
  static DateTime _parseTimestamp(dynamic tm) {
    if (tm is Timestamp) return tm.toDate();
    if (tm is DateTime) return tm;
    return DateTime.now();
  }

  /// Tarkistaa vanheneeko kohta (24h sisällä)
  bool get isExpiringSoon {
    final hoursUntilExpiration = expiresAt.difference(DateTime.now()).inHours;
    return hoursUntilExpiration <= 24 && hoursUntilExpiration > 0;
  }

  /// Tarkistaa onko jo vanhentunut
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  /// Palauttaa päivät vanhentumiseen
  int get daysUntilExpiration {
    final duration = expiresAt.difference(DateTime.now());
    return duration.inDays;
  }

  /// Palauttaa tunnit vanhentumiseen
  int get hoursUntilExpiration {
    final duration = expiresAt.difference(DateTime.now());
    return duration.inHours;
  }

  /// Palauttaa kaikki kuvat (imageUrl + imageUrls)
  List<String> get allImages {
    final List<String> images = [];
    if (imageUrl.isNotEmpty) {
      images.add(imageUrl);
    }
    images.addAll(
        imageUrls.where((url) => url.isNotEmpty && !images.contains(url)));
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
      'status': status.name,
      'isReserved': status ==
          ReservationStatus
              .reserved, // Yhteensopivuus vanhojen versioiden kanssa
      'reservedByUserId': reservedByUserId,
      'reservedAt': reservedAt != null ? Timestamp.fromDate(reservedAt!) : null,
      'pickedUpAt': pickedUpAt != null ? Timestamp.fromDate(pickedUpAt!) : null,
      'dietaryTags': dietaryTags,
      'geohash': geohash,
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

    // Status logiikka (migraatio)
    ReservationStatus status = ReservationStatus.available;
    if (map['status'] != null) {
      try {
        status = ReservationStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => ReservationStatus.available,
        );
      } catch (e) {
        status = ReservationStatus.available;
      }
    } else if (map['isReserved'] == true) {
      // Fallback vanhalle boolean kentälle
      status = ReservationStatus.reserved;
    }

    // Käsittele imageUrls (takaisin yhteensopivuus)
    List<String> imageUrlsList = [];
    if (map['imageUrls'] != null) {
      if (map['imageUrls'] is List) {
        imageUrlsList = List<String>.from(map['imageUrls']);
      }
    }

    // Käsittele dietaryTags
    List<String> dietaryTagsList = [];
    if (map['dietaryTags'] != null) {
      if (map['dietaryTags'] is List) {
        dietaryTagsList = List<String>.from(map['dietaryTags']);
      }
    }

    return FoodItem(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      imageUrls: imageUrlsList,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: _parseTimestamp(map['timestamp']),
      category: category,
      userId: map['userId'] as String?,
      userName: map['userName'] as String?,
      userProfileImageUrl: map['userProfileImageUrl'] as String?,
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      quantity:
          map['quantity'] != null ? (map['quantity'] as num).toDouble() : null,
      quantityUnit: map['quantityUnit'] as String?,
      status: status,
      reservedByUserId: map['reservedByUserId'] as String?,
      reservedAt: _parseTimestamp(map['reservedAt']),
      pickedUpAt: _parseTimestamp(map['pickedUpAt']),
      dietaryTags: dietaryTagsList,
      geohash: map['geohash'] as String?,
    );
    // Fixed double );
  }
}

/// Tulos tekoäly-tunnistuksesta
class FoodRecognitionResult {
  final String title;
  final String description;
  final FoodCategory category;

  FoodRecognitionResult({
    required this.title,
    required this.description,
    required this.category,
  });
}
