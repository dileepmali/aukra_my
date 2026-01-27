import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/ledger_detail_api.dart';
import '../core/api/ledger_transaction_api.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/sync_service.dart';
import '../models/ledger_detail_model.dart';
import '../models/transaction_list_model.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import 'ledger_controller.dart';

class LedgerDetailController extends GetxController {
  final LedgerDetailApi _api = LedgerDetailApi();
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();

  // 🗄️ Offline-first repositories
  TransactionRepository? _transactionRepository;
  TransactionRepository get transactionRepository {
    if (_transactionRepository == null) {
      if (Get.isRegistered<TransactionRepository>()) {
        _transactionRepository = Get.find<TransactionRepository>();
        debugPrint('✅ TransactionRepository found via GetX');
      } else {
        debugPrint('⚠️ TransactionRepository NOT registered - creating new instance');
        _transactionRepository = TransactionRepository();
      }
    }
    return _transactionRepository!;
  }

  LedgerRepository? _ledgerRepository;
  LedgerRepository get ledgerRepository {
    if (_ledgerRepository == null) {
      if (Get.isRegistered<LedgerRepository>()) {
        _ledgerRepository = Get.find<LedgerRepository>();
        debugPrint('✅ LedgerRepository found via GetX');
      } else {
        debugPrint('⚠️ LedgerRepository NOT registered - creating new instance');
        _ledgerRepository = LedgerRepository();
      }
    }
    return _ledgerRepository!;
  }

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

  // Track when data was last fetched
  DateTime? _lastFetchTime;

  @override
  void onInit() {
    super.onInit();

    // Get ledger ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    ledgerId = args?['ledgerId'] ?? 0;

    debugPrint('📋 LedgerDetailController initialized with ledger ID: $ledgerId');

    // Setup scroll listener for infinite scrolling
    _setupScrollListener();

    // Register for sync completion callbacks to auto-refresh after sync
    _registerSyncCallback();

    if (ledgerId > 0) {
      // Check if this ledger needs refresh (sync happened while we were away)
      _checkAndRefreshIfNeeded();
    } else {
      debugPrint('❌ Invalid ledger ID provided');
      isLoading.value = false;
      isTransactionsLoading.value = false;
    }
  }

  /// Check if ledger needs refresh due to sync that happened while controller was inactive
  void _checkAndRefreshIfNeeded() {
    try {
      if (Get.isRegistered<SyncService>()) {
        final syncService = SyncService.instance;

        // Check if this ledger was marked for refresh
        if (syncService.doesLedgerNeedRefresh(ledgerId)) {
          debugPrint('🔄 Ledger $ledgerId marked for refresh - sync happened while we were away');
          syncService.clearLedgerRefreshFlag(ledgerId);
        }

        // Check if sync happened after our last fetch
        if (_lastFetchTime != null && syncService.didSyncHappenAfter(_lastFetchTime!)) {
          debugPrint('🔄 Sync happened after last fetch - forcing refresh');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Could not check sync status: $e');
    }

    // Always fetch data on init
    refreshAll();
  }

  /// Callback function for sync completion
  void _onSyncComplete(bool hadTransactions) {
    if (hadTransactions) {
      debugPrint('🔄 Sync completed with transactions - refreshing ledger detail data...');
      // Refresh to link any newly synced transactions
      refreshAll();
    }
  }

  /// Register callback to listen for sync completion
  void _registerSyncCallback() {
    try {
      if (Get.isRegistered<SyncService>()) {
        SyncService.instance.onSyncComplete(_onSyncComplete);
        debugPrint('✅ Registered sync completion callback');
      }
    } catch (e) {
      debugPrint('⚠️ Could not register sync callback: $e');
    }
  }

  /// Unregister sync callback
  void _unregisterSyncCallback() {
    try {
      if (Get.isRegistered<SyncService>()) {
        SyncService.instance.removeSyncCompleteCallback(_onSyncComplete);
        debugPrint('✅ Unregistered sync completion callback');
      }
    } catch (e) {
      debugPrint('⚠️ Could not unregister sync callback: $e');
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
    _unregisterSyncCallback();
    scrollController.dispose();
    super.onClose();
  }

  /// Fetch ledger details - OFFLINE FIRST
  Future<void> fetchLedgerDetails() async {
    try {
      isLoading.value = true;

      debugPrint('🔄 Fetching ledger details (OFFLINE-FIRST)...');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      // 🗄️ OFFLINE-FIRST: Try cached ledger first
      try {
        final cachedLedger = await ledgerRepository.getLedgerById(ledgerId);
        if (cachedLedger != null) {
          debugPrint('📦 Loaded cached ledger: ${cachedLedger.name}, Balance: ${cachedLedger.currentBalance}');
          ledgerDetail.value = LedgerDetailModel(
            id: cachedLedger.id ?? 0,
            merchantId: cachedLedger.merchantId,
            partyName: cachedLedger.name,
            partyType: cachedLedger.partyType,
            mobileNumber: cachedLedger.mobileNumber,
            currentBalance: cachedLedger.currentBalance,
            openingBalance: cachedLedger.openingBalance,
            area: cachedLedger.area,
            address: cachedLedger.address,
            pinCode: cachedLedger.pinCode,
            creditLimit: cachedLedger.creditLimit,
            creditDay: cachedLedger.creditDay,
            interestType: cachedLedger.interestType,
            interestRate: cachedLedger.interestRate,
            transactionType: cachedLedger.transactionType,
            isDelete: false,
            salary: 0.0,
            salaryType: 'MONTHLY',
            createdAt: cachedLedger.createdAt ?? DateTime.now(),
            updatedAt: cachedLedger.updatedAt ?? DateTime.now(),
          );
        }
      } catch (e) {
        debugPrint('⚠️ Could not load cached ledger: $e');
      }

      // If online, fetch fresh data from API
      if (isOnline) {
        try {
          final detail = await _api.getLedgerDetails(ledgerId);
          ledgerDetail.value = detail;
          debugPrint('✅ Ledger details loaded from API: ${detail.partyName}');

          // 🗄️ Cache ledger to local DB for offline use
          await ledgerRepository.cacheLedgerDetailFromApi(detail);
        } catch (apiError) {
          debugPrint('⚠️ API fetch failed: $apiError');
          // If we have cached data, don't show error
          if (ledgerDetail.value == null) {
            rethrow;
          }
        }
      } else {
        debugPrint('📴 Offline - Using cached ledger details');
        if (ledgerDetail.value == null) {
          throw Exception('No cached data available. Please connect to internet.');
        }
      }
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

  /// Fetch transaction history for this specific ledger - OFFLINE FIRST
  Future<void> fetchTransactions() async {
    try {
      isTransactionsLoading.value = true;

      // Reset pagination state for fresh fetch
      currentOffset.value = 0;
      hasMoreData.value = true;
      allTransactions.clear();

      debugPrint('🔄 Fetching transaction history for ledger: $ledgerId (OFFLINE-FIRST)');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Is Online: $isOnline');

      // 🔧 REPAIR: Fix duplicates and recalculate balances first
      await transactionRepository.repairLedgerData(ledgerId);

      // 🔄 Refresh ledger balance from DB (after recalculation)
      final updatedBalance = await transactionRepository.getLedgerBalanceFromDb(ledgerId);
      if (ledgerDetail.value != null) {
        ledgerDetail.value = LedgerDetailModel(
          id: ledgerDetail.value!.id,
          merchantId: ledgerDetail.value!.merchantId,
          partyName: ledgerDetail.value!.partyName,
          partyType: ledgerDetail.value!.partyType,
          mobileNumber: ledgerDetail.value!.mobileNumber,
          currentBalance: updatedBalance, // Updated balance from DB
          openingBalance: ledgerDetail.value!.openingBalance,
          area: ledgerDetail.value!.area,
          address: ledgerDetail.value!.address,
          pinCode: ledgerDetail.value!.pinCode,
          creditLimit: ledgerDetail.value!.creditLimit,
          creditDay: ledgerDetail.value!.creditDay,
          interestType: ledgerDetail.value!.interestType,
          interestRate: ledgerDetail.value!.interestRate,
          transactionType: ledgerDetail.value!.transactionType,
          isDelete: ledgerDetail.value!.isDelete,
          salary: ledgerDetail.value!.salary,
          salaryType: ledgerDetail.value!.salaryType,
          createdAt: ledgerDetail.value!.createdAt,
          updatedAt: ledgerDetail.value!.updatedAt,
        );
        debugPrint('💰 Ledger balance updated in UI: $updatedBalance');
      }

      // 🗄️ OFFLINE-FIRST: Load cached data with proper balances
      List<TransactionItemModel> cachedTransactions = [];
      List<TransactionItemModel> unsyncedTransactions = [];

      try {
        // Get cached transactions with proper balance calculation
        cachedTransactions = await transactionRepository.getTransactionsWithBalances(ledgerId);
        debugPrint('📦 Loaded ${cachedTransactions.length} cached transactions');

        // 🔍 DEBUG: Log each transaction's full details
        debugPrint('📦📦📦 CACHED TRANSACTIONS DETAIL:');
        for (final tx in cachedTransactions) {
          final deleteIcon = tx.isDelete ? '🗑️' : '✅';
          debugPrint('   $deleteIcon ID: ${tx.id}');
          debugPrint('      Amount: ₹${tx.amount}');
          debugPrint('      Type: ${tx.transactionType}');
          debugPrint('      Date: ${tx.transactionDate}');
          debugPrint('      Description: "${tx.description ?? "No description"}"');
        }
        debugPrint('📦📦📦 Total deleted in cache: ${cachedTransactions.where((t) => t.isDelete).length}');

        // Get unsynced transactions separately (to preserve during API merge)
        unsyncedTransactions = await transactionRepository.getUnsyncedTransactionsByLedger(ledgerId);
        debugPrint('📤 Found ${unsyncedTransactions.length} unsynced transactions');
        for (final tx in unsyncedTransactions) {
          debugPrint('   📤 Unsynced - ID: ${tx.id}, isDelete: ${tx.isDelete}');
        }

        // Show cached data immediately
        if (cachedTransactions.isNotEmpty) {
          _updateTransactionUI(cachedTransactions);
        }
      } catch (e) {
        debugPrint('⚠️ Could not load cached transactions: $e');
      }

      // 🌐 If online, fetch fresh data from API and merge with unsynced
      if (isOnline) {
        try {
          debugPrint('🔄 Online - Fetching fresh transactions from API...');
          final history = await _transactionApi.getLedgerTransactions(
            ledgerId: ledgerId,
            skip: currentOffset.value,
            limit: _limit,
          );

          // Get API transactions
          List<TransactionItemModel> apiTransactions = history.data;
          totalTransactionCount.value = history.totalCount;

          debugPrint('✅ Got ${apiTransactions.length} transactions from API (total: ${history.totalCount})');

          // 🗄️ Cache API transactions to local DB for offline use
          // This preserves local deletes (isDelete: true) that haven't synced yet
          await transactionRepository.cacheTransactionsFromApi(apiTransactions, ledgerId);

          // 🔄 IMPORTANT: Re-fetch from cache to get preserved local deletes
          // The apiTransactions list has isDelete: false from API, but cache has isDelete: true for pending deletes
          final cachedAfterSync = await transactionRepository.getTransactionsWithBalances(ledgerId);
          debugPrint('📦 Re-fetched ${cachedAfterSync.length} transactions from cache (with preserved deletes)');

          // 🔍 DEBUG: Log each transaction's full details after sync
          debugPrint('🔄🔄🔄 AFTER ONLINE SYNC - CACHED TRANSACTIONS DETAIL:');
          for (final tx in cachedAfterSync) {
            final deleteIcon = tx.isDelete ? '🗑️' : '✅';
            debugPrint('   $deleteIcon ID: ${tx.id}');
            debugPrint('      Amount: ₹${tx.amount}');
            debugPrint('      Type: ${tx.transactionType}');
            debugPrint('      Date: ${tx.transactionDate}');
            debugPrint('      Description: "${tx.description ?? "No description"}"');
            debugPrint('      isDelete: ${tx.isDelete}');
          }

          // Count how many are deleted (for verification)
          final deletedCount = cachedAfterSync.where((t) => t.isDelete).length;
          debugPrint('🗑️🗑️🗑️ TOTAL with isDelete=true AFTER SYNC: $deletedCount');

          // Update total count
          totalTransactionCount.value = cachedAfterSync.length;

          debugPrint('🔀 Using ${cachedAfterSync.length} cached transactions (includes preserved deletes)');

          // Update UI with cached data (which has correct isDelete values)
          allTransactions.clear();
          _updateTransactionUI(cachedAfterSync);

        } catch (apiError) {
          debugPrint('⚠️ API fetch failed: $apiError');
          // If we have cached data, keep using it
          if (allTransactions.isEmpty && cachedTransactions.isNotEmpty) {
            debugPrint('📦 Using cached data as fallback');
            _updateTransactionUI(cachedTransactions);
          } else if (allTransactions.isEmpty) {
            rethrow;
          }
        }
      } else {
        debugPrint('📴 Offline - Using cached transactions with balances');
        if (cachedTransactions.isEmpty) {
          debugPrint('⚠️ No cached transactions available');
        }
      }

      // Update ledger's cached transactionDate to the latest transaction date
      if (allTransactions.isNotEmpty) {
        try {
          // Find the latest transactionDate from loaded transactions
          DateTime? latestDate;
          for (final tx in allTransactions) {
            try {
              final txDate = DateTime.parse(tx.transactionDate);
              if (latestDate == null || txDate.isAfter(latestDate)) {
                latestDate = txDate;
              }
            } catch (_) {}
          }
          if (latestDate != null) {
            await ledgerRepository.updateLedgerTransactionDate(ledgerId, latestDate);
          }
        } catch (e) {
          debugPrint('⚠️ Could not update ledger transactionDate: $e');
        }
      }

      debugPrint('✅ Transactions loaded: ${allTransactions.length}/${totalTransactionCount.value} for ledger $ledgerId');
      debugPrint('📄 Has more data: ${hasMoreData.value}');
    } catch (e) {
      debugPrint('❌ Error fetching transactions: $e');
      // Don't show error if we're offline and have no data
      if (allTransactions.isEmpty) {
        AdvancedErrorService.showError(
          e.toString().replaceAll('Exception: ', ''),
          severity: ErrorSeverity.high,
          category: ErrorCategory.network,
        );
      }
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  /// Helper method to update transaction UI
  void _updateTransactionUI(List<TransactionItemModel> transactions) {
    debugPrint('');
    debugPrint('🎯🎯🎯 ========== _updateTransactionUI CALLED ========== 🎯🎯🎯');
    debugPrint('🎯 Input transactions count: ${transactions.length}');
    debugPrint('🎯 Deleted in input: ${transactions.where((t) => t.isDelete).length}');

    // Store total count if not set
    if (totalTransactionCount.value == 0) {
      totalTransactionCount.value = transactions.length;
    }

    // Sort transactions by transactionDate (descending - newest first) for display
    final sortedData = List.of(transactions);
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

    // 🔍 DEBUG: Log final transaction list going to UI
    debugPrint('🎯 FINAL TRANSACTIONS FOR UI:');
    for (final tx in allTransactions) {
      final deleteIcon = tx.isDelete ? '🗑️ DELETED' : '✅ ACTIVE';
      debugPrint('   $deleteIcon - ID: ${tx.id}, ₹${tx.amount}');
    }
    debugPrint('🎯 Total in allTransactions: ${allTransactions.length}');
    debugPrint('🎯 Total deleted for strikethrough: ${allTransactions.where((t) => t.isDelete).length}');

    // Update hasMoreData based on total count
    hasMoreData.value = allTransactions.length < totalTransactionCount.value;

    // Update transaction history for UI
    transactionHistory.value = TransactionListModel(
      count: allTransactions.length,
      totalCount: totalTransactionCount.value,
      data: allTransactions.toList(),
    );

    debugPrint('🎯🎯🎯 ========== _updateTransactionUI END ========== 🎯🎯🎯');
    debugPrint('');
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

    // Track when data was last fetched
    _lastFetchTime = DateTime.now();

    // Clear refresh flag for this ledger if set
    try {
      if (Get.isRegistered<SyncService>()) {
        SyncService.instance.clearLedgerRefreshFlag(ledgerId);
      }
    } catch (e) {
      // Ignore
    }

    debugPrint('✅ refreshAll() completed');
    debugPrint('📊 Transaction count AFTER refresh: ${transactionHistory.value?.count ?? 0}');
  }

  @override
  void onReady() {
    super.onReady();

    // Check if refresh is needed when screen becomes visible
    // This handles cases where controller was reused (not recreated)
    _checkForPendingRefresh();
  }

  /// Check for pending refresh when screen becomes ready
  void _checkForPendingRefresh() {
    try {
      if (!Get.isRegistered<SyncService>()) return;

      final syncService = SyncService.instance;

      // If ledger is marked for refresh, do it now
      if (syncService.doesLedgerNeedRefresh(ledgerId)) {
        debugPrint('🔄 onReady: Ledger $ledgerId needs refresh - triggering refreshAll()');
        refreshAll();
        return;
      }

      // If sync happened after our last fetch, refresh
      if (_lastFetchTime != null && syncService.didSyncHappenAfter(_lastFetchTime!)) {
        debugPrint('🔄 onReady: Sync happened after last fetch - triggering refreshAll()');
        refreshAll();
      }
    } catch (e) {
      debugPrint('⚠️ Could not check pending refresh: $e');
    }
  }

  /// Deactivate ledger
  /// Calls PATCH /api/ledger/{ledgerId}/status with isActive: false
  Future<bool> deactivateLedger(String securityKey) async {
    try {
      debugPrint('🔒 Deactivating ledger: $ledgerId');

      final response = await _api.updateLedgerStatus(
        ledgerId: ledgerId,
        isActive: false,
        securityKey: securityKey,
      );

      debugPrint('✅ Ledger deactivated: ${response.message}');

      // Update local DB to mark ledger as inactive
      await ledgerRepository.updateLedgerStatus(ledgerId, false, securityKey);
      debugPrint('💾 Local DB updated - ledger marked as inactive');

      // Immediately remove from LedgerController lists for instant UI update
      try {
        final ledgerController = Get.find<LedgerController>();
        ledgerController.removeLedgerFromLists(ledgerId);
        debugPrint('🗑️ Ledger removed from LedgerController lists');
      } catch (e) {
        debugPrint('⚠️ LedgerController not found: $e');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error deactivating ledger: $e');
      AdvancedErrorService.showError(
        'Unable to deactivate. Please try again.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.general,
      );
      return false;
    }
  }

  /// Activate ledger
  /// Calls PATCH /api/ledger/{ledgerId}/status with isActive: true
  Future<bool> activateLedger(String securityKey) async {
    try {
      debugPrint('🔓 Activating ledger: $ledgerId');

      final response = await _api.updateLedgerStatus(
        ledgerId: ledgerId,
        isActive: true,
        securityKey: securityKey,
      );

      debugPrint('✅ Ledger activated: ${response.message}');
      return true;
    } catch (e) {
      debugPrint('❌ Error activating ledger: $e');
      AdvancedErrorService.showError(
        'Unable to activate. Please try again.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.general,
      );
      return false;
    }
  }

  // ============ OFFLINE-FIRST HELPERS ============

  /// Refresh ledger balance from local DB after offline transaction
  Future<void> refreshLedgerBalanceFromDb() async {
    try {
      final cachedLedger = await ledgerRepository.getLedgerById(ledgerId);
      if (cachedLedger != null && ledgerDetail.value != null) {
        // Update the observable with new balance
        ledgerDetail.value = LedgerDetailModel(
          id: ledgerDetail.value!.id,
          merchantId: ledgerDetail.value!.merchantId,
          partyName: ledgerDetail.value!.partyName,
          partyType: ledgerDetail.value!.partyType,
          mobileNumber: ledgerDetail.value!.mobileNumber,
          currentBalance: cachedLedger.currentBalance, // Updated balance
          openingBalance: ledgerDetail.value!.openingBalance,
          area: ledgerDetail.value!.area,
          address: ledgerDetail.value!.address,
          pinCode: ledgerDetail.value!.pinCode,
          creditLimit: ledgerDetail.value!.creditLimit,
          creditDay: ledgerDetail.value!.creditDay,
          interestType: ledgerDetail.value!.interestType,
          interestRate: ledgerDetail.value!.interestRate,
          transactionType: ledgerDetail.value!.transactionType,
          isDelete: ledgerDetail.value!.isDelete,
          salary: ledgerDetail.value!.salary,
          salaryType: ledgerDetail.value!.salaryType,
          createdAt: ledgerDetail.value!.createdAt,
          updatedAt: ledgerDetail.value!.updatedAt,
        );
        debugPrint('💰 Ledger balance refreshed from DB: ${cachedLedger.currentBalance}');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to refresh ledger balance: $e');
    }
  }

}
