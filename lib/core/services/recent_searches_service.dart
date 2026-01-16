import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage recent search queries
/// Stores search history locally using SharedPreferences
class RecentSearchesService {
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10; // Maximum number of recent searches to store

  /// Save a search query to recent searches
  static Future<void> saveSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing searches
      List<String> recentSearches = await getRecentSearches();

      // Remove if already exists (to move it to top)
      recentSearches.remove(query.trim());

      // Add to beginning of list
      recentSearches.insert(0, query.trim());

      // Keep only the most recent searches
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches = recentSearches.sublist(0, _maxRecentSearches);
      }

      // Save to SharedPreferences
      await prefs.setStringList(_recentSearchesKey, recentSearches);

      if (kDebugMode) {
        print('✅ Saved search query: "$query"');
        print('   Total recent searches: ${recentSearches.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving search query: $e');
      }
    }
  }

  /// Get all recent searches
  static Future<List<String>> getRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final searches = prefs.getStringList(_recentSearchesKey) ?? [];

      if (kDebugMode) {
        print('📋 Retrieved ${searches.length} recent searches');
      }

      return searches;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error retrieving recent searches: $e');
      }
      return [];
    }
  }

  /// Clear a specific search from recent searches
  static Future<void> removeSearch(String query) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> recentSearches = await getRecentSearches();

      recentSearches.remove(query);

      await prefs.setStringList(_recentSearchesKey, recentSearches);

      if (kDebugMode) {
        print('🗑️ Removed search query: "$query"');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error removing search query: $e');
      }
    }
  }

  /// Clear all recent searches
  static Future<void> clearAllSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentSearchesKey);

      if (kDebugMode) {
        print('🗑️ Cleared all recent searches');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing recent searches: $e');
      }
    }
  }
}
