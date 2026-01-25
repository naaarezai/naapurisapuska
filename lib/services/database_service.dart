import 'dart:async';
// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart'; // Import XFile
import 'package:dart_geohash/dart_geohash.dart';
import '../models/food_item.dart';
import '../utils/retry_utils.dart';

class DatabaseService {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  // Määritellään kokoelmien nimet vakioina
  static const String _collectionFood = 'food_items';
  static const String _storageImagesPath = 'food_images';

  DatabaseService({FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance {
    // Varmista offline-välimuistin asetukset
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Optimoi kuvan koko ennen latausta (maksimi 800px leveys, JPEG, laatu 85%)
  Future<Uint8List> _compressImage(XFile imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Lataa kuva
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Kuvan lukeminen epäonnistui');
      }

      // Laske uusi koko (säilytä kuvasuhde)
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;
      const int maxWidth = 800;

      if (newWidth > maxWidth) {
        final double ratio = maxWidth / newWidth;
        newWidth = maxWidth;
        newHeight = (newHeight * ratio).round();
      }

      // Muuta kuvan kokoa
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear,
      );

      // Muunna JPEG-muotoon (laatu 85%)
      final Uint8List compressedBytes = Uint8List.fromList(
        img.encodeJpg(resizedImage, quality: 85),
      );

      return compressedBytes;
    } catch (e) {
      if (kDebugMode) {
        print('Kuvan optimointi epäonnistui: $e');
      }

      // Tarkista tiedostokoko. Jos kuva on yli 3MB ja optimointi epäonnistui, heitä virhe.
      final int originalSize = await imageFile.length();
      const int maxAllowedSize = 3 * 1024 * 1024; // 3MB raja

      if (originalSize > maxAllowedSize) {
        throw Exception(
            'Kuva on liian suuri (${(originalSize / 1024 / 1024).toStringAsFixed(1)} MB) eikä sitä voitu optimoida.');
      }

      // Jos kuva on alle 3MB, voidaan käyttää alkuperäistä hätätapauksessa
      return await imageFile.readAsBytes();
    }
  }

  /// Lisää uuden ruokailmoituksen Firestoreen.
  Future<void> addFoodItem(
    FoodItem item,
    XFile imageFile, {
    Function(double)? onProgress,
  }) async {
    await addFoodItemWithMultipleImages(
      item,
      [imageFile],
      onProgress: onProgress,
    );
  }

  /// Lisää uuden ruokailmoituksen useilla kuvilla.
  Future<void> addFoodItemWithMultipleImages(
    FoodItem item,
    List<XFile> imageFiles, {
    Function(double)? onProgress,
  }) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('Vähintään yksi kuva vaaditaan');
      }

      // 1. Lataa kaikki kuvat Firebase Storageen
      List<String> imageUrls = [];
      final int totalImages = imageFiles.length;

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];

        if (kDebugMode) {
          print('Optimoidaan kuva ${i + 1}/$totalImages...');
        }
        final Uint8List compressedImage = await _compressImage(imageFile);

        final String fileName =
            '${item.id}_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage
            .ref()
            .child('$_storageImagesPath/${item.userId}/$fileName');

        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        );

        final UploadTask uploadTask = ref.putData(compressedImage, metadata);

        StreamSubscription<TaskSnapshot>? uploadSubscription;
        uploadSubscription =
            uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final imageProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          final totalProgress = (i + imageProgress) / totalImages;
          if (onProgress != null) {
            onProgress(totalProgress);
          }
        });

        final TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            uploadSubscription?.cancel();
            throw Exception('Kuvan ${i + 1} lataus kesti liian kauan.');
          },
        );

        await uploadSubscription.cancel();

        final String imageUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception(
                'Kuvan ${i + 1} URL:n hakeminen kesti liian kauan.');
          },
        );

        imageUrls.add(imageUrl);
      }

      // 2. Päivitä FoodItem-olio kuvien URL:illa
      final String primaryImageUrl =
          imageUrls.isNotEmpty ? imageUrls.first : '';
      final List<String> additionalImageUrls =
          imageUrls.length > 1 ? imageUrls.sublist(1) : [];

      final FoodItem itemWithImages = FoodItem(
        id: item.id,
        title: item.title,
        description: item.description,
        imageUrl: primaryImageUrl,
        imageUrls: additionalImageUrls,
        latitude: item.latitude,
        longitude: item.longitude,
        timestamp: item.timestamp,
        category: item.category,
        userId: item.userId,
        userName: item.userName,
        userProfileImageUrl: item.userProfileImageUrl,
        price: item.price,
        quantity: item.quantity,
        quantityUnit: item.quantityUnit,
        status: item.status,
        reservedByUserId: item.reservedByUserId,
        dietaryTags: item.dietaryTags,
        geohash: GeoHasher().encode(item.longitude, item.latitude),
      );

      // 3. Tallenna Firestoreen
      await RetryUtils.retry(() => _firestore
              .collection(_collectionFood)
              .doc(item.id)
              .set(itemWithImages.toMap())
              .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Tietojen tallennus kesti liian kauan.');
            },
          ));

      if (kDebugMode) {
        print('✅ Ilmoitus tallennettu. Cloud Function lähettää ilmoitukset.');
      }
    } catch (e) {
      String errorMessage = 'Virhe ruokailmoituksen lisäämisessä';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Käyttöoikeusvirhe. Tarkista Firebase Security Rules.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Verkkovirhe. Tarkista internetyhteys.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Aikakatkaisu. Yritä uudelleen.';
      } else {
        errorMessage = 'Virhe: ${e.toString()}';
      }
      throw Exception(errorMessage);
    }
  }

  /// Palauttaa reaaliaikaisen virran (Stream) kaikista ruokailmoituksista.
  Stream<List<FoodItem>> getFoodItems() {
    return getFoodItemsStream();
  }

  Stream<List<FoodItem>> getFoodItemsStream() {
    return _firestore
        .collection(_collectionFood)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ==================== PAGINATION METHODS ====================

  /// Get first batch of food items (paginated)
  Future<QuerySnapshot> getFirstBatch({int limit = 20}) {
    return _firestore
        .collection(_collectionFood)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();
  }

  /// Get next batch of food items after a specific document
  Future<QuerySnapshot> getNextBatch({
    required DocumentSnapshot lastDocument,
    int limit = 20,
  }) {
    return _firestore
        .collection(_collectionFood)
        .orderBy('timestamp', descending: true)
        .startAfterDocument(lastDocument)
        .limit(limit)
        .get();
  }

  /// Get paginated stream of food items (real-time updates for current page)
  Stream<List<FoodItem>> getFoodItemsPaginated({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = _firestore
        .collection(_collectionFood)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              FoodItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  /// Hakee käyttäjän tekemät varaukset
  Stream<List<FoodItem>> getUserReservations(String userId) {
    return _firestore
        .collection(_collectionFood)
        .where('reservedByUserId', isEqualTo: userId)
        .orderBy('reservedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Hakee käyttäjän omat ilmoitukset
  Stream<List<FoodItem>> getMyFoodItems(String userId) {
    return _firestore
        .collection(_collectionFood)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FoodItem.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Palauttaa poistetun ruokailmoituksen
  Future<void> deleteFoodItem(String itemId) async {
    try {
      await _firestore.collection(_collectionFood).doc(itemId).delete();
      if (kDebugMode) {
        print('✅ Ilmoitus poistettu');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ilmoituksen poisto epäonnistui: $e');
      }
      rethrow;
    }
  }

  /// Palauttaa reaaliaikaisen virran (Stream) yhdestä ruokailmoituksesta.
  Stream<FoodItem> getFoodItemStream(String itemId) {
    return _firestore
        .collection(_collectionFood)
        .doc(itemId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception('Ilmoitusta ei löytynyt');
      }
      return FoodItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// Päivittää ruokailmoituksen tilan
  Future<void> updateFoodItemStatus(String itemId, ReservationStatus status,
      {String? reservedByUserId}) async {
    try {
      final Map<String, dynamic> data = {
        'status': status.name,
        'isReserved': status == ReservationStatus.reserved, // Legacy support
      };

      if (status == ReservationStatus.reserved) {
        data['reservedByUserId'] = reservedByUserId;
        data['reservedAt'] = Timestamp.now();
        data['pickedUpAt'] = null;
      } else if (status == ReservationStatus.available) {
        data['reservedByUserId'] = null;
        data['reservedAt'] = null;
        data['pickedUpAt'] = null;
      } else if (status == ReservationStatus.pickedUp) {
        data['pickedUpAt'] = Timestamp.now();
      }

      await _firestore.collection(_collectionFood).doc(itemId).update(data);

      if (kDebugMode) {
        print('✅ Ilmoituksen tila päivitetty: $status');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Tilan päivitys epäonnistui: $e');
      }
      rethrow;
    }
  }

  /// Merkitsee ilmoituksen varatuksi
  Future<void> reserveFoodItem(String itemId, String userId) async {
    await updateFoodItemStatus(itemId, ReservationStatus.reserved,
        reservedByUserId: userId);
  }

  /// Poistaa varauksen (vapauttaa ruoan)
  Future<void> unreserveFoodItem(String itemId) async {
    await updateFoodItemStatus(itemId, ReservationStatus.available);
  }

  /// Merkitsee noudetuksi
  Future<void> markAsPickedUp(String itemId) async {
    await updateFoodItemStatus(itemId, ReservationStatus.pickedUp);
  }

  /// Päivittää ruokailmoituksen tiedot
  Future<void> updateFoodItem(
    FoodItem item, {
    XFile? newImageFile,
    Function(double)? onProgress,
  }) async {
    try {
      String imageUrl = item.imageUrl;

      if (newImageFile != null) {
        if (kDebugMode) {
          print('Optimoidaan uusi kuva...');
        }
        final Uint8List compressedImage = await _compressImage(newImageFile);

        final String fileName =
            '${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage
            .ref()
            .child('$_storageImagesPath/${item.userId}/$fileName');

        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        );

        final UploadTask uploadTask = ref.putData(compressedImage, metadata);

        StreamSubscription<TaskSnapshot>? uploadSubscription;
        uploadSubscription =
            uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (onProgress != null) {
            onProgress(progress);
          }
        });

        final TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            uploadSubscription?.cancel();
            throw Exception(
                'Kuvan lataus kesti liian kauan. Tarkista internetyhteys.');
          },
        );

        await uploadSubscription.cancel();

        imageUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Kuvan URL:n hakeminen kesti liian kauan.');
          },
        );
      }

      final FoodItem updatedItem = FoodItem(
        id: item.id,
        title: item.title,
        description: item.description,
        imageUrl: imageUrl,
        imageUrls: item.imageUrls,
        latitude: item.latitude,
        longitude: item.longitude,
        timestamp: item.timestamp,
        category: item.category,
        userId: item.userId,
        userName: item.userName,
        userProfileImageUrl: item.userProfileImageUrl,
        price: item.price,
        quantity: item.quantity,
        quantityUnit: item.quantityUnit,
        status: item.status,
        reservedByUserId: item.reservedByUserId,
        reservedAt: item.reservedAt,
        dietaryTags: item.dietaryTags,
        geohash: GeoHasher().encode(item.longitude, item.latitude),
      );

      await RetryUtils.retry(() => _firestore
              .collection(_collectionFood)
              .doc(item.id)
              .update(updatedItem.toMap())
              .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Tietojen päivitys kesti liian kauan.');
            },
          ));

      if (kDebugMode) {
        print('✅ Ilmoitus päivitetty onnistuneesti');
      }
    } catch (e) {
      String errorMessage = 'Virhe ruokailmoituksen päivityksessä';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Käyttöoikeusvirhe. Tarkista Firebase Security Rules.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Verkkovirhe. Tarkista internetyhteys.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Aikakatkaisu. Yritä uudelleen.';
      } else {
        errorMessage = 'Virhe: ${e.toString()}';
      }
      throw Exception(errorMessage);
    }
  }
}
