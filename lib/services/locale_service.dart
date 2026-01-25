import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale service supporting System/Finnish/English modes
class LocaleService extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  // null means system default, otherwise specific locale
  Locale? _locale;

  Locale? get locale => _locale;

  // Check if using system locale
  bool get isSystemLocale => _locale == null;

  LocaleService() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    if (savedLocale != null) {
      switch (savedLocale) {
        case 'system':
          _locale = null; // System default
          break;
        case 'fi':
          _locale = const Locale('fi');
          break;
        case 'en':
          _locale = const Locale('en');
          break;
        default:
          _locale = null; // Fallback to system
      }
    } else {
      // Default to system for new users
      _locale = null;
    }

    notifyListeners();
  }

  /// Set locale (null for system, or specific Locale)
  Future<void> setLocale(Locale? newLocale) async {
    _locale = newLocale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String localeString;
    if (newLocale == null) {
      localeString = 'system';
    } else {
      localeString = newLocale.languageCode;
    }
    await prefs.setString(_localeKey, localeString);
  }

  /// Helper to set system mode
  Future<void> setSystemLocale() async {
    await setLocale(null);
  }

  /// Helper to set Finnish
  Future<void> setFinnish() async {
    await setLocale(const Locale('fi'));
  }

  /// Helper to set English
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  /// Get display name for current locale mode
  String getDisplayName(BuildContext context) {
    if (_locale == null) {
      return 'Järjestelmä / System';
    } else if (_locale!.languageCode == 'fi') {
      return 'Suomi';
    } else {
      return 'English';
    }
  }
}
