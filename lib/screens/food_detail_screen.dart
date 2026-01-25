import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart'; // Flutter Map
import 'package:latlong2/latlong.dart'; // LatLng
import 'package:firebase_auth/firebase_auth.dart';
import '../models/food_item.dart';
import '../services/rating_service.dart';
import '../services/database_service.dart';
import 'chat_screen.dart';
import 'edit_food_screen.dart';
import '../utils/error_helper.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_helper.dart';
import '../l10n/app_localizations.dart';
import '../utils/category_helper.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  final Position? userPosition;
  final RatingService? ratingService;
  final DatabaseService? databaseService;
  final FirebaseAuth? auth;

  const FoodDetailScreen({
    super.key,
    required this.foodItem,
    this.userPosition,
    this.ratingService,
    this.databaseService,
    this.auth,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late final RatingService _ratingService;
  late final DatabaseService _databaseService;
  late final FirebaseAuth _auth;
  double _averageRating = 0.0;
  int _ratingCount = 0;
  bool _isLoadingRating = true;
  late ReservationStatus _status;
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  late Stream<FoodItem> _foodItemStream;

  // CartoDB styles (Free and high quality)
  static const String _cartoLight =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const String _cartoDark =
      'https://{s}.basemaps.cartocdn.com/rastertiles/dark_all/{z}/{x}/{y}{r}.png';

  @override
  void initState() {
    super.initState();
    _ratingService = widget.ratingService ?? RatingService();
    _databaseService = widget.databaseService ?? DatabaseService();
    _auth = widget.auth ?? FirebaseAuth.instance;
    _status = widget.foodItem.status;
    _foodItemStream = _databaseService.getFoodItemStream(widget.foodItem.id);
    _loadRatings();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadRatings() async {
    final average = await _ratingService.getAverageRating(widget.foodItem.id);
    final count = await _ratingService.getRatingCount(widget.foodItem.id);
    if (mounted) {
      setState(() {
        _averageRating = average;
        _ratingCount = count;
        _isLoadingRating = false;
      });
    }
  }

  void _shareFoodItem() {
    HapticHelper.lightImpact();

    // Rakenna rikkaampi viesti
    final StringBuffer message = StringBuffer();
    message.writeln('🍽️ ${widget.foodItem.title}');
    message.writeln();

    // Kategoria
    message.writeln('📁 ${widget.foodItem.category.displayName}');

    // Hinta
    final priceText =
        widget.foodItem.price == null || widget.foodItem.price == 0
            ? '💰 Ilmainen'
            : '💰 ${widget.foodItem.price!.toStringAsFixed(2)} €';
    message.writeln(priceText);

    // Määrä
    if (widget.foodItem.quantity != null) {
      message.writeln(
          '📊 ${widget.foodItem.quantity!.toStringAsFixed(1)} ${widget.foodItem.quantityUnit ?? ''}');
    }

    // Etäisyys
    final distance = _calculateDistance(widget.foodItem);
    if (distance != null) {
      message.writeln(
          '📍 $distance ${AppLocalizations.of(context)!.distanceAway}');
    }

    // Ruokavaliotagit
    if (widget.foodItem.dietaryTags.isNotEmpty) {
      message.writeln('🌱 ${widget.foodItem.dietaryTags.join(', ')}');
    }

    message.writeln();

    // Kuvaus
    if (widget.foodItem.description.isNotEmpty) {
      message.writeln(widget.foodItem.description);
      message.writeln();
    }

    // Web-linkki
    message.writeln('🔗 ${AppLocalizations.of(context)!.seeMore}');
    message.writeln(
        'https://naaarezai.github.io/naapurisapuska/#/food/${widget.foodItem.id}');
    message.writeln();

    message.writeln('Lataa Naapurisapuska-sovellus! 🍴');

    // ignore: deprecated_member_use
    Share.share(message.toString());
  }

  Future<void> _reserveFoodItem() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.loginToReserve), backgroundColor: Colors.orange),
      );
      return;
    }

    if (widget.foodItem.userId == user.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l10n.cannotReserveOwn), backgroundColor: Colors.red),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reserveFood),
        content: const Text(
            'Haluatko varmasti varata tämän ruoan?\n\nTämä avaa chatin ilmoittajan kanssa.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.reserve)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.reserveFoodItem(widget.foodItem.id, user.uid);

        if (mounted) {
          setState(() {
            _status = ReservationStatus.reserved;
          });
          HapticHelper.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.foodReserved),
                backgroundColor: AppTheme.primaryGreen),
          );

          // Avaa chat automaattisesti
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        otherUserId: widget.foodItem.userId!,
                        otherUserName: widget.foodItem.userName,
                        otherUserProfileImageUrl:
                            widget.foodItem.userProfileImageUrl,
                      )));
        }
      } catch (e) {
        if (mounted) {
          HapticHelper.heavyImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(ErrorHelper.getUserFriendlyErrorMessage(
                    e, AppLocalizations.of(context)!)),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _unreserveFoodItem() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelReservation),
        content: Text(l10n.cancelReservationMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.no)),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.yesCancelReservation)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.unreserveFoodItem(widget.foodItem.id);
        if (mounted) {
          setState(() {
            _status = ReservationStatus.available;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.reservationCancelled)),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .errorGenericWithDetails(e.toString())),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _markAsPickedUp() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.markAsPickedUp),
        content: Text(l10n.markAsPickedUpMessage),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.yesPickedUp)),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.markAsPickedUp(widget.foodItem.id);
        if (mounted) {
          setState(() {
            _status = ReservationStatus.pickedUp;
          });
          HapticHelper.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(l10n.markedAsPickedUpSuccess),
                backgroundColor: AppTheme.primaryGreen),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(AppLocalizations.of(context)!
                    .errorGenericWithDetails(e.toString())),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deleteFoodItem() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteListing),
        content: Text(l10n.deleteListingMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _databaseService.deleteFoodItem(widget.foodItem.id);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(ErrorHelper.getUserFriendlyErrorMessage(
                    e, AppLocalizations.of(context)!)),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _editFoodItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFoodScreen(foodItem: widget.foodItem),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 0) {
      return l10n.daysAgo(difference.inDays);
    }
    if (difference.inHours > 0) {
      return l10n.hoursAgoShort(difference.inHours);
    }
    if (difference.inMinutes > 0) {
      return l10n.minutesAgoShort(difference.inMinutes);
    }
    return l10n.justNow;
  }

  String? _calculateDistance(FoodItem item) {
    if (widget.userPosition == null) return null;
    final distance = Geolocator.distanceBetween(
      widget.userPosition!.latitude,
      widget.userPosition!.longitude,
      item.latitude,
      item.longitude,
    );
    if (distance < 1000) return '${distance.toInt()}m';
    return '${(distance / 1000).toStringAsFixed(1)}km';
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FoodItem>(
      stream: _foodItemStream,
      initialData: widget.foodItem,
      builder: (context, snapshot) {
        final foodItem = snapshot.data ?? widget.foodItem;
        final distance = _calculateDistance(foodItem);
        final currentUser = _auth.currentUser;
        final isOwner =
            currentUser != null && foodItem.userId == currentUser.uid;
        final canChat = !isOwner;
        final isReservedByMe =
            currentUser != null && foodItem.reservedByUserId == currentUser.uid;

        // Kuvat Hero-animaatiota varten
        final heroTag = 'food_image_${foodItem.id}';

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final urlTemplate = isDark ? _cartoDark : _cartoLight;

        // Minikartta (Flutter Map)
        final miniMap = FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(foodItem.latitude, foodItem.longitude),
            initialZoom: 15.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Static map
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.example.naapurisapuska',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(foodItem.latitude, foodItem.longitude),
                  child: const Icon(Icons.location_on,
                      color: Colors.red, size: 40),
                ),
              ],
            ),
          ],
        );

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 350,
                    pinned: true,
                    backgroundColor: AppTheme.primaryGreen,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: foodItem.allImages.isNotEmpty
                                ? PageView.builder(
                                    controller: _pageController,
                                    onPageChanged: (index) => setState(
                                        () => _currentImageIndex = index),
                                    itemCount: foodItem.allImages.length,
                                    itemBuilder: (context, index) {
                                      return CachedNetworkImage(
                                        imageUrl: foodItem.allImages[index],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                                color: Colors.grey.shade200),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(Icons.error_outline,
                                              color: Colors.red),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.fastfood,
                                        size: 80, color: Colors.grey)),
                          ),
                          // Gradientti tekstin luettavuudelle
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 120,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Kuva-indikaattorit
                          if (foodItem.allImages.length > 1)
                            Positioned(
                              bottom: 20,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  foodItem.allImages.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentImageIndex == index
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    leading: IconButton(
                      icon: const ContainerWithShadow(
                          child: Icon(Icons.arrow_back)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon:
                            const ContainerWithShadow(child: Icon(Icons.share)),
                        onPressed: _shareFoodItem,
                      ),
                      if (isOwner)
                        IconButton(
                          icon: const ContainerWithShadow(
                              child: Icon(Icons.edit)),
                          onPressed: _editFoodItem,
                        ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Otsikko ja Hinta
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  foodItem.title,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        height: 1.2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  foodItem.price == null || foodItem.price == 0
                                      ? AppLocalizations.of(context)!.freeLabel
                                      : '${foodItem.price!.toStringAsFixed(2)}€',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Badge rivi
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildBadge(
                                  CategoryHelper.getCategoryName(
                                      foodItem.category, context),
                                  Icons.folder_outlined,
                                  Colors.blueGrey),
                              if (foodItem.quantity != null)
                                _buildBadge(
                                  '${foodItem.quantity!.toStringAsFixed(1)} ${foodItem.quantityUnit ?? ''}',
                                  Icons.scale_outlined,
                                  Colors.blueGrey,
                                ),
                              if (distance != null)
                                _buildBadge(distance,
                                    Icons.location_on_outlined, Colors.red),
                              if (_status == ReservationStatus.reserved)
                                _buildBadge(
                                    AppLocalizations.of(context)!
                                        .reserved
                                        .toUpperCase(),
                                    Icons.lock,
                                    Colors.orange),
                              if (_status == ReservationStatus.pickedUp)
                                _buildBadge(
                                    AppLocalizations.of(context)!
                                        .pickedUp
                                        .toUpperCase(),
                                    Icons.check_circle,
                                    Colors.grey),
                            ],
                          ),

                          // Ruokavaliotagit
                          if (foodItem.dietaryTags.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: foodItem.dietaryTags.map((tag) {
                                return Chip(
                                  label: Text(
                                      CategoryHelper.getTagName(tag, context)),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  side: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.2)),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Jakaja profiili (Modernisoitu kortti)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                  color: Theme.of(context)
                                      .dividerColor
                                      .withValues(alpha: 0.1)),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Linkki profiiliin tulevaisuudessa
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey.shade200,
                                    backgroundImage:
                                        widget.foodItem.userProfileImageUrl !=
                                                null
                                            ? CachedNetworkImageProvider(widget
                                                .foodItem.userProfileImageUrl!)
                                            : null,
                                    child:
                                        widget.foodItem.userProfileImageUrl ==
                                                null
                                            ? const Icon(Icons.person,
                                                color: Colors.grey, size: 30)
                                            : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .posterLabel,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          widget.foodItem.userName ??
                                              AppLocalizations.of(context)!
                                                  .anonymousUser,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                        Row(
                                          children: [
                                            if (!_isLoadingRating) ...[
                                              const Icon(Icons.star,
                                                  size: 16,
                                                  color: AppTheme.accentOrange),
                                              const SizedBox(width: 4),
                                              Text(
                                                _ratingCount > 0
                                                    ? '$_averageRating ($_ratingCount)'
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .newUser,
                                                style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              '•  ${_formatTimestamp(widget.foodItem.timestamp)}',
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Kuvaus
                          Text(
                            AppLocalizations.of(context)!.foodInfoHeader,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            foodItem.description.isEmpty
                                ? AppLocalizations.of(context)!.noDescription
                                : foodItem.description,
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.6,
                                      fontSize: 16,
                                    ),
                          ),

                          const SizedBox(height: 32),

                          // Kartta Preview
                          Text(
                            AppLocalizations.of(context)!.locationHeader,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: miniMap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Action buttons
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: SafeArea(
                  child: SizedBox(
                    height: 56,
                    child: _buildActionButton(
                        foodItem, isOwner, isReservedByMe, canChat),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      FoodItem foodItem, bool isOwner, bool isReservedByMe, bool canChat) {
    final l10n = AppLocalizations.of(context)!;
    if (isOwner) {
      if (foodItem.status == ReservationStatus.available) {
        return OutlinedButton.icon(
          onPressed: _deleteFoodItem,
          icon: const Icon(Icons.delete),
          label: Text(l10n.deleteListingButton),
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).cardTheme.color,
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            elevation: 4,
          ),
        );
      } else if (foodItem.status == ReservationStatus.reserved) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _unreserveFoodItem,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardTheme.color,
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(l10n.cancelButton),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _markAsPickedUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: Text(l10n.pickedUpButton,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      } else {
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: Text(l10n.eventEnded),
        );
      }
    } else {
      // User view
      return Row(
        children: [
          if (canChat) ...[
            Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  HapticHelper.lightImpact();
                  if (FirebaseAuth.instance.currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.loginToChat)),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        otherUserId: foodItem.userId!,
                        otherUserName: foodItem.userName,
                        otherUserProfileImageUrl: foodItem.userProfileImageUrl,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.chat_bubble_outline),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: foodItem.status == ReservationStatus.available &&
                      !isReservedByMe
                  ? _reserveFoodItem
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                elevation: 4,
              ),
              child: Text(
                isReservedByMe
                    ? AppLocalizations.of(context)!.reservedForYou
                    : AppLocalizations.of(context)!.reserveFoodButton,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

class ContainerWithShadow extends StatelessWidget {
  final Widget child;

  const ContainerWithShadow({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      // Force icon color to be visible against the card color
      // (AppBar usually forces icons to be white, which is invisible on a white card)
      child: IconTheme(
        data: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
          size: 22,
        ),
        child: child,
      ),
    );
  }
}
