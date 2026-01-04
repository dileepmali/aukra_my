import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../models/contact_model.dart';

/// ✅ ULTRA FAST: Contact caching service using Hive
/// First load: 3-8 seconds (from device)
/// Subsequent loads: under 500ms (from cache)
class ContactCacheService {
  static const String _boxName = 'contacts_cache';
  static const String _contactsKey = 'cached_contacts';
  static const String _lastUpdateKey = 'last_update_timestamp';

  // Cache expiry: 24 hours (contacts don't change frequently)
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Initialize Hive (call this in main.dart before runApp)
  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      print("✅ Hive initialized for contact caching");
    } catch (e) {
      print("❌ Hive initialization error: $e");
    }
  }

  /// Get Hive box for contacts
  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  /// Check if cache exists and is valid (not expired)
  static Future<bool> isCacheValid() async {
    try {
      final box = await _getBox();

      // Check if cache exists
      if (!box.containsKey(_contactsKey)) {
        print("📭 No cached contacts found");
        return false;
      }

      // Check if cache is expired
      final lastUpdate = box.get(_lastUpdateKey) as int?;
      if (lastUpdate == null) {
        print("⚠️ Cache timestamp missing");
        return false;
      }

      final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
      final now = DateTime.now();
      final difference = now.difference(lastUpdateTime);

      if (difference > _cacheExpiry) {
        print("⏰ Cache expired (${difference.inHours} hours old)");
        return false;
      }

      print("✅ Cache is valid (${difference.inHours} hours old)");
      return true;
    } catch (e) {
      print("❌ Error checking cache validity: $e");
      return false;
    }
  }

  /// Load contacts from cache (ULTRA FAST - under 500ms)
  static Future<List<ContactItem>> loadFromCache() async {
    final loadStartTime = DateTime.now();
    print("🚀 Loading contacts from cache...");

    try {
      final box = await _getBox();

      // Get cached data
      final cachedData = box.get(_contactsKey) as List<dynamic>?;

      if (cachedData == null || cachedData.isEmpty) {
        print("📭 No cached contacts found");
        return [];
      }

      // Convert cached data to ContactItem objects
      List<ContactItem> contacts = [];

      for (var item in cachedData) {
        try {
          if (item is Map) {
            final contact = ContactItem(
              name: item['name'] as String? ?? '',
              phone: item['phone'] as String? ?? '',
              initials: item['initials'] as String? ?? '',
            );

            // Set tagIndex if available
            if (item['tagIndex'] != null) {
              contact.tagIndex = item['tagIndex'] as String;
            }

            contacts.add(contact);
          }
        } catch (e) {
          // Skip invalid contact items
          if (kDebugMode) {
            print("⚠️ Skipping invalid cached contact: $e");
          }
        }
      }

      final loadDuration = DateTime.now().difference(loadStartTime);
      print("⚡ CACHE HIT: Loaded ${contacts.length} contacts in ${loadDuration.inMilliseconds}ms");

      return contacts;
    } catch (e) {
      print("❌ Error loading from cache: $e");
      return [];
    }
  }

  /// Save contacts to cache for next time
  static Future<void> saveToCache(List<ContactItem> contacts) async {
    final saveStartTime = DateTime.now();
    print("💾 Saving ${contacts.length} contacts to cache...");

    try {
      final box = await _getBox();

      // Convert ContactItem objects to serializable maps
      List<Map<String, dynamic>> serializedContacts = [];

      for (var contact in contacts) {
        serializedContacts.add({
          'name': contact.name,
          'phone': contact.phone,
          'initials': contact.initials,
          'tagIndex': contact.tagIndex,
        });
      }

      // Save to cache
      await box.put(_contactsKey, serializedContacts);
      await box.put(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);

      final saveDuration = DateTime.now().difference(saveStartTime);
      print("✅ Cache saved successfully in ${saveDuration.inMilliseconds}ms");
    } catch (e) {
      print("❌ Error saving to cache: $e");
    }
  }

  /// Clear cache (useful for testing or manual refresh)
  static Future<void> clearCache() async {
    try {
      final box = await _getBox();
      await box.clear();
      print("🗑️ Contact cache cleared");
    } catch (e) {
      print("❌ Error clearing cache: $e");
    }
  }

  /// Get cache info for debugging
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final box = await _getBox();
      final lastUpdate = box.get(_lastUpdateKey) as int?;
      final contactsCount = (box.get(_contactsKey) as List<dynamic>?)?.length ?? 0;

      return {
        'exists': box.containsKey(_contactsKey),
        'count': contactsCount,
        'lastUpdate': lastUpdate != null
            ? DateTime.fromMillisecondsSinceEpoch(lastUpdate).toIso8601String()
            : 'Never',
        'isValid': await isCacheValid(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }
}
