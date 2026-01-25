import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Widget karttanäkymälle (Mapbox via flutter_map)
class HomeMapWidget extends StatelessWidget {
  final MapController mapController;
  final Position? userPosition;
  final Function(MapController) onMapCreated;
  final double sheetSize;
  final bool isDarkTheme; // Käytetään Mapbox-teeman vaihtoon
  final List<Marker> markers;

  // CartoDB styles (Free and high quality)
  static const String _cartoLight =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const String _cartoDark =
      'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}{r}.png';

  const HomeMapWidget({
    super.key,
    required this.mapController,
    required this.userPosition,
    required this.onMapCreated,
    required this.sheetSize,
    required this.isDarkTheme,
    this.markers = const [],
  });

  @override
  Widget build(BuildContext context) {
    final opacity = sheetSize > 0.7 ? 0.0 : 1.0;
    final urlTemplate = isDarkTheme ? _cartoDark : _cartoLight;

    return Opacity(
      opacity: opacity,
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: userPosition != null
              ? LatLng(userPosition!.latitude, userPosition!.longitude)
              : const LatLng(60.1699, 24.9384), // Helsinki default
          initialZoom: 13.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
          onMapReady: () => onMapCreated(mapController),
        ),
        children: [
          TileLayer(
            urlTemplate: urlTemplate,
            subdomains: const ['a', 'b', 'c', 'd'],
            userAgentPackageName: 'com.example.naapurisapuska',
          ),
          MarkerLayer(markers: markers),
          // User Location Marker
          if (userPosition != null)
            MarkerLayer(
              markers: [
                Marker(
                  width: 20.0,
                  height: 20.0,
                  point:
                      LatLng(userPosition!.latitude, userPosition!.longitude),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
