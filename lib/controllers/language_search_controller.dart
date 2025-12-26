import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/localization_service.dart';

class LanguageSearchController extends GetxController {
  // Search related properties
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;
  var filteredLanguages = <Map<String, String>>[].obs;
  var isSearching = false.obs;

  // Selection state
  var selectedLanguageKey = ''.obs;
  var isSelecting = false.obs;
  var autoSelectedLanguageKey = ''.obs; // Auto-selected language during search

  // Get languages from LocalizationService to ensure consistency
  List<Map<String, String>> get originalLanguages {
    return Get.find<LocalizationService>().getLanguageList();
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize with all languages
    filteredLanguages.value = originalLanguages;

    // Don't set any auto-selected language initially
    autoSelectedLanguageKey.value = '';

    // Listen to search changes
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    // Prevent usage after disposal
    if (isClosed) return;

    searchQuery.value = searchController.text;
    _performSearch();
  }

  void _performSearch() {
    final query = searchQuery.value.toLowerCase().trim();

    if (query.isEmpty) {
      // Show all languages in original order when search is empty
      filteredLanguages.value = originalLanguages;
      isSearching.value = false;
      // Clear auto-selection when search is cleared
      autoSelectedLanguageKey.value = '';
    } else {
      isSearching.value = true;

      // Create separate lists for different match types
      List<Map<String, String>> exactMatches = [];
      List<Map<String, String>> startsWith = [];
      List<Map<String, String>> contains = [];

      for (final language in originalLanguages) {
        final name = language['name']!.toLowerCase();
        final englishName = _getEnglishName(language['code']!).toLowerCase();

        // Check for exact matches first
        if (name == query || englishName == query) {
          exactMatches.add(language);
        }
        // Check for starts with
        else if (name.startsWith(query) || englishName.startsWith(query)) {
          startsWith.add(language);
        }
        // Check for contains
        else if (name.contains(query) || englishName.contains(query)) {
          contains.add(language);
        }
      }

      // Combine results: exact matches first, then starts with, then contains
      filteredLanguages.value = [
        ...exactMatches,
        ...startsWith,
        ...contains,
      ];

      // Auto-select first search result when typing
      if (filteredLanguages.isNotEmpty) {
        autoSelectedLanguageKey.value = filteredLanguages.first['code']!;
      } else {
        autoSelectedLanguageKey.value = '';
      }
    }
  }

  // Helper method to get English names for better search
  String _getEnglishName(String key) {
    final englishNames = {
      'en': 'english',
      'hi': 'hindi',
      'gu': 'gujarati',
      'bn': 'bengali',
      'ta': 'tamil',
      'te': 'telugu',
      'kn': 'kannada',
      'mr': 'marathi',
      'or': 'odia',
      'ml': 'malayalam',
      'pa': 'punjabi',
      'as': 'assamese',
    };
    return englishNames[key] ?? '';
  }

  // Clear search
  void clearSearch() {
    // Prevent usage after disposal
    if (isClosed) return;

    searchController.clear();
    searchQuery.value = '';
    filteredLanguages.value = originalLanguages;
    isSearching.value = false;
    // Clear auto-selection when search is cleared
    autoSelectedLanguageKey.value = '';
  }

  // Get current language list
  List<Map<String, String>> get currentLanguages => filteredLanguages;

  // Check if any language matches the search
  bool get hasResults => filteredLanguages.isNotEmpty;

  // Get search results count
  int get resultsCount => filteredLanguages.length;

  // Get search status message
  String get searchStatusMessage {
    if (!isSearching.value) return '';

    if (filteredLanguages.isEmpty) {
      return 'No languages found for "${searchQuery.value}"';
    } else if (filteredLanguages.length == 1) {
      return '1 language found';
    } else {
      return '${filteredLanguages.length} languages found';
    }
  }

  // Selection methods
  void selectLanguage(String languageKey) {
    selectedLanguageKey.value = languageKey;
    isSelecting.value = true;
    update(); // Force rebuild
  }

  void clearSelection() {
    selectedLanguageKey.value = '';
    isSelecting.value = false;
    update();
  }

  bool isLanguageSelected(String languageKey) {
    return selectedLanguageKey.value == languageKey;
  }

  // Check if language should appear as auto-selected
  bool isLanguageAutoSelected(String languageKey) {
    return autoSelectedLanguageKey.value == languageKey;
  }

  @override
  void onClose() {
    // Remove listener before disposing to prevent "used after being disposed" errors
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }
}