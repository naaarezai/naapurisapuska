import 'package:flutter/services.dart';

/// Helper-luokka haptic feedbackille
class HapticHelper {
  /// Keveä tärinä (napautukset)
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Keskitasoinen tärinä (painallukset)
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Vahva tärinä (tärkeät toiminnot)
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Valinta-tärinä (valinnat)
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
}
