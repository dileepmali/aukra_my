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

  // Pagination states
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  var currentOffset = 0.obs;
  final int _limit = 10;
  var totalTransactionCount = 0.obs;

  // ScrollController for infinite scrolling
  final ScrollController scrollController = ScrollController();

  // Ledger detail data
  Rx<LedgerDetailModel?> ledgerDetail = Rx<LedgerDetailModel?>(null);

  // Transaction history data - UPDATED to use TransactionListModel
  Rx<TransactionListModel?> transactionHistory =
      Rx<TransactionListModel?>(null);

  // All loaded transactions (accumulated from pagination)
  RxList<TransactionItemModel> allTransactions = <TransactionItemModel>[].obs;

  // Ledger ID
  late final int ledgerId;

  @override
  void onInit() {
    super.onInit();

    // Get ledger ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    ledgerId = args?['ledgerId'] ?? 0;

    debugPrint('📋 LedgerDetailController initialized with ledger ID: $ledgerId');

    // Setup scroll listener for infinite scrolling
    _setupScrollListener();

    if (ledgerId > 0) {
      // Fetch data on init - use refreshAll to ensure running balance calculation
      refreshAll();
    } else {
      debugPrint('❌ Invalid ledger ID provided');
      isLoading.value = false;
      isTransactionsLoading.value = false;
    }
  }

  /// Setup scroll listener for 80% scroll detection
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        final maxScroll = scrollController.position.maxScrollExtent;
        final currentScroll = scrollController.position.pixels;
        final threshold = maxScroll * 0.8; // 80% threshold

        // Load more when scrolled to 80% and not already loading
        if (currentScroll >= threshold &&
            !isLoadingMore.value &&
            hasMoreData.value) {
          debugPrint('📜 Scroll reached 80% - Loading more transactions...');
          loadMoreTransactions();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
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

  /// Fetch transaction history for this specific ledger (first page)
  Future<void> fetchTransactions() async {
    try {
      isTransactionsLoading.value = true;

      // Reset pagination state for fresh fetch
      currentOffset.value = 0;
      hasMoreData.value = true;
      allTransactions.clear();

      debugPrint('🔄 Fetching transaction history for ledger: $ledgerId (skip: ${currentOffset.value}, limit: $_limit)');

      // Use the correct API endpoint for specific ledger transactions with pagination
      final history = await _transactionApi.getLedgerTransactions(
        ledgerId: ledgerId,
        skip: currentOffset.value,
        limit: _limit,
      );

      debugPrint('📊 Fetched ${history.data.length} transactions (total: ${history.totalCount})');
      debugPrint('📋 Transaction IDs: ${history.data.map((t) => t.id).toList()}');

      // Store total count for pagination check (use totalCount from API)
      totalTransactionCount.value = history.totalCount;

      // Sort transactions by transactionDate (descending - newest first) for display
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

      // Add to accumulated list
      allTransactions.addAll(sortedData);

      // Update hasMoreData based on total count
      hasMoreData.value = allTransactions.length < totalTransactionCount.value;

      // Update transaction history for UI
      transactionHistory.value = TransactionListModel(
        count: allTransactions.length,
        totalCount: totalTransactionCount.value,
        data: allTransactions.toList(),
      );

      debugPrint('✅ Transactions loaded: ${allTransactions.length}/${totalTransactionCount.value} for ledger $ledgerId');
      debugPrint('📄 Has more data: ${hasMoreData.value}');
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

  /// Load more transactions (next page) for infinite scrolling
  Future<void> loadMoreTransactions() async {
    // Prevent duplicate calls
    if (isLoadingMore.value || !hasMoreData.value) {
      debugPrint('⏸️ Skip loading more: isLoadingMore=${isLoadingMore.value}, hasMoreData=${hasMoreData.value}');
      return;
    }

    try {
      isLoadingMore.value = true;

      // Calculate next offset
      final nextOffset = currentOffset.value + _limit;

      debugPrint('🔄 Loading more transactions - skip: $nextOffset, limit: $_limit');

      final history = await _transactionApi.getLedgerTransactions(
        ledgerId: ledgerId,
        skip: nextOffset,
        limit: _limit,
      );

      debugPrint('📊 Fetched ${history.data.length} more transactions');

      if (history.data.isEmpty) {
        hasMoreData.value = false;
        debugPrint('📭 No more transactions to load');
        return;
      }

      // Update offset after successful fetch
      currentOffset.value = nextOffset;

      // Sort new transactions by date (descending)
      final sortedData = List.of(history.data);
      sortedData.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.transactionDate);
          final dateB = DateTime.parse(b.transactionDate);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      // Append to accumulated list
      allTransactions.addAll(sortedData);

      // Update hasMoreData
      hasMoreData.value = allTransactions.length < totalTransactionCount.value;

      // Update transaction history for UI
      transactionHistory.value = TransactionListModel(
        count: allTransactions.length,
        totalCount: totalTransactionCount.value,
        data: allTransactions.toList(),
      );

      debugPrint('✅ Loaded more: ${allTransactions.length}/${totalTransactionCount.value} transactions');
      debugPrint('📄 Has more data: ${hasMoreData.value}');
    } catch (e) {
      debugPrint('❌ Error loading more transactions: $e');
      // No need to revert offset since we only update after success
    } finally {
      isLoadingMore.value = false;
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

}
