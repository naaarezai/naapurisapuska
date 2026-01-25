import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/food_item.dart';
import 'home_list_widget.dart';
import '../l10n/app_localizations.dart';

class HomeBottomSheet extends StatefulWidget {
  final List<FoodItem> foodItems;
  final Position? userPosition;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onCenterMap;
  final Function(FoodItem) onItemTap;
  final VoidCallback onEmptyStateAction;
  final bool hasFilters;
  final Set<String> favoriteIds;
  final Set<String> dismissedIds;
  final Function(String) onDismissNotification;

  // Pagination
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMoreItems;
  final double topPadding; // New parameter for responsive padding

  const HomeBottomSheet({
    super.key,
    required this.foodItems,
    required this.userPosition,
    required this.isLoading,
    required this.onRefresh,
    required this.onCenterMap,
    required this.onItemTap,
    required this.onEmptyStateAction,
    required this.hasFilters,
    this.favoriteIds = const {},
    this.dismissedIds = const {},
    required this.onDismissNotification,
    // Pagination
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMoreItems = true,
    this.topPadding = 0, // Default to 0
  });

  @override
  State<HomeBottomSheet> createState() => HomeBottomSheetState();
}

class HomeBottomSheetState extends State<HomeBottomSheet> {
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  void expandSheet() {
    if (_draggableController.isAttached) {
      _animateTo(1.0);
    } else {
      // Retry after frame if not yet attached (e.g. during rebuild)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_draggableController.isAttached) {
          _animateTo(1.0);
        }
      });
    }
  }

  @override
  void dispose() {
    _draggableController.dispose();
    super.dispose();
  }

  void _animateTo(double targetSize) {
    try {
      _draggableController.animateTo(
        targetSize,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    } catch (e) {
      debugPrint("Error animating sheet: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // We rely on the parent (HomeScreen) to provide proper constraints/padding
    // so the sheet doesn't overlap the search bar.
    const double maxSheetHeight = 1.0;
    const List<double> snapSizes = [0.25, 0.5, 1.0];

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: maxSheetHeight,
      snap: true,
      snapSizes: snapSizes,
      builder: (context, scrollController) {
        return Material(
          elevation: 4,
          shadowColor: Colors.black26,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          color: Theme.of(context).cardTheme.color,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // Kahva - napautettava ja vedettävissä
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onVerticalDragUpdate: (details) {
                  // Calculate dynamic delta based on current viewport height
                  final double height = context.size?.height ??
                      MediaQuery.of(context).size.height;
                  double delta = details.primaryDelta! / height;
                  double newSize = _draggableController.size - delta;
                  _draggableController
                      .jumpTo(newSize.clamp(0.25, maxSheetHeight));
                },
                onVerticalDragEnd: (details) {
                  const double velocityThreshold = 300.0;
                  if (details.primaryVelocity! < -velocityThreshold) {
                    _animateTo(maxSheetHeight); // Heitto ylös
                  } else if (details.primaryVelocity! > velocityThreshold) {
                    _animateTo(0.25); // Heitto alas
                  } else {
                    // Hidas liike, mene lähimpään tilaan
                    if (_draggableController.size > 0.75) {
                      _animateTo(1.0);
                    } else if (_draggableController.size > 0.375) {
                      _animateTo(0.5);
                    } else {
                      _animateTo(0.25);
                    }
                  }
                },
                onTap: () {
                  if (_draggableController.size < 0.5) {
                    _animateTo(1.0);
                  } else {
                    _animateTo(0.25);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Column(
                    children: [
                      // Kahva viiva
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Header (Otsikko + Info)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.nearbyYou,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontSize: 18,
                                  ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color ??
                                        Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  AppLocalizations.of(context)!
                                      .listingCount(widget.foodItems.length),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
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
                  foodItems: widget.foodItems,
                  userPosition: widget.userPosition,
                  scrollController: scrollController,
                  onRefresh: widget.onRefresh,
                  onEmptyStateAction: widget.onEmptyStateAction,
                  hasFilters: widget.hasFilters,
                  onItemTap: widget.onItemTap,
                  isLoading: widget.isLoading,
                  favoriteIds: widget.favoriteIds,
                  dismissedIds: widget.dismissedIds,
                  onDismissNotification: widget.onDismissNotification,
                  // Pagination
                  onLoadMore: widget.onLoadMore,
                  isLoadingMore: widget.isLoadingMore,
                  hasMoreItems: widget.hasMoreItems,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
