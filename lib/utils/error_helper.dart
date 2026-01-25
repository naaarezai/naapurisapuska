import 'dart:async';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import '../l10n/app_localizations.dart';

/// Helper-luokka käyttäjäystävällisille virheilmoituksille
class ErrorHelper {
  /// Muuntaa teknisen virheen käyttäjäystävälliseksi viestiksi.
  /// Vaatii [AppLocalizations] -instanssin, jotta se on irrallaan BuildContextista.
  static String getUserFriendlyErrorMessage(
      dynamic error, AppLocalizations l10n) {
    // 1. Käsittele tunnetut poikkeustyypit
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return l10n.errorPermission;
        case 'unavailable':
          return l10n.errorUnavailable;
        case 'not-found':
          return l10n.errorNotFound;
        case 'network-request-failed':
          return l10n.errorNetwork;
        case 'deadline-exceeded':
          return l10n.errorTimeout;
      }
    }

    if (error is SocketException) {
      return l10n.errorNetwork;
    }

    if (error is TimeoutException) {
      return l10n.errorTimeout;
    }

    // 2. Jos ei ole tunnettu tyyppi, yritä merkkijonon perusteella (varalla)
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('socketexception') ||
        errorString.contains('network_error') ||
        errorString.contains('failed host lookup')) {
      return l10n.errorNetwork;
    }

    if (errorString.contains('permission-denied') ||
        errorString.contains('permission_denied')) {
      return l10n.errorPermission;
    }

    if (errorString.contains('timeout')) {
      return l10n.errorTimeout;
    }

    if (errorString.contains('not found') ||
        errorString.contains('not-found')) {
      return l10n.errorNotFound;
    }

    if (errorString.contains('unavailable')) {
      return l10n.errorUnavailable;
    }

    return l10n.errorGeneric;
  }
}
