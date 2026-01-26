import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../core/api/ledger_transaction_api.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import '../models/grouped_transaction_model.dart';
import '../models/transaction_list_model.dart';

/// Controller for Account Statement Logic
/// 🗄️ OFFLINE-FIRST: Uses cached transactions when offline, API when online
class AccountStatementController extends GetxController {
  // API instance
  final LedgerTransactionApi _api = LedgerTransactionApi();

  // 🗄️ Offline-first repository
  TransactionRepository? _transactionRepository;
  TransactionRepository get transactionRepository {
    if (_transactionRepository == null) {
      if (Get.isRegistered<TransactionRepository>()) {
        _transactionRepository = Get.find<TransactionRepository>();
      } else {
        _transactionRepository = TransactionRepository();
      }
    }
    return _transactionRepository!;
  }

  // Ledger ID (set from parent)
  int? _ledgerId;

  // Selected month (observable)
  final selectedMonth = Rx<DateTime>(DateTime(DateTime.now().year, DateTime.now().month, 1));

  // Grouped transactions from API
  final groupedTransactions = Rx<GroupedTransactionModel?>(null);

  // Loading state
  final isLoading = false.obs;

  // Error message
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to selectedMonth changes and fetch data
    ever(selectedMonth, (_) => _fetchGroupedTransactions());
  }

  /// Set ledger ID and fetch initial data
  /// Only fetches if ledgerId is different from current
  void setLedgerId(int ledgerId) {
    if (_ledgerId == ledgerId) {
      return; // Already set, no need to fetch again
    }
    debugPrint('📊 AccountStatementController: Setting ledgerId: $ledgerId');
    _ledgerId = ledgerId;
    _fetchGroupedTransactions();
  }

  /// Go to previous month
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
      1,
    );
    debugPrint('📅 Previous Month: ${getMonthRangeText()}');
  }

  /// Go to next month
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      1,
    );
    debugPrint('📅 Next Month: ${getMonthRangeText()}');
  }

  /// Get month range display text
  String getMonthRangeText() {
    final firstDay = selectedMonth.value;
    final lastDay = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      0,
    );

    return '${firstDay.day} ${DateFormat('MMM yyyy').format(firstDay)} - ${lastDay.day} ${DateFormat('MMM yyyy').format(lastDay)}';
  }

  /// 🗄️ OFFLINE-FIRST: Fetch grouped transactions
  Future<void> _fetchGroupedTransactions() async {
    if (_ledgerId == null) {
      debugPrint('⚠️ AccountStatementController: ledgerId not set');
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Calculate date range for selected month
      final firstDay = selectedMonth.value;
      final lastDay = DateTime(
        selectedMonth.value.year,
        selectedMonth.value.month + 1,
        0,
      );

      // Format dates as YYYY-MM-DD
      final startDate = DateFormat('yyyy-MM-dd').format(firstDay);
      final endDate = DateFormat('yyyy-MM-dd').format(lastDay);

      debugPrint('📊 Fetching grouped transactions for ledger: $_ledgerId (OFFLINE-FIRST)');
      debugPrint('   Date range: $startDate to $endDate');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Is Online: $isOnline');

      // 🗄️ OFFLINE-FIRST: Load cached transactions first (including deleted for display)
      List<TransactionItemModel> cachedTransactions = [];
      try {
        cachedTransactions = await transactionRepository.getAllTransactionsByDateRangeForDisplay(
          _ledgerId!,
          firstDay,
          lastDay,
        );
        debugPrint('📦 Loaded ${cachedTransactions.length} cached transactions for date range (including deleted)');

        // Group cached transactions locally
        if (cachedTransactions.isNotEmpty) {
          final grouped = _groupTransactionsLocally(cachedTransactions, firstDay, lastDay);
          groupedTransactions.value = grouped;
          debugPrint('📦 Grouped into ${grouped.data.length} daily groups from cache');
        }
      } catch (e) {
        debugPrint('⚠️ Could not load cached transactions: $e');
      }

      // 🌐 If online, fetch from API
      if (isOnline) {
        try {
          debugPrint('🔄 Online - Fetching from API...');
          final response = await _api.getGroupedTransactionsByDate(
            ledgerId: _ledgerId!,
            startDate: startDate,
            endDate: endDate,
          );

          // Merge with local unsynced transactions
          final mergedResponse = await _mergeWithLocalTransactions(response, firstDay, lastDay);
          groupedTransactions.value = mergedResponse;
          debugPrint('✅ Fetched ${mergedResponse.data.length} grouped transactions (merged with local)');
        } catch (apiError) {
          debugPrint('⚠️ API fetch failed: $apiError');
          // If API fails but we have cached data, use that
          if (groupedTransactions.value != null && groupedTransactions.value!.data.isNotEmpty) {
            debugPrint('📦 Using cached data as fallback');
          } else {
            rethrow;
          }
        }
      } else {
        debugPrint('📴 Offline - Using cached grouped transactions');
        if (groupedTransactions.value == null || groupedTransactions.value!.data.isEmpty) {
          if (cachedTransactions.isEmpty) {
            errorMessage.value = 'No cached data available for this date range.';
          }
        }
      }

    } catch (e) {
      debugPrint('❌ Error fetching grouped transactions: $e');
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// 🗄️ Group transactions locally (for offline use)
  GroupedTransactionModel _groupTransactionsLocally(
    List<TransactionItemModel> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    debugPrint('📊 Grouping ${transactions.length} transactions locally...');

    // Group by date
    final Map<String, List<TransactionItemModel>> groupedByDate = {};

    for (final transaction in transactions) {
      try {
        final date = DateTime.parse(transaction.transactionDate);
        final dateKey = DateFormat('yyyy-MM-dd').format(date);

        groupedByDate.putIfAbsent(dateKey, () => []);
        groupedByDate[dateKey]!.add(transaction);
      } catch (e) {
        debugPrint('⚠️ Error parsing date: ${transaction.transactionDate}');
      }
    }

    // Convert to DailyGroupedTransaction list
    final List<DailyGroupedTransaction> dailyGroups = [];

    // Track running balance for each day
    double runningBalance = 0;

    // Process in ascending order for balance calculation, then reverse for display
    final ascendingDates = groupedByDate.keys.toList()..sort();

    for (final dateKey in ascendingDates) {
      final dayTransactions = groupedByDate[dateKey]!;

      // Calculate daily totals (skip deleted transactions for totals)
      double dailyIn = 0;
      double dailyOut = 0;

      for (final tx in dayTransactions) {
        // Only count non-deleted for totals
        if (!tx.isDelete) {
          if (tx.transactionType == 'IN') {
            dailyIn += tx.amount;
          } else {
            dailyOut += tx.amount;
          }
        }
      }

      // Update running balance (Khatabook logic: IN decreases, OUT increases)
      runningBalance = runningBalance - dailyIn + dailyOut;

      // Determine balance type
      final balanceType = runningBalance >= 0 ? 'OUT' : 'IN';

      dailyGroups.add(DailyGroupedTransaction(
        date: dateKey,
        inAmount: dailyIn,
        outAmount: dailyOut,
        balance: runningBalance.abs(),
        balanceType: balanceType,
      ));
    }

    // Reverse to show newest first
    dailyGroups.sort((a, b) => b.date.compareTo(a.date));

    debugPrint('📊 Local grouping result:');
    debugPrint('   - ${dailyGroups.length} daily groups');

    return GroupedTransactionModel(
      startDate: DateFormat('d MMM yyyy').format(startDate),
      endDate: DateFormat('d MMM yyyy').format(endDate),
      data: dailyGroups,
    );
  }

  /// 🗄️ Merge API response with local unsynced transactions
  Future<GroupedTransactionModel> _mergeWithLocalTransactions(
    GroupedTransactionModel apiResponse,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get unsynced local transactions for this ledger
      final unsyncedTransactions = await transactionRepository.getUnsyncedTransactionsByLedger(_ledgerId!);

      if (unsyncedTransactions.isEmpty) {
        debugPrint('📦 No unsynced transactions to merge');
        return apiResponse;
      }

      // Filter to only include transactions in the date range
      final unsyncedInRange = unsyncedTransactions.where((tx) {
        try {
          final date = DateTime.parse(tx.transactionDate);
          return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                 date.isBefore(endDate.add(const Duration(days: 1)));
        } catch (e) {
          return false;
        }
      }).toList();

      if (unsyncedInRange.isEmpty) {
        debugPrint('📦 No unsynced transactions in date range');
        return apiResponse;
      }

      debugPrint('📦 Merging ${unsyncedInRange.length} unsynced transactions with API response');

      // Get all transactions from cache (includes both synced, unsynced, and deleted for display)
      final allCachedTransactions = await transactionRepository.getAllTransactionsByDateRangeForDisplay(
        _ledgerId!,
        startDate,
        endDate,
      );

      // Re-group all cached transactions (they include the correct local state)
      return _groupTransactionsLocally(allCachedTransactions, startDate, endDate);
    } catch (e) {
      debugPrint('⚠️ Error merging with local transactions: $e');
      return apiResponse;
    }
  }

  /// Refresh data
  @override
  Future<void> refresh() async {
    await _fetchGroupedTransactions();
  }

  /// Get daily grouped transactions list (for widget compatibility)
  List<DailyGroupedTransaction> get groupedDailyTransactions {
    return groupedTransactions.value?.data ?? [];
  }
}