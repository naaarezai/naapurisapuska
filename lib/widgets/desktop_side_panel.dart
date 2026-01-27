import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../models/food_item.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';
import 'home_list_widget.dart';
import '../screens/add_food_screen.dart';

class DesktopSidePanel extends StatelessWidget {
  final List<FoodItem> foodItems;
  final bool hasFilters;
  final Position? userPosition;
  final bool isLoadingFood;
  final UserService userService;
  final Function() onRefresh;
  final Function(FoodItem) onItemTap;
  final Function() onShowFilterDialog;
  final Set<String> dismissedNotificationIds;
  final Function(String) onDismissNotification;
  final Function() onLoadMore;
  final bool isLoadingMore;
  final bool hasMoreItems;

  const DesktopSidePanel({
    super.key,
    required this.foodItems,
    required this.hasFilters,
    required this.userPosition,
    required this.isLoadingFood,
    required this.userService,
    required this.onRefresh,
    required this.onItemTap,
    required this.onShowFilterDialog,
    required this.dismissedNotificationIds,
    required this.onDismissNotification,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.hasMoreItems,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      top: 160,
      bottom: 20,
      width: 420,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            final user = authSnapshot.data;

            if (user == null) {
              return _buildFoodListContent(
                context,
                foodItems,
                hasFilters,
                const {},
              );
            }

            return StreamBuilder<UserModel?>(
              stream: userService.getUserStream(user.uid),
              builder: (context, userSnapshot) {
                final favorites =
                    userSnapshot.data?.favorites.toSet() ?? const {};

                return _buildFoodListContent(
                  context,
                  foodItems,
                  hasFilters,
                  favorites,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodListContent(
    BuildContext context,
    List<FoodItem> foodItems,
    bool hasFilters,
    Set<String> favoriteIds,
  ) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.nearbyFood,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (hasFilters)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentOrange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        // List
        Expanded(
          child: HomeListWidget(
            foodItems: foodItems,
            userPosition: userPosition,
            scrollController: ScrollController(),
            onRefresh: onRefresh,
            isLoading: isLoadingFood,
            onItemTap: onItemTap,
            onEmptyStateAction: () {
              if (hasFilters) {
                onShowFilterDialog();
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddFoodScreen()),
                );
              }
            },
            hasFilters: hasFilters,
            favoriteIds: favoriteIds,
            dismissedIds: dismissedNotificationIds,
            onDismissNotification: onDismissNotification,
            // Pagination
            onLoadMore: onLoadMore,
            isLoadingMore: isLoadingMore,
            hasMoreItems: hasMoreItems,
          ),
        ),
      ],
    );
  }
}
