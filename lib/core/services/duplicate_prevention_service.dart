import '../utils/secure_logger.dart';

/// Service to prevent duplicate transactions and submissions
///
/// Tracks pending operations to prevent accidental double-submissions
/// when users click buttons multiple times or network is slow
///
/// Usage:
/// ```dart
/// final txKey = DuplicatePrevention.generateTransactionKey(
///   ledgerId: 123,
///   amount: 500.0,
///   type: 'IN',
/// );
///
/// if (DuplicatePrevention.isPending(txKey)) {
///   // Duplicate detected
///   return;
/// }
///
/// DuplicatePrevention.markPending(txKey);
/// try {
///   // ... API call
/// } finally {
///   DuplicatePrevention.removePending(txKey);
/// }
/// ```
class DuplicatePrevention {
  /// Set of currently pending transaction keys
  static final Set<String> _pendingTransactions = {};

  /// Set of recently completed transactions (for short-term duplicate detection)
  static final Map<String, DateTime> _recentTransactions = {};

  /// How long to remember completed transactions (default: 5 minutes)
  static const Duration _rememberedDuration = Duration(minutes: 5);

  /// Check if a transaction is currently pending
  ///
  /// Returns true if operation is already in progress
  static bool isPending(String uniqueKey) {
    return _pendingTransactions.contains(uniqueKey);
  }

  /// Mark a transaction as pending
  ///
  /// Call this before starting an API call or async operation
  static void markPending(String uniqueKey) {
    _pendingTransactions.add(uniqueKey);
    SecureLogger.info('Marked as pending: $uniqueKey');
  }

  /// Remove from pending transactions
  ///
  /// Call this in finally block after API call completes
  static void removePending(String uniqueKey) {
    _pendingTransactions.remove(uniqueKey);

    // Add to recent transactions for short-term duplicate detection
    _recentTransactions[uniqueKey] = DateTime.now();
    SecureLogger.info('Removed from pending: $uniqueKey');

    // Clean up old entries
    _cleanupRecentTransactions();
  }

  /// Check if a transaction was recently completed
  ///
  /// Prevents submitting the same transaction multiple times within short period
  static bool wasRecentlyCompleted(String uniqueKey) {
    final completedTime = _recentTransactions[uniqueKey];

    if (completedTime == null) {
      return false;
    }

    final now = DateTime.now();
    final timeSince = now.difference(completedTime);

    if (timeSince > _rememberedDuration) {
      _recentTransactions.remove(uniqueKey);
      return false;
    }

    return true;
  }

  /// Generate unique key for transaction
  ///
  /// Uses ledger ID, amount, and type to create fingerprint
  static String generateTransactionKey({
    required int ledgerId,
    required double amount,
    required String type,
  }) {
    // Round amount to 2 decimals for consistency
    final roundedAmount = (amount * 100).round() / 100;

    // Create unique key
    return 'tx_${ledgerId}_${roundedAmount}_${type}';
  }

  /// Generate unique key for ledger creation
  static String generateLedgerKey({
    required String name,
    required String mobileNumber,
  }) {
    final normalizedName = name.trim().toLowerCase();
    final normalizedPhone = mobileNumber.trim();

    return 'ledger_${normalizedName}_$normalizedPhone';
  }

  /// Generate unique key for image upload
  static String generateImageUploadKey({
    required String filePath,
  }) {
    return 'image_$filePath';
  }

  /// Generate unique key for any operation
  static String generateKey({
    required String operation,
    required Map<String, dynamic> params,
  }) {
    final sortedKeys = params.keys.toList()..sort();
    final paramString = sortedKeys.map((key) => '$key:${params[key]}').join('_');

    return '${operation}_$paramString';
  }

  /// Clear all pending transactions
  ///
  /// Use with caution - typically only for logout or app reset
  static void clearAll() {
    _pendingTransactions.clear();
    _recentTransactions.clear();
    SecureLogger.warning('Cleared all duplicate prevention tracking');
  }

  /// Clear a specific pending transaction
  static void clear(String uniqueKey) {
    _pendingTransactions.remove(uniqueKey);
    _recentTransactions.remove(uniqueKey);
  }

  /// Get count of pending operations
  static int getPendingCount() {
    return _pendingTransactions.length;
  }

  /// Check if there are any pending operations
  static bool hasPendingOperations() {
    return _pendingTransactions.isNotEmpty;
  }

  /// Clean up old entries from recent transactions
  static void _cleanupRecentTransactions() {
    final now = DateTime.now();
    final keysToRemove = <String>[];

    _recentTransactions.forEach((key, completedTime) {
      if (now.difference(completedTime) > _rememberedDuration) {
        keysToRemove.add(key);
      }
    });

    for (final key in keysToRemove) {
      _recentTransactions.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      SecureLogger.info('Cleaned up ${keysToRemove.length} old transaction entries');
    }
  }

  /// Get time since transaction was completed
  static Duration? getTimeSinceCompleted(String uniqueKey) {
    final completedTime = _recentTransactions[uniqueKey];
    if (completedTime == null) {
      return null;
    }

    return DateTime.now().difference(completedTime);
  }
}
