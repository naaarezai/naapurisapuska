import 'package:flutter/material.dart';

enum UserBadge {
  newcomer, // 0-9
  regular, // 10-49
  expert, // 50-99
  master, // 100+
}

class BadgeDetails {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  BadgeDetails({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class BadgeHelper {
  static UserBadge getBadge(int savedFoodCount) {
    if (savedFoodCount >= 100) return UserBadge.master;
    if (savedFoodCount >= 50) return UserBadge.expert;
    if (savedFoodCount >= 10) return UserBadge.regular;
    return UserBadge.newcomer;
  }

  static BadgeDetails getBadgeDetails(UserBadge badge) {
    switch (badge) {
      case UserBadge.newcomer:
        return BadgeDetails(
          title: 'Aloittelija',
          description: 'Olet aloittanut matkasi ruokahävikin vähentämisessä!',
          icon: Icons.grass,
          color: Colors.lightGreen,
        );
      case UserBadge.regular:
        return BadgeDetails(
          title: 'Konkari',
          description: 'Olet jo kokenut ruokapelastaja.',
          icon: Icons.eco,
          color: Colors.green,
        );
      case UserBadge.expert:
        return BadgeDetails(
          title: 'Asiantuntija',
          description: 'Ruokahävikin vähentäminen on sinulle sydämen asia.',
          icon: Icons.star,
          color: Colors.orange,
        );
      case UserBadge.master:
        return BadgeDetails(
          title: 'Mestari',
          description: 'Olet todellinen legenda naapuristossa!',
          icon: Icons.workspace_premium,
          color: Colors.purple,
        );
    }
  }

  static double getProgressToNextLevel(int savedFoodCount) {
    if (savedFoodCount >= 100) return 1.0;
    if (savedFoodCount >= 50) return (savedFoodCount - 50) / 50;
    if (savedFoodCount >= 10) return (savedFoodCount - 10) / 40;
    return savedFoodCount / 10;
  }

  static String getNextLevelText(int savedFoodCount) {
    if (savedFoodCount >= 100) return 'Max taso saavutettu!';
    if (savedFoodCount >= 50) {
      return '${100 - savedFoodCount} pelastusta Mestariksi';
    }
    if (savedFoodCount >= 10) {
      return '${50 - savedFoodCount} pelastusta Asiantuntijaksi';
    }
    return '${10 - savedFoodCount} pelastusta Konkariksi';
  }
}
