import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Native Android contact fetching service using MethodChannel
/// Directly communicates with Android ContactsContract API for better performance
class NativeContactService {
  // MethodChannel for Android native communication
  static const MethodChannel _channel = MethodChannel('com.aukra/contacts');

  /// Fetch all contacts from device using native Android API
  /// Returns List<Map<String, String>> with 'name' and 'phone' keys
  static Future<List<Map<String, String>>> fetchContacts() async {
    try {
      print('📱 NativeContactService: Fetching contacts from native Android...');

      // Call native Android method
      final dynamic result = await _channel.invokeMethod('getContacts');

      if (result == null) {
        print('⚠️ NativeContactService: Native method returned null');
        return [];
      }

      // Convert result to List<Map<String, String>>
      final List<Map<String, String>> contacts = [];

      if (result is List) {
        for (var item in result) {
          if (item is Map) {
            final name = item['name']?.toString() ?? '';
            final phone = item['phone']?.toString() ?? '';

            // Only add contacts with non-empty names
            if (name.isNotEmpty) {
              contacts.add({
                'name': name,
                'phone': phone,
              });
            }
          }
        }
      }

      print('✅ NativeContactService: Fetched ${contacts.length} contacts from native');

      // Debug: Print first 3 contacts
      if (kDebugMode && contacts.isNotEmpty) {
        print('📋 First 3 contacts:');
        for (int i = 0; i < contacts.length.clamp(0, 3); i++) {
          print('   ${i + 1}. Name: "${contacts[i]['name']}", Phone: "${contacts[i]['phone']}"');
        }
      }

      return contacts;
    } on PlatformException catch (e) {
      print('❌ NativeContactService: Platform error - ${e.message}');
      print('   Code: ${e.code}, Details: ${e.details}');
      return [];
    } catch (e, stackTrace) {
      print('❌ NativeContactService: Unexpected error - $e');
      if (kDebugMode) {
        print('   Stack trace: $stackTrace');
      }
      return [];
    }
  }

  /// Check if contact permission is granted (via native)
  static Future<bool> hasPermission() async {
    try {
      final bool? result = await _channel.invokeMethod('hasContactPermission');
      return result ?? false;
    } catch (e) {
      print('❌ NativeContactService: Error checking permission - $e');
      return false;
    }
  }

  /// Request contact permission (via native)
  static Future<bool> requestPermission() async {
    try {
      final bool? result = await _channel.invokeMethod('requestContactPermission');
      return result ?? false;
    } catch (e) {
      print('❌ NativeContactService: Error requesting permission - $e');
      return false;
    }
  }
}
