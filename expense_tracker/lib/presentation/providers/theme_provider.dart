import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  final Box _settingsBox;
  ThemeMode _themeMode;

  ThemeProvider({Box? settingsBox})
      : _settingsBox = settingsBox ?? Hive.box('settings'),
        _themeMode = ThemeMode.system {
    _loadSavedTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void _loadSavedTheme() {
    final themeIndex = _settingsBox.get('themeMode', defaultValue: 0);
    _themeMode = ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _settingsBox.put('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    await _settingsBox.put('themeMode', _themeMode.index);
    notifyListeners();
  }
}

