import 'package:flutter/foundation.dart';

/// 🚀 Optimized Logger Service for Production Performance
/// Replaces all print() statements to improve app performance
class AppLogger {
  static const String _tag = 'AnantSpace';

  /// 🔍 Debug logs (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('🔍 [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// ✅ Success logs (only in debug mode)
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('✅ [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// ⚠️ Warning logs (only in debug mode)
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('⚠️ [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// ❌ Error logs (always shown for debugging)
  static void error(String message, [String? tag, Object? error]) {
    if (kDebugMode) {
      debugPrint('❌ [$_tag${tag != null ? ':$tag' : ''}] $message');
      if (error != null) {
        debugPrint('   Error details: $error');
      }
    }
  }

  /// 🌐 API logs (only in debug mode)
  static void api(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('🌐 [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// 📱 UI logs (only in debug mode)
  static void ui(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('📱 [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// 🔐 Auth logs (only in debug mode)
  static void auth(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('🔐 [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }

  /// 📁 Storage logs (only in debug mode)
  static void storage(String message, [String? tag]) {
    if (kDebugMode) {
      debugPrint('📁 [$_tag${tag != null ? ':$tag' : ''}] $message');
    }
  }
}