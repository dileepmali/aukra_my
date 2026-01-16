import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/search_api.dart';
import '../models/ledger_model.dart';
import '../models/search_model.dart';

/// Controller for Search Screen
/// Uses SearchModel for configuration and results
class SearchController extends GetxController {
  final SearchApi _searchApi = SearchApi();

  // ============================================================
  // CONFIGURATION
  // ============================================================

  /// Search configuration (party type, enabled fields, etc.)
  /// Initialized with default CUSTOMER config, updated in onInit
  SearchConfig config = SearchConfig.customer();

  // ============================================================
  // OBSERVABLE STATE
  // ============================================================

  /// Loading state for initial data fetch
  final isInitialLoading = true.obs;

  /// Loading state for search operation
  final isSearching = false.obs;

  /// Error message
  final errorMessage = ''.obs;

  /// Current search query
  final searchQuery = ''.obs;

  /// All ledgers for the party type
  final allLedgers = <LedgerModel>[].obs;

  /// Filtered search results
  final searchResults = <SearchResultItem>[].obs;

  /// Search summary (counts and totals)
  final summary = SearchSummary.empty().obs;

  /// Current sort option
  final sortBy = SearchSortBy.name.obs;

  /// Current sort order
  final sortOrder = SearchSortOrder.ascending.obs;

  // ============================================================
  // FILTER STATE
  // ============================================================

  /// Date filter: today, yesterday, older_week, older_month, all_time, custom
  final dateFilter = 'all_time'.obs;

  /// Transaction filter: all_transaction, in_transaction, out_transaction
  final transactionFilter = 'all_transaction'.obs;

  /// Reminder filter: all, overdue, today, upcoming
  final reminderFilter = 'all'.obs;

  /// User filter: all, customer, supplier, employee
  final userFilter = 'all'.obs;

  /// Custom date range (for older_week, older_month, custom)
  final customDateFrom = Rxn<DateTime>();
  final customDateTo = Rxn<DateTime>();

  /// Flag to indicate if filters are active
  final hasActiveFilters = false.obs;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();

    // Get configuration from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final partyType = args?['partyType'] ?? 'CUSTOMER';

    // Create config based on party type
    config = SearchConfig.fromPartyType(partyType);

    debugPrint('🔍 SearchController initialized');
    debugPrint('   Party Type: ${config.partyType}');
    debugPrint('   Label: ${config.partyTypeLabel}');
    debugPrint('   Enabled Fields: ${config.enabledFields.map((f) => f.label).join(", ")}');

    // Fetch data
    fetchData();
  }

  // ============================================================
  // DATA FETCHING
  // ============================================================

  /// Fetch ledger data for the configured party type
  Future<void> fetchData() async {
    try {
      isInitialLoading.value = true;
      errorMessage.value = '';

      debugPrint('📡 Fetching ${config.partyTypeLabel} data...');

      final result = await _searchApi.getLedgersByPartyType(config.partyType);
      allLedgers.value = result;

      // Calculate summary
      _calculateSummary();

      debugPrint('✅ Loaded ${allLedgers.length} ${config.partyTypeLabel}s');
    } catch (e) {
      debugPrint('❌ Error fetching data: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isInitialLoading.value = false;
    }
  }

  /// Calculate search summary from all ledgers
  void _calculateSummary() {
    int inCount = 0;
    int outCount = 0;
    double totalIn = 0;
    double totalOut = 0;

    for (var ledger in allLedgers) {
      if (ledger.currentBalance >= 0) {
        inCount++;
        totalIn += ledger.currentBalance;
      } else {
        outCount++;
        totalOut += ledger.currentBalance.abs();
      }
    }

    summary.value = SearchSummary(
      totalCount: allLedgers.length,
      inCount: inCount,
      outCount: outCount,
      totalInAmount: totalIn,
      totalOutAmount: totalOut,
    );
  }

  // ============================================================
  // SEARCH LOGIC
  // ============================================================

  /// Perform search with the given query
  /// Searches across all enabled fields
  void performSearch(String query) {
    searchQuery.value = query.trim();

    if (searchQuery.value.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    final results = <SearchResultItem>[];
    final queryLower = searchQuery.value.toLowerCase();

    // Debug: Print data availability
    debugPrint('🔍 Searching for: "$queryLower"');
    debugPrint('📋 Total ledgers: ${allLedgers.length}');

    // Check mobile numbers
    final nonEmptyMobiles = allLedgers.where((l) => l.mobileNumber.isNotEmpty).toList();
    debugPrint('📱 Ledgers with mobile: ${nonEmptyMobiles.length}');
    if (nonEmptyMobiles.isNotEmpty) {
      debugPrint('📱 Sample mobiles: ${nonEmptyMobiles.take(3).map((l) => '"${l.mobileNumber}"').join(", ")}');
    }

    // Check areas
    final nonEmptyAreas = allLedgers.where((l) => l.area.isNotEmpty).toList();
    debugPrint('📍 Ledgers with area: ${nonEmptyAreas.length}');
    if (nonEmptyAreas.isNotEmpty) {
      debugPrint('📍 Sample areas: ${nonEmptyAreas.take(3).map((l) => '"${l.area}"').join(", ")}');
    }

    // Check addresses
    final nonEmptyAddresses = allLedgers.where((l) => l.address.isNotEmpty).toList();
    debugPrint('🏠 Ledgers with address: ${nonEmptyAddresses.length}');

    // Check if query is numeric (for balance amount search)
    final numericQuery = double.tryParse(queryLower.replaceAll(',', ''));
    final isNumeric = numericQuery != null;

    // Check if query is IN/OUT (for balance type search)
    final isBalanceTypeQuery = queryLower == 'in' || queryLower == 'out';

    for (var ledger in allLedgers) {
      SearchableField? matchedField;

      // Search by Name
      if (config.enabledFields.contains(SearchableField.name)) {
        if (ledger.name.toLowerCase().contains(queryLower)) {
          matchedField = SearchableField.name;
        }
      }

      // Search by Mobile Number
      if (matchedField == null &&
          config.enabledFields.contains(SearchableField.mobileNumber)) {
        if (ledger.mobileNumber.isNotEmpty && ledger.mobileNumber.toLowerCase().contains(queryLower)) {
          debugPrint('✅ Mobile match: "${ledger.name}" - mobile: "${ledger.mobileNumber}"');
          matchedField = SearchableField.mobileNumber;
        }
      }

      // Search by Address
      if (matchedField == null &&
          config.enabledFields.contains(SearchableField.address)) {
        if (ledger.address.toLowerCase().contains(queryLower)) {
          matchedField = SearchableField.address;
        }
      }

      // Search by Area
      if (matchedField == null &&
          config.enabledFields.contains(SearchableField.area)) {
        if (ledger.area.isNotEmpty && ledger.area.toLowerCase().contains(queryLower)) {
          debugPrint('✅ Area match: "${ledger.name}" - area: "${ledger.area}"');
          matchedField = SearchableField.area;
        }
      }

      // Search by Pincode
      if (matchedField == null &&
          config.enabledFields.contains(SearchableField.pinCode)) {
        if (ledger.pinCode.toLowerCase().contains(queryLower)) {
          matchedField = SearchableField.pinCode;
        }
      }

      // Search by Balance Amount (numeric query)
      if (matchedField == null &&
          isNumeric &&
          config.enabledFields.contains(SearchableField.balanceAmount)) {
        final balance = ledger.currentBalance.abs();
        // Match if balance contains the query or equals it
        if (balance.toStringAsFixed(0).contains(numericQuery.toStringAsFixed(0)) ||
            balance == numericQuery) {
          matchedField = SearchableField.balanceAmount;
        }
      }

      // Search by Balance Type (IN/OUT)
      if (matchedField == null &&
          isBalanceTypeQuery &&
          config.enabledFields.contains(SearchableField.balanceType)) {
        final balanceType = ledger.currentBalance >= 0 ? 'in' : 'out';
        if (queryLower == balanceType) {
          matchedField = SearchableField.balanceType;
        }
      }

      // Add to results if matched
      if (matchedField != null) {
        results.add(SearchResultItem.fromLedger(
          ledger,
          matchedField: matchedField,
        ));
      }
    }

    // Apply filters
    var filteredResults = _applyFilters(results);
    debugPrint('🔍 After filters: ${filteredResults.length} results (from ${results.length})');

    // Sort results
    _sortResults(filteredResults);

    searchResults.value = filteredResults;
    isSearching.value = false;

    debugPrint('🔍 Found ${filteredResults.length} results for "$query"');
  }

  /// Sort search results based on current sort options
  void _sortResults(List<SearchResultItem> results) {
    final isAsc = sortOrder.value == SearchSortOrder.ascending;

    switch (sortBy.value) {
      case SearchSortBy.name:
        results.sort((a, b) => isAsc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case SearchSortBy.balance:
        results.sort((a, b) => isAsc
            ? a.balance.compareTo(b.balance)
            : b.balance.compareTo(a.balance));
        break;

      case SearchSortBy.recent:
        // Sort by ID (newer entries have higher IDs)
        results.sort((a, b) => isAsc
            ? a.id.compareTo(b.id)
            : b.id.compareTo(a.id));
        break;
    }
  }

  // ============================================================
  // SORT & FILTER
  // ============================================================

  /// Set sort option
  void setSortBy(SearchSortBy newSortBy) {
    sortBy.value = newSortBy;
    if (searchResults.isNotEmpty) {
      _sortResults(searchResults);
      searchResults.refresh();
    }
  }

  /// Set sort order
  void setSortOrder(SearchSortOrder newOrder) {
    sortOrder.value = newOrder;
    if (searchResults.isNotEmpty) {
      _sortResults(searchResults);
      searchResults.refresh();
    }
  }

  /// Toggle sort order
  void toggleSortOrder() {
    sortOrder.value = sortOrder.value == SearchSortOrder.ascending
        ? SearchSortOrder.descending
        : SearchSortOrder.ascending;
    if (searchResults.isNotEmpty) {
      _sortResults(searchResults);
      searchResults.refresh();
    }
  }

  /// Handle filters from AppBar
  void handleFiltersApplied(Map<String, dynamic> filters) {
    debugPrint('🔍 Filters applied: $filters');

    // Handle Sort By
    final filterSortBy = filters['sortBy'] as String?;
    final filterSortOrder = filters['sortOrder'] as String?;

    if (filterSortBy != null) {
      switch (filterSortBy.toLowerCase()) {
        case 'name':
          sortBy.value = SearchSortBy.name;
          break;
        case 'balance':
        case 'amount':
          sortBy.value = SearchSortBy.balance;
          break;
        case 'recent':
        case 'date':
        case 'transaction_date':
          sortBy.value = SearchSortBy.recent;
          break;
        case 'default':
          sortBy.value = SearchSortBy.name;
          break;
      }
    }

    if (filterSortOrder != null) {
      sortOrder.value = filterSortOrder.toLowerCase() == 'desc' ||
              filterSortOrder.toLowerCase() == 'descending'
          ? SearchSortOrder.descending
          : SearchSortOrder.ascending;
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

    // Handle Reminder Filter
    final filterReminder = filters['reminderFilter'] as String?;
    if (filterReminder != null) {
      reminderFilter.value = filterReminder;
      debugPrint('⏰ Reminder filter: $filterReminder');
    }

    // Handle User Filter (partyType)
    final filterUser = filters['userFilter'] as String?;
    if (filterUser != null) {
      userFilter.value = filterUser;
      debugPrint('👤 User filter: $filterUser');
    }

    // Check if any filter is active (including sort)
    _updateActiveFiltersFlag();

    // Re-apply search with filters OR show all filtered/sorted results
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    } else {
      // Always show all ledgers with filters/sort applied when user clicks Apply
      // This ensures sort-only filters also work
      showAllWithFilters();
    }
  }

  /// Show all ledgers with filters applied (without search query)
  void showAllWithFilters() {
    debugPrint('🔍 Showing all ledgers with filters (no search query)');

    // Convert all ledgers to SearchResultItem
    final allResults = allLedgers.map((ledger) {
      return SearchResultItem.fromLedger(ledger);
    }).toList();

    debugPrint('📋 Total ledgers: ${allResults.length}');

    // Apply filters
    var filteredResults = _applyFilters(allResults);
    debugPrint('🔍 After filters: ${filteredResults.length} results');

    // Sort results
    _sortResults(filteredResults);

    searchResults.value = filteredResults;
  }

  /// Update flag to indicate if filters are active (including sort)
  void _updateActiveFiltersFlag() {
    // Check if sort is non-default (default is name + ascending)
    final isSortActive = sortBy.value != SearchSortBy.name ||
        sortOrder.value != SearchSortOrder.ascending;

    hasActiveFilters.value = isSortActive ||
        dateFilter.value != 'all_time' ||
        transactionFilter.value != 'all_transaction' ||
        reminderFilter.value != 'all' ||
        userFilter.value != 'all' ||
        customDateFrom.value != null ||
        customDateTo.value != null;
  }

  /// Apply all filters to a list of results
  List<SearchResultItem> _applyFilters(List<SearchResultItem> results) {
    var filtered = results.toList();

    // Apply Date Filter
    filtered = _applyDateFilter(filtered);

    // Apply Transaction Filter (IN/OUT)
    filtered = _applyTransactionFilter(filtered);

    // Apply User Filter (partyType) - Note: Already filtered by partyType in fetch
    // This is for additional filtering if user selects different type
    filtered = _applyUserFilter(filtered);

    return filtered;
  }

  /// Apply date filter
  List<SearchResultItem> _applyDateFilter(List<SearchResultItem> results) {
    if (dateFilter.value == 'all_time') return results;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return results.where((item) {
      final itemDate = item.updatedAt ?? item.createdAt;
      if (itemDate == null) return true; // Include items without date

      final itemDateOnly = DateTime(itemDate.year, itemDate.month, itemDate.day);

      switch (dateFilter.value) {
        case 'today':
          return itemDateOnly.isAtSameMomentAs(today);

        case 'yesterday':
          final yesterday = today.subtract(const Duration(days: 1));
          return itemDateOnly.isAtSameMomentAs(yesterday);

        case 'older_week':
          // Older than a week (no custom date picker)
          final weekAgo = today.subtract(const Duration(days: 7));
          return itemDateOnly.isBefore(weekAgo);

        case 'older_month':
          // Older than a month (no custom date picker)
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
  List<SearchResultItem> _applyTransactionFilter(List<SearchResultItem> results) {
    switch (transactionFilter.value) {
      case 'in_transaction':
        return results.where((item) => item.balanceType == 'IN').toList();
      case 'out_transaction':
      case 'old_transaction':
        return results.where((item) => item.balanceType == 'OUT').toList();
      case 'all_transaction':
      default:
        return results;
    }
  }

  /// Apply user filter (partyType)
  List<SearchResultItem> _applyUserFilter(List<SearchResultItem> results) {
    switch (userFilter.value.toLowerCase()) {
      case 'customer':
        return results.where((item) => item.partyType.toUpperCase() == 'CUSTOMER').toList();
      case 'supplier':
        return results.where((item) => item.partyType.toUpperCase() == 'SUPPLIER').toList();
      case 'employee':
        return results.where((item) => item.partyType.toUpperCase() == 'EMPLOYEE').toList();
      case 'all':
      default:
        return results;
    }
  }

  /// Clear all filters
  void clearFilters() {
    dateFilter.value = 'all_time';
    transactionFilter.value = 'all_transaction';
    reminderFilter.value = 'all';
    userFilter.value = 'all';
    customDateFrom.value = null;
    customDateTo.value = null;
    hasActiveFilters.value = false;

    // Re-apply search without filters OR clear results
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    } else {
      searchResults.clear();
    }
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
  }

  /// Refresh data
  Future<void> refresh() async {
    await fetchData();
    if (searchQuery.value.isNotEmpty) {
      performSearch(searchQuery.value);
    }
  }

  // ============================================================
  // GETTERS
  // ============================================================

  /// Get screen title
  String get screenTitle => 'Search ${config.partyTypeLabel}s';

  /// Get search hint
  String get searchHint => config.searchHint;

  /// Check if has results
  bool get hasResults => searchResults.isNotEmpty;

  /// Check if is searching (query entered but no results)
  bool get isEmptySearch =>
      searchQuery.value.isNotEmpty && searchResults.isEmpty;

  /// Get result count text
  String get resultCountText {
    if (searchResults.isEmpty) return '';
    final count = searchResults.length;
    if (searchQuery.value.isEmpty && hasActiveFilters.value) {
      return '$count ${count == 1 ? 'result' : 'results'} (filtered)';
    }
    return '$count ${count == 1 ? 'result' : 'results'} found';
  }
}
