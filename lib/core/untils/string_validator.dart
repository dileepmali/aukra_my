import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// String validation and sanitization utilities
class StringValidator {
  /// Sanitize text to prevent UTF-16 surrogate pair errors
  /// Removes invalid Unicode characters that can cause crashes
  static String sanitizeForText(String input) {
    if (input.isEmpty) return input;

    try {
      // Remove zero-width characters and other problematic Unicode
      String sanitized = input
          .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '') // Zero-width chars
          .replaceAll(RegExp(r'[\u0000-\u001F]'), '') // Control characters
          .trim();

      // Validate using characters property to safely handle emojis
      final characters = sanitized.characters;
      if (characters.isEmpty) return '';

      // Return sanitized string
      return sanitized;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ StringValidator: Error sanitizing text: $e');
      }
      // Return empty string on error to prevent crashes
      return '';
    }
  }

  /// Validate if string contains only valid characters
  static bool isValidText(String input) {
    if (input.isEmpty) return false;

    try {
      final characters = input.characters;
      return characters.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Remove emojis from string
  static String removeEmojis(String input) {
    if (input.isEmpty) return input;

    try {
      return input.replaceAll(
        RegExp(
          r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
        ),
        '',
      );
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ StringValidator: Error removing emojis: $e');
      }
      return input;
    }
  }

  /// Sanitize phone number (keep only digits and +)
  static String sanitizePhoneNumber(String phone) {
    if (phone.isEmpty) return phone;

    try {
      return phone.replaceAll(RegExp(r'[^\d+]'), '');
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ StringValidator: Error sanitizing phone number: $e');
      }
      return phone;
    }
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;

    try {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );
      return emailRegex.hasMatch(email);
    } catch (e) {
      return false;
    }
  }

  /// Truncate string to max length with ellipsis
  static String truncate(String input, int maxLength, {bool addEllipsis = true}) {
    if (input.isEmpty || input.length <= maxLength) return input;

    try {
      final characters = input.characters;
      if (characters.length <= maxLength) return input;

      final truncated = characters.take(maxLength).toString();
      return addEllipsis ? '$truncated...' : truncated;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ StringValidator: Error truncating string: $e');
      }
      return input;
    }
  }
}
