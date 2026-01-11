import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Widget karttanäkymälle
class HomeMapWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final Position? userPosition;
  final Function(GoogleMapController) onMapCreated;
  final double sheetSize;
  final MapType mapType;
  final Set<Marker> markers;

  const HomeMapWidget({
    super.key,
    required this.mapController,
    required this.userPosition,
    required this.onMapCreated,
    required this.sheetSize,
    this.mapType = MapType.normal,
    this.markers = const {},
  });

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(60.1699, 24.9384),
    zoom: 12.0,
  );

  @override
  Widget build(BuildContext context) {
    final opacity = sheetSize > 0.7 ? 0.0 : 1.0;
    
    return Opacity(
      opacity: opacity,
      child: GoogleMap(
        key: const ValueKey('main_map'),
        mapType: mapType,
        initialCameraPosition: userPosition != null
            ? CameraPosition(
                target: LatLng(userPosition!.latitude, userPosition!.longitude),
                zoom: 14.0,
              )
            : _initialPosition,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        markers: markers,
        onMapCreated: onMapCreated,
      ),
    );
  }
}
