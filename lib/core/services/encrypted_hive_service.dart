import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../utils/secure_logger.dart';

/// Encrypted Hive service for secure local data storage
///
/// Uses AES encryption with keys stored in Flutter Secure Storage
/// to protect sensitive data at rest (contacts, cached data, etc.)
///
/// Usage:
/// ```dart
/// await EncryptedHiveService.init();
/// final box = await EncryptedHiveService.openEncryptedBox<Contact>('contacts');
/// ```
class EncryptedHiveService {
  static const _secureStorage = FlutterSecureStorage();
  static const _encryptionKeyName = 'hive_encryption_key_v1';
  static bool _initialized = false;

  /// Initialize Hive with Flutter
  ///
  /// Call this once during app startup
  static Future<void> init() async {
    if (_initialized) {
      SecureLogger.warning('EncryptedHiveService already initialized');
      return;
    }

    try {
      await Hive.initFlutter();
      _initialized = true;
      SecureLogger.success('EncryptedHiveService initialized successfully');
    } catch (e) {
      SecureLogger.error('Failed to initialize EncryptedHiveService: $e');
      rethrow;
    }
  }

  /// Get or generate encryption key for Hive
  ///
  /// - First time: Generates a new 256-bit key and stores in secure storage
  /// - Subsequent calls: Retrieves existing key from secure storage
  ///
  /// Returns Uint8List encryption key for Hive
  static Future<Uint8List> getEncryptionKey() async {
    try {
      // Check if key already exists in secure storage
      String? keyString = await _secureStorage.read(key: _encryptionKeyName);

      if (keyString == null) {
        SecureLogger.info('Generating new Hive encryption key');

        // Generate new 256-bit AES key
        final key = Hive.generateSecureKey();

        // Convert to base64 for storage
        final keyBase64 = base64Url.encode(key);

        // Save to secure storage (encrypted at OS level)
        await _secureStorage.write(
          key: _encryptionKeyName,
          value: keyBase64,
        );

        SecureLogger.success('Hive encryption key generated and stored');

        return Uint8List.fromList(key);
      }

      // Decode existing key from base64
      final keyBytes = base64Url.decode(keyString);
      SecureLogger.info('Loaded existing Hive encryption key');

      return Uint8List.fromList(keyBytes);
    } catch (e) {
      SecureLogger.error('Failed to get/generate encryption key: $e');
      rethrow;
    }
  }

  /// Open an encrypted Hive box
  ///
  /// [boxName] - Name of the box to open
  /// [T] - Type of objects stored in the box
  ///
  /// Returns encrypted Box instance
  static Future<Box<T>> openEncryptedBox<T>(String boxName) async {
    try {
      if (!_initialized) {
        await init();
      }

      // Get encryption key
      final encryptionKey = await getEncryptionKey();

      // Check if box is already open
      if (Hive.isBoxOpen(boxName)) {
        SecureLogger.info('Box "$boxName" already open, returning existing instance');
        return Hive.box<T>(boxName);
      }

      SecureLogger.info('Opening encrypted box: $boxName');

      // Open box with encryption
      final box = await Hive.openBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      SecureLogger.success('Encrypted box "$boxName" opened successfully');

      return box;
    } catch (e) {
      SecureLogger.error('Failed to open encrypted box "$boxName": $e');
      rethrow;
    }
  }

  /// Open a lazy encrypted Hive box (for large datasets)
  ///
  /// Lazy boxes load data on-demand, better for performance with large data
  static Future<LazyBox<T>> openEncryptedLazyBox<T>(String boxName) async {
    try {
      if (!_initialized) {
        await init();
      }

      final encryptionKey = await getEncryptionKey();

      if (Hive.isBoxOpen(boxName)) {
        SecureLogger.info('Lazy box "$boxName" already open');
        return Hive.lazyBox<T>(boxName);
      }

      SecureLogger.info('Opening encrypted lazy box: $boxName');

      final box = await Hive.openLazyBox<T>(
        boxName,
        encryptionCipher: HiveAesCipher(encryptionKey),
      );

      SecureLogger.success('Encrypted lazy box "$boxName" opened successfully');

      return box;
    } catch (e) {
      SecureLogger.error('Failed to open encrypted lazy box "$boxName": $e');
      rethrow;
    }
  }

  /// Close a specific box
  static Future<void> closeBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
        SecureLogger.info('Box "$boxName" closed');
      }
    } catch (e) {
      SecureLogger.error('Failed to close box "$boxName": $e');
    }
  }

  /// Delete a box and all its data
  ///
  /// WARNING: This permanently deletes all data in the box
  static Future<void> deleteBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).deleteFromDisk();
      } else {
        await Hive.deleteBoxFromDisk(boxName);
      }
      SecureLogger.success('Box "$boxName" deleted from disk');
    } catch (e) {
      SecureLogger.error('Failed to delete box "$boxName": $e');
    }
  }

  /// Delete encryption key from secure storage
  ///
  /// WARNING: After deleting the key, previously encrypted data cannot be decrypted
  static Future<void> deleteEncryptionKey() async {
    try {
      await _secureStorage.delete(key: _encryptionKeyName);
      SecureLogger.warning('Hive encryption key deleted - encrypted data will be unreadable');
    } catch (e) {
      SecureLogger.error('Failed to delete encryption key: $e');
    }
  }

  /// Close all open boxes
  static Future<void> closeAll() async {
    try {
      await Hive.close();
      _initialized = false;
      SecureLogger.info('All Hive boxes closed');
    } catch (e) {
      SecureLogger.error('Failed to close all boxes: $e');
    }
  }

  /// Delete all boxes and encryption key
  ///
  /// WARNING: This permanently deletes all locally stored data
  static Future<void> deleteAllData() async {
    try {
      await Hive.deleteFromDisk();
      await deleteEncryptionKey();
      _initialized = false;
      SecureLogger.warning('All Hive data and encryption key deleted');
    } catch (e) {
      SecureLogger.error('Failed to delete all data: $e');
    }
  }

  /// Check if a box exists
  static Future<bool> boxExists(String boxName) async {
    try {
      return await Hive.boxExists(boxName);
    } catch (e) {
      SecureLogger.error('Failed to check if box exists: $e');
      return false;
    }
  }

  /// Get box size in bytes (approximate)
  static Future<int?> getBoxSize(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        return null;
      }

      final box = Hive.box(boxName);
      // This is an approximation - actual file size may differ
      return box.length;
    } catch (e) {
      SecureLogger.error('Failed to get box size: $e');
      return null;
    }
  }

  /// Compact a box to reclaim disk space
  ///
  /// Useful after deleting many entries
  static Future<void> compactBox(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).compact();
        SecureLogger.success('Box "$boxName" compacted');
      }
    } catch (e) {
      SecureLogger.error('Failed to compact box "$boxName": $e');
    }
  }
}
