import 'dart:async';
import 'dart:math' as math;
import '../models/food_item.dart';

/// Helper for advanced search and filtering with debouncing
class SearchHelper {
  static Timer? _debounceTimer;

  /// Debounced search - waits for user to stop typing before executing
  static void debounceSearch({
    required String query,
    required Function(String) onSearch,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () => onSearch(query));
  }

  /// Search items across multiple fields
  /// Searches in: title, description, category name, and dietary tags
  static List<FoodItem> searchItems(
    List<FoodItem> items,
    String query,
  ) {
    if (query.isEmpty) return items;

    final lowerQuery = query.toLowerCase();

    return items.where((item) {
      // Search in title
      if (item.title.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in description
      if (item.description.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in category name
      if (item.category.displayName.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      // Search in dietary tags
      if (item.dietaryTags
          .any((tag) => tag.toLowerCase().contains(lowerQuery))) {
        return true;
      }

      // Search in user name (who shared the food)
      if (item.userName != null &&
          item.userName!.toLowerCase().contains(lowerQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Filter items by category
  static List<FoodItem> filterByCategory(
    List<FoodItem> items,
    FoodCategory? category,
  ) {
    if (category == null) return items;
    return items.where((item) => item.category == category).toList();
  }

  /// Filter items by dietary tags
  static List<FoodItem> filterByTags(
    List<FoodItem> items,
    List<String> selectedTags,
  ) {
    if (selectedTags.isEmpty) return items;

    return items.where((item) {
      // Item must have ALL selected tags
      return selectedTags.every((tag) => item.dietaryTags.contains(tag));
    }).toList();
  }

  /// Filter items by price (free only)
  static List<FoodItem> filterByFree(
    List<FoodItem> items,
    bool freeOnly,
  ) {
    if (!freeOnly) return items;
    return items
        .where((item) => item.price == null || item.price == 0)
        .toList();
  }

  /// Filter items by distance
  static List<FoodItem> filterByDistance(
    List<FoodItem> items,
    double? maxDistanceKm,
    double? userLat,
    double? userLon,
  ) {
    if (maxDistanceKm == null || userLat == null || userLon == null) {
      return items;
    }

    return items.where((item) {
      final distance = _calculateDistance(
        userLat,
        userLon,
        item.latitude,
        item.longitude,
      );
      return distance <= maxDistanceKm;
    }).toList();
  }

  /// Calculate distance between two points in kilometers
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Dispose timer when no longer needed
  static void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
