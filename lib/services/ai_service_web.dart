import 'package:image_picker/image_picker.dart';
import '../models/food_item.dart';

/// Abstract base class or interface for AI Service
abstract class AIServiceImplementation {
  // Keep this interface definition here or move it?
  // Should essentially be compatible with both implementations.
  Future<FoodRecognitionResult?> recognizeFood(XFile imageFile);
}

/// Web implementation (Stub)
class AIServiceImpl implements AIServiceImplementation {
  @override
  Future<FoodRecognitionResult?> recognizeFood(XFile imageFile) async {
    // ML Kit is not supported on Web
    return null;
  }
}
