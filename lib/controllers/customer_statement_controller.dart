import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/customer_statement_api.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/customer_statement_model.dart';

/// Controller for Customer Statement Screen
class CustomerStatementController extends GetxController {
  final CustomerStatementApi _statementApi = CustomerStatementApi();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final statementData = Rxn<CustomerStatementModel>();
  final searchQuery = ''.obs;

  // Party type: 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  String partyType = 'CUSTOMER';
  String partyTypeLabel = 'Customer';

  // ============================================================
  // FILTER STATE (same as SearchController)
  // ============================================================

  /// Sort by: name, amount, transaction_date
  final sortBy = 'name'.obs;

  /// Sort order: asc, desc
  final sortOrder = 'asc'.obs;

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

    // Fetch statement data
    fetchStatement();
  }

  /// Fetch statement data
  Future<void> fetchStatement() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('📡 Fetching $partyType statement...');

      final data = await _statementApi.getCustomerStatement(
        partyType: partyType,
      );

      statementData.value = data;

      debugPrint('✅ Statement loaded successfully');
      debugPrint('   - Net Balance: ₹${data.netBalance}');
      debugPrint('   - Total ${partyTypeLabel}s: ${data.totalCustomers}');
      debugPrint('   - Yesterday IN: ₹${data.yesterdayTotalIn}');
      debugPrint('   - Yesterday OUT: ₹${data.yesterdayTotalOut}');
    } catch (e) {
      debugPrint('❌ Error fetching statement: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh statement data
  Future<void> refreshStatement() async {
    await fetchStatement();
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
    final isSortActive = sortBy.value != 'name' || sortOrder.value != 'asc';

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
  /// ✅ FIX: Use balanceType for filtering
  List<CustomerStatementItem> _applyTransactionFilter(List<CustomerStatementItem> customers) {
    switch (transactionFilter.value) {
      case 'in_transaction':
        // IN = Positive (Receivable) - Customer owes you
        return customers.where((c) => c.balanceType == 'IN').toList();
      case 'out_transaction':
        // OUT = Negative (Payable) - You owe customer
        return customers.where((c) => c.balanceType == 'OUT').toList();
      case 'all_transaction':
      default:
        return customers;
    }
  }

  /// Apply sorting to customers
  /// ✅ Today's data always shows at TOP, then sorted by selected criteria
  List<CustomerStatementItem> _applySorting(List<CustomerStatementItem> customers) {
    final isAsc = sortOrder.value == 'asc';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ✅ Step 1: Separate today's customers from others
    final todayCustomers = <CustomerStatementItem>[];
    final otherCustomers = <CustomerStatementItem>[];

    for (final customer in customers) {
      final itemDate = customer.lastTransactionDate;
      final itemDateOnly = DateTime(itemDate.year, itemDate.month, itemDate.day);

      if (itemDateOnly.isAtSameMomentAs(today)) {
        todayCustomers.add(customer);
      } else {
        otherCustomers.add(customer);
      }
    }

    // ✅ Step 2: Sort each group by selected criteria
    void sortList(List<CustomerStatementItem> list) {
      switch (sortBy.value) {
        case 'name':
          list.sort((a, b) => isAsc
              ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
              : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;

        case 'amount':
          list.sort((a, b) => isAsc
              ? a.balance.compareTo(b.balance)
              : b.balance.compareTo(a.balance));
          break;

        case 'transaction_date':
          list.sort((a, b) => isAsc
              ? a.lastTransactionDate.compareTo(b.lastTransactionDate)
              : b.lastTransactionDate.compareTo(a.lastTransactionDate));
          break;

        default:
          // Default: sort by name ascending
          list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      }
    }

    // Sort both groups
    sortList(todayCustomers);
    sortList(otherCustomers);

    // ✅ Step 3: Today's customers FIRST, then others
    debugPrint('📊 Sorting: Today\'s customers: ${todayCustomers.length}, Others: ${otherCustomers.length}');

    return [...todayCustomers, ...otherCustomers];
  }

  /// Clear all filters
  void clearFilters() {
    sortBy.value = 'name';
    sortOrder.value = 'asc';
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
