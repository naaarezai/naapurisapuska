import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme service supporting System/Light/Dark modes
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  // ThemeMode: system, light, or dark
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  // For backwards compatibility with existing code
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_themeModeKey);

    if (savedMode != null) {
      switch (savedMode) {
        case 'system':
          _themeMode = ThemeMode.system;
          break;
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    } else {
      // Default to system for new users
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  /// Set theme mode (system, light, or dark)
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String modeString;
    switch (mode) {
      case ThemeMode.system:
        modeString = 'system';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
    }
    await prefs.setString(_themeModeKey, modeString);
  }

  /// For backwards compatibility - converts bool to ThemeMode
  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}
