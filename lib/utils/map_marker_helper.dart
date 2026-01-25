import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/food_item.dart';
import 'category_helper.dart';

/// Helper-luokka kartan markkereiden luomiseen Flutter Mapille
class MapMarkerHelper {
  /// Luo markkerit listasta FoodItemeja
  static List<Marker> createMarkersFromFoodItems(
    List<FoodItem> items, {
    Function(String foodItemId)? onMarkerTap,
  }) {
    final List<Marker> markers = [];

    for (var item in items) {
      if (item.latitude != 0.0 &&
          item.longitude != 0.0 &&
          item.latitude.isFinite &&
          item.longitude.isFinite &&
          item.status == ReservationStatus.available) {
        markers.add(
          Marker(
            width: 40.0,
            height: 40.0,
            point: LatLng(item.latitude, item.longitude),
            child: GestureDetector(
              onTap: onMarkerTap != null ? () => onMarkerTap(item.id) : null,
              child: _buildCategoryMarker(item.category),
            ),
          ),
        );
      }
    }

    return markers;
  }

  static Widget _buildCategoryMarker(FoodCategory category) {
    // Use CategoryHelper for consistent colors across the app
    final color = CategoryHelper.getCategoryColor(category);
    final iconData = CategoryHelper.getCategoryIcon(category);

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
