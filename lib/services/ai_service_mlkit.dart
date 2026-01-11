import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/food_item.dart';

/// Tekoäly-palvelu kuvan tunnistamiseen ML Kit:llä
/// 
/// ILMAINEN vaihtoehto Google Vision API:lle
/// - Toimii offline (ei tarvitse internettiä)
/// - Ei tarvitse API-avainta
/// - Ei kiintiöitä
class AIServiceMLKit {
  /// Tunnistaa ruoan kuvasta ML Kit:llä
  Future<FoodRecognitionResult?> recognizeFood(File imageFile) async {
    try {
      if (kDebugMode) {
        print('🔍 Aloitetaan kuvan tunnistus ML Kit:llä (ilmainen, offline)...');
      }
      
      // 1. Lataa kuva
      final inputImage = InputImage.fromFile(imageFile);
      
      // 2. Luo image labeler (luottamusraja 0.5 = 50%)
      final imageLabeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.5),
      );
      
      // 3. Tunnista kuvasta
      if (kDebugMode) {
        print('📡 Tunnistetaan kuvaa...');
      }
      final labels = await imageLabeler.processImage(inputImage);
      
      // 4. Sulje labeler (tärkeää muistin kannalta)
      await imageLabeler.close();
      
      if (labels.isEmpty) {
        if (kDebugMode) {
          print('⚠️ Ei tunnistettu mitään kuvasta');
        }
        return null;
      }
      
      if (kDebugMode) {
        print('✅ Tunnistettu ${labels.length} labelia');
      }
      
      // 5. Etsi ruoka-aiheisia labeleita
      String? foodLabel;
      double maxScore = 0.0;
      
      for (var label in labels) {
        final description = label.label.toLowerCase();
        final score = label.confidence;
        
        if (kDebugMode) {
          print('  - ${label.label} (${(score * 100).toStringAsFixed(1)}%)');
        }
        
        // Tarkista onko ruoka-aiheinen
        if (_isFoodRelated(description) && score > maxScore) {
          foodLabel = label.label;
          maxScore = score;
        }
      }
      
      // 6. Jos ei löydy ruokaa, käytä ensimmäistä labelia
      if (foodLabel == null && labels.isNotEmpty) {
        foodLabel = labels[0].label;
        if (kDebugMode) {
          print('ℹ️ Ruokaa ei löytynyt, käytetään ensimmäistä labelia: $foodLabel');
        }
      }
      
      // 7. Määritä kategoria ja käännä suomeksi
      FoodCategory category = _determineCategory(foodLabel ?? '');
      String title = _translateToFinnish(foodLabel ?? 'Ruokaa');
      
      if (kDebugMode) {
        print('✅ Ruoka tunnistettu: $title (${category.displayName})');
      }
      
      return FoodRecognitionResult(
        title: title,
        description: 'Automaattisesti tunnistettu: $title',
        category: category,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ ML Kit -tunnistus epäonnistui: $e');
      }
      return null;
    }
  }

  /// Tarkistaa onko label ruoka-aiheinen
  bool _isFoodRelated(String description) {
    final foodKeywords = [
      'food', 'ruoka', 'bread', 'leipä', 'fruit', 'hedelmä',
      'vegetable', 'vihannes', 'meal', 'dish', 'cuisine',
      'bakery', 'leivonnainen', 'apple', 'omena', 'banana',
      'tomato', 'tomaatti', 'salad', 'salaatti', 'cake',
      'kakku', 'cookie', 'keksi', 'pasta', 'pizza',
      'sandwich', 'voileipä', 'soup', 'keitto', 'rice',
      'riisi', 'potato', 'peruna', 'carrot', 'porkkana',
      'banana', 'banaani', 'orange', 'appelsiini', 'strawberry',
      'mansikka', 'grape', 'viinirypäle', 'cherry', 'kirsikka',
    ];
    
    return foodKeywords.any((keyword) => description.contains(keyword));
  }

  /// Määrittää kategorian labelin perusteella
  FoodCategory _determineCategory(String label) {
    final lowerLabel = label.toLowerCase();
    
    // Leivonnaiset
    if (lowerLabel.contains('bread') || 
        lowerLabel.contains('leipä') || 
        lowerLabel.contains('bakery') ||
        lowerLabel.contains('leivonnainen') ||
        lowerLabel.contains('cake') ||
        lowerLabel.contains('kakku') ||
        lowerLabel.contains('cookie') ||
        lowerLabel.contains('keksi') ||
        lowerLabel.contains('pastry') ||
        lowerLabel.contains('muffin')) {
      return FoodCategory.leivonnaiset;
    }
    
    // Hedelmät
    if (lowerLabel.contains('fruit') || 
        lowerLabel.contains('hedelmä') ||
        lowerLabel.contains('apple') ||
        lowerLabel.contains('omena') ||
        lowerLabel.contains('banana') ||
        lowerLabel.contains('banaani') ||
        lowerLabel.contains('orange') ||
        lowerLabel.contains('appelsiini') ||
        lowerLabel.contains('strawberry') ||
        lowerLabel.contains('mansikka') ||
        lowerLabel.contains('grape') ||
        lowerLabel.contains('viinirypäle') ||
        lowerLabel.contains('cherry') ||
        lowerLabel.contains('kirsikka')) {
      return FoodCategory.hedelmat;
    }
    
    // Vihannekset
    if (lowerLabel.contains('vegetable') || 
        lowerLabel.contains('vihannes') ||
        lowerLabel.contains('tomato') ||
        lowerLabel.contains('tomaatti') ||
        lowerLabel.contains('salad') ||
        lowerLabel.contains('salaatti') ||
        lowerLabel.contains('carrot') ||
        lowerLabel.contains('porkkana') ||
        lowerLabel.contains('potato') ||
        lowerLabel.contains('peruna') ||
        lowerLabel.contains('onion') ||
        lowerLabel.contains('sipuli') ||
        lowerLabel.contains('pepper') ||
        lowerLabel.contains('paprika')) {
      return FoodCategory.vihannekset;
    }
    
    return FoodCategory.muut;
  }

  /// Yksinkertainen käännös englanniksi -> suomeksi
  String _translateToFinnish(String englishLabel) {
    final translations = {
      'bread': 'Leipää',
      'fruit': 'Hedelmää',
      'apple': 'Omenoita',
      'banana': 'Banaaneja',
      'vegetable': 'Vihanneksia',
      'tomato': 'Tomaatteja',
      'salad': 'Salaattia',
      'cake': 'Kakkua',
      'cookie': 'Keksejä',
      'pasta': 'Pastaa',
      'pizza': 'Pizzaa',
      'sandwich': 'Voileipää',
      'soup': 'Keittoa',
      'rice': 'Riisiä',
      'potato': 'Perunoita',
      'carrot': 'Porkkanoita',
      'food': 'Ruokaa',
      'meal': 'Ruokaa',
      'dish': 'Ruokaa',
      'orange': 'Appelsiineja',
      'strawberry': 'Mansikoita',
      'grape': 'Viinirypäleitä',
      'cherry': 'Kirsikoita',
    };

    final lowerLabel = englishLabel.toLowerCase();
    
    // Tarkista onko suora käännös
    for (var entry in translations.entries) {
      if (lowerLabel.contains(entry.key)) {
        return entry.value;
      }
    }

    // Jos ei löydy käännöstä, palauta alkuperäinen (voi olla jo suomeksi)
    return englishLabel;
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
