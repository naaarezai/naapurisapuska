import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naapurisapuska/utils/error_helper.dart';
import 'package:naapurisapuska/l10n/app_localizations_fi.dart';

void main() {
  final l10n = AppLocalizationsFi();

  group('ErrorHelper', () {
    test('returns correct message for FirebaseException: permission-denied',
        () {
      final error = FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      );
      final message = ErrorHelper.getUserFriendlyErrorMessage(error, l10n);
      expect(message, l10n.errorPermission);
    });

    test('returns correct message for FirebaseException: unavailable', () {
      final error = FirebaseException(
        plugin: 'firestore',
        code: 'unavailable',
      );
      final message = ErrorHelper.getUserFriendlyErrorMessage(error, l10n);
      expect(message, l10n.errorUnavailable);
    });

    test('returns correct message for SocketException', () {
      const error = SocketException('Failed host lookup');
      final message = ErrorHelper.getUserFriendlyErrorMessage(error, l10n);
      expect(message, l10n.errorNetwork);
    });

    test('returns correct message for TimeoutException', () {
      final error = TimeoutException('Timed out');
      final message = ErrorHelper.getUserFriendlyErrorMessage(error, l10n);
      expect(message, l10n.errorTimeout);
    });

    test('returns correct message for generic string error (fallback)', () {
      const error = 'Some unknown technical error';
      final message = ErrorHelper.getUserFriendlyErrorMessage(error, l10n);
      expect(message, l10n.errorGeneric);
    });

    test('returns correct message for "not found" string (fallback)', () {
      const error = 'The document was not found in the database';
      final message = ErrorHelper.getUserFriendlyErrorMessage(error, l10n);
      expect(message, l10n.errorNotFound);
    });

    test('returns correct message for null error', () {
      final message = ErrorHelper.getUserFriendlyErrorMessage(null, l10n);
      expect(message, l10n.errorGeneric);
    });

    test('returns correct message for unknown object', () {
      final message = ErrorHelper.getUserFriendlyErrorMessage(12345, l10n);
      expect(message, l10n.errorGeneric);
    });
  });
}
