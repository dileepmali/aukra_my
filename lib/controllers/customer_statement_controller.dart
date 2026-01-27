import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/customer_statement_api.dart';
import '../core/api/ledger_transaction_dashboard_api.dart';
import '../core/api/merchant_dashboard_api.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/ledger_transaction_dashboard_model.dart';
import '../models/party_dashboard_model.dart';

/// Controller for Customer Statement Screen
/// Uses:
/// - GET /api/ledgerTransaction/{merchantId}/dashboard (for list data with filters)
/// - GET /api/merchant/{merchantId}/{partyType}/dashboard (for header summary)
class CustomerStatementController extends GetxController {
  // APIs
  final LedgerTransactionDashboardApi _transactionApi = LedgerTransactionDashboardApi();
  final MerchantDashboardApi _dashboardApi = MerchantDashboardApi();
  final CustomerStatementApi _exportApi = CustomerStatementApi(); // For export only

  // 🗄️ Offline-first repositories
  LedgerRepository? _ledgerRepository;
  LedgerRepository get ledgerRepository {
    if (_ledgerRepository == null) {
      if (Get.isRegistered<LedgerRepository>()) {
        _ledgerRepository = Get.find<LedgerRepository>();
      } else {
        _ledgerRepository = LedgerRepository();
      }
    }
    return _ledgerRepository!;
  }

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

  // ============================================================
  // OBSERVABLE VARIABLES
  // ============================================================
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  // Transaction list data from GET /api/ledgerTransaction/{merchantId}/dashboard
  final transactionData = Rxn<LedgerTransactionDashboardModel>();

  // Party-specific Dashboard data from GET /api/merchant/{merchantId}/{partyType}/dashboard
  final partyDashboardData = Rxn<PartyDashboardModel>();

  // Party type: 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  String partyType = 'CUSTOMER';
  String partyTypeLabel = 'Customer';

  // ============================================================
  // PAGINATION VARIABLES
  // ============================================================
  final ScrollController scrollController = ScrollController();
  final currentSkip = 0.obs;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;
  final int pageLimit = 10;
  final totalCount = 0.obs;

  // ============================================================
  // PARTY DASHBOARD API DATA GETTERS
  // ============================================================
  // Data from GET /api/merchant/{merchantId}/{partyType}/dashboard

  /// Get net balance from Party Dashboard API
  double get partyNetBalance {
    return partyDashboardData.value?.netBalance ?? 0.0;
  }

  /// Get net balance type from Party Dashboard API
  String get partyNetBalanceType {
    return partyDashboardData.value?.netBalanceType ?? 'OUT';
  }

  /// Get total count from Party Dashboard API
  int get partyTotal {
    return partyDashboardData.value?.total ?? 0;
  }

  /// Get today IN from Party Dashboard API
  double get todayIn {
    return partyDashboardData.value?.todayIn ?? 0.0;
  }

  /// Get today OUT from Party Dashboard API
  double get todayOut {
    return partyDashboardData.value?.todayOut ?? 0.0;
  }

  /// Get overall received from Party Dashboard API
  double get overallReceived {
    return partyDashboardData.value?.overallReceived ?? 0.0;
  }

  /// Get overall given from Party Dashboard API
  double get overallGiven {
    return partyDashboardData.value?.overallGiven ?? 0.0;
  }

  // ============================================================
  // FILTER STATE - Server-side filtering
  // ============================================================

  /// Sort by: default, name, amount, transaction_date
  /// Default: 'default' (server decides, usually transactionDate desc)
  final sortBy = 'default'.obs;

  /// Sort order: asc, desc
  /// Default: desc (newest first)
  final sortOrder = 'desc'.obs;

  /// Date filter: today, yesterday, older_week, older_month, all_time, custom
  final dateFilter = 'all_time'.obs;

  /// Transaction filter: all_transaction, in_transaction, out_transaction
  final transactionFilter = 'all_transaction'.obs;

  /// Party type filter for list: all, CUSTOMER, SUPPLIER, EMPLOYEE
  final partyTypeFilter = 'all'.obs;

  /// Custom date range
  final customDateFrom = Rxn<DateTime>();
  final customDateTo = Rxn<DateTime>();

  /// Flag to indicate if filters are active
  final hasActiveFilters = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get party type from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      partyType = args['partyType'] ?? 'CUSTOMER';
      partyTypeLabel = args['partyTypeLabel'] ?? 'Customer';
    }

    // Set initial party type filter based on screen type
    partyTypeFilter.value = partyType;

    debugPrint('📊 CustomerStatementController initialized for: $partyType');

    // Setup scroll listener for infinite scrolling
    _setupScrollListener();

    // Fetch data
    fetchAllData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  /// Setup scroll listener for infinite scrolling
  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        // User is near the bottom, load more data
        loadMoreData();
      }
    });
  }

  /// Load more data for pagination (infinite scrolling)
  Future<void> loadMoreData() async {
    // Don't load if already loading or no more data
    if (isLoadingMore.value || !hasMoreData.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;
      final nextSkip = currentSkip.value + pageLimit;

      debugPrint('📡 Loading more transactions (Skip: $nextSkip)...');

      final newData = await _transactionApi.getLedgerTransactionDashboard(
        partyType: _getPartyTypeForApi(),
        skip: nextSkip,
        limit: pageLimit,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        sortBy: _getSortByForApi(),
        sortOrder: _getSortOrderForApi(),
        dateFilter: dateFilter.value != 'all_time' ? dateFilter.value : null,
        startDate: dateFilter.value == 'custom' ? customDateFrom.value : null,
        endDate: dateFilter.value == 'custom' ? customDateTo.value : null,
        transactionType: _getTransactionTypeForApi(),
      );

      if (newData.data.isEmpty) {
        hasMoreData.value = false;
        debugPrint('📭 No more data available');
      } else {
        // Append new items to existing list
        final existingItems = transactionData.value?.data ?? [];
        final allItems = [...existingItems, ...newData.data];

        transactionData.value = LedgerTransactionDashboardModel(
          count: newData.count,
          totalCount: newData.totalCount,
          data: allItems,
        );

        currentSkip.value = nextSkip;

        // Check if we got less than limit (means no more data)
        if (newData.data.length < pageLimit) {
          hasMoreData.value = false;
        }

        debugPrint('✅ Loaded ${newData.data.length} more items. Total: ${allItems.length}');
      }
    } catch (e) {
      debugPrint('❌ Error loading more data: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Get party type for API (null if 'all')
  String? _getPartyTypeForApi() {
    if (partyTypeFilter.value == 'all') return null;
    return partyTypeFilter.value;
  }

  /// Get transaction type for API based on filter
  String? _getTransactionTypeForApi() {
    switch (transactionFilter.value) {
      case 'in_transaction':
        return 'IN';
      case 'out_transaction':
        return 'OUT';
      default:
        return null; // all_transaction
    }
  }

  /// Fetch all data (transaction list + dashboard)
  Future<void> fetchAllData() async {
    // Check connectivity
    final isOnline = Get.isRegistered<ConnectivityService>()
        ? ConnectivityService.instance.isConnected.value
        : true;

    if (isOnline) {
      // Online: Fetch in parallel for speed
      await Future.wait([
        fetchTransactionList(),
        fetchDashboard(),
      ]);
    } else {
      // Offline: Fetch sequentially
      await fetchTransactionList();
      await fetchDashboard();
    }
  }

  /// Fetch party-specific dashboard data
  /// GET /api/merchant/{merchantId}/{partyType}/dashboard
  Future<void> fetchDashboard() async {
    try {
      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('📊 Fetching $partyType dashboard...');

      if (!isOnline) {
        if (partyDashboardData.value != null) {
          debugPrint('📴 Offline - Using cached dashboard');
          return;
        }
        await _calculateDashboardFromCachedData();
        return;
      }

      // 🌐 Online: Fetch from API
      try {
        debugPrint('🔄 Fetching $partyType dashboard from API...');
        final data = await _dashboardApi.getPartyDashboard(partyType: partyType);
        partyDashboardData.value = data;

        debugPrint('✅ $partyType Dashboard loaded');
        debugPrint('   - Net Balance: ₹${data.netBalance} (${data.netBalanceType})');
        debugPrint('   - Total: ${data.total}');
        debugPrint('   - Today In: ₹${data.todayIn}');
        debugPrint('   - Today Out: ₹${data.todayOut}');
      } catch (apiError) {
        debugPrint('⚠️ Dashboard API failed: $apiError');
        await _calculateDashboardFromCachedData();
      }
    } catch (e) {
      debugPrint('❌ Error fetching dashboard: $e');
    }
  }

  /// Calculate dashboard from cached data (offline fallback)
  Future<void> _calculateDashboardFromCachedData() async {
    try {
      final merchantId = await _getMerchantId();
      if (merchantId == null) return;

      final ledgers = await ledgerRepository.getLedgersByPartyType(merchantId, partyType);
      if (ledgers.isEmpty) return;

      double overallReceivedAmount = 0;
      double overallGivenAmount = 0;
      int count = 0;

      for (final ledger in ledgers) {
        count++;
        if (ledger.currentBalance >= 0) {
          overallGivenAmount += ledger.currentBalance.abs();
        } else {
          overallReceivedAmount += ledger.currentBalance.abs();
        }
      }

      final netBalance = overallGivenAmount - overallReceivedAmount;
      final netBalanceType = netBalance >= 0 ? 'OUT' : 'IN';

      partyDashboardData.value = PartyDashboardModel(
        todayIn: 0,
        todayOut: 0,
        overallGiven: overallGivenAmount,
        overallReceived: overallReceivedAmount,
        netBalance: netBalance.abs(),
        netBalanceType: netBalanceType,
        total: count,
      );

      debugPrint('📦 Dashboard calculated from cache');
    } catch (e) {
      debugPrint('⚠️ Error calculating dashboard from cache: $e');
    }
  }

  /// Fetch transaction list with filters
  /// GET /api/ledgerTransaction/{merchantId}/dashboard
  Future<void> fetchTransactionList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Reset pagination
      currentSkip.value = 0;
      hasMoreData.value = true;

      debugPrint('');
      debugPrint('========================================');
      debugPrint('📡 FETCH TRANSACTION LIST CALLED');
      debugPrint('========================================');
      debugPrint('   partyType: ${_getPartyTypeForApi() ?? "ALL"}');
      debugPrint('   sortBy (raw): ${sortBy.value}');
      debugPrint('   sortOrder (raw): ${sortOrder.value}');
      debugPrint('   sortBy (API): ${_getSortByForApi() ?? "null (default)"}');
      debugPrint('   sortOrder (API): ${_getSortOrderForApi() ?? "null (default)"}');
      debugPrint('   dateFilter: ${dateFilter.value}');
      debugPrint('   transactionType: ${_getTransactionTypeForApi() ?? "ALL"}');
      debugPrint('   search: ${searchQuery.value.isEmpty ? "none" : searchQuery.value}');
      debugPrint('   customDateFrom: ${customDateFrom.value}');
      debugPrint('   customDateTo: ${customDateTo.value}');
      debugPrint('   skip: 0, limit: $pageLimit');
      debugPrint('========================================');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Online: $isOnline');

      if (!isOnline) {
        debugPrint('📴 OFFLINE - loading from cache (NO FILTER SUPPORT)');
        await _loadFromCache();
        return;
      }

      // 🌐 Online: Fetch from API
      try {
        debugPrint('🔄 Making API call...');
        final data = await _transactionApi.getLedgerTransactionDashboard(
          partyType: _getPartyTypeForApi(),
          skip: 0,
          limit: pageLimit,
          search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
          sortBy: _getSortByForApi(),
          sortOrder: _getSortOrderForApi(),
          dateFilter: dateFilter.value != 'all_time' ? dateFilter.value : null,
          startDate: dateFilter.value == 'custom' ? customDateFrom.value : null,
          endDate: dateFilter.value == 'custom' ? customDateTo.value : null,
          transactionType: _getTransactionTypeForApi(),
        );

        transactionData.value = data;
        totalCount.value = data.totalCount;

        // Check if we got less than limit (means no more data)
        if (data.data.length < pageLimit) {
          hasMoreData.value = false;
        }

        debugPrint('✅ API SUCCESS - Transaction list loaded');
        debugPrint('   Count: ${data.count}, TotalCount: ${data.totalCount}');
        debugPrint('   Items received: ${data.data.length}');
        if (data.data.isNotEmpty) {
          debugPrint('   First item: ${data.data.first.partyName} - ₹${data.data.first.amount}');
        }
      } catch (apiError) {
        debugPrint('');
        debugPrint('❌❌❌ API FAILED ❌❌❌');
        debugPrint('   Error: $apiError');
        debugPrint('   Loading from CACHE instead (NO FILTER SUPPORT)');
        debugPrint('');
        await _loadFromCache();
        if (transactionData.value == null || transactionData.value!.data.isEmpty) {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load data from local cache (offline fallback)
  Future<void> _loadFromCache() async {
    try {
      final merchantId = await _getMerchantId();
      if (merchantId == null) return;

      final ledgers = await ledgerRepository.getLedgersByPartyType(merchantId, partyType);
      if (ledgers.isEmpty) {
        errorMessage.value = 'No cached data available. Please connect to internet.';
        return;
      }

      // Convert to LedgerTransactionItem format
      final items = ledgers.map((ledger) => LedgerTransactionItem(
        ledgerId: ledger.id ?? 0,
        partyName: ledger.name,
        partyType: ledger.partyType,
        mobileNumber: ledger.mobileNumber,
        transactionId: 0,
        amount: 0,
        lastBalance: 0,
        isDelete: false,
        currentBalance: ledger.currentBalance,
        description: null,
        transactionDate: ledger.updatedAt ?? DateTime.now(),
        updatedAt: ledger.updatedAt ?? DateTime.now(),
        transactionType: ledger.currentBalance >= 0 ? 'IN' : 'OUT',
        balanceType: ledger.currentBalance >= 0 ? 'IN' : 'OUT',
        rowNum: 0,
      )).toList();

      transactionData.value = LedgerTransactionDashboardModel(
        count: items.length,
        totalCount: items.length,
        data: items,
      );

      hasMoreData.value = false;
      debugPrint('📦 Loaded ${items.length} items from cache');
    } catch (e) {
      debugPrint('⚠️ Error loading from cache: $e');
    }
  }

  /// Get merchant ID from storage
  Future<int?> _getMerchantId() async {
    try {
      return await AuthStorage.getMerchantId();
    } catch (e) {
      debugPrint('⚠️ Could not get merchant ID: $e');
      return null;
    }
  }

  /// Refresh data (resets pagination and refetches)
  Future<void> refreshStatement() async {
    currentSkip.value = 0;
    hasMoreData.value = true;
    await fetchAllData();
  }

  /// Get transaction list (for UI)
  List<LedgerTransactionItem> get filteredCustomers {
    return transactionData.value?.data ?? [];
  }

  // ============================================================
  // FILTER METHODS - Server-side filtering
  // ============================================================

  /// Handle filters from AppBar - ALWAYS refetch with applied filters
  void handleFiltersApplied(Map<String, dynamic> filters) {
    debugPrint('🔍 ===== FILTERS APPLIED =====');
    debugPrint('🔍 Raw filters from BottomSheet: $filters');

    // Handle Sort By - store EXACTLY what bottom sheet sends
    final filterSortBy = filters['sortBy'] as String?;
    if (filterSortBy != null) {
      sortBy.value = filterSortBy;
    }

    // Handle Sort Order
    final filterSortOrder = filters['sortOrder'] as String?;
    if (filterSortOrder != null) {
      sortOrder.value = filterSortOrder;
    }

    // Handle Date Filter
    final filterDate = filters['dateFilter'] as String?;
    if (filterDate != null) {
      dateFilter.value = filterDate;
    }

    // Handle Custom Date Range
    customDateFrom.value = filters['customDateFrom'] as DateTime?;
    customDateTo.value = filters['customDateTo'] as DateTime?;

    // Handle Transaction Filter (IN/OUT)
    final filterTransaction = filters['transactionFilter'] as String?;
    if (filterTransaction != null) {
      transactionFilter.value = filterTransaction;
    }

    // Handle Party Type Filter
    final filterPartyType = filters['userFilter'] as String?;
    if (filterPartyType != null) {
      partyTypeFilter.value = _mapUserFilterToPartyType(filterPartyType);
    }

    // Update active filters flag
    _updateActiveFiltersFlag();

    // ALWAYS refetch when user presses Apply
    debugPrint('🔄 Refetching with filters...');
    debugPrint('   sortBy=${sortBy.value}, sortOrder=${sortOrder.value}');
    debugPrint('   dateFilter=${dateFilter.value}, transactionType=${_getTransactionTypeForApi()}');
    debugPrint('   partyType=${_getPartyTypeForApi()}, search=${searchQuery.value}');
    debugPrint('   customDateFrom=${customDateFrom.value}, customDateTo=${customDateTo.value}');
    fetchTransactionList();
  }

  /// Get sortBy field name for API
  /// Maps UI field names to API field names
  String? _getSortByForApi() {
    if (sortBy.value == 'default' || sortBy.value.isEmpty) {
      return null; // Don't send - let backend use its default
    }

    // Map bottom sheet field names to API field names
    switch (sortBy.value) {
      case 'name':
        return 'partyName';
      case 'transaction_date':
        return 'transactionDate';
      case 'amount':
        return 'amount';
      default:
        return sortBy.value;
    }
  }

  /// Get sortOrder for API (separate param)
  String? _getSortOrderForApi() {
    if (sortBy.value == 'default' || sortBy.value.isEmpty) {
      return null; // Don't send if no sortBy
    }
    return sortOrder.value.isNotEmpty ? sortOrder.value : 'desc';
  }

  /// Get current sortBy for AppBar display (pass-through)
  String get sortByForUI => sortBy.value;

  /// Map userFilter to partyType
  String _mapUserFilterToPartyType(String userFilter) {
    switch (userFilter) {
      case 'customer':
        return 'CUSTOMER';
      case 'supplier':
        return 'SUPPLIER';
      case 'employee':
        return 'EMPLOYEE';
      default:
        return partyType; // Use screen's default party type
    }
  }

  /// Update flag to indicate if filters are active
  void _updateActiveFiltersFlag() {
    final isSortActive = sortBy.value != 'default' || sortOrder.value != 'desc';

    hasActiveFilters.value = isSortActive ||
        dateFilter.value != 'all_time' ||
        transactionFilter.value != 'all_transaction' ||
        partyTypeFilter.value != partyType ||
        customDateFrom.value != null ||
        customDateTo.value != null ||
        searchQuery.value.isNotEmpty;
  }

  /// Handle search query change
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _updateActiveFiltersFlag();

    // Debounce search - fetch after user stops typing
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery.value == query) {
        fetchTransactionList();
      }
    });
  }

  /// Clear all filters (reset to defaults)
  void clearFilters() {
    sortBy.value = 'transactionDate';
    sortOrder.value = 'desc';
    dateFilter.value = 'all_time';
    transactionFilter.value = 'all_transaction';
    partyTypeFilter.value = partyType;
    customDateFrom.value = null;
    customDateTo.value = null;
    searchQuery.value = '';
    hasActiveFilters.value = false;

    // Refetch with cleared filters
    fetchTransactionList();
  }

  // ============================================================
  // DOWNLOAD
  // ============================================================
  final isDownloading = false.obs;

  /// Download statement - calls export API
  Future<void> downloadStatement() async {
    if (isDownloading.value) return;

    try {
      debugPrint('📥 Downloading $partyType statement...');
      isDownloading.value = true;

      final response = await _exportApi.exportTransactions(
        partyType: partyType,
      );

      isDownloading.value = false;

      final message = response['message'] ?? 'Export initiated';
      debugPrint('✅ Export Response: $message');

      AdvancedErrorService.showSuccess(
        message,
        type: SuccessType.snackbar,
        customDuration: const Duration(seconds: 3),
      );
    } catch (e) {
      isDownloading.value = false;
      debugPrint('❌ Error downloading: $e');

      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.download,
        customDuration: const Duration(seconds: 3),
      );
    }
  }

  // ============================================================
  // UI HELPERS
  // ============================================================

  /// Get screen title based on party type
  String get screenTitle {
    switch (partyType) {
      case 'CUSTOMER':
        return 'Customers account statements';
      case 'SUPPLIER':
        return 'Suppliers account statements';
      case 'EMPLOYEE':
        return 'Employees account statements';
      default:
        return 'Account statements';
    }
  }

  /// Get label text
  String get customerLabel {
    switch (partyType) {
      case 'CUSTOMER':
        return 'customers';
      case 'SUPPLIER':
        return 'suppliers';
      case 'EMPLOYEE':
        return 'employees';
      default:
        return 'entries';
    }
  }
}