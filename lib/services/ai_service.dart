import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/food_item.dart';

/// Tekoäly-palvelu kuvan tunnistamiseen
/// 
/// Käyttää Google Cloud Vision API:ta ruoan tunnistamiseen
class AIService {
  /// Hae API-avain .env-tiedostosta
  static String? get _apiKey {
    // Tarkista että dotenv on alustettu
    if (!dotenv.isInitialized) {
      if (kDebugMode) {
        print('⚠️ dotenv ei ole alustettu! Tarkista että .env-tiedosto on oikeassa paikassa.');
      }
      return null;
    }
    return dotenv.env['GOOGLE_VISION_API_KEY'];
  }
  static const String _apiUrl = 'https://vision.googleapis.com/v1/images:annotate';

  /// Tunnistaa ruoan kuvasta Google Vision API:lla
  Future<FoodRecognitionResult?> recognizeFood(File imageFile) async {
    // Tarkista että dotenv on alustettu
    if (!dotenv.isInitialized) {
      if (kDebugMode) {
        print('⚠️ dotenv ei ole alustettu! Tarkista että .env-tiedosto on projektin juuressa.');
      }
      return null;
    }
    
    if (_apiKey == null || _apiKey!.isEmpty || _apiKey == 'YOUR_API_KEY_HERE') {
      if (kDebugMode) {
        print('⚠️ Google Vision API-avain puuttuu! Lisää GOOGLE_VISION_API_KEY .env-tiedostoon.');
      }
      return null;
    }

    try {
      if (kDebugMode) {
        print('🔍 Aloitetaan kuvan tunnistus...');
      }
      
      // 1. Muunna kuva base64:ksi
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      if (kDebugMode) {
        print('✅ Kuva muunnettu base64:ksi (${imageBytes.length} tavua)');
      }

      // 2. Lähetä API-kutsu Google Vision API:lle
      if (kDebugMode) {
        print('📡 Lähetetään API-kutsu Google Vision API:lle...');
      }
      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requests': [
            {
              'image': {
                'content': base64Image,
              },
              'features': [
                {
                  'type': 'LABEL_DETECTION',
                  'maxResults': 10,
                },
              ],
            },
          ],
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('API-kutsu aikakatkaistiin (15s)');
        },
      );

      if (kDebugMode) {
        print('📥 Vastaus saatu: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ Vastaus parsittu onnistuneesti');
        }
        final result = _parseGoogleVisionResponse(data);
        if (result != null) {
          if (kDebugMode) {
            print('✅ Ruoka tunnistettu: ${result.title} (${result.category.displayName})');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ Ruokaa ei tunnistettu vastauksesta');
          }
        }
        return result;
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          print('❌ API-virhe: ${response.statusCode}');
          print('❌ Virheilmoitus: $errorBody');
        }
        throw Exception('API-virhe: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      // Jos API-kutsu epäonnistuu, palauta null (käyttäjä täyttää manuaalisesti)
      if (kDebugMode) {
        print('❌ Tekoäly-tunnistus epäonnistui: $e');
      }
      return null;
    }
  }

  /// Parsii Google Vision API -vastauksen FoodRecognitionResult-olioksi
  FoodRecognitionResult? _parseGoogleVisionResponse(Map<String, dynamic> data) {
    try {
      final responses = data['responses'] as List?;
      if (responses == null || responses.isEmpty) {
        return null;
      }

      final response = responses[0] as Map<String, dynamic>;
      final labels = response['labelAnnotations'] as List?;

      if (labels == null || labels.isEmpty) {
        return null;
      }

      // Etsi ruoka-aiheisia labeleita
      String? foodLabel;
      double maxScore = 0.0;

      for (var label in labels) {
        final description = (label['description'] as String? ?? '').toLowerCase();
        final score = (label['score'] as num? ?? 0.0).toDouble();

        // Tarkista onko ruoka-aiheinen
        if (_isFoodRelated(description) && score > maxScore) {
          foodLabel = label['description'] as String;
          maxScore = score;
        }
      }

      // Jos ei löydy ruokaa, käytä ensimmäistä labelia (vaikka se ei olisi ruokaa)
      if (foodLabel == null && labels.isNotEmpty) {
        foodLabel = labels[0]['description'] as String;
        if (kDebugMode) {
          print('ℹ️ Ruokaa ei löytynyt, käytetään ensimmäistä labelia: $foodLabel');
        }
      }

      // Määritä kategoria
      FoodCategory category = _determineCategory(foodLabel ?? '');

      // Muunna otsikko suomeksi jos mahdollista
      String title = _translateToFinnish(foodLabel ?? 'Ruokaa');

      return FoodRecognitionResult(
        title: title,
        description: 'Automaattisesti tunnistettu: $title',
        category: category,
      );
    } catch (e) {
      print('Vastauksen parsiminen epäonnistui: $e');
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
        lowerLabel.contains('keksi')) {
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
        lowerLabel.contains('appelsiini')) {
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
        lowerLabel.contains('peruna')) {
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

  /// Yksinkertainen mock-toteutus testausta varten
  /// Tunnistaa perusruokia kuvien perusteella (ei oikeaa API-kutsua)
  Future<FoodRecognitionResult?> recognizeFoodMock(File imageFile) async {
    // Simuloi API-kutsua
    await Future.delayed(const Duration(seconds: 1));

    // Esim. käyttäen google_ml_kit tai muuta ML-kirjastoa

    // Palauta mock-tulos
    return FoodRecognitionResult(
      title: 'Automaattisesti tunnistettu ruoka',
      description: 'Tekoäly tunnisti ruoan kuvasta. Voit muokata tietoja tarpeen mukaan.',
      category: FoodCategory.muut,
    );
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
