import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/utils/validation_helper.dart';

void main() {
  group('ValidationHelper - Title Validation', () {
    test('valid title passes', () {
      expect(ValidationHelper.validateTitle('Pizza'), null);
      expect(ValidationHelper.validateTitle('Hyvää leipää'), null);
      expect(ValidationHelper.validateTitle('123'), null);
    });

    test('null or empty title fails', () {
      expect(ValidationHelper.validateTitle(null), isNotNull);
      expect(ValidationHelper.validateTitle(''), isNotNull);
      expect(ValidationHelper.validateTitle('   '), isNotNull);
    });

    test('too short title fails', () {
      expect(ValidationHelper.validateTitle('AB'), isNotNull,
          reason: 'Title must be at least 3 characters');
    });

    test('too long title fails', () {
      final longTitle = 'A' * 101;
      expect(ValidationHelper.validateTitle(longTitle), isNotNull,
          reason: 'Title must be max 100 characters');
    });

    test('max length title passes', () {
      final maxTitle = 'A' * 100;
      expect(ValidationHelper.validateTitle(maxTitle), null);
    });
  });

  group('ValidationHelper - Password Validation', () {
    test('valid passwords pass', () {
      expect(ValidationHelper.validatePassword('password123'), null);
      expect(ValidationHelper.validatePassword('123456'), null);
      expect(ValidationHelper.validatePassword('abcdefgh'), null);
    });

    test('too short password fails', () {
      expect(ValidationHelper.validatePassword('12345'), isNotNull,
          reason: 'Password must be at least 6 characters');
    });

    test('null or empty password fails', () {
      expect(ValidationHelper.validatePassword(null), isNotNull);
      expect(ValidationHelper.validatePassword(''), isNotNull);
    });
  });

  group('ValidationHelper - Name Validation', () {
    test('valid names pass', () {
      expect(ValidationHelper.validateName('John'), null);
      expect(ValidationHelper.validateName('Matti Virtanen'), null);
      expect(ValidationHelper.validateName('Åsa'), null);
    });

    test('null or empty name fails', () {
      expect(ValidationHelper.validateName(null), isNotNull);
      expect(ValidationHelper.validateName(''), isNotNull);
      expect(ValidationHelper.validateName('   '), isNotNull);
    });

    test('too short name fails', () {
      expect(ValidationHelper.validateName('A'), isNotNull,
          reason: 'Name must be at least 2 characters');
    });
  });

  group('ValidationHelper - Phone Number Validation', () {
    test('valid phone numbers pass', () {
      expect(ValidationHelper.validatePhoneNumber('+358401234567'), null);
      expect(ValidationHelper.validatePhoneNumber('0401234567'), null);
      expect(ValidationHelper.validatePhoneNumber('040 123 4567'), null);
    });

    test('null or empty phone fails', () {
      expect(ValidationHelper.validatePhoneNumber(null), isNotNull);
      expect(ValidationHelper.validatePhoneNumber(''), isNotNull);
    });

    test('too short phone fails', () {
      expect(ValidationHelper.validatePhoneNumber('12345'), isNotNull);
    });
  });

  group('ValidationHelper - Price Validation', () {
    test('valid prices pass when not free', () {
      expect(ValidationHelper.validatePrice('5.50', false), null);
      expect(ValidationHelper.validatePrice('10', false), null);
      expect(ValidationHelper.validatePrice('100.99', false), null);
    });

    test('negative price fails', () {
      expect(ValidationHelper.validatePrice('-5', false), isNotNull,
          reason: 'Price cannot be negative');
    });

    test('non-numeric price fails', () {
      expect(ValidationHelper.validatePrice('abc', false), isNotNull);
    });

    test('free items skip validation', () {
      expect(ValidationHelper.validatePrice(null, true), null);
      expect(ValidationHelper.validatePrice('', true), null);
      expect(ValidationHelper.validatePrice('invalid', true), null);
    });

    test('empty price fails when not free', () {
      expect(ValidationHelper.validatePrice(null, false), isNotNull);
      expect(ValidationHelper.validatePrice('', false), isNotNull);
    });
  });
}
