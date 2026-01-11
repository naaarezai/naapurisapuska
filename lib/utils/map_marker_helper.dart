import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/food_item.dart';

/// Helper-luokka kartan markkereiden luomiseen
class MapMarkerHelper {
  /// Luo marker-ikonin kategorian perusteella
  /// 
  /// Värikoodaus:
  /// - Hedelmät: Punainen (🍎)
  /// - Leivonnaiset: Keltainen (🥐)
  /// - Vihannekset: Vihreä (🥕)
  /// - Muut: Sininen (📦)
  static Future<BitmapDescriptor> getCategoryMarkerIcon(FoodCategory category) async {
    switch (category) {
      case FoodCategory.hedelmat:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case FoodCategory.leivonnaiset:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      case FoodCategory.vihannekset:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case FoodCategory.muut:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }

  /// Luo Marker-olion FoodItem:sta
  static Future<Marker> createMarkerFromFoodItem(
    FoodItem item, {
    VoidCallback? onTap,
    Position? userPosition,
  }) async {
    final icon = await getCategoryMarkerIcon(item.category);
    
    // Rakenna InfoWindow-teksti
    String snippet = '';
    
    // Hinta
    if (item.price != null) {
      snippet += '€${item.price!.toStringAsFixed(2)}';
    } else {
      snippet += 'Ilmainen';
    }
    
    // Määrä
    if (item.quantity != null && item.quantityUnit != null) {
      snippet += ' • ${item.quantity!.toStringAsFixed(1)} ${item.quantityUnit}';
    }
    
    // Etäisyys
    if (userPosition != null) {
      final distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        item.latitude,
        item.longitude,
      );
      if (distance < 1000) {
        snippet += '\n${distance.toInt()}m päässä';
      } else {
        snippet += '\n${(distance / 1000).toStringAsFixed(1)}km päässä';
      }
    }
    
    return Marker(
      markerId: MarkerId(item.id),
      position: LatLng(item.latitude, item.longitude),
      icon: icon,
      infoWindow: InfoWindow(
        title: item.title,
        snippet: snippet,
      ),
      onTap: onTap,
    );
  }

  /// Luo markkerit listasta FoodItemeja
  static Future<Set<Marker>> createMarkersFromFoodItems(
    List<FoodItem> items, {
    Function(String foodItemId)? onMarkerTap,
    Position? userPosition,
  }) async {
    final Set<Marker> markers = {};
    
    for (var item in items) {
      // Suodata pois nollakoordinaatit ja varatut
      if (item.latitude != 0.0 && 
          item.longitude != 0.0 &&
          item.latitude.isFinite &&
          item.longitude.isFinite &&
          !item.isReserved) {
        final marker = await createMarkerFromFoodItem(
          item,
          onTap: onMarkerTap != null ? () => onMarkerTap(item.id) : null,
          userPosition: userPosition,
        );
        markers.add(marker);
      }
    }
    
    return markers;
  }
}
