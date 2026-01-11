import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_food_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'food_detail_screen.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/chat_service.dart';
import '../widgets/food_card.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/home_map_widget.dart';
import '../widgets/home_list_widget.dart';
import 'chat_list_screen.dart';
import '../utils/error_helper.dart';
import '../utils/map_marker_helper.dart';
import '../utils/haptic_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final ChatService _chatService = ChatService();
  
  final _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Position? _userPosition;
  FoodCategory? _selectedCategory;
  double? _maxDistance;
  StreamSubscription<Position>? _positionStream;
  bool _isLocationLoading = true;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  final DraggableScrollableController _draggableController = DraggableScrollableController();
  MapType _mapType = MapType.normal;
  Set<Marker> _markers = {};
  List<String> _lastMarkerIds = [];

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(60.1699, 24.9384),
    zoom: 12.0,
  );

  @override
  void initState() {
    super.initState();
    // KORJAUS: Käynnistetään alustusketju, joka kysyy luvat vuorotellen
    _initAppSequence();
    
    _searchController.addListener(() {
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.toLowerCase();
          });
        }
      });
    });
  }

  // UUSI METODI: Hoitaa luvat järjestyksessä
  Future<void> _initAppSequence() async {
    // 1. Pyydä ensin ilmoituslupa
    await _notificationService.initialize();
    
    if (!mounted) return;

    // 2. Pieni tauko, jotta käyttöjärjestelmä ehtii toipua edellisestä dialogista
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    // 3. Vasta nyt pyydetään sijaintilupa ja aloitetaan seuranta
    await _startLocationTracking();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _positionStream?.cancel();
    _mapController?.dispose();
    _searchDebounceTimer?.cancel();
    _draggableController.dispose();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLocationLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLocationLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLocationLoading = false);
        return;
      }

      // Hae ensimmäinen sijainti
      final initialPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (mounted) {
        setState(() {
          _userPosition = initialPosition;
          _isLocationLoading = false;
        });
        
        // Tallenna sijainti heti Firestoreen!
        _notificationService.updateUserLocation(initialPosition);
        
        // Keskitä kartta
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(initialPosition.latitude, initialPosition.longitude),
            14.0,
          ),
        );
      }

      // Aloita seuranta
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium, 
          distanceFilter: 200, 
        ),
      ).listen(
        (Position position) {
          if (mounted) {
            // Päivitetään jos sijainti muuttuu merkittävästi
            if (_userPosition == null || 
                Geolocator.distanceBetween(
                  _userPosition!.latitude,
                  _userPosition!.longitude,
                  position.latitude,
                  position.longitude,
                ) > 100) { 
              setState(() {
                _userPosition = position;
              });
              // Päivitä Firestoreen kun liikutaan
              _notificationService.updateUserLocation(position);
            }
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isLocationLoading = false);
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<void> _centerMapOnUser() async {
    if (_userPosition == null || _mapController == null) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        if (mounted) {
          setState(() {
            _userPosition = position;
          });
          // Päivitetään myös tässä napista painaessa
          _notificationService.updateUserLocation(position);
          
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(position.latitude, position.longitude),
              14.0,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sijaintia ei voitu hakea. Tarkista GPS-asetukset.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
      return;
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(_userPosition!.latitude, _userPosition!.longitude),
        14.0,
      ),
    );
  }

  String? _calculateDistance(FoodItem item) {
    if (_userPosition == null) return null;
    
    final distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      item.latitude,
      item.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  List<FoodItem> _filterItems(List<FoodItem> items) {
    var filtered = items;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final title = item.title.toLowerCase();
        final description = item.description.toLowerCase();
        final category = item.category.displayName.toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || 
               description.contains(query) || 
               category.contains(query);
      }).toList();
    }

    if (_selectedCategory != null) {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    if (_maxDistance != null && _userPosition != null) {
      filtered = filtered.where((item) {
        final distance = Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          item.latitude,
          item.longitude,
        );
        return (distance / 1000) <= _maxDistance!;
      }).toList();
    }

    filtered = filtered.where((item) => !item.isReserved).toList();

    return filtered;
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        selectedCategory: _selectedCategory,
        maxDistance: _maxDistance,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result['category'] as FoodCategory?;
        _maxDistance = result['maxDistance'] as double?;
      });
    }
  }

  Future<void> _updateMarkers(List<FoodItem> items, List<FoodItem> allItems) async {
    final currentIds = items
        .where((item) => 
            item.latitude != 0.0 && 
            item.longitude != 0.0 &&
            item.latitude.isFinite &&
            item.longitude.isFinite &&
            !item.isReserved)
        .map((item) => item.id)
        .toList()
      ..sort();
    
    if (_lastMarkerIds.length == currentIds.length &&
        _lastMarkerIds.every((id) => currentIds.contains(id))) {
      return;
    }
    
    final markers = await MapMarkerHelper.createMarkersFromFoodItems(
      items,
      onMarkerTap: (String foodItemId) {
        _handleMarkerTap(foodItemId, allItems);
      },
      userPosition: _userPosition,
    );
    if (mounted) {
      setState(() {
        _markers = markers;
        _lastMarkerIds = currentIds;
      });
    }
  }

  void _handleMarkerTap(String foodItemId, List<FoodItem> allItems) {
    HapticHelper.selectionClick();
    
    final item = allItems.firstWhere(
      (item) => item.id == foodItemId,
      orElse: () => allItems.first,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodItem: item,
          userPosition: _userPosition,
        ),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    final errorMessage = ErrorHelper.getUserFriendlyErrorMessage(error);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text('Virhe tietojen lataamisessa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(errorMessage, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Yritä uudelleen'),
            ),
          ],
        ),
      ),
    );
  }

  void _animateTo(double targetSize) {
      _draggableController.animateTo(
        targetSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naapurisapuska'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_selectedCategory != null || _maxDistance != null)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFFF6F00), shape: BoxShape.circle)),
                  ),
              ],
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Suodata',
          ),
          PopupMenuButton<MapType>(
            icon: const Icon(Icons.map),
            tooltip: 'Kartan tyyli',
            onSelected: (MapType type) {
              setState(() {
                _mapType = type;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: MapType.normal, child: Row(children: [Icon(Icons.map, size: 20), SizedBox(width: 8), Text('Normaali')])),
              const PopupMenuItem(value: MapType.satellite, child: Row(children: [Icon(Icons.satellite, size: 20), SizedBox(width: 8), Text('Satelliitti')])),
              const PopupMenuItem(value: MapType.terrain, child: Row(children: [Icon(Icons.terrain, size: 20), SizedBox(width: 8), Text('Maasto')])),
            ],
          ),
          // --- CHAT IKONI BADGELLA ---
          StreamBuilder<int>(
            stream: _chatService.getTotalUnreadCount(),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;
              return IconButton(
                icon: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text(
                    unreadCount > 99 ? '99+' : '$unreadCount',
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                tooltip: 'Viestit',
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListScreen()));
                  }
                },
              );
            },
          ),
          IconButton(
            icon: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                return Icon(snapshot.data != null ? Icons.account_circle : Icons.login);
              },
            ),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              }
            },
            tooltip: 'Kirjaudu',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Hae ruokaa...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => _searchController.clear())
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<FoodItem>>(
        stream: _databaseService.getFoodItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Ladataan ilmoituksia...', style: TextStyle(color: Colors.grey))]));
          }
          
          if (_isLocationLoading) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(), const SizedBox(height: 16), const Text('Haetaan sijaintia...', style: TextStyle(color: Colors.grey))]));
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error);
          }

          final allFoodItems = snapshot.data ?? [];
          var foodItems = _filterItems(allFoodItems);
          
          if (_userPosition != null) {
            foodItems.sort((a, b) {
              final distA = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, a.latitude, a.longitude);
              final distB = Geolocator.distanceBetween(_userPosition!.latitude, _userPosition!.longitude, b.latitude, b.longitude);
              return distA.compareTo(distB);
            });
          }
          
          _updateMarkers(foodItems, allFoodItems);

          final minChildSize = 0.15;
          final maxChildSize = 0.95;
          final initialChildSize = 0.35;

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _draggableController,
                builder: (context, child) {
                  final sheetSize = _draggableController.isAttached ? _draggableController.size : 0.35;
                  return HomeMapWidget(
                    mapController: _mapController,
                    userPosition: _userPosition,
                    onMapCreated: (GoogleMapController controller) {
                      if (mounted) {
                        _mapController = controller;
                        if (_userPosition != null) {
                          controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(_userPosition!.latitude, _userPosition!.longitude), 14.0));
                        }
                      }
                    },
                    sheetSize: sheetSize,
                    mapType: _mapType,
                    markers: _markers,
                  );
                },
              ),
              Positioned(
                right: 16,
                bottom: 120,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      heroTag: "zoom_in",
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                      child: const Icon(Icons.add, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      heroTag: "zoom_out",
                      mini: true,
                      backgroundColor: Colors.white,
                      onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                      child: const Icon(Icons.remove, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              if (_userPosition != null)
                AnimatedBuilder(
                  animation: _draggableController,
                  builder: (context, child) {
                    final sheetSize = _draggableController.isAttached ? _draggableController.size : 0.35;
                    final bottom = sheetSize > 0.7 ? -100.0 : 320.0;
                    return Positioned(
                      bottom: bottom,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        backgroundColor: Colors.white,
                        onPressed: _centerMapOnUser,
                        child: const Icon(Icons.my_location, color: Color(0xFF2E7D32)),
                      ),
                    );
                  },
                ),
              DraggableScrollableSheet(
                controller: _draggableController,
                initialChildSize: initialChildSize,
                minChildSize: minChildSize,
                maxChildSize: maxChildSize,
                snap: true,
                snapSizes: const [0.15, 0.95],
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onVerticalDragUpdate: (details) {
                            double delta = details.primaryDelta! / MediaQuery.of(context).size.height;
                            double newSize = _draggableController.size - delta;
                            _draggableController.jumpTo(newSize.clamp(0.15, 0.95));
                          },
                          onVerticalDragEnd: (details) {
                            const double velocityThreshold = -300.0;
                            if (details.primaryVelocity! < -velocityThreshold) {
                              _animateTo(0.95);
                            } else if (details.primaryVelocity! > velocityThreshold) {
                              _animateTo(0.15);
                            } else {
                              if (_draggableController.size > 0.55) {
                                _animateTo(0.95);
                              } else {
                                _animateTo(0.15);
                              }
                            }
                          },
                          onTap: () {
                            if (_draggableController.size < 0.5) {
                              _animateTo(0.95);
                            } else {
                              _animateTo(0.15);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      const Text('Lähellä sinua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          if (_userPosition != null) ...[
                                            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                          ],
                                          Text('${foodItems.length} ilmoitusta', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: HomeListWidget(
                            foodItems: foodItems,
                            userPosition: _userPosition,
                            scrollController: scrollController,
                            onRefresh: () async {
                              // Päivitetään sijainti myös manuaalisesti vetämällä listaa alas
                              if (_userPosition != null) {
                                _notificationService.updateUserLocation(_userPosition!);
                              }
                            },
                            onEmptyStateAction: () {
                              if (_selectedCategory != null || _maxDistance != null) {
                                _showFilterDialog();
                              } else {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFoodScreen()));
                              }
                            },
                            hasFilters: _selectedCategory != null || _maxDistance != null,
                            calculateDistance: _calculateDistance,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFoodScreen()));
        },
        label: const Text('Jaa ruokaa'),
        icon: const Icon(Icons.add_a_photo),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}