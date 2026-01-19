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

  // ✅ Calculated running balances (transaction id -> running balance)
  final Map<int, double> runningBalances = {};

  // ✅ Running balance types (transaction id -> "IN" or "OUT")
  final Map<int, String> runningBalanceTypes = {};

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

      // Sort transactions by transactionDate (descending - newest first)
      // This ensures edited transactions stay in their original position
      final sortedData = List.of(history.data);
      sortedData.sort((a, b) {
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
        data: sortedData,
      );
      debugPrint('✅ Transactions loaded: ${history.count} items for ledger $ledgerId');
      debugPrint('📊 Updated transaction count AFTER fetch: ${transactionHistory.value?.count ?? 0}');

      // ✅ Calculate running balances after loading transactions
      _calculateRunningBalances();
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

    // ✅ Recalculate running balances after both data are loaded
    _calculateRunningBalances();

    debugPrint('✅ refreshAll() completed');
    debugPrint('📊 Transaction count AFTER refresh: ${transactionHistory.value?.count ?? 0}');
  }

  /// ✅ Calculate running balance for each transaction
  /// Running balance = openingBalance + cumulative transactions
  /// OUT = add to balance (customer owes more)
  /// IN = subtract from balance (customer paid)
  void _calculateRunningBalances() {
    debugPrint('🧮 _calculateRunningBalances() CALLED');

    if (transactionHistory.value == null) {
      debugPrint('❌ transactionHistory.value is NULL - skipping calculation');
      return;
    }

    if (ledgerDetail.value == null) {
      debugPrint('⚠️ ledgerDetail.value is NULL - using openingBalance = 0');
    }

    // Clear previous calculations
    runningBalances.clear();
    runningBalanceTypes.clear();

    // ✅ KHATABOOK LOGIC: Get opening balance and apply sign based on transactionType
    final openingBalanceAbs = ledgerDetail.value?.openingBalance ?? 0.0;
    final ledgerTransactionType = ledgerDetail.value?.transactionType ?? 'OUT';

    // Apply sign based on transactionType:
    // OUT = Customer owes you (positive opening balance)
    // IN = You owe customer (negative opening balance)
    final openingBalance = ledgerTransactionType == 'IN'
        ? -openingBalanceAbs  // Negative: You owe customer
        : openingBalanceAbs;  // Positive: Customer owes you

    debugPrint('📊 Calculating running balances:');
    debugPrint('   Opening Balance (abs): ₹$openingBalanceAbs');
    debugPrint('   Ledger TransactionType: $ledgerTransactionType');
    debugPrint('   Signed Opening Balance: ₹$openingBalance');

    // Get transactions and sort by date (OLDEST first for calculation)
    final transactions = List.of(transactionHistory.value!.data);
    transactions.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.transactionDate);
        final dateB = DateTime.parse(b.transactionDate);
        return dateA.compareTo(dateB); // Ascending (oldest first)
      } catch (e) {
        return 0;
      }
    });

    // Calculate running balance for each transaction
    // ✅ CORRECT FORMULA: Closing = Opening + IN - OUT
    double runningBalance = openingBalance;

    for (final transaction in transactions) {
      // ✅ Skip deleted transactions - they don't affect running balance
      if (transaction.isDelete) {
        // Store the CURRENT running balance (unchanged) for deleted transactions
        runningBalances[transaction.id] = runningBalance;
        runningBalanceTypes[transaction.id] = runningBalance >= 0 ? 'IN' : 'OUT';
        debugPrint('   Transaction ${transaction.id}: DELETED (skipped) → Bal: ₹$runningBalance');
        continue;
      }

      // ✅ CORRECT FORMULA: Closing = Opening + IN - OUT
      // IN = money received (adds to balance)
      // OUT = money/goods given (subtracts from balance)
      if (transaction.transactionType == 'IN') {
        runningBalance += transaction.amount;  // IN adds
      } else {
        runningBalance -= transaction.amount;  // OUT subtracts
      }

      // Store the running balance after this transaction
      runningBalances[transaction.id] = runningBalance;

      // Determine balance type based on sign
      // Positive balance = IN (customer owes you - receivable)
      // Negative balance = OUT (you owe customer - payable)
      runningBalanceTypes[transaction.id] = runningBalance >= 0 ? 'IN' : 'OUT';

      debugPrint('   Transaction ${transaction.id}: ${transaction.transactionType} ₹${transaction.amount} → Bal: ₹$runningBalance (${runningBalanceTypes[transaction.id]})');
    }

    debugPrint('✅ Running balances calculated for ${transactions.length} transactions');
  }

  /// Get calculated running balance for a transaction
  double getRunningBalance(int transactionId) {
    return runningBalances[transactionId] ?? 0.0;
  }

  /// Get running balance type (IN/OUT) for a transaction
  String getRunningBalanceType(int transactionId) {
    return runningBalanceTypes[transactionId] ?? 'IN';
  }

  /// ✅ CORRECT FORMULA: Closing = Opening + IN - OUT
  /// IN increases balance (money received)
  /// OUT decreases balance (money/goods given)
  double getCalculatedClosingBalance() {
    if (ledgerDetail.value == null) return 0.0;

    final openingBalanceAbs = ledgerDetail.value?.openingBalance ?? 0.0;
    final ledgerTransactionType = ledgerDetail.value?.transactionType ?? 'OUT';

    // Apply sign based on transactionType:
    // OUT = Customer owes you (positive opening balance)
    // IN = You owe customer (negative opening balance)
    double closingBalance = ledgerTransactionType == 'IN'
        ? -openingBalanceAbs
        : openingBalanceAbs;

    // ✅ CORRECT FORMULA: Closing = Opening + IN - OUT
    final transactions = transactionHistory.value?.data ?? [];
    for (final tx in transactions) {
      if (tx.isDelete) continue;

      if (tx.transactionType == 'IN') {
        closingBalance += tx.amount;  // IN adds to balance
      } else {
        closingBalance -= tx.amount;  // OUT subtracts from balance
      }
    }

    debugPrint('💰 Calculated Closing Balance: ₹$closingBalance');
    debugPrint('   Formula: Opening(${ledgerTransactionType == 'IN' ? '-' : '+'}$openingBalanceAbs) + IN - OUT');

    return closingBalance;
  }
}
