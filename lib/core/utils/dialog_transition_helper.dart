import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for smooth dialog transitions
/// Keeps keyboard open between multiple dialogs for seamless UX
/// Use this class whenever showing multiple dialogs in sequence
class DialogTransitionHelper {
  /// Default delay for dialog transition animation (milliseconds)
  /// This is the time for dialog dismiss + new dialog appear animation
  static const int _dialogTransitionDelay = 100;

  /// Default delay for keyboard close animation (milliseconds)
  static const int _keyboardCloseDelay = 350;

  /// Wait for dialog transition WITHOUT closing keyboard
  /// Use this between dialogs that have text input fields
  /// Keyboard stays open, only waits for dialog animation
  static Future<void> waitForDialogTransition({int? delayMs}) async {
    await Future.delayed(Duration(milliseconds: delayMs ?? _dialogTransitionDelay));
  }

  /// Wait for keyboard to close (use only when needed)
  /// Call this only when you want to explicitly close keyboard
  static Future<void> waitForKeyboardClose({int? delayMs}) async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await Future.delayed(Duration(milliseconds: delayMs ?? _keyboardCloseDelay));
  }

  /// Hide keyboard immediately
  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Hide keyboard using FocusScope (alternative method)
  static void hideKeyboardWithContext(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Prepare for dialog sequence - keeps keyboard state
  /// Just a minimal wait for any pending UI updates
  static Future<void> prepareForDialogSequence(BuildContext context) async {
    // Just wait for any pending frame, don't hide keyboard
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Show dialog keeping keyboard open
  /// Automatically handles smooth transition
  static Future<T?> showDialogKeepingKeyboard<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) async {
    if (!context.mounted) return null;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show dialog and hide keyboard first (for final dialog in sequence)
  static Future<T?> showDialogWithKeyboardClose<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) async {
    await waitForKeyboardClose();

    if (!context.mounted) return null;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: builder,
    );
  }

  /// Show bottom sheet keeping keyboard open
  static Future<T?> showBottomSheetKeepingKeyboard<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) async {
    if (!context.mounted) return null;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor,
      shape: shape,
      builder: builder,
    );
  }
}