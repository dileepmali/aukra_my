import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to get real device information
class DeviceInfoService {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  // Cached value
  static String? _deviceName;
  static String? _deviceType;
  static String? _deviceId;
  static String? _deviceVersion;

  /// Initialize device info (call once at app startup)
  static Future<void> init() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceName = androidInfo.model; // e.g., "OnePlus Nord", "Samsung Galaxy S21"
        _deviceType = 'ANDROID';
        _deviceId = androidInfo.id; // Unique device ID
        _deviceVersion = androidInfo.version.release; // e.g., "14", "13"

        debugPrint('');
        debugPrint('📱 ========== DEVICE INFO ==========');
        debugPrint('   Device Name: $_deviceName');
        debugPrint('   Device Type: $_deviceType');
        debugPrint('   Device ID: $_deviceId');
        debugPrint('   Android Version: $_deviceVersion');
        debugPrint('   Brand: ${androidInfo.brand}');
        debugPrint('   Manufacturer: ${androidInfo.manufacturer}');
        debugPrint('=====================================');
        debugPrint('');
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceName = iosInfo.name; // e.g., "iPhone 15 Pro"
        _deviceType = 'IOS';
        _deviceId = iosInfo.identifierForVendor; // Unique device ID
        _deviceVersion = iosInfo.systemVersion; // e.g., "17.0"

        debugPrint('');
        debugPrint('📱 ========== DEVICE INFO ==========');
        debugPrint('   Device Name: $_deviceName');
        debugPrint('   Device Type: $_deviceType');
        debugPrint('   Device ID: $_deviceId');
        debugPrint('   iOS Version: $_deviceVersion');
        debugPrint('   Model: ${iosInfo.model}');
        debugPrint('=====================================');
        debugPrint('');
      }
    } catch (e) {
      debugPrint('❌ Error getting device info: $e');
      // Fallback values
      _deviceName = 'Unknown Device';
      _deviceType = Platform.isAndroid ? 'ANDROID' : 'IOS';
      _deviceId = 'unknown_device_id';
      _deviceVersion = '1.0';
    }
  }

  /// Get device name (e.g., "OnePlus Nord", "iPhone 15 Pro")
  static String get deviceName => _deviceName ?? 'Unknown Device';

  /// Get device type (ANDROID or IOS)
  static String get deviceType => _deviceType ?? (Platform.isAndroid ? 'ANDROID' : 'IOS');

  /// Get unique device ID
  static String get deviceId => _deviceId ?? 'unknown_device_id';

  /// Get device OS version (e.g., "14", "17.0")
  static String get deviceVersion => _deviceVersion ?? '1.0';

  /// Check if device info is initialized
  static bool get isInitialized => _deviceName != null;
}