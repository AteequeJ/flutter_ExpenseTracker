import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageProvider with ChangeNotifier {
  final Box _settingsBox;
  Locale _locale;

  LanguageProvider({Box? settingsBox})
    : _settingsBox = settingsBox ?? Hive.box('settings'),
      _locale = const Locale('en', '') {
    _loadSavedLanguage();
  }

  Locale get locale => _locale;

  void _loadSavedLanguage() {
    final languageCode = _settingsBox.get('languageCode', defaultValue: 'en');
    _locale = Locale(languageCode, '');
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode, '');
    print("setLanguage: $languageCode");
    await _settingsBox.put('languageCode', languageCode);
    notifyListeners();
  }
}
