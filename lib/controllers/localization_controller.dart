import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../core/services/localization_service.dart';

class LocalizationController extends GetxController {
  final GetStorage _storage;
  LocalizationController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  Rx<Locale> currentLocale = const Locale('en').obs;

  @override
  void onInit() {
    super.onInit();
    // Load saved language synchronously on controller initialization
    _loadSavedLanguageSync();
  }

  Future<void> loadSavedLanguage() async {
    try {
      // ✅ FIX: Check if keys exist (not just default value)
      // After logout, keys are removed completely, so this will be null
      final dynamic firstTimeValue = _storage.read('is_first_time_install');
      final String? savedLang = _storage.read('selected_language');

      // If both keys are missing (null), treat as first time (post-logout scenario)
      bool isFirstTime = firstTimeValue ?? true;

      if (isFirstTime || savedLang == null) {
        // First time OR post-logout - set English but DON'T mark as complete yet
        // This will be marked as false only when user completes language selection
        changeLocaleInternal('en', updateGet: true);

        // DON'T write to storage yet - let user select language first
        print('🔤 First time or post-logout detected - English set as default UI language');
        print('🔤 Storage state: is_first_time=$firstTimeValue, selected_language=$savedLang');
        return;
      }

      // Not first time - load saved language
      print('🔤 Loading saved language: $savedLang');

      // Safe check for LocalizationService
      if (Get.isRegistered<LocalizationService>() &&
          Get.find<LocalizationService>().isLanguageSupported(savedLang)) {
        // Set the locale properly and update GetX
        changeLocaleInternal(savedLang, updateGet: true);
        print('🔤 Language loaded successfully: $savedLang');
      } else {
        // Invalid language - reset to English
        changeLocaleInternal('en', updateGet: true);
        print('🔤 Invalid saved language, defaulting to English');
      }
    } catch (e) {
      print('❌ Error loading saved language: $e');
      // Fallback to English
      changeLocaleInternal('en', updateGet: true);
    }
  }

  void setDefaultLanguage() {
    changeLocaleInternal('en');
  }

  Future<void> changeLocale(String langCode) async {
    // Safe check for LocalizationService
    if (!Get.isRegistered<LocalizationService>()) {
      print('⚠️ LocalizationService not registered, cannot change locale');
      return;
    }

    if (!Get.find<LocalizationService>().isLanguageSupported(langCode)) {
      // Unsupported language: $langCode
      return;
    }

    Get.find<LocalizationService>().changeLanguage(langCode);
    await _storage.write('selected_language', langCode);
    currentLocale.value = Locale(langCode);
    // Language successfully changed to: $langCode
  }

  /// Mark language selection as complete (called when user confirms selection)
  Future<void> completeLanguageSelection() async {
    try {
      await _storage.write('is_first_time_install', false);
      print('✅ Language selection marked as complete');
    } catch (e) {
      print('❌ Error marking language selection as complete: $e');
    }
  }

  void changeLocaleInternal(String langCode, {bool updateGet = true}) {
    Locale newLocale = Locale(langCode);
    currentLocale.value = newLocale;

    if (updateGet && !Get.testMode && Get.isRegistered<LocalizationService>()) {
      Get.find<LocalizationService>().changeLanguage(langCode);
    }
  }

  String get currentLanguageCode => currentLocale.value.languageCode;

  bool isLanguageSelected(String langCode) => currentLanguageCode == langCode;

  /// Reset language to English (for logout/uninstall scenarios)
  Future<void> resetToDefaultLanguage() async {
    try {
      // ✅ CRITICAL FIX: Remove language keys completely instead of writing defaults
      // This ensures fresh state on next login (like token behavior)
      await _storage.remove('selected_language');
      await _storage.remove('is_first_time_install');

      // Set UI to English immediately for current session
      changeLocaleInternal('en', updateGet: true);

      print('🔄 Language storage cleared completely - next login will show language screen');
    } catch (e) {
      print('❌ Error resetting language: $e');
      // Fallback: Try writing defaults if remove fails
      await _storage.write('selected_language', 'en');
      await _storage.write('is_first_time_install', true);
    }
  }

  String get currentLanguageDisplayName {
    if (!Get.isRegistered<LocalizationService>()) {
      return 'English'; // Fallback to English if service not registered
    }
    return Get.find<LocalizationService>().getCurrentLanguageName();
  }

  /// Synchronous version for onInit - loads saved language immediately
  void _loadSavedLanguageSync() {
    try {
      // ✅ FIX: Check if keys exist (not just default value)
      // After logout, keys are removed completely, so this will be null
      final dynamic firstTimeValue = _storage.read('is_first_time_install');
      final String? savedLang = _storage.read('selected_language');

      // If both keys are missing (null), treat as first time (post-logout scenario)
      bool isFirstTime = firstTimeValue ?? true;

      if (isFirstTime || savedLang == null) {
        // First time OR post-logout - set English but DON'T mark as complete yet
        // This will be marked as false only when user completes language selection
        changeLocaleInternal('en', updateGet: true);

        // DON'T write to storage yet - let user select language first
        print('🔤 Sync: First time or post-logout detected - English set as default UI');
        print('🔤 Sync: Storage state: is_first_time=$firstTimeValue, selected_language=$savedLang');
        return;
      }

      // Not first time - load saved language
      print('🔤 Sync: Loading saved language: $savedLang');

      // Safe check for LocalizationService
      if (Get.isRegistered<LocalizationService>() &&
          Get.find<LocalizationService>().isLanguageSupported(savedLang)) {
        // Set the locale properly and update GetX
        changeLocaleInternal(savedLang, updateGet: true);
        print('🔤 Sync: Language loaded successfully: $savedLang');
      } else {
        // Invalid language - reset to English
        changeLocaleInternal('en', updateGet: true);
        print('🔤 Sync: Invalid saved language, defaulting to English');
      }
    } catch (e) {
      print('❌ Sync: Error loading saved language: $e');
      // Fallback to English
      changeLocaleInternal('en', updateGet: true);
    }
  }
}