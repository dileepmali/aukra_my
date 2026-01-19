import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';

/// Centralized helper class for balance positive/negative logic
///
/// ════════════════════════════════════════════════════════════
/// 📘 CORRECT FORMULA
/// ════════════════════════════════════════════════════════════
///
/// Formula: Closing Balance = Opening + IN - OUT
///
/// - IN = Money received (adds to balance)
/// - OUT = Money/goods given (subtracts from balance)
///
/// Balance Color Rules:
/// ┌─────────────────┬──────────────────────────────┬─────────┐
/// │ Balance         │ Meaning                      │ Color   │
/// ├─────────────────┼──────────────────────────────┼─────────┤
/// │ Positive (> 0)  │ Customer owes YOU            │ 🔴 RED  │
/// │                 │ (You will RECEIVE)           │         │
/// ├─────────────────┼──────────────────────────────┼─────────┤
/// │ Negative (< 0)  │ YOU owe customer             │ ✅ GREEN│
/// │                 │ (You will GIVE)              │         │
/// ├─────────────────┼──────────────────────────────┼─────────┤
/// │ Zero (= 0)      │ No balance                   │ Neutral │
/// └─────────────────┴──────────────────────────────┴─────────┘
///
/// Simple Rule:
/// 🔹 IN बढ़े = Positive = RED (तुम्हें लेना बाकी)
/// 🔹 OUT बढ़े = Negative = GREEN (तुम पर देना बाकी)
///
/// ════════════════════════════════════════════════════════════
class BalanceHelper {

  // 🧪 DEBUG MODE - Set to true to see balance logs in console
  static bool debugMode = false;

  /// Check if balance should show GREEN color
  ///
  /// ✅ KHATABOOK LOGIC:
  /// - Negative balance (< 0) = GREEN (You owe customer - You will GIVE)
  /// - Positive balance (> 0) = RED (Customer owes you - You will RECEIVE)
  ///
  /// Note: "isPositive" now means "should show GREEN" for Khatabook logic
  static bool isPositive({
    String? transactionType,
    String? balanceType,
    double? currentBalance,
    String? itemName,
  }) {
    bool result;

    // ✅ PRIORITY 1: Use balance SIGN if currentBalance is provided (KHATABOOK LOGIC)
    if (currentBalance != null) {
      // KHATABOOK: Negative balance = GREEN (you owe customer)
      //            Positive balance = RED (customer owes you)
      result = currentBalance < 0;

      // 🧪 DEBUG LOG
      if (debugMode) {
        debugPrint('🧪 BalanceHelper.isPositive() [KHATABOOK LOGIC]');
        debugPrint('   Item: ${itemName ?? "N/A"}');
        debugPrint('   Balance: ₹$currentBalance');
        debugPrint('   Result: ${result ? "GREEN ✅ (You will GIVE)" : "RED 🔴 (You will RECEIVE)"}');
      }
      return result;
    }

    // PRIORITY 2: Use transactionType for transaction items (not balance)
    // For individual transactions: IN = GREEN (received), OUT = RED (given)
    final type = balanceType ?? transactionType ?? 'OUT';
    result = type == 'IN';

    // 🧪 DEBUG LOG
    if (debugMode) {
      debugPrint('🧪 BalanceHelper.isPositive() [Transaction Type]');
      debugPrint('   Item: ${itemName ?? "N/A"}');
      debugPrint('   Type: $type');
      debugPrint('   Result: ${result ? "GREEN ✅ (IN)" : "RED 🔴 (OUT)"}');
    }

    return result;
  }

  /// Get balance color based on balance value (KHATABOOK LOGIC)
  ///
  /// - Negative balance = GREEN (You owe customer)
  /// - Positive balance = RED (Customer owes you)
  static Color getBalanceColorFromValue(double balance, {bool isDark = true}) {
    // KHATABOOK: Negative = GREEN, Positive = RED
    if (balance < 0) {
      return AppColors.successPrimary; // GREEN - You will give
    } else if (balance > 0) {
      return AppColors.red500; // RED - You will receive
    }
    return isDark ? AppColors.white : AppColorsLight.textPrimary; // Neutral
  }

  /// Get balance color based on type (for transactions, not closing balance)
  ///
  /// "IN" = Green (received money)
  /// "OUT" = Red (gave money/goods)
  static Color getBalanceColor({
    String? transactionType,
    String? balanceType,
    bool isDark = true,
  }) {
    final type = balanceType ?? transactionType ?? 'OUT';

    return type == 'IN'
        ? AppColors.successPrimary  // Green for IN
        : AppColors.red500;         // Red for OUT
  }

  /// Get balance color for light theme
  static Color getBalanceColorLight({
    String? transactionType,
    String? balanceType,
  }) {
    final type = balanceType ?? transactionType ?? 'OUT';

    return type == 'IN'
        ? AppColorsLight.success  // Green for light theme
        : AppColorsLight.error;   // Red for light theme
  }

  /// Get balance text label based on balance value (KHATABOOK LOGIC)
  ///
  /// - Positive balance = "You will receive" (Customer owes you)
  /// - Negative balance = "You will give" (You owe customer)
  static String getBalanceLabelFromValue(double balance, {bool shortLabel = false}) {
    if (balance > 0) {
      return shortLabel ? 'Receivable' : 'You will receive';
    } else if (balance < 0) {
      return shortLabel ? 'Payable' : 'You will give';
    }
    return shortLabel ? 'Settled' : 'No balance';
  }

  /// Get balance text label based on type
  static String getBalanceLabel({
    String? transactionType,
    String? balanceType,
    bool shortLabel = false,
  }) {
    final type = balanceType ?? transactionType ?? 'OUT';
    final isIn = type == 'IN';

    if (shortLabel) {
      return isIn ? 'Received' : 'Given';
    }
    return isIn ? 'Money received' : 'Money/Goods given';
  }

  // ═══════════════════════════════════════════════════════════
  // 🧪 DEBUG METHODS
  // ═══════════════════════════════════════════════════════════

  /// Enable debug mode to see balance logs in console
  static void enableDebug() {
    debugMode = true;
    debugPrint('');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('🧪 BALANCE DEBUG MODE: ON (KHATABOOK LOGIC)');
    debugPrint('🧪 ──────────────────────────────────────────');
    debugPrint('🧪 Balance Color Rules:');
    debugPrint('🧪   Positive (> 0) → RED 🔴 (You will RECEIVE)');
    debugPrint('🧪   Negative (< 0) → GREEN ✅ (You will GIVE)');
    debugPrint('🧪 ──────────────────────────────────────────');
    debugPrint('🧪 Transaction Type Rules:');
    debugPrint('🧪   IN  → GREEN ✅ (Received)');
    debugPrint('🧪   OUT → RED 🔴 (Given)');
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
    debugPrint('🧪 KHATABOOK BALANCE LOGIC RULES');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('🧪');
    debugPrint('🧪 Closing Balance Color:');
    debugPrint('🧪 ┌─────────────────┬───────────────────┬─────────┐');
    debugPrint('🧪 │ Balance         │ Meaning           │ Color   │');
    debugPrint('🧪 ├─────────────────┼───────────────────┼─────────┤');
    debugPrint('🧪 │ Positive (> 0)  │ Customer owes you │ RED 🔴  │');
    debugPrint('🧪 │ Negative (< 0)  │ You owe customer  │ GREEN ✅│');
    debugPrint('🧪 └─────────────────┴───────────────────┴─────────┘');
    debugPrint('🧪');
    debugPrint('🧪 Formula: Closing = Opening + IN - OUT');
    debugPrint('🧪 Simple Rule:');
    debugPrint('🧪   IN बढ़े = Positive = RED (तुम्हें लेना बाकी)');
    debugPrint('🧪   OUT बढ़े = Negative = GREEN (तुम पर देना बाकी)');
    debugPrint('🧪 ══════════════════════════════════════════');
    debugPrint('');
  }
}
