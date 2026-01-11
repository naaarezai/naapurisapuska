import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/food_item.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Määritellään kokoelmien nimet vakioina
  static const String _collectionFood = 'food_items';
  static const String _storageImagesPath = 'food_images';

  DatabaseService() {
    // Varmista offline-välimuistin asetukset
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  /// Optimoi kuvan koko ennen latausta (maksimi 800px leveys, JPEG, laatu 85%)
  Future<Uint8List> _compressImage(File imageFile) async {
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
        throw Exception('Kuva on liian suuri (${(originalSize / 1024 / 1024).toStringAsFixed(1)} MB) eikä sitä voitu optimoida.');
      }

      // Jos kuva on alle 3MB, voidaan käyttää alkuperäistä hätätapauksessa
      return await imageFile.readAsBytes();
    }
  }

  /// Lisää uuden ruokailmoituksen Firestoreen.
  Future<void> addFoodItem(
    FoodItem item,
    File imageFile, {
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
    List<File> imageFiles, {
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

        final String fileName = '${item.id}_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage.ref().child('$_storageImagesPath/$fileName');

        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        );

        final UploadTask uploadTask = ref.putData(compressedImage, metadata);

        StreamSubscription<TaskSnapshot>? uploadSubscription;
        uploadSubscription = uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
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

        await uploadSubscription?.cancel();

        final String imageUrl = await snapshot.ref.getDownloadURL().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw Exception('Kuvan ${i + 1} URL:n hakeminen kesti liian kauan.');
          },
        );

        imageUrls.add(imageUrl);
      }

      // 2. Päivitä FoodItem-olio kuvien URL:illa
      final String primaryImageUrl = imageUrls.isNotEmpty ? imageUrls.first : '';
      final List<String> additionalImageUrls = imageUrls.length > 1 ? imageUrls.sublist(1) : [];

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
        isReserved: item.isReserved,
        reservedByUserId: item.reservedByUserId,
      );

      // 3. Tallenna Firestoreen
      await _firestore
          .collection(_collectionFood)
          .doc(item.id)
          .set(itemWithImages.toMap())
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tietojen tallennus kesti liian kauan.');
        },
      );

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

  /// Poistaa ruokailmoituksen
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

  /// Merkitsee ilmoituksen varatuksi
  Future<void> reserveFoodItem(String itemId, String userId) async {
    try {
      await _firestore.collection(_collectionFood).doc(itemId).update({
        'isReserved': true,
        'reservedByUserId': userId,
      });
      if (kDebugMode) {
        print('✅ Ilmoitus merkitty varatuksi');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Varauksen merkitseminen epäonnistui: $e');
      }
      rethrow;
    }
  }

  /// Poistaa varauksen
  Future<void> unreserveFoodItem(String itemId) async {
    try {
      await _firestore.collection(_collectionFood).doc(itemId).update({
        'isReserved': false,
        'reservedByUserId': null,
      });
      if (kDebugMode) {
        print('✅ Varaus poistettu');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Varauksen poisto epäonnistui: $e');
      }
      rethrow;
    }
  }

  /// Päivittää ruokailmoituksen tiedot
  Future<void> updateFoodItem(
    FoodItem item, {
    File? newImageFile,
    Function(double)? onProgress,
  }) async {
    try {
      String imageUrl = item.imageUrl;

      if (newImageFile != null) {
        if (kDebugMode) {
          print('Optimoidaan uusi kuva...');
        }
        final Uint8List compressedImage = await _compressImage(newImageFile);

        final String fileName = '${item.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage.ref().child('$_storageImagesPath/$fileName');

        final SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public, max-age=31536000',
        );

        final UploadTask uploadTask = ref.putData(compressedImage, metadata);

        StreamSubscription<TaskSnapshot>? uploadSubscription;
        uploadSubscription = uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (onProgress != null) {
            onProgress(progress);
          }
        });

        final TaskSnapshot snapshot = await uploadTask.timeout(
          const Duration(seconds: 60),
          onTimeout: () {
            uploadSubscription?.cancel();
            throw Exception('Kuvan lataus kesti liian kauan. Tarkista internetyhteys.');
          },
        );

        await uploadSubscription?.cancel();

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
        isReserved: item.isReserved,
        reservedByUserId: item.reservedByUserId,
      );

      await _firestore
          .collection(_collectionFood)
          .doc(item.id)
          .update(updatedItem.toMap())
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Tietojen päivitys kesti liian kauan.');
        },
      );

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