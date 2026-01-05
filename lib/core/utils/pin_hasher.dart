import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'secure_logger.dart';

/// Utility for securely hashing PINs before transmission
///
/// Uses SHA-256 hashing with optional salt for added security.
/// This prevents plain-text PINs from being exposed in logs or intercepted traffic.
///
/// Usage:
/// ```dart
/// final hashedPin = PinHasher.hashPin('1234', salt: userId);
/// ```
class PinHasher {
  /// Hash PIN using SHA-256 with optional salt
  ///
  /// [pin] - The PIN to hash (typically 4-6 digits)
  /// [salt] - Optional salt value for uniqueness (e.g., userId or merchantId)
  ///
  /// Returns hashed PIN as hexadecimal string
  static String hashPin(String pin, {String? salt}) {
    try {
      // Use provided salt or default
      final saltValue = salt ?? 'aukra_anantkhata_2025';

      // Combine PIN with salt
      final combined = '$pin:$saltValue';

      // Convert to bytes
      final bytes = utf8.encode(combined);

      // Generate SHA-256 hash
      final hash = sha256.convert(bytes);

      SecureLogger.log('PIN hashed successfully', sensitive: true);

      return hash.toString();
    } catch (e) {
      SecureLogger.error('Failed to hash PIN: $e');
      rethrow;
    }
  }

  /// Hash PIN with timestamp for one-time use scenarios
  ///
  /// Useful for preventing replay attacks - each hash is unique even for same PIN
  ///
  /// [pin] - The PIN to hash
  /// [salt] - Optional salt value
  ///
  /// Returns object containing hash and timestamp
  static HashedPinWithTimestamp hashPinWithTimestamp(String pin, {String? salt}) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final saltValue = salt ?? 'aukra_anantkhata_2025';

      // Combine PIN + salt + timestamp
      final combined = '$pin:$saltValue:$timestamp';

      // Convert to bytes and hash
      final bytes = utf8.encode(combined);
      final hash = sha256.convert(bytes);

      SecureLogger.log('PIN hashed with timestamp', sensitive: true);

      return HashedPinWithTimestamp(
        hash: hash.toString(),
        timestamp: timestamp,
      );
    } catch (e) {
      SecureLogger.error('Failed to hash PIN with timestamp: $e');
      rethrow;
    }
  }

  /// Verify if a PIN matches a hash
  ///
  /// [pin] - The PIN to verify
  /// [hash] - The hash to compare against
  /// [salt] - Salt used during original hashing
  ///
  /// Returns true if PIN matches the hash
  static bool verifyPin(String pin, String hash, {String? salt}) {
    final computedHash = hashPin(pin, salt: salt);
    return computedHash == hash;
  }

  /// Generate a random salt value
  ///
  /// Useful for creating unique salts per user
  static String generateSalt() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    final combined = '$timestamp:$random';

    final bytes = utf8.encode(combined);
    final hash = sha256.convert(bytes);

    return hash.toString().substring(0, 16); // Use first 16 characters
  }

  /// Hash with HMAC-SHA256 for extra security
  ///
  /// HMAC provides stronger authentication than simple hashing
  ///
  /// [pin] - The PIN to hash
  /// [secretKey] - Secret key for HMAC (should be stored securely)
  ///
  /// Returns HMAC hash
  static String hashPinWithHMAC(String pin, String secretKey) {
    try {
      final key = utf8.encode(secretKey);
      final bytes = utf8.encode(pin);

      final hmac = Hmac(sha256, key);
      final digest = hmac.convert(bytes);

      SecureLogger.log('PIN hashed with HMAC', sensitive: true);

      return digest.toString();
    } catch (e) {
      SecureLogger.error('Failed to hash PIN with HMAC: $e');
      rethrow;
    }
  }
}

/// Result of PIN hashing with timestamp
class HashedPinWithTimestamp {
  final String hash;
  final int timestamp;

  HashedPinWithTimestamp({
    required this.hash,
    required this.timestamp,
  });

  /// Convert to JSON for API transmission
  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'timestamp': timestamp,
    };
  }

  /// Create from JSON
  factory HashedPinWithTimestamp.fromJson(Map<String, dynamic> json) {
    return HashedPinWithTimestamp(
      hash: json['hash'] as String,
      timestamp: json['timestamp'] as int,
    );
  }
}
