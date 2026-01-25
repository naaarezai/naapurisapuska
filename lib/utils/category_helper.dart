import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../l10n/app_localizations.dart';

/// Helper class for category-related utilities
/// Provides colors, icons, and styled badges for food categories
class CategoryHelper {
  /// Get the localized name for a category
  static String getCategoryName(FoodCategory category, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (category) {
      case FoodCategory.hedelmat:
        return l10n.categoryFruits;
      case FoodCategory.vihannekset:
        return l10n.categoryVegetables;
      case FoodCategory.leivonnaiset:
        return l10n.categoryBakedGoods;
      case FoodCategory.muut:
        return l10n.categoryOther;
    }
  }

  /// Get the localized name for a distinct dietary tag (mapping legacy strings)
  static String getTagName(String tag, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Map existing hardcoded Finnish strings to localized keys
    // This ensures backward compatibility with database values
    switch (tag) {
      case 'Vegaaninen':
        return l10n.dietVegan;
      case 'Gluteeniton':
        return l10n.dietGlutenFree;
      case 'Laktoositon':
        return l10n.dietLactoseFree;
      case 'Maidoton':
        return l10n.dietMilkFree;
      case 'Pähkinätön':
        return l10n.dietNutFree;
      case 'Kotimainen':
        return l10n.dietDomestic;
      case 'Lähiruoka':
        return l10n.dietLocal;
      default:
        return tag; // Fallback to original string if no match
    }
  }

  /// Get the color associated with a specific food category
  static Color getCategoryColor(FoodCategory category) {
    switch (category) {
      case FoodCategory.hedelmat:
        return const Color(0xFFFF6B6B); // Red - Fruits
      case FoodCategory.vihannekset:
        return const Color(0xFF4CAF50); // Green - Vegetables
      case FoodCategory.leivonnaiset:
        return const Color(0xFFFFB74D); // Orange - Baked goods
      case FoodCategory.muut:
        return const Color(0xFF90A4AE); // Grey - Other
    }
  }

  /// Get the icon associated with a specific food category
  static IconData getCategoryIcon(FoodCategory category) {
    switch (category) {
      case FoodCategory.hedelmat:
        return Icons.apple;
      case FoodCategory.vihannekset:
        return Icons.eco;
      case FoodCategory.leivonnaiset:
        return Icons.cake;
      case FoodCategory.muut:
        return Icons.fastfood;
    }
  }

  /// Get a ready-to-use category badge widget
  /// Displays the category name with an icon and category-specific color
  static Widget getCategoryBadge(
    FoodCategory category, {
    double fontSize = 12,
    double iconSize = 16,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  }) {
    return _CategoryBadge(
      category: category,
      fontSize: fontSize,
      iconSize: iconSize,
      padding: padding,
    );
  }

  /// Get a simple colored dot indicator for the category
  static Widget getCategoryDot(
    FoodCategory category, {
    double size = 12,
  }) {
    final color = getCategoryColor(category);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
    );
  }

  /// Get just the category icon with color
  static Widget getCategoryIconWidget(
    FoodCategory category, {
    double size = 24,
  }) {
    final color = getCategoryColor(category);
    final icon = getCategoryIcon(category);

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final FoodCategory category;
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;

  const _CategoryBadge({
    required this.category,
    required this.fontSize,
    required this.iconSize,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = CategoryHelper.getCategoryColor(category);
    final icon = CategoryHelper.getCategoryIcon(category);
    // Safe lookup for localization; fallback if not available (e.g. in tests without setup)
    String name;
    try {
      name = CategoryHelper.getCategoryName(category, context);
    } catch (e) {
      name = category.displayName;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
