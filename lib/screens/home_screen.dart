import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Flutter Map
import 'package:latlong2/latlong.dart'; // LatLng for Flutter Map
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For DocumentSnapshot
import '../l10n/app_localizations.dart';

import 'add_food_screen.dart';
import 'login_screen.dart';
import 'chat_list_screen.dart';
import 'profile_screen.dart';
import 'notification_screen.dart';
import '../services/chat_service.dart';
import 'food_detail_screen.dart';
import '../models/food_item.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/home_map_widget.dart';
import '../widgets/home_bottom_sheet.dart';
import '../widgets/desktop_side_panel.dart'; // Add this
import '../utils/error_helper.dart';
import '../utils/map_marker_helper.dart';
import '../utils/haptic_helper.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final DatabaseService _databaseService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  final _searchController = TextEditingController();
  final MapController _mapController = MapController();
  Position? _userPosition;
  FoodCategory? _selectedCategory;
  double? _maxDistance;
  List<String>? _selectedTags;
  StreamSubscription<List<FoodItem>>? _foodItemsSubscription;
  List<FoodItem> _foodItems = [];
  bool _isLoadingFood = true;

  // Pagination state
  DocumentSnapshot? _lastDocument;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;
  final int _itemsPerPage = 20;

  StreamSubscription<Position>? _positionStream;
  bool _isLocationLoading = true;
  String _searchQuery = '';
  Timer? _searchDebounceTimer;
  // Mapbox doesn't support "MapType" in the same way, we toggle themes
  bool _isDarkMapTheme = false;
  List<Marker> _markers = [];
  List<String> _lastMarkerIds = [];

  final GlobalKey<HomeBottomSheetState> _bottomSheetKey = GlobalKey();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _initAppSequence();
    _loadLastViewedTime(); // Load persisted time
    _subscribeToFoodItems();

    _searchController.addListener(() {
      _searchDebounceTimer?.cancel();
      _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _searchQuery = _searchController.text.toLowerCase();
          });
          _updateView();
        }
      });
    });

    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        // Viive jotta näppäimistö ehtii alkaa nousta
        Future.delayed(const Duration(milliseconds: 100), () {
          _bottomSheetKey.currentState?.expandSheet();
        });
      }
    });
  }

  Future<void> _initAppSequence() async {
    await _notificationService.initialize();
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await _startLocationTracking();
  }

  void _subscribeToFoodItems() async {
    _foodItemsSubscription?.cancel();
    if (_foodItems.isEmpty) {
      if (mounted) setState(() => _isLoadingFood = true);
    }

    try {
      // Get first batch
      final snapshot =
          await _databaseService.getFirstBatch(limit: _itemsPerPage);

      if (!mounted) return;

      final items = snapshot.docs
          .map((doc) =>
              FoodItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      setState(() {
        _foodItems = items;
        _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        _hasMoreItems = items.length >= _itemsPerPage;
        _isLoadingFood = false;
      });
      _updateView();

      // Subscribe to real-time updates for the current batch
      _foodItemsSubscription =
          _databaseService.getFoodItemsPaginated(limit: _itemsPerPage).listen(
        (items) {
          if (mounted) {
            setState(() {
              // Update existing items with new data
              _foodItems = items;
            });
            _updateView();
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _isLoadingFood = false;
            });
            _showErrorSnackBar(error);
          }
        },
      );
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoadingFood = false;
        });
        _showErrorSnackBar(error);
      }
    }
  }

  /// Load more items for infinite scroll
  Future<void> _loadMoreItems() async {
    if (_isLoadingMore || !_hasMoreItems || _lastDocument == null) return;

    setState(() => _isLoadingMore = true);

    try {
      final snapshot = await _databaseService.getNextBatch(
        lastDocument: _lastDocument!,
        limit: _itemsPerPage,
      );

      final newItems = snapshot.docs
          .map((doc) =>
              FoodItem.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (mounted) {
        setState(() {
          _foodItems.addAll(newItems);
          _lastDocument =
              snapshot.docs.isNotEmpty ? snapshot.docs.last : _lastDocument;
          _hasMoreItems = newItems.length >= _itemsPerPage;
          _isLoadingMore = false;
        });
        _updateView();
      }
    } catch (e) {
      debugPrint('Load more items error: $e');
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ErrorHelper.getUserFriendlyErrorMessage(
            error, AppLocalizations.of(context)!)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateView() {
    final filtered = _filterItems(_foodItems);
    _updateMarkers(filtered, _foodItems);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update map theme when app theme changes
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isDarkMapTheme != isDark) {
      setState(() {
        _isDarkMapTheme = isDark;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _positionStream?.cancel();
    _foodItemsSubscription?.cancel();
    _mapController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndRefreshLocation();
    }
  }

  Future<void> _loadLastViewedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('lastViewedNotificationTime');
    if (timestamp != null) {
      if (mounted) {
        setState(() {
          _lastViewedNotificationTime =
              DateTime.fromMillisecondsSinceEpoch(timestamp);
        });
      }
    }
  }

  Future<void> _saveLastViewedTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'lastViewedNotificationTime', time.millisecondsSinceEpoch);
  }

  Future<void> _checkPermissionAndRefreshLocation() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (_userPosition == null) {
        setState(() => _isLocationLoading = true);
        await _startLocationTracking();
      }
    }
  }

  void _showPermissionDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.locationPermissionTitle),
        content: Text(l10n.locationPermissionMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Geolocator.openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
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
        if (mounted) {
          setState(() => _isLocationLoading = false);
          _showPermissionDialog();
        }
        return;
      }

      // Default location (Helsinki)
      const defaultLocation = LatLng(60.1699, 24.9384);

      // FAST PATH: Check last known location first
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null && mounted) {
          setState(() {
            _userPosition = lastKnown;
            _isLocationLoading = false;
          });
          _notificationService.updateUserLocation(lastKnown);
          // Move map only if this is the first update (don't jump around on restart)
          // But since this is startLocationTracking, moving is appropriate.
          _mapController.move(
            LatLng(lastKnown.latitude, lastKnown.longitude),
            14.0,
          );
          _updateView();
        }
      } catch (e) {
        debugPrint('Last known location error: $e');
      }

      // ROBUST PATH: Get fresh location if needed or update it
      try {
        // If we already have a position, we don't need to block UI,
        // but we still want a fresh one.
        final initialPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 30), // Increased to 30s
          ),
        );

        if (mounted) {
          setState(() {
            _userPosition = initialPosition;
            _isLocationLoading = false;
          });

          _notificationService.updateUserLocation(initialPosition);

          // Only move map if we didn't have a position before (or to refine it)
          _mapController.move(
            LatLng(initialPosition.latitude, initialPosition.longitude),
            14.0,
          );
          _updateView();
        }
      } catch (e) {
        debugPrint('Sijainnin haku epäonnistui: $e');

        if (mounted) {
          setState(() {
            _isLocationLoading = false;
          });

          // Only fallback to default if we have NO position at all
          if (_userPosition == null) {
            _mapController.move(defaultLocation, 12.0);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.locationError),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 200,
        ),
      ).listen(
        (Position position) {
          if (mounted) {
            if (_userPosition == null ||
                Geolocator.distanceBetween(
                      _userPosition!.latitude,
                      _userPosition!.longitude,
                      position.latitude,
                      position.longitude,
                    ) >
                    100) {
              setState(() {
                _userPosition = position;
              });
              _notificationService.updateUserLocation(position);
              _updateView();
            }
          }
        },
        onError: (error) {
          debugPrint('Sijaintivirhe streamissa: $error');
        },
      );
    } catch (e) {
      if (mounted) setState(() => _isLocationLoading = false);
    }
  }

  Future<void> _centerMapOnUser() async {
    if (_userPosition == null) {
      await _startLocationTracking();
      return;
    }

    _mapController.move(
      LatLng(_userPosition!.latitude, _userPosition!.longitude),
      14.0,
    );
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
      filtered =
          filtered.where((item) => item.category == _selectedCategory).toList();
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

    if (_selectedTags != null && _selectedTags!.isNotEmpty) {
      filtered = filtered.where((item) {
        if (item.dietaryTags.isEmpty) return false;
        return _selectedTags!.any((tag) => item.dietaryTags.contains(tag));
      }).toList();
    }

    filtered = filtered
        .where((item) => item.status == ReservationStatus.available)
        .toList();

    if (_userPosition != null) {
      filtered.sort((a, b) {
        final distA = Geolocator.distanceBetween(_userPosition!.latitude,
            _userPosition!.longitude, a.latitude, a.longitude);
        final distB = Geolocator.distanceBetween(_userPosition!.latitude,
            _userPosition!.longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
    }

    return filtered;
  }

  Future<bool> _showFilterDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(
        selectedCategory: _selectedCategory,
        maxDistance: _maxDistance,
        selectedTags: _selectedTags,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result['category'] as FoodCategory?;
        _maxDistance = result['maxDistance'] as double?;
        _selectedTags = result['tags'] as List<String>?;
      });
      _updateView();
      return true;
    }
    return false;
  }

  void _updateMarkers(List<FoodItem> items, List<FoodItem> allItems) {
    final currentIds = items
        .where((item) =>
            item.latitude != 0.0 &&
            item.longitude != 0.0 &&
            item.latitude.isFinite &&
            item.latitude.isFinite &&
            item.longitude.isFinite &&
            item.status == ReservationStatus.available)
        .map((item) => item.id)
        .toList()
      ..sort();

    if (_lastMarkerIds.length == currentIds.length &&
        _lastMarkerIds.every((id) => currentIds.contains(id))) {
      return;
    }

    final markers = MapMarkerHelper.createMarkersFromFoodItems(
      items,
      onMarkerTap: (String foodItemId) {
        _handleMarkerTap(foodItemId, allItems);
      },
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

  // Track dismissed notifications locally
  // Track when user last checked notifications to clear the badge
  DateTime _lastViewedNotificationTime =
      DateTime.now().subtract(const Duration(days: 1));
  final Set<String> _dismissedNotificationIds = {};

  bool _hasNewNotifications() {
    final now = DateTime.now();
    final user = FirebaseAuth.instance.currentUser;
    final currentUserId = user?.uid;

    return _foodItems.any((item) {
      final difference = now.difference(item.timestamp);
      // New if < 24h AND not dismissed AND newer than last view time AND not own item
      return difference.inHours < 24 &&
          item.timestamp.isAfter(_lastViewedNotificationTime) &&
          !_dismissedNotificationIds.contains(item.id) &&
          item.userId != currentUserId;
    });
  }

  void _handleNotificationDismiss(String itemId) {
    setState(() {
      _dismissedNotificationIds.add(itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final foodItems = _filterItems(_foodItems);
    final hasFilters = _selectedCategory != null ||
        _maxDistance != null ||
        (_selectedTags != null && _selectedTags!.isNotEmpty);

    // Detect screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).primaryColor,
        elevation: 0,
        actions: [
          // Ilmoitukset ikoni (Uudet ruoat)
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_hasNewNotifications())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.accentOrange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              // Clear notification badge immediately when pressed
              final now = DateTime.now();
              setState(() {
                _lastViewedNotificationTime = now;
              });
              _saveLastViewedTime(now); // Persist time

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationScreen(
                          dismissedIds: _dismissedNotificationIds,
                          onDismiss: _handleNotificationDismiss,
                          userPosition: _userPosition,
                        )),
              );
            },
            tooltip: AppLocalizations.of(context)!.newNotificationsTooltip,
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (hasFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppTheme.accentOrange,
                            shape: BoxShape.circle)),
                  ),
              ],
            ),
            onPressed: () async {
              final filtersApplied = await _showFilterDialog();
              if (filtersApplied && !isDesktop) {
                // Only expand sheet on mobile
                Future.delayed(const Duration(milliseconds: 100), () {
                  try {
                    _bottomSheetKey.currentState?.expandSheet();
                  } catch (e) {
                    debugPrint("Sheet expansion failed: $e");
                  }
                });
              }
            },
            tooltip: l10n.filter,
          ),

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
                  backgroundColor: AppTheme.accentOrange,
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                tooltip: l10n.messages,
                onPressed: () {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChatListScreen()));
                  }
                },
              );
            },
          ),
          IconButton(
            icon: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                return Icon(
                    snapshot.data != null ? Icons.account_circle : Icons.login);
              },
            ),
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              }
            },
            tooltip: l10n.login,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context)
                          .appBarTheme
                          .backgroundColor
                          ?.withValues(alpha: 0.95) ??
                      Theme.of(context).primaryColor.withValues(alpha: 0.95),
                  Theme.of(context)
                          .appBarTheme
                          .backgroundColor
                          ?.withValues(alpha: 0.0) ??
                      Theme.of(context).primaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: l10n.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear())
                    : null,
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                      color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddFoodScreen()),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        // Add white border in dark mode for better visibility
        shape: Theme.of(context).brightness == Brightness.dark
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.white, width: 2.0),
              )
            : RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Text(
          l10n.shareFood,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        children: [
          HomeMapWidget(
            mapController: _mapController,
            userPosition: _userPosition,
            onMapCreated: (MapController controller) {
              // MapController is handled externally
            },
            sheetSize: 0.35,
            isDarkTheme: _isDarkMapTheme,
            markers: _markers,
          ),
          // Floating Action Buttons - adjusted position for desktop
          Positioned(
            right: 16,
            bottom: isDesktop
                ? MediaQuery.of(context).size.height * 0.15
                : MediaQuery.of(context).size.height * 0.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, currentZoom + 1);
                  },
                  child: const Icon(Icons.add, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                        _mapController.camera.center, currentZoom - 1);
                  },
                  child: const Icon(Icons.remove, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  heroTag: "my_location",
                  backgroundColor: Colors.white,
                  onPressed: _centerMapOnUser,
                  child: const Icon(Icons.my_location,
                      color: AppTheme.primaryGreen),
                ),
              ],
            ),
          ),
          // Responsive Layout: Desktop Side Panel or Mobile Bottom Sheet
          if (isDesktop)
            _buildDesktopSidePanel(foodItems, hasFilters)
          else
            _buildMobileBottomSheet(foodItems, hasFilters),
          if (_isLocationLoading)
            Positioned(
              top: 200,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(AppLocalizations.of(context)!.fetchingLocation),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Desktop: Floating side panel on the left
  Widget _buildDesktopSidePanel(List<FoodItem> foodItems, bool hasFilters) {
    return DesktopSidePanel(
      foodItems: foodItems,
      hasFilters: hasFilters,
      userPosition: _userPosition,
      isLoadingFood: _isLoadingFood,
      userService: _userService,
      onRefresh: () {
        setState(() => _isLoadingFood = true);
        _subscribeToFoodItems();
      },
      onItemTap: (item) => _handleMarkerTap(item.id, _foodItems),
      onShowFilterDialog: () {
        _showFilterDialog();
      },
      dismissedNotificationIds: _dismissedNotificationIds,
      onDismissNotification: _handleNotificationDismiss,
      onLoadMore: _loadMoreItems,
      isLoadingMore: _isLoadingMore,
      hasMoreItems: _hasMoreItems,
    );
  }

  // Mobile: Bottom sheet
  Widget _buildMobileBottomSheet(List<FoodItem> foodItems, bool hasFilters) {
    // Calculate safe top padding to prevent overlap with search/app bar
    final double safeTopPadding =
        MediaQuery.of(context).padding.top + kToolbarHeight + 70 + 16;

    return Padding(
      padding: EdgeInsets.only(top: safeTopPadding),
      child: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          final user = authSnapshot.data;
          // Use a function to build the sheet to avoid duplication
          Widget buildSheet(Set<String> favorites) {
            return HomeBottomSheet(
              key: _bottomSheetKey,
              foodItems: foodItems,
              userPosition: _userPosition,
              isLoading: _isLoadingFood,
              onRefresh: () {
                setState(() => _isLoadingFood = true);
                _subscribeToFoodItems();
              },
              onCenterMap: _centerMapOnUser,
              onItemTap: (item) => _handleMarkerTap(item.id, _foodItems),
              onEmptyStateAction: () {
                if (hasFilters) {
                  _showFilterDialog();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddFoodScreen()),
                  );
                }
              },
              hasFilters: hasFilters,
              favoriteIds: favorites,
              dismissedIds: _dismissedNotificationIds,
              onDismissNotification: _handleNotificationDismiss,
              onLoadMore: _loadMoreItems,
              isLoadingMore: _isLoadingMore,
              hasMoreItems: _hasMoreItems,
            );
          }

          if (user == null) {
            return buildSheet(const {});
          }

          return StreamBuilder<UserModel?>(
            stream: _userService.getUserStream(user.uid),
            builder: (context, userSnapshot) {
              final favorites =
                  userSnapshot.data?.favorites.toSet() ?? const {};
              return buildSheet(favorites);
            },
          );
        },
      ),
    );
  }
}
