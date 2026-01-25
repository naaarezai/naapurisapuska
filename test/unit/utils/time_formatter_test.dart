import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/utils/time_formatter.dart';

void main() {
  group('TimeFormatter - Relative Time', () {
    test('formats seconds ago', () {
      final now = DateTime.now();
      final thirtySecondsAgo = now.subtract(const Duration(seconds: 30));

      final result = TimeFormatter.formatShortRelativeTime(thirtySecondsAgo);
      expect(result, 'Juuri nyt');
    });

    test('formats minutes ago', () {
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));

      final result = TimeFormatter.formatShortRelativeTime(fiveMinutesAgo);
      expect(result, '5 min');
    });

    test('formats hours ago', () {
      final now = DateTime.now();
      final twoHoursAgo = now.subtract(const Duration(hours: 2));

      final result = TimeFormatter.formatShortRelativeTime(twoHoursAgo);
      expect(result, '2h');
    });

    test('formats days ago', () {
      final now = DateTime.now();
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      final result = TimeFormatter.formatShortRelativeTime(threeDaysAgo);
      expect(result, '3pv');
    });

    test('formats weeks ago', () {
      final now = DateTime.now();
      final twoWeeksAgo = now.subtract(const Duration(days: 14));

      final result = TimeFormatter.formatShortRelativeTime(twoWeeksAgo);
      expect(result, '2vk');
    });
  });

  group('TimeFormatter - isRecent', () {
    test('returns true for items less than 24h old', () {
      final twelveHoursAgo = DateTime.now().subtract(const Duration(hours: 12));
      expect(TimeFormatter.isRecent(twelveHoursAgo), true);
    });

    test('returns false for items more than 24h old', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      expect(TimeFormatter.isRecent(twoDaysAgo), false);
    });

    test('returns true for very recent items', () {
      final oneMinuteAgo = DateTime.now().subtract(const Duration(minutes: 1));
      expect(TimeFormatter.isRecent(oneMinuteAgo), true);
    });
  });

  group('TimeFormatter - Edge Cases', () {
    test('handles future dates gracefully', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      final result = TimeFormatter.formatShortRelativeTime(futureDate);

      // Should not crash and should return some value
      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });

    test('handles very old dates', () {
      final veryOld = DateTime(2020, 1, 1);
      final result = TimeFormatter.formatShortRelativeTime(veryOld);

      expect(result, isNotNull);
      expect(result, isNotEmpty);
    });
  });
}
