import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocalizationService extends GetxService {
  static LocalizationService get instance => Get.find<LocalizationService>();

  final _storage = GetStorage();
  static const String _languageKey = 'selected_language';

  final supportedLanguages = {
    'en': {'name': 'English', 'flag': '🇺🇸'},
    'hi': {'name': 'हिंदी', 'flag': '🇮🇳'},
    'gu': {'name': 'ગુજરાતી', 'flag': '🇮🇳'},
    'bn': {'name': 'বাংলা', 'flag': '🇮🇳'},
    'ta': {'name': 'தமிழ்', 'flag': '🇮🇳'},
    'te': {'name': 'తెలుగు', 'flag': '🇮🇳'},
    'kn': {'name': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    'mr': {'name': 'मराठी', 'flag': '🇮🇳'},
    'ml': {'name': 'മലയാളം', 'flag': '🇮🇳'},
    'or': {'name': 'ଓଡ଼ିଆ', 'flag': '🇮🇳'},
    'pa': {'name': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    'as': {'name': 'অসমীয়া', 'flag': '🇮🇳'},
  };

  final supportedLocales = [
    const Locale('en'),
    const Locale('hi'),
    const Locale('gu'),
    const Locale('bn'),
    const Locale('ta'),
    const Locale('te'),
    const Locale('kn'),
    const Locale('mr'),
    const Locale('ml'),
    const Locale('or'),
    const Locale('pa'),
    const Locale('as'),
  ];

  final fallbackLocale = const Locale('en');

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  Locale get currentLocale {
    String languageCode = _storage.read(_languageKey) ?? 'en';
    return Locale(languageCode);
  }

  void _loadSavedLanguage() {
    String? savedLanguage = _storage.read(_languageKey);
    if (savedLanguage != null && supportedLanguages.containsKey(savedLanguage)) {
      Get.updateLocale(Locale(savedLanguage));
      print('🔤 LocalizationService: Loaded saved language: $savedLanguage');
    } else {
      // ✅ CRITICAL FIX: Don't auto-save language on startup!
      // Just set UI locale to English, let user select language explicitly
      // This prevents re-writing language after logout
      Get.updateLocale(Locale('en'));
      print('🔤 LocalizationService: No saved language, defaulting to English (NOT saving yet)');
    }
  }

  void _changeLanguage(String languageCode) {
    if (supportedLanguages.containsKey(languageCode)) {
      _storage.write(_languageKey, languageCode);
      Get.updateLocale(Locale(languageCode));
    }
  }

  void changeLanguage(String languageCode) {
    _changeLanguage(languageCode);
    Get.forceAppUpdate(); // Force rebuild to apply language changes
  }

  String getCurrentLanguageName() {
    String currentLang = _storage.read(_languageKey) ?? 'en';
    return supportedLanguages[currentLang]?['name'] ?? 'English';
  }

  String getCurrentLanguageFlag() {
    String currentLang = _storage.read(_languageKey) ?? 'en';
    return supportedLanguages[currentLang]?['flag'] ?? '🇺🇸';
  }

  List<Map<String, String>> getLanguageList() {
    return supportedLanguages.entries.map((entry) {
      return {
        'code': entry.key,
        'name': entry.value['name'] ?? '',
        'flag': entry.value['flag'] ?? '',
      };
    }).toList();
  }

  bool isLanguageSupported(String languageCode) {
    return supportedLanguages.containsKey(languageCode);
  }
}