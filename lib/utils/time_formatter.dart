import 'package:intl/intl.dart';

/// Helper class for formatting timestamps in a user-friendly way
/// Provides relative time formatting and urgency detection
class TimeFormatter {
  /// Format a timestamp as relative time (e.g., "2 tuntia sitten", "Juuri nyt")
  static String formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Juuri nyt';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? "minuutti" : "minuuttia"} sitten';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? "tunti" : "tuntia"} sitten';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? "päivä" : "päivää"} sitten';
    } else {
      return DateFormat('d.M.yyyy HH:mm').format(timestamp);
    }
  }

  /// Format a timestamp with contextual information
  /// (e.g., "Tänään 14:30", "Eilen 09:15", full date otherwise)
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Tänään ${DateFormat('HH:mm').format(timestamp)}';
    } else if (difference.inDays == 1) {
      return 'Eilen ${DateFormat('HH:mm').format(timestamp)}';
    } else if (difference.inDays < 7) {
      // Show weekday name for last 7 days
      final weekdays = [
        'Maanantai',
        'Tiistai',
        'Keskiviikko',
        'Torstai',
        'Perjantai',
        'Lauantai',
        'Sunnuntai'
      ];
      final weekday = weekdays[timestamp.weekday - 1];
      return '$weekday ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('d.M.yyyy HH:mm').format(timestamp);
    }
  }

  /// Check if a timestamp is considered "recent" (less than 1 hour old)
  /// Useful for highlighting new items
  static bool isRecent(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    return difference.inHours < 24;
  }

  /// Check if a timestamp is considered "urgent" (less than 2 hours old)
  /// Can be used for special styling or badges
  static bool isUrgent(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    return difference.inHours < 2;
  }

  /// Check if a timestamp is from today
  static bool isToday(DateTime timestamp) {
    final now = DateTime.now();
    return timestamp.year == now.year &&
        timestamp.month == now.month &&
        timestamp.day == now.day;
  }

  /// Check if a timestamp is from yesterday
  static bool isYesterday(DateTime timestamp) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return timestamp.year == yesterday.year &&
        timestamp.month == yesterday.month &&
        timestamp.day == yesterday.day;
  }

  /// Format duration in a human-readable way
  /// (e.g., "2h 30min")
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (minutes > 0) {
        return '${hours}h ${minutes}min';
      }
      return '${hours}h';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}min';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Get a time-ago string in short format
  /// (e.g., "2h", "5min", "1d")
  static String formatShortRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Juuri nyt';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}pv';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}vk';
    } else {
      return DateFormat('d.M.').format(timestamp);
    }
  }
}
