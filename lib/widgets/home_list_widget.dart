import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../widgets/food_card.dart';
import 'package:geolocator/geolocator.dart';

/// Widget listanäkymälle ruokailmoituksista
class HomeListWidget extends StatelessWidget {
  final List<FoodItem> foodItems;
  final Position? userPosition;
  final ScrollController scrollController;
  final Function() onRefresh;
  final Function() onEmptyStateAction;
  final bool hasFilters;
  final String? Function(FoodItem) calculateDistance;

  const HomeListWidget({
    super.key,
    required this.foodItems,
    required this.userPosition,
    required this.scrollController,
    required this.onRefresh,
    required this.onEmptyStateAction,
    required this.hasFilters,
    required this.calculateDistance,
  });

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasFilters ? Icons.search_off : Icons.restaurant_menu,
                      size: 50,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            hasFilters 
                ? 'Ei tuloksia suodattimilla'
                : 'Ei ruokaa lähistöllä',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Kokeile poistaa suodattimia tai valita eri kategoria'
                : 'Ole sinä ensimmäinen, joka jakaa ruokaa naapureille!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onEmptyStateAction,
            icon: Icon(hasFilters ? Icons.filter_alt_outlined : Icons.add_a_photo),
            label: Text(hasFilters ? 'Muuta suodattimia' : 'Jaa ensimmäinen ilmoitus'),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasFilters ? Colors.grey.shade200 : null,
              foregroundColor: hasFilters ? Colors.grey.shade800 : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
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
        await Future.delayed(const Duration(milliseconds: 500));
        onRefresh();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            if (scrollController.position.pixels <= 0 && 
                notification.scrollDelta! < 0) {
              return false;
            }
          }
          return false;
        },
        child: foodItems.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: _buildEmptyState(context),
                ),
              )
            : ListView.builder(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                itemCount: foodItems.length,
                itemBuilder: (context, index) {
                  final item = foodItems[index];
                  return FoodCard(
                    foodItem: item,
                    distance: calculateDistance(item),
                  );
                },
              ),
      ),
    );
  }

  String? _calculateDistance(FoodItem item) {
    if (userPosition == null) return null;
    
    final distance = Geolocator.distanceBetween(
      userPosition!.latitude,
      userPosition!.longitude,
      item.latitude,
      item.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.toInt()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }
}
