import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/ledger_detail_api.dart';
import '../core/api/ledger_transaction_api.dart';
import '../models/ledger_detail_model.dart';
import '../models/transaction_list_model.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';

class LedgerDetailController extends GetxController {
  final LedgerDetailApi _api = LedgerDetailApi();
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();

  // Observable states
  var isLoading = true.obs;
  var isTransactionsLoading = true.obs;

  // Ledger detail data
  Rx<LedgerDetailModel?> ledgerDetail = Rx<LedgerDetailModel?>(null);

  // Transaction history data - UPDATED to use TransactionListModel
  Rx<TransactionListModel?> transactionHistory =
      Rx<TransactionListModel?>(null);

  // ✅ Recalculated closing balance (fixes backend not updating after edit)
  var recalculatedClosingBalance = 0.0.obs;

  // Ledger ID
  late final int ledgerId;

  @override
  void onInit() {
    super.onInit();

    // Get ledger ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    ledgerId = args?['ledgerId'] ?? 0;

    debugPrint('📋 LedgerDetailController initialized with ledger ID: $ledgerId');

    if (ledgerId > 0) {
      // Fetch data on init - use refreshAll to ensure running balance calculation
      refreshAll();
    } else {
      debugPrint('❌ Invalid ledger ID provided');
      isLoading.value = false;
      isTransactionsLoading.value = false;
    }
  }

  /// Fetch ledger details
  Future<void> fetchLedgerDetails() async {
    try {
      isLoading.value = true;

      debugPrint('🔄 Fetching ledger details...');
      final detail = await _api.getLedgerDetails(ledgerId);

      ledgerDetail.value = detail;
      debugPrint('✅ Ledger details loaded: ${detail.partyName}');
    } catch (e) {
      debugPrint('❌ Error fetching ledger details: $e');
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch transaction history for this specific ledger
  Future<void> fetchTransactions() async {
    try {
      isTransactionsLoading.value = true;

      debugPrint('🔄 Fetching transaction history for ledger: $ledgerId');
      debugPrint('📊 Current transaction count BEFORE fetch: ${transactionHistory.value?.count ?? 0}');

      // Use the correct API endpoint for specific ledger transactions
      final history = await _transactionApi.getLedgerTransactions(ledgerId: ledgerId);

      debugPrint('📊 NEW transaction count from API: ${history.count}');
      debugPrint('📋 Transaction IDs: ${history.data.map((t) => t.id).toList()}');

      // Check for duplicates
      final ids = history.data.map((t) => t.id).toList();
      final uniqueIds = ids.toSet().toList();
      if (ids.length != uniqueIds.length) {
        debugPrint('⚠️ WARNING: DUPLICATE transactions detected!');
        debugPrint('   Total: ${ids.length}, Unique: ${uniqueIds.length}');
      }

      // Sort transactions by transactionDate (ascending - oldest first) for balance calculation
      final sortedAscending = List.of(history.data);
      sortedAscending.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.transactionDate);
          final dateB = DateTime.parse(b.transactionDate);
          return dateA.compareTo(dateB); // Ascending order (oldest first)
        } catch (e) {
          return 0;
        }
      });

      // ✅ FIX: Recalculate running balances in frontend
      // Backend doesn't recalculate balances after edit, so we do it here
      final recalculatedData = _recalculateRunningBalances(sortedAscending);

      // Re-sort to descending (newest first) for display
      recalculatedData.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.transactionDate);
          final dateB = DateTime.parse(b.transactionDate);
          return dateB.compareTo(dateA); // Descending order (newest first)
        } catch (e) {
          return 0;
        }
      });

      transactionHistory.value = TransactionListModel(
        count: history.count,
        data: recalculatedData,
      );
      debugPrint('✅ Transactions loaded: ${history.count} items for ledger $ledgerId');
      debugPrint('📊 Updated transaction count AFTER fetch: ${transactionHistory.value?.count ?? 0}');
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
      );
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    debugPrint('🔄 refreshAll() called - Starting full refresh...');
    debugPrint('📊 Transaction count BEFORE refresh: ${transactionHistory.value?.count ?? 0}');

    await Future.wait([
      fetchLedgerDetails(),
      fetchTransactions(),
    ]);

    debugPrint('✅ refreshAll() completed');
    debugPrint('📊 Transaction count AFTER refresh: ${transactionHistory.value?.count ?? 0}');
  }

  /// Recalculate running balances for all transactions
  /// This fixes the issue where backend doesn't update balances after edit
  ///
  /// Logic:
  /// - Transactions should be sorted by date (oldest first) before calling
  /// - For each transaction:
  ///   - lastBalance = previous transaction's currentBalance (or opening balance for first)
  ///   - currentBalance = lastBalance + amount (for OUT) or lastBalance - amount (for IN)
  ///
  /// Balance meaning:
  /// - Positive balance = Customer owes you (Receivable)
  /// - Negative balance = You owe customer (Payable)
  /// - OUT (giving to customer) increases what they owe = balance increases
  /// - IN (receiving from customer) decreases what they owe = balance decreases
  List<TransactionItemModel> _recalculateRunningBalances(
    List<TransactionItemModel> transactions,
  ) {
    if (transactions.isEmpty) {
      // If no transactions, use API's closing balance as fallback
      recalculatedClosingBalance.value = ledgerDetail.value?.currentBalance ?? 0.0;
      debugPrint('💰 No transactions - Using API closing balance: ${recalculatedClosingBalance.value}');
      return transactions;
    }

    debugPrint('🔢 Recalculating running balances for ${transactions.length} transactions...');

    final List<TransactionItemModel> recalculated = [];

    // Start with the first transaction's lastBalance as opening balance
    double runningBalance = transactions.first.lastBalance;
    debugPrint('📊 Opening balance: $runningBalance');

    for (int i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];

      // Skip deleted transactions in balance calculation
      if (transaction.isDelete) {
        recalculated.add(transaction);
        continue;
      }

      // Calculate new balance based on transaction type
      double newBalance;
      if (transaction.transactionType == 'OUT') {
        // OUT = Giving money to customer = They owe more = Balance increases
        newBalance = runningBalance + transaction.amount;
      } else {
        // IN = Receiving money from customer = They owe less = Balance decreases
        newBalance = runningBalance - transaction.amount;
      }

      // Create updated transaction with recalculated balances
      final updatedTransaction = transaction.copyWith(
        lastBalance: runningBalance,
        currentBalance: newBalance,
      );

      debugPrint('   📝 ID ${transaction.id}: ${transaction.transactionType} ₹${transaction.amount} | '
          'lastBal: $runningBalance → currentBal: $newBalance');

      recalculated.add(updatedTransaction);

      // Update running balance for next transaction
      runningBalance = newBalance;
    }

    debugPrint('✅ Balance recalculation complete. Final balance: $runningBalance');

    // ✅ Store the recalculated closing balance for use in Closing Balance Card
    recalculatedClosingBalance.value = runningBalance;
    debugPrint('💰 Recalculated Closing Balance stored: $runningBalance');

    return recalculated;
  }
}
