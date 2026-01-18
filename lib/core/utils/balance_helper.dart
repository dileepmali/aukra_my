import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';

/// Centralized helper class for balance positive/negative logic
///
/// Usage:
/// - `BalanceHelper.isPositive(transactionType: 'IN')` → true
/// - `BalanceHelper.isPositive(balanceType: 'OUT')` → false
/// - `BalanceHelper.getBalanceColor(transactionType: 'IN')` → Green
/// - `BalanceHelper.getBalanceColor(balanceType: 'OUT')` → Red
///
/// Rules:
/// - "IN" = Positive (Green) - Customer owes you / Receivable
/// - "OUT" = Negative (Red) - You owe customer / Payable
class BalanceHelper {

  // 🧪 DEBUG MODE - Set to true to see balance logs in console
  static bool debugMode = false;

  /// Check if balance is positive
  /// Use either transactionType or balanceType (both follow same logic)
  ///
  /// Returns true if "IN" (positive/receivable)
  /// Returns false if "OUT" (negative/payable)
  static bool isPositive({
    String? transactionType,
    String? balanceType,
    String? itemName, // Optional: for debug logging
  }) {
    // Priority: balanceType > transactionType
    final type = balanceType ?? transactionType ?? 'OUT';
    final result = type == 'IN';

    // 🧪 DEBUG LOG
    if (debugMode) {
      debugPrint('🧪 BalanceHelper.isPositive()');
      debugPrint('   Item: ${itemName ?? "N/A"}');
      debugPrint('   Type: $type');
      debugPrint('   Result: ${result ? "POSITIVE ✅ (GREEN)" : "NEGATIVE ❌ (RED)"}');
    }

    return result;
  }

  /// Get balance color based on type
  ///
  /// "IN" = Green (primeryamount)
  /// "OUT" = Red (red500)
  static Color getBalanceColor({
    String? transactionType,
    String? balanceType,
    bool isDark = true,
  }) {
    final positive = isPositive(
      transactionType: transactionType,
      balanceType: balanceType,
    );

    return positive
        ? AppColors.primeryamount  // Green
        : AppColors.red500;        // Red
  }

  /// Get balance color for light theme
  static Color getBalanceColorLight({
    String? transactionType,
    String? balanceType,
  }) {
    final positive = isPositive(
      transactionType: transactionType,
      balanceType: balanceType,
    );

    return positive
        ? AppColorsLight.success  // Green for light theme
        : AppColorsLight.error;   // Red for light theme
  }

  /// Get balance text label
  ///
  /// "IN" = "Receivable" / "You will receive"
  /// "OUT" = "Payable" / "You will pay"
  static String getBalanceLabel({
    String? transactionType,
    String? balanceType,
    bool shortLabel = false,
  }) {
    final positive = isPositive(
      transactionType: transactionType,
      balanceType: balanceType,
    );

    if (shortLabel) {
      return positive ? 'Receivable' : 'Payable';
    }
    return positive ? 'You will receive' : 'You will pay';
  }

  // ═══════════════════════════════════════════════════════════
  // 🧪 DEBUG METHODS
  // ═══════════════════════════════════════════════════════════

  /// Enable debug mode to see balance logs in console
  static void enableDebug() {
    debugMode = true;
    debugPrint('');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('🧪 BALANCE DEBUG MODE: ON');
    debugPrint('🧪 ──────────────────────────────────────────');
    debugPrint('🧪 Rules:');
    debugPrint('🧪   IN  → POSITIVE ✅ (GREEN)');
    debugPrint('🧪   OUT → NEGATIVE ❌ (RED)');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('');
  }

  /// Disable debug mode
  static void disableDebug() {
    debugMode = false;
    debugPrint('');
    debugPrint('🧪 BALANCE DEBUG MODE: OFF');
    debugPrint('');
  }

  /// Toggle debug mode
  static void toggleDebug() {
    if (debugMode) {
      disableDebug();
    } else {
      enableDebug();
    }
  }

  /// Print summary of balance logic rules
  static void printRules() {
    debugPrint('');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('🧪 BALANCE LOGIC RULES');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('🧪');
    debugPrint('🧪 transactionType / balanceType:');
    debugPrint('🧪 ┌─────────┬───────────┬─────────┐');
    debugPrint('🧪 │  Type   │  Result   │  Color  │');
    debugPrint('🧪 ├─────────┼───────────┼─────────┤');
    debugPrint('🧪 │   IN    │ POSITIVE  │  GREEN  │');
    debugPrint('🧪 │   OUT   │ NEGATIVE  │   RED   │');
    debugPrint('🧪 └─────────┴───────────┴─────────┘');
    debugPrint('🧪');
    debugPrint('🧪 Meaning:');
    debugPrint('🧪   IN  = Customer owes you (Receivable)');
    debugPrint('🧪   OUT = You owe customer (Payable)');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('');
  }
}
