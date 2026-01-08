import 'package:flutter/foundation.dart';

/// Secure logging utility that only logs in debug mode
/// and masks sensitive data like tokens, PINs, passwords
class SecureLogger {
  /// Log a message (only in debug mode)
  static void log(String message, {bool sensitive = false}) {
    if (kDebugMode) {
      if (sensitive) {
        print('[SENSITIVE] ${_maskSensitiveData(message)}');
      } else {
        print(message);
      }
    }
  }

  /// Log info message
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  /// Log success message
  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }

  /// Log warning message
  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  /// Log error with optional stack trace
  static void error(String error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }
  }

  /// Log API request (masks sensitive headers)
  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? headers,
    dynamic body,
  }) {
    if (kDebugMode) {
      print('\n🌐 ===== API REQUEST START =====');
      print('📍 Method: $method');
      print('📍 URL: $url');

      if (headers != null) {
        final maskedHeaders = _maskHeaders(headers);
        print('📋 Headers: $maskedHeaders');
      }

      if (body != null) {
        print('📦 Body: $body');
      }
      print('🌐 ===== API REQUEST END =====\n');
    }
  }

  /// Log API response
  static void apiResponse({
    required int statusCode,
    required String url,
    dynamic body,
  }) {
    if (kDebugMode) {
      print('\n📡 ===== API RESPONSE START =====');
      print('📍 URL: $url');
      print('📈 Status: $statusCode');

      if (body != null) {
        // Mask any tokens in response
        final maskedBody = _maskSensitiveData(body.toString());
        print('📄 Body: $maskedBody');
      }
      print('📡 ===== API RESPONSE END =====\n');
    }
  }

  /// Mask sensitive data in strings
  static String _maskSensitiveData(String data) {
    String masked = data;

    // Mask Bearer tokens
    final tokenRegex = RegExp(r'Bearer\s+[A-Za-z0-9\-_.]+');
    masked = masked.replaceAllMapped(tokenRegex, (match) => 'Bearer ***MASKED***');

    // Mask JWT tokens (long alphanumeric strings)
    final jwtRegex = RegExp(r'[A-Za-z0-9\-_]{20,}\.[A-Za-z0-9\-_]{20,}\.[A-Za-z0-9\-_]{20,}');
    masked = masked.replaceAllMapped(jwtRegex, (match) => '***JWT_TOKEN_MASKED***');

    // Mask 10-digit phone numbers
    final phoneRegex = RegExp(r'\b\d{10}\b');
    masked = masked.replaceAllMapped(phoneRegex, (match) {
      final phone = match.group(0)!;
      return '${phone.substring(0, 2)}****${phone.substring(8)}';
    });

    // Mask 4-digit PINs
    final pinRegex = RegExp(r'\b\d{4}\b');
    masked = masked.replaceAllMapped(pinRegex, (match) => '****');

    // Mask passwords
    final passwordRegex = RegExp(r'"password"\s*:\s*"[^"]*"', caseSensitive: false);
    masked = masked.replaceAllMapped(passwordRegex, (match) => '"password":"***MASKED***"');

    // Mask security keys
    final securityKeyRegex = RegExp(r'"securityKey"\s*:\s*"[^"]*"', caseSensitive: false);
    masked = masked.replaceAllMapped(securityKeyRegex, (match) => '"securityKey":"***MASKED***"');

    return masked;
  }

  /// Mask sensitive headers (Authorization, etc.)
  static Map<String, dynamic> _maskHeaders(Map<String, dynamic> headers) {
    final masked = Map<String, dynamic>.from(headers);

    // Mask Authorization header
    if (masked.containsKey('Authorization')) {
      masked['Authorization'] = 'Bearer ***MASKED***';
    }

    if (masked.containsKey('authorization')) {
      masked['authorization'] = 'Bearer ***MASKED***';
    }

    return masked;
  }

  /// Log controller lifecycle events
  static void controllerLifecycle(String controllerName, String event) {
    if (kDebugMode) {
      print('🔄 Controller: $controllerName → $event');
    }
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    if (kDebugMode) {
      print('🧭 Navigation: $from → $to');
    }
  }

  /// Log data model parsing
  static void modelParsing(String modelName, {bool success = true}) {
    if (kDebugMode) {
      if (success) {
        print('📦 Model Parsed: $modelName ✅');
      } else {
        print('📦 Model Parse Failed: $modelName ❌');
      }
    }
  }

  /// Divider for separating log sections
  static void divider([String? label]) {
    if (kDebugMode) {
      if (label != null) {
        print('\n━━━━━━━━━━ $label ━━━━━━━━━━\n');
      } else {
        print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      }
    }
  }
}
