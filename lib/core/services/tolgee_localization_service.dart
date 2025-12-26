import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/tolgee_config.dart';

class TolgeeLocalizationService extends GetxService {
  static TolgeeLocalizationService get to => Get.find();

  final Rx<String> currentLanguage = 'en'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  // Mock translations map for now (will be replaced with actual Tolgee integration)
  final RxMap<String, Map<String, String>> _translations = <String, Map<String, String>>{}.obs;

  Map<String, Map<String, String>> get translations => _translations;

  // Cached language preference key
  static const String _languagePrefKey = 'selected_language';

  Future<TolgeeLocalizationService> init() async {
    try {
      isLoading.value = true;

      // Initialize mock translations for now
      _initializeMockTranslations();

      // Load saved language preference
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languagePrefKey);

      if (savedLanguage != null && TolgeeConfig.supportedLanguages.contains(savedLanguage)) {
        currentLanguage.value = savedLanguage;
        print('🔤 TolgeeService: Loaded saved language: $savedLanguage');
      } else {
        // ✅ CRITICAL FIX: Don't auto-save device locale on startup!
        // Just use English as default, let user select language explicitly
        currentLanguage.value = TolgeeConfig.defaultLanguage;
        print('🔤 TolgeeService: No saved language, defaulting to English (NOT saving yet)');
      }

      isInitialized.value = true;
      isLoading.value = false;

      return this;
    } catch (e) {
      print('Error initializing TolgeeLocalizationService: $e');
      isLoading.value = false;
      // Fallback to default language on error
      currentLanguage.value = TolgeeConfig.defaultLanguage;
      return this;
    }
  }

  void _initializeMockTranslations() {
    _translations.value = {
      'en': {
        'select_language': 'Select Language',
        'search_language': 'Search language...',
        'no_languages_found': 'No languages found',
        'continue': 'Continue',
        'welcome': 'Welcome',
        'settings': 'Settings',
        'try_different_search_term': 'Try a different search term',
        'no_languages_found_title': 'No languages found',
      },
      'hi': {
        'select_language': 'भाषा चुनें',
        'search_language': 'भाषा खोजें...',
        'no_languages_found': 'कोई भाषा नहीं मिली',
        'continue': 'जारी रखें',
        'welcome': 'स्वागत है',
        'settings': 'सेटिंग्स',
        'try_different_search_term': 'एक अलग खोज शब्द आज़माएं',
        'no_languages_found_title': 'कोई भाषा नहीं मिली',
      },
      'es': {
        'select_language': 'Seleccionar idioma',
        'search_language': 'Buscar idioma...',
        'no_languages_found': 'No se encontraron idiomas',
        'continue': 'Continuar',
        'welcome': 'Bienvenido',
        'settings': 'Configuración',
        'try_different_search_term': 'Prueba un término de búsqueda diferente',
        'no_languages_found_title': 'No se encontraron idiomas',
      },
      'fr': {
        'select_language': 'Sélectionner la langue',
        'search_language': 'Rechercher une langue...',
        'no_languages_found': 'Aucune langue trouvée',
        'continue': 'Continuer',
        'welcome': 'Bienvenue',
        'settings': 'Paramètres',
        'try_different_search_term': 'Essayez un terme de recherche différent',
        'no_languages_found_title': 'Aucune langue trouvée',
      },
    };
  }

  Future<void> changeLanguage(String languageCode) async {
    if (!TolgeeConfig.supportedLanguages.contains(languageCode)) {
      print('Unsupported language: $languageCode');
      return;
    }

    try {
      isLoading.value = true;
      currentLanguage.value = languageCode;

      // Save language preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languagePrefKey, languageCode);

      // Update GetX locale
      final locale = Locale(languageCode);
      Get.updateLocale(locale);

      isLoading.value = false;
    } catch (e) {
      print('Error changing language: $e');
      isLoading.value = false;
    }
  }

  String translate(String key, {Map<String, dynamic>? params}) {
    if (!isInitialized.value) {
      return key; // Return key as fallback if not initialized
    }

    try {
      final languageTranslations = _translations[currentLanguage.value];
      if (languageTranslations != null && languageTranslations.containsKey(key)) {
        String translation = languageTranslations[key]!;

        // Simple parameter replacement
        if (params != null) {
          params.forEach((paramKey, paramValue) {
            translation = translation.replaceAll('{$paramKey}', paramValue.toString());
          });
        }

        return translation;
      }

      // Fallback to English if current language doesn't have the key
      final englishTranslations = _translations['en'];
      if (englishTranslations != null && englishTranslations.containsKey(key)) {
        return englishTranslations[key]!;
      }

      return key; // Return key if no translation found
    } catch (e) {
      print('Error translating key $key: $e');
      return key;
    }
  }

  // Instant translation method for real-time updates
  String t(String key, {Map<String, dynamic>? params}) {
    return translate(key, params: params);
  }

  // Get available languages with display names
  Map<String, String> getAvailableLanguages() {
    return TolgeeConfig.getLanguageDisplayNames();
  }

  // Check if a language is RTL
  bool isRTL(String languageCode) {
    const rtlLanguages = ['ar', 'he', 'ur'];
    return rtlLanguages.contains(languageCode);
  }

  // Get current text direction
  TextDirection getTextDirection() {
    return isRTL(currentLanguage.value) ? TextDirection.rtl : TextDirection.ltr;
  }

  // Add a new translation key (useful for development)
  void addTranslation(String languageCode, String key, String value) {
    if (_translations[languageCode] == null) {
      _translations[languageCode] = {};
    }
    _translations[languageCode]![key] = value;
    _translations.refresh();
  }

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}