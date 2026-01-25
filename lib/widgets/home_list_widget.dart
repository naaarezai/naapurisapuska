import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../widgets/food_card.dart';
import '../widgets/food_card_skeleton.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../utils/haptic_helper.dart';
import '../l10n/app_localizations.dart';

class HomeListWidget extends StatelessWidget {
  final List<FoodItem> foodItems;
  final Position? userPosition;
  final ScrollController scrollController;
  final Function() onRefresh;
  final Function() onEmptyStateAction;
  final bool hasFilters;
  final Function(FoodItem) onItemTap;
  final bool isLoading;
  final Set<String> favoriteIds;
  final Set<String> dismissedIds;
  final Function(String) onDismissNotification;

  // Pagination
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMoreItems;

  const HomeListWidget({
    super.key,
    required this.foodItems,
    required this.userPosition,
    required this.scrollController,
    required this.onRefresh,
    required this.onEmptyStateAction,
    required this.hasFilters,
    required this.onItemTap,
    this.isLoading = false,
    this.favoriteIds = const {},
    this.dismissedIds = const {},
    required this.onDismissNotification,
    // Pagination
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMoreItems = true,
  });

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated illustration
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              'assets/empty_state.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image not found
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasFilters ? Icons.search_off : Icons.restaurant_menu,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),

          // Heading with fade-in
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Text(
              hasFilters
                  ? AppLocalizations.of(context)!.noResults
                  : AppLocalizations.of(context)!.noFoodNearby,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),

          // Subtext
          Text(
            hasFilters
                ? AppLocalizations.of(context)!.tryExpandDistance
                : AppLocalizations.of(context)!.beFirstToShare,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Call-to-action button
          ElevatedButton.icon(
            onPressed: onEmptyStateAction,
            icon: Icon(
              hasFilters ? Icons.tune : Icons.restaurant,
              size: 22,
            ),
            label: Text(
              hasFilters
                  ? AppLocalizations.of(context)!.editFilters
                  : AppLocalizations.of(context)!.shareFood,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasFilters
                  ? Theme.of(context).colorScheme.surface
                  : Theme.of(context).primaryColor,
              foregroundColor: hasFilters
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 18,
              ),
              elevation: 4,
              shadowColor: hasFilters
                  ? Colors.black26
                  : Theme.of(context).primaryColor.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        HapticHelper.lightImpact(); // Haptic feedback on refresh
        await Future.delayed(const Duration(milliseconds: 500));
        onRefresh();
        HapticHelper.selectionClick(); // Confirmation feedback
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (notification.metrics.pixels <= 0 &&
                notification.scrollDelta! < 0) {
              return false;
            }
          }
          return false;
        },
        child: _buildListContent(context),
      ),
    );
  }

  Widget _buildListContent(BuildContext context) {
    if (isLoading) {
      return ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 200, top: 0),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const FoodCardSkeleton();
        },
      );
    }

    if (foodItems.isEmpty) {
      return SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: _buildEmptyState(context),
        ),
      );
    }

    // Find the first "new" item that hasn't been dismissed
    final now = DateTime.now();
    FoodItem? newArrivalItem;
    try {
      newArrivalItem = foodItems.firstWhere((item) {
        final isNew = now.difference(item.timestamp).inHours < 24;
        final isDismissed = dismissedIds.contains(item.id);
        return isNew && !isDismissed;
      });
    } catch (_) {
      newArrivalItem = null;
    }

    final hasBanner = newArrivalItem != null;
    final listCount =
        foodItems.length + (hasBanner ? 1 : 0) + (isLoadingMore ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Trigger load more when near bottom
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200 &&
            hasMoreItems &&
            !isLoadingMore &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 200, top: 0),
        itemCount: listCount,
        itemBuilder: (context, index) {
          if (hasBanner && index == 0) {
            return _buildNewArrivalBanner(context, newArrivalItem!);
          }

          // Show loading indicator at bottom if loading more
          if (isLoadingMore && index == listCount - 1) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final itemIndex = hasBanner ? index - 1 : index;
          final item = foodItems[itemIndex];

          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 500),
            tween: Tween(begin: 0.0, end: 1.0),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: FoodCard(
              foodItem: item,
              userPosition: userPosition,
              isFavorite: favoriteIds.contains(item.id),
              onFavoriteToggle: () async {
                HapticHelper.selectionClick();
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await UserService().toggleFavorite(user.uid, item.id);
                }
              },
              onTap: () => onItemTap(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewArrivalBanner(BuildContext context, FoodItem item) {
    return Dismissible(
      key: ValueKey('new_arrival_${item.id}'),
      onDismissed: (_) {
        onDismissNotification(item.id);
        HapticHelper.lightImpact();
      },
      child: GestureDetector(
        onTap: () => onItemTap(item),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.of(context)!.newListingBanner,
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
