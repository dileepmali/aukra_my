import 'package:flutter/services.dart';

/// 🎯 HapticService - Centralized haptic feedback service
/// Provides consistent tactile feedback across the app
///
/// Usage:
/// - Light impact: Navigation, bottom bar taps, checkbox toggles
/// - Medium impact: Primary actions (FAB, submit buttons)
/// - Heavy impact: Critical actions (delete, confirm)
/// - Selection: Picker/dropdown selection changes
/// - Vibrate: Success/error notifications
class HapticService {

  /// ✅ Light impact - For subtle interactions
  /// Use for: Bottom navigation, list item taps, checkbox toggles
  static Future<void> lightImpact() async {
    print('🔊 HapticService: lightImpact() called');
    try {
      // ✅ Use selectionClick for more noticeable feedback
      await HapticFeedback.selectionClick();
      print('✅ HapticService: lightImpact() executed successfully');
    } catch (e) {
      // Ignore haptic errors (not supported on all devices)
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Medium impact - For primary actions
  /// Use for: FAB, submit buttons, primary CTAs
  static Future<void> mediumImpact() async {
    print('🔊 HapticService: mediumImpact() called');
    try {
      // ✅ Use vibrate() for more noticeable feedback on button presses
      await HapticFeedback.vibrate();
      print('✅ HapticService: mediumImpact() executed successfully');
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Heavy impact - For critical actions
  /// Use for: Delete confirmations, destructive actions
  static Future<void> heavyImpact() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Selection click - For picker/dropdown changes
  /// Use for: Date picker, dropdown selection, slider changes
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Vibrate - For notifications and alerts
  /// Use for: Success notifications, error alerts, completion feedback
  static Future<void> vibrate() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Success feedback - Light vibration for success
  static Future<void> success() async {
    try {
      await HapticFeedback.lightImpact();
      await Future.delayed(Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Error feedback - Heavy vibration for errors
  static Future<void> error() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }

  /// ✅ Warning feedback - Medium vibration for warnings
  static Future<void> warning() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      print('⚠️ Haptic feedback not supported: $e');
    }
  }
}
