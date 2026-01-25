import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/services/expiration_service.dart';

void main() {
  group('ExpirationService - getDaysUntilExpiration', () {
    // Inject null for firestore because we aren't using the database methods
    final service = ExpirationService(firestore: null);

    test('calculates correct days for available item', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final itemData = {
        'timestamp': threeDaysAgo,
        'status': 'available',
      };

      final days = service.getDaysUntilExpiration(itemData);
      expect(days, greaterThanOrEqualTo(1));
    });

    test('calculates correct days for reserved item', () {
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      final itemData = {
        'timestamp': fourDaysAgo,
        'status': 'reserved',
        'reservedAt': fourDaysAgo,
      };

      final days = service.getDaysUntilExpiration(itemData);
      expect(days, greaterThanOrEqualTo(2));
    });
  });

  group('ExpirationService - getExpirationText', () {
    final service = ExpirationService(firestore: null);

    test('returns "Vanhentunut" for expired item', () {
      final sixDaysAgo = DateTime.now().subtract(const Duration(days: 6));
      final itemData = {
        'timestamp': sixDaysAgo,
        'status': 'available',
      };

      final text = service.getExpirationText(itemData);
      expect(text, 'Vanhentunut');
    });

    test('returns correct text for 1 day remaining', () {
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      final itemData = {
        'timestamp': fourDaysAgo,
        'status': 'available',
      };

      final text = service.getExpirationText(itemData);
      expect(text, anyOf(contains('huomenna'), contains('tunnin')));
    });

    test('returns correct days text for multiple days', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final itemData = {
        'timestamp': twoDaysAgo,
        'status': 'available',
      };

      final text = service.getExpirationText(itemData);
      expect(text,
          anyOf('Vanhenee 3 päivän kuluttua', 'Vanhenee 2 päivän kuluttua'));
    });
  });
}
