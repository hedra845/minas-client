import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _countryKey = 'selected_country';

  Locale _currentLocale = const Locale('en');
  String _currentCountry = 'US';

  LanguageProvider({Locale? deviceLocale}) {
    _loadLanguage(deviceLocale);
  }

  Locale get currentLocale => _currentLocale;
  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';
  String get currentCountry => _currentCountry;
  String get currentLanguageCode => _currentLocale.languageCode;

  // Get formatted language name
  String getCurrentLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return 'English';
    }
  }

  // Get opposite language name
  String getOppositeLanguageName() {
    return isArabic ? 'English' : 'العربية';
  }

  // Get language code for display
  String getLanguageCodeForDisplay() {
    return isArabic ? 'AR' : 'EN';
  }

  // Get language info for settings
  Map<String, String> getLanguageInfo() {
    return {
      'code': _currentLocale.languageCode,
      'name': getCurrentLanguageName(),
      'nativeName': isArabic ? 'العربية' : 'English',
      'country': _currentCountry,
    };
  }

  // Get supported languages
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {
        'code': 'en',
        'name': 'English',
        'nativeName': 'English',
        'country': 'US',
        'flag': '🇺🇸',
      },
      {
        'code': 'ar',
        'name': 'Arabic',
        'nativeName': 'العربية',
        'country': 'SA',
        'flag': '🇸🇦',
      },
    ];
  }

  Future<void> _loadLanguage(Locale? deviceLocale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      final countryCode = prefs.getString(_countryKey);

      if (languageCode != null) {
        // User has a saved preference, use it
        _currentLocale = Locale(languageCode);
        _currentCountry = countryCode ?? _getDefaultCountry(languageCode);
      } else if (deviceLocale != null) {
        // No saved preference, use device locale
        _currentLocale = deviceLocale;
        _currentCountry = _getDefaultCountry(deviceLocale.languageCode);
        // Save the device locale as the initial preference
        await prefs.setString(_languageKey, deviceLocale.languageCode);
        await prefs.setString(_countryKey, _currentCountry);
      }
      // If neither exists, keep the default English locale

      notifyListeners();
    } catch (e) {
      // Fallback to English
      _currentLocale = const Locale('en');
      _currentCountry = 'US';
    }
  }

  String _getDefaultCountry(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return 'SA';
      case 'en':
        return 'US';
      default:
        return 'US';
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale != locale) {
      try {
        _currentLocale = locale;
        _currentCountry = _getDefaultCountry(locale.languageCode);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, locale.languageCode);
        await prefs.setString(_countryKey, _currentCountry);

        notifyListeners();
      } catch (e) {}
    }
  }

  Future<void> changeLanguageByCode(String languageCode) async {
    final locale = Locale(languageCode);
    await changeLanguage(locale);
  }

  Future<void> changeLanguageWithCountry(
    String languageCode,
    String countryCode,
  ) async {
    final locale = Locale(languageCode, countryCode);
    if (_currentLocale != locale) {
      try {
        _currentLocale = locale;
        _currentCountry = countryCode;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        await prefs.setString(_countryKey, countryCode);

        notifyListeners();
      } catch (e) {}
    }
  }

  // Reset to device language
  Future<void> resetToDeviceLanguage(Locale deviceLocale) async {
    await changeLanguage(deviceLocale);
  }

  // Check if language is supported
  bool isLanguageSupported(String languageCode) {
    return ['en', 'ar'].contains(languageCode);
  }

  // Get next language in rotation
  String getNextLanguage() {
    return isArabic ? 'en' : 'ar';
  }

  // Toggle between supported languages
  Future<void> toggleLanguage() async {
    final nextLanguage = getNextLanguage();
    await changeLanguageByCode(nextLanguage);
  }

  // Get language statistics
  Map<String, dynamic> getLanguageStats() {
    return {
      'currentLanguage': _currentLocale.languageCode,
      'currentCountry': _currentCountry,
      'isRTL': isArabic,
      'supportedLanguages': getSupportedLanguages().length,
      'lastChanged': DateTime.now().toIso8601String(),
    };
  }
}
