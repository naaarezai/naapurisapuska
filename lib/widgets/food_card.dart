import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import '../models/food_item.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_helper.dart';
import '../utils/category_helper.dart';
import '../utils/time_formatter.dart';
import '../l10n/app_localizations.dart';

class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final Position? userPosition;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback onTap;

  const FoodCard({
    super.key,
    required this.foodItem,
    required this.onTap,
    this.userPosition,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink(); // Fallback for tests or missing context
    }
    final distanceVal = Geolocator.distanceBetween(
      userPosition?.latitude ?? 0,
      userPosition?.longitude ?? 0,
      foodItem.latitude,
      foodItem.longitude,
    );

    // Custom distance string with localized unit
    String? distanceString;
    if (userPosition != null) {
      if (distanceVal < 1000) {
        distanceString = '${distanceVal.toInt()}${l10n.distanceUnitM}';
      } else {
        distanceString =
            '${(distanceVal / 1000).toStringAsFixed(1)}${l10n.distanceUnitKm}';
      }
    }

    final timeAgo = TimeFormatter.formatShortRelativeTime(foodItem.timestamp);
    final isRecent = TimeFormatter.isRecent(foodItem.timestamp);
    final imageUrl =
        foodItem.allImages.isNotEmpty ? foodItem.allImages.first : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      color: Theme.of(context).cardTheme.color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: AppTheme.primaryGreen.withValues(alpha: 0.1),
        highlightColor: AppTheme.primaryGreen.withValues(alpha: 0.05),
        onTap: () {
          HapticHelper.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vasen: Kuva
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: imageUrl.isNotEmpty
                      ? Hero(
                          tag: 'food_image_${foodItem.id}',
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.image,
                                  color: Colors.grey, size: 30),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey, size: 30),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.fastfood,
                              size: 40, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // Oikea: Tiedot
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ylärivi: Kategoria & Hinta & Sydän
                    Row(
                      children: [
                        // Kategoria with color coding
                        CategoryHelper.getCategoryBadge(
                          foodItem.category,
                          fontSize: 10,
                          iconSize: 14,
                        ),
                        const Spacer(),
                        // Hinta
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: foodItem.price == null || foodItem.price == 0
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1)
                                : AppTheme.accentOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            foodItem.price == null || foodItem.price == 0
                                ? l10n.free
                                : '${foodItem.price!.toStringAsFixed(2)} €',
                            style: TextStyle(
                              color:
                                  foodItem.price == null || foodItem.price == 0
                                      ? Theme.of(context).colorScheme.primary
                                      : AppTheme.accentOrange,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Sydän
                        IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? AppTheme.accentOrange
                                : Colors.grey.withValues(alpha: 0.5),
                          ),
                          onPressed: onFavoriteToggle,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Otsikko
                    Text(
                      foodItem.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Kuvaus
                    Text(
                      foodItem.description.isNotEmpty
                          ? foodItem.description
                          : l10n.noDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Alarivi: Aika & Sijainti & NEW badge & EXPIRATION
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: isRecent ? AppTheme.accentOrange : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                isRecent ? AppTheme.accentOrange : Colors.grey,
                            fontWeight:
                                isRecent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isRecent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.accentOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              l10n.newBadge,
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        // Expiration warning badge
                        if (foodItem.isExpiringSoon ||
                            foodItem.daysUntilExpiration <= 2) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: foodItem.isExpiringSoon
                                  ? Colors.red.shade600
                                  : Colors.orange.shade600,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.timer_outlined,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  foodItem.isExpiringSoon
                                      ? '${foodItem.hoursUntilExpiration}${l10n.hourShort}'
                                      : '${foodItem.daysUntilExpiration}${l10n.dayShort}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (distanceString != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            distanceString,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
