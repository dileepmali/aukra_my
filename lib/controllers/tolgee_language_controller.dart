import 'package:get/get.dart';

import '../config/tolgee_config.dart';
import '../core/services/tolgee_localization_service.dart';


class TolgeeLanguageController extends GetxController {
  late final TolgeeLocalizationService _tolgeeService;

  final RxString selectedLanguageCode = 'en'.obs;
  final RxBool isChangingLanguage = false.obs;
  final RxList<Map<String, String>> availableLanguages = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLanguages();
    _tolgeeService = Get.find<TolgeeLocalizationService>();

    // Sync with Tolgee service
    ever(_tolgeeService.currentLanguage, (language) {
      selectedLanguageCode.value = language;
    });

    selectedLanguageCode.value = _tolgeeService.currentLanguage.value;
  }

  void _initializeLanguages() {
    final languageMap = TolgeeConfig.getLanguageDisplayNames();
    availableLanguages.value = languageMap.entries.map((entry) {
      return {
        'code': entry.key,
        'name': entry.value,
      };
    }).toList();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (languageCode == selectedLanguageCode.value) {
      return; // No change needed
    }

    try {
      isChangingLanguage.value = true;

      // Change language in Tolgee service
      await _tolgeeService.changeLanguage(languageCode);

      selectedLanguageCode.value = languageCode;

      // Refresh UI to apply new translations
      Get.forceAppUpdate();

    } catch (e) {
      print('Error changing language: $e');
      Get.snackbar(
        'Error',
        'Failed to change language. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isChangingLanguage.value = false;
    }
  }

  String getLanguageDisplayName(String code) {
    final languages = TolgeeConfig.getLanguageDisplayNames();
    return languages[code] ?? code;
  }

  bool isLanguageSelected(String code) {
    return selectedLanguageCode.value == code;
  }

  // Helper method to get translated text
  String t(String key, {Map<String, dynamic>? params}) {
    return _tolgeeService.t(key, params: params);
  }

  // Search languages by name
  List<Map<String, String>> searchLanguages(String query) {
    if (query.isEmpty) {
      return availableLanguages;
    }

    final lowerQuery = query.toLowerCase();
    return availableLanguages.where((lang) {
      final name = lang['name']?.toLowerCase() ?? '';
      final code = lang['code']?.toLowerCase() ?? '';
      return name.contains(lowerQuery) || code.contains(lowerQuery);
    }).toList();
  }
}