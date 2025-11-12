import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/legacy.dart';

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'theme_mode'; // values: 'system', 'light', 'dark'

  ThemeMode _themeMode = ThemeMode.light;
  ThemeProvider() {
    _loadFromPrefs();
  }
  ThemeMode get themeMode => _themeMode;
  bool get isDark {
    return _themeMode == ThemeMode.dark;
  }

  // Resolve effective ThemeMode given a BuildContext (useful in widgets)
  ThemeMode resolveWithContext(BuildContext context) {
    if (_themeMode != ThemeMode.system) return _themeMode;
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> toggleLightDark() async {
    final newMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey) ?? 'system';
    switch (value) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final value = _themeMode == ThemeMode.light
        ? 'light'
        : _themeMode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await prefs.setString(_prefKey, value);
  }
}

/// A Riverpod ChangeNotifierProvider exposing [ThemeProvider].
final themeChangeNotifierProvider =
    ChangeNotifierProvider<ThemeProvider>((ref) => ThemeProvider());