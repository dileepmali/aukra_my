import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/customer_statement_api.dart';
import '../core/api/merchant_dashboard_api.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/customer_statement_model.dart';
import '../models/merchant_dashboard_model.dart';

/// Controller for Customer Statement Screen
class CustomerStatementController extends GetxController {
  final CustomerStatementApi _statementApi = CustomerStatementApi();
  final MerchantDashboardApi _dashboardApi = MerchantDashboardApi();

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

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final statementData = Rxn<CustomerStatementModel>();
  final searchQuery = ''.obs;

  // Dashboard data from GET /api/merchant/{merchantId}/dashboard
  final dashboardData = Rxn<MerchantDashboardModel>();

  // Party type: 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  String partyType = 'CUSTOMER';
  String partyTypeLabel = 'Customer';

  // ============================================================
  // PAGINATION VARIABLES
  // ============================================================
  final ScrollController scrollController = ScrollController();
  final currentPage = 1.obs;
  final hasMoreData = true.obs;
  final isLoadingMore = false.obs;
  final int pageLimit = 20;

  // ============================================================
  // DASHBOARD API DATA GETTERS
  // ============================================================

  /// Get net balance for current party type from Dashboard API
  double get partyNetBalance {
    if (dashboardData.value == null) return 0.0;
    switch (partyType) {
      case 'CUSTOMER':
        return dashboardData.value!.party.customer.netBalance;
      case 'SUPPLIER':
        return dashboardData.value!.party.supplier.netBalance;
      case 'EMPLOYEE':
        return dashboardData.value!.party.employee.netBalance;
      default:
        return 0.0;
    }
  }

  /// Get net balance type for current party type from Dashboard API
  String get partyNetBalanceType {
    if (dashboardData.value == null) return 'OUT';
    switch (partyType) {
      case 'CUSTOMER':
        return dashboardData.value!.party.customer.netBalanceType;
      case 'SUPPLIER':
        return dashboardData.value!.party.supplier.netBalanceType;
      case 'EMPLOYEE':
        return dashboardData.value!.party.employee.netBalanceType;
      default:
        return 'OUT';
    }
  }

  /// Get total count for current party type from Dashboard API
  int get partyTotal {
    if (dashboardData.value == null) return 0;
    switch (partyType) {
      case 'CUSTOMER':
        return dashboardData.value!.party.customer.total;
      case 'SUPPLIER':
        return dashboardData.value!.party.supplier.total;
      case 'EMPLOYEE':
        return dashboardData.value!.party.employee.total;
      default:
        return 0;
    }
  }

  /// Get total IN for current party type from Dashboard API
  /// Uses party-specific overallReceived (money received from this party type)
  double get todayIn {
    if (dashboardData.value == null) return 0.0;
    switch (partyType) {
      case 'CUSTOMER':
        return dashboardData.value!.party.customer.overallReceived;
      case 'SUPPLIER':
        return dashboardData.value!.party.supplier.overallReceived;
      case 'EMPLOYEE':
        return dashboardData.value!.party.employee.overallReceived;
      default:
        return 0.0;
    }
  }

  /// Get total OUT for current party type from Dashboard API
  /// Uses party-specific overallGiven (money given to this party type)
  double get todayOut {
    if (dashboardData.value == null) return 0.0;
    switch (partyType) {
      case 'CUSTOMER':
        return dashboardData.value!.party.customer.overallGiven;
      case 'SUPPLIER':
        return dashboardData.value!.party.supplier.overallGiven;
      case 'EMPLOYEE':
        return dashboardData.value!.party.employee.overallGiven;
      default:
        return 0.0;
    }
  }

  // ============================================================
  // FILTER STATE (same as SearchController)
  // ============================================================

  /// Sort by: name, amount, transaction_date
  /// Default: transaction_date (most recent first)
  final sortBy = 'transaction_date'.obs;

  /// Sort order: asc, desc
  /// Default: desc (newest first)
  final sortOrder = 'desc'.obs;

  /// Date filter: today, yesterday, older_week, older_month, all_time, custom
  final dateFilter = 'all_time'.obs;

  /// Transaction filter: all_transaction, in_transaction, out_transaction
  final transactionFilter = 'all_transaction'.obs;

  /// Reminder filter: all, overdue, today, upcoming (hidden in this screen)
  final reminderFilter = 'all'.obs;

  /// User filter: all, customer, supplier, employee (hidden in this screen)
  final userFilter = 'all'.obs;

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

    debugPrint('📊 CustomerStatementController initialized for: $partyType');

    // Setup scroll listener for infinite scrolling
    _setupScrollListener();

    // Fetch statement data and dashboard data
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

  /// Load more data for pagination
  Future<void> loadMoreData() async {
    // Don't load if already loading or no more data
    if (isLoadingMore.value || !hasMoreData.value || isLoading.value) return;

    try {
      isLoadingMore.value = true;
      final nextPage = currentPage.value + 1;

      debugPrint('📡 Loading more $partyType (Page: $nextPage)...');

      final newData = await _statementApi.getCustomerStatement(
        partyType: partyType,
        page: nextPage,
        limit: pageLimit,
      );

      if (newData.customers.isEmpty) {
        hasMoreData.value = false;
        debugPrint('📭 No more data available');
      } else {
        // Append new customers to existing list
        final existingCustomers = statementData.value?.customers ?? [];
        final allCustomers = [...existingCustomers, ...newData.customers];

        statementData.value = CustomerStatementModel(
          customers: allCustomers,
        );

        currentPage.value = nextPage;

        // Check if we got less than limit (means no more data)
        if (newData.customers.length < pageLimit) {
          hasMoreData.value = false;
        }

        debugPrint('✅ Loaded ${newData.customers.length} more items. Total: ${allCustomers.length}');
      }
    } catch (e) {
      debugPrint('❌ Error loading more data: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Fetch all data (statement + dashboard)
  /// 🗄️ OFFLINE-FIRST: Fetch statement first, then dashboard (dashboard depends on statement data)
  Future<void> fetchAllData() async {
    // Check connectivity
    final isOnline = Get.isRegistered<ConnectivityService>()
        ? ConnectivityService.instance.isConnected.value
        : true;

    if (isOnline) {
      // Online: Fetch in parallel for speed
      await Future.wait([
        fetchStatement(),
        fetchDashboard(),
      ]);
    } else {
      // Offline: Fetch sequentially (dashboard depends on statement data)
      await fetchStatement();
      await fetchDashboard();
    }
  }

  /// 🧪 TEST METHOD: Simulates an error for testing UI visibility
  Future<void> _simulateErrorForTesting() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    errorMessage.value = 'Test Error: Data fetch failed (for testing UI)';
    isLoading.value = false;
  }

  /// Fetch dashboard data from GET /api/merchant/{merchantId}/dashboard - OFFLINE FIRST
  Future<void> fetchDashboard() async {
    try {
      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('📊 Fetching dashboard data for $partyType (OFFLINE-FIRST)...');
      debugPrint('🌐 Is Online: $isOnline');

      // 🗄️ OFFLINE: Skip if dashboard already calculated from fetchStatement()
      if (!isOnline) {
        if (dashboardData.value != null) {
          debugPrint('📴 Offline - Dashboard already calculated, skipping');
          return;
        }
        // Try to calculate if not yet done
        if (statementData.value != null && statementData.value!.customers.isNotEmpty) {
          await _calculateDashboardFromCachedData();
          debugPrint('📦 Dashboard calculated from cached data');
        }
        return;
      }

      // 🌐 If online, fetch fresh data from API
      try {
        debugPrint('🔄 Online - Fetching fresh dashboard from API...');
        final data = await _dashboardApi.getMerchantDashboard();
        dashboardData.value = data;

        debugPrint('✅ Dashboard loaded from API successfully for $partyType');
        debugPrint('   - Party Net Balance: ₹$partyNetBalance');
        debugPrint('   - Party Net Balance Type: $partyNetBalanceType');
        debugPrint('   - Party Total: $partyTotal');
        debugPrint('   - Party Overall Received (IN): ₹$todayIn');
        debugPrint('   - Party Overall Given (OUT): ₹$todayOut');
      } catch (apiError) {
        debugPrint('⚠️ API fetch failed: $apiError');
        // If API fails, try to calculate from cached data
        if (dashboardData.value == null && statementData.value != null) {
          await _calculateDashboardFromCachedData();
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching dashboard: $e');
    }
  }

  /// Calculate dashboard stats from cached statement data - OFFLINE FIRST
  Future<void> _calculateDashboardFromCachedData() async {
    if (statementData.value == null) return;

    double overallReceived = 0; // Total IN (money received from party)
    double overallGiven = 0;    // Total OUT (money given to party)
    int totalCount = 0;

    // Calculate overall totals from ledger balances
    for (final customer in statementData.value!.customers) {
      totalCount++;
      // Balance type 'IN' = customer owes you (positive balance)
      // Balance type 'OUT' = you owe customer (negative balance)
      if (customer.balanceType == 'IN') {
        overallGiven += customer.balance; // They owe you = you gave them
      } else {
        overallReceived += customer.balance; // You owe them = you received from them
      }
    }

    // Calculate net balance
    final netBalance = overallGiven - overallReceived;
    final netBalanceType = netBalance >= 0 ? 'OUT' : 'IN';

    // Calculate today's IN/OUT from cached transactions
    double todayInAmount = 0;
    double todayOutAmount = 0;

    try {
      final merchantId = await _getMerchantId();
      if (merchantId != null) {
        // Get all ledgers for this party type
        final ledgers = await ledgerRepository.getLedgersByPartyType(merchantId, partyType);

        // Get today's date range
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

        // Sum up today's transactions from all ledgers
        for (final ledger in ledgers) {
          if (ledger.id != null) {
            final todayTransactions = await transactionRepository.getTransactionsByDateRange(
              ledger.id!,
              todayStart,
              todayEnd,
            );

            for (final tx in todayTransactions) {
              if (!tx.isDelete) {
                if (tx.transactionType == 'IN') {
                  todayInAmount += tx.amount;
                } else {
                  todayOutAmount += tx.amount;
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error calculating today transactions: $e');
    }

    // Create MerchantPartyData for current party type
    final partyData = MerchantPartyData(
      total: totalCount,
      netBalance: netBalance.abs(),
      netBalanceType: netBalanceType,
      overallGiven: overallGiven,
      overallReceived: overallReceived,
    );

    final emptyParty = MerchantPartyData(
      total: 0,
      netBalance: 0,
      netBalanceType: 'OUT',
      overallGiven: 0,
      overallReceived: 0,
    );

    // Create dashboard model
    dashboardData.value = MerchantDashboardModel(
      todayIn: todayInAmount,
      todayOut: todayOutAmount,
      overallGiven: overallGiven,
      overallReceived: overallReceived,
      netBalance: netBalance.abs(),
      netBalanceType: netBalanceType,
      party: MerchantPartyBreakdown(
        customer: partyType == 'CUSTOMER' ? partyData : emptyParty,
        supplier: partyType == 'SUPPLIER' ? partyData : emptyParty,
        employee: partyType == 'EMPLOYEE' ? partyData : emptyParty,
      ),
    );

    debugPrint('📦 Dashboard calculated from cached data:');
    debugPrint('   - Party Type: $partyType');
    debugPrint('   - Total Count: $totalCount');
    debugPrint('   - Overall Given (OUT): ₹$overallGiven');
    debugPrint('   - Overall Received (IN): ₹$overallReceived');
    debugPrint('   - Net Balance: ₹${netBalance.abs()} ($netBalanceType)');
    debugPrint('   - Today IN: ₹$todayInAmount');
    debugPrint('   - Today OUT: ₹$todayOutAmount');
  }

  /// Fetch statement data with pagination - OFFLINE FIRST
  Future<void> fetchStatement() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Reset pagination
      currentPage.value = 1;
      hasMoreData.value = true;

      debugPrint('📡 Fetching $partyType statement (OFFLINE-FIRST)...');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Is Online: $isOnline');

      // 🗄️ OFFLINE-FIRST: Try to load cached ledgers first
      try {
        final merchantId = await _getMerchantId();
        if (merchantId != null) {
          final cachedLedgers = await ledgerRepository.getLedgersByPartyType(merchantId, partyType);
          if (cachedLedgers.isNotEmpty) {
            debugPrint('📦 Loaded ${cachedLedgers.length} cached $partyType ledgers');

            // Convert LedgerModel to CustomerStatementItem
            final cachedCustomers = cachedLedgers.map((ledger) => CustomerStatementItem(
              id: ledger.id ?? 0,
              name: ledger.name,
              mobileNumber: ledger.mobileNumber,
              location: ledger.area ?? '',
              balance: ledger.currentBalance.abs(),
              balanceType: ledger.currentBalance >= 0 ? 'IN' : 'OUT',
              lastTransactionDate: ledger.updatedAt ?? DateTime.now(),
            )).toList();

            statementData.value = CustomerStatementModel(customers: cachedCustomers);
            debugPrint('📦 Using ${cachedCustomers.length} cached items');

            // 🗄️ Calculate dashboard stats immediately after loading cached data
            await _calculateDashboardFromCachedData();
            debugPrint('📦 Dashboard calculated from cached data immediately');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Could not load cached ledgers: $e');
      }

      // If online, fetch fresh data from API
      if (isOnline) {
        try {
          debugPrint('🔄 Online - Fetching fresh data from API...');
          final data = await _statementApi.getCustomerStatement(
            partyType: partyType,
            page: 1,
            limit: pageLimit,
          );

          statementData.value = data;

          // Check if we got less than limit (means no more data)
          if (data.customers.length < pageLimit) {
            hasMoreData.value = false;
          }

          debugPrint('✅ Statement loaded from API successfully');
          debugPrint('   - Total customers in list: ${data.customers.length}');
          debugPrint('   - Has more data: ${hasMoreData.value}');
        } catch (apiError) {
          debugPrint('⚠️ API fetch failed: $apiError');
          // If we have cached data, don't show error
          if (statementData.value == null || statementData.value!.customers.isEmpty) {
            rethrow;
          } else {
            debugPrint('📦 Using cached data as fallback');
          }
        }
      } else {
        debugPrint('📴 Offline - Using cached data');
        if (statementData.value == null || statementData.value!.customers.isEmpty) {
          errorMessage.value = 'No cached data available. Please connect to internet.';
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching statement: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
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

  /// Refresh statement data and dashboard data (resets pagination)
  Future<void> refreshStatement() async {
    // Reset pagination on refresh
    currentPage.value = 1;
    hasMoreData.value = true;
    await fetchAllData();
  }

  /// Get filtered customers based on search query AND filters
  List<CustomerStatementItem> get filteredCustomers {
    if (statementData.value == null) return [];

    var customers = statementData.value!.customers.toList();

    // Apply search query filter
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      customers = customers.where((customer) {
        return customer.name.toLowerCase().contains(query) ||
            customer.location.toLowerCase().contains(query) ||
            (customer.mobileNumber?.contains(query) ?? false);
      }).toList();
    }

    // Apply date filter
    customers = _applyDateFilter(customers);

    // Apply transaction filter (IN/OUT)
    customers = _applyTransactionFilter(customers);

    // Apply sorting
    customers = _applySorting(customers);

    return customers;
  }

  // ============================================================
  // FILTER METHODS
  // ============================================================

  /// Handle filters from AppBar (same pattern as SearchController)
  void handleFiltersApplied(Map<String, dynamic> filters) {
    debugPrint('🔍 CustomerStatement: Filters applied: $filters');

    // Handle Sort By
    final filterSortBy = filters['sortBy'] as String?;
    final filterSortOrder = filters['sortOrder'] as String?;

    if (filterSortBy != null) {
      sortBy.value = filterSortBy;
      debugPrint('📊 Sort by: $filterSortBy');
    }

    if (filterSortOrder != null) {
      sortOrder.value = filterSortOrder;
      debugPrint('📊 Sort order: $filterSortOrder');
    }

    // Handle Date Filter
    final filterDate = filters['dateFilter'] as String?;
    if (filterDate != null) {
      dateFilter.value = filterDate;
      debugPrint('📅 Date filter: $filterDate');
    }

    // Handle Custom Date Range
    if (filters['customDateFrom'] != null) {
      customDateFrom.value = filters['customDateFrom'] as DateTime;
      debugPrint('📅 Custom date from: ${customDateFrom.value}');
    }
    if (filters['customDateTo'] != null) {
      customDateTo.value = filters['customDateTo'] as DateTime;
      debugPrint('📅 Custom date to: ${customDateTo.value}');
    }

    // Handle Transaction Filter (IN/OUT)
    final filterTransaction = filters['transactionFilter'] as String?;
    if (filterTransaction != null) {
      transactionFilter.value = filterTransaction;
      debugPrint('💰 Transaction filter: $filterTransaction');
    }

    // Update active filters flag
    _updateActiveFiltersFlag();

    // Trigger UI refresh
    statementData.refresh();

    debugPrint('✅ Filters applied - Results: ${filteredCustomers.length}');
  }

  /// Update flag to indicate if filters are active
  void _updateActiveFiltersFlag() {
    // Default is now transaction_date desc (most recent first)
    final isSortActive = sortBy.value != 'transaction_date' || sortOrder.value != 'desc';

    hasActiveFilters.value = isSortActive ||
        dateFilter.value != 'all_time' ||
        transactionFilter.value != 'all_transaction' ||
        customDateFrom.value != null ||
        customDateTo.value != null;
  }

  /// Apply date filter to customers
  List<CustomerStatementItem> _applyDateFilter(List<CustomerStatementItem> customers) {
    if (dateFilter.value == 'all_time') return customers;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return customers.where((customer) {
      final itemDate = customer.lastTransactionDate;
      final itemDateOnly = DateTime(itemDate.year, itemDate.month, itemDate.day);

      switch (dateFilter.value) {
        case 'today':
          return itemDateOnly.isAtSameMomentAs(today);

        case 'yesterday':
          final yesterday = today.subtract(const Duration(days: 1));
          return itemDateOnly.isAtSameMomentAs(yesterday);

        case 'older_week':
          final weekAgo = today.subtract(const Duration(days: 7));
          return itemDateOnly.isBefore(weekAgo);

        case 'older_month':
          final monthAgo = DateTime(now.year, now.month - 1, now.day);
          return itemDateOnly.isBefore(monthAgo);

        case 'custom':
          if (customDateFrom.value != null && customDateTo.value != null) {
            return itemDateOnly.isAfter(customDateFrom.value!.subtract(const Duration(days: 1))) &&
                   itemDateOnly.isBefore(customDateTo.value!.add(const Duration(days: 1)));
          }
          return true;

        default:
          return true;
      }
    }).toList();
  }

  /// Apply transaction filter (IN/OUT)
  /// ✅ FIX: Swap filter logic - IN filter shows OUT balanceType and vice versa
  List<CustomerStatementItem> _applyTransactionFilter(List<CustomerStatementItem> customers) {
    switch (transactionFilter.value) {
      case 'in_transaction':
        // IN filter = Show customers with OUT balanceType (negative balance - you owe them)
        return customers.where((c) => c.balanceType == 'OUT').toList();
      case 'out_transaction':
        // OUT filter = Show customers with IN balanceType (positive balance - they owe you)
        return customers.where((c) => c.balanceType == 'IN').toList();
      case 'all_transaction':
      default:
        return customers;
    }
  }

  /// Apply sorting to customers
  /// Sort by selected criteria (default: transaction_date descending)
  List<CustomerStatementItem> _applySorting(List<CustomerStatementItem> customers) {
    final isAsc = sortOrder.value == 'asc';
    final sortedList = customers.toList();

    switch (sortBy.value) {
      case 'name':
        sortedList.sort((a, b) => isAsc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case 'amount':
        sortedList.sort((a, b) => isAsc
            ? a.balance.compareTo(b.balance)
            : b.balance.compareTo(a.balance));
        break;

      case 'transaction_date':
        sortedList.sort((a, b) => isAsc
            ? a.lastTransactionDate.compareTo(b.lastTransactionDate)
            : b.lastTransactionDate.compareTo(a.lastTransactionDate));
        break;

      default:
        // Default: sort by date descending (newest first)
        sortedList.sort((a, b) => b.lastTransactionDate.compareTo(a.lastTransactionDate));
    }

    debugPrint('📊 Sorting: ${sortBy.value} ${sortOrder.value}, Total: ${sortedList.length}');

    // Debug: Print sorted list with dates
    debugPrint('📋 ========== SORTED LIST ==========');
    for (int i = 0; i < sortedList.length; i++) {
      final customer = sortedList[i];
      final date = customer.lastTransactionDate;
      debugPrint('   ${i + 1}. ${customer.name} - Date: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}');
    }
    debugPrint('📋 ==================================');

    return sortedList;
  }

  /// Clear all filters (reset to defaults: sort by date descending)
  void clearFilters() {
    sortBy.value = 'transaction_date';
    sortOrder.value = 'desc';
    dateFilter.value = 'all_time';
    transactionFilter.value = 'all_transaction';
    reminderFilter.value = 'all';
    userFilter.value = 'all';
    customDateFrom.value = null;
    customDateTo.value = null;
    hasActiveFilters.value = false;

    // Trigger UI refresh
    statementData.refresh();
  }

  // Download button loading state
  final isDownloading = false.obs;

  /// Download statement - calls export API
  Future<void> downloadStatement() async {
    if (isDownloading.value) return; // Prevent double tap

    try {
      debugPrint('📥 Downloading $partyType statement...');

      isDownloading.value = true;

      // Call export API with partyType
      final response = await _statementApi.exportTransactions(
        partyType: partyType,
      );

      isDownloading.value = false;

      final message = response['message'] ?? 'Export initiated';
      final jobId = response['jobId'];
      final status = response['status'];

      debugPrint('✅ Export Response:');
      debugPrint('   - Message: $message');
      debugPrint('   - Job ID: $jobId');
      debugPrint('   - Status: $status');

      // Show success message
      AdvancedErrorService.showSuccess(
        message,
        type: SuccessType.snackbar,
        customDuration: const Duration(seconds: 3),
      );

    } catch (e) {
      isDownloading.value = false;
      debugPrint('❌ Error downloading statement: $e');

      // Show error message
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.download,
        customDuration: const Duration(seconds: 3),
      );
    }
  }

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
