import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/global_api_function.dart';
import '../models/ledger_model.dart';

class LedgerController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString merchantName = ''.obs;
  final RxString businessName = ''.obs;

  // Lists for different party types
  final RxList<LedgerModel> customers = <LedgerModel>[].obs;
  final RxList<LedgerModel> suppliers = <LedgerModel>[].obs;
  final RxList<LedgerModel> employers = <LedgerModel>[].obs;
  final RxList<LedgerModel> allLedgers = <LedgerModel>[].obs;

  final ApiFetcher _apiFetcher = ApiFetcher();

  // ============================================================
  // FILTER STATE (same as SearchController/CustomerStatementController)
  // ============================================================

  /// Sort by: name, amount, transaction_date
  /// Default: transaction_date (so recently updated items appear first)
  final sortBy = 'transaction_date'.obs;

  /// Sort order: asc, desc
  /// Default: desc (newest first, so recently updated items appear at top)
  final sortOrder = 'desc'.obs;

  /// Date filter: today, yesterday, older_week, older_month, all_time, custom
  final dateFilter = 'all_time'.obs;

  /// Transaction filter: all_transaction, in_transaction, out_transaction
  final transactionFilter = 'all_transaction'.obs;

  /// Custom date range
  final customDateFrom = Rxn<DateTime>();
  final customDateTo = Rxn<DateTime>();

  /// Flag to indicate if filters are active
  final hasActiveFilters = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMerchantDetails();
    fetchAllLedgers();
  }

  /// Fetch merchant details - Always fetch fresh from API (same as my_profile_screen)
  Future<void> fetchMerchantDetails() async {
    try {
      debugPrint('📡 Fetching merchant details from API...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      debugPrint('🏢 Merchant ID from storage: $merchantId');

      // ✅ Always call API to get fresh merchant data (same as my_profile_screen.dart)
      await _apiFetcher.request(
        url: 'api/merchant/all',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ Merchant API request timeout');
          merchantName.value = 'Aukra'; // Default name on timeout
          return;
        },
      );

      debugPrint('📥 Merchant API Response from /api/merchant/all');
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ Merchant API Error: ${_apiFetcher.errorMessage}');
      }

      // Check if we got valid merchant data from API
      if (_apiFetcher.data != null) {
        debugPrint('✅ Merchant details fetched from /api/merchant/all successfully');

        if (_apiFetcher.data is List && (_apiFetcher.data as List).isNotEmpty) {
          final merchantList = _apiFetcher.data as List;
          Map<String, dynamic>? currentMerchant;

          debugPrint('🔍 Looking for main account in ${merchantList.length} merchants');

          // ✅ SAME LOGIC AS my_profile_screen.dart: Find main account first
          for (var merchant in merchantList) {
            if (merchant is Map && merchant['isMainAccount'] == true) {
              currentMerchant = merchant as Map<String, dynamic>;
              debugPrint('✅ Found main account: ${currentMerchant['businessName']}');
              break;
            }
          }

          // If no main account found, use first merchant (same as my_profile_screen.dart)
          if (currentMerchant == null && merchantList.isNotEmpty) {
            currentMerchant = merchantList[0] as Map<String, dynamic>;
            debugPrint('✅ Using first merchant: ${currentMerchant['businessName']}');
          }

          if (currentMerchant != null) {
            // ✅ Use businessName (same as my_profile_screen.dart)
            final business = currentMerchant['businessName']?.toString() ?? '';
            merchantName.value = business.isNotEmpty ? business : 'Aukra';
            businessName.value = business;

            debugPrint('🏢 Merchant Name (from API): ${merchantName.value}');
            debugPrint('🏪 Business Name (from API): ${businessName.value}');

            // Save to storage for consistency
            await AuthStorage.saveMerchantName(merchantName.value);
            if (businessName.value.isNotEmpty) {
              await AuthStorage.saveBusinessName(businessName.value);
            }
            debugPrint('💾 Merchant data saved to storage');
          } else {
            merchantName.value = 'Aukra';
          }
        } else if (_apiFetcher.data is Map) {
          final data = _apiFetcher.data as Map<String, dynamic>;

          // Use businessName (same as my_profile_screen.dart)
          final business = data['businessName']?.toString() ?? '';
          merchantName.value = business.isNotEmpty ? business : 'Aukra';
          businessName.value = business;

          debugPrint('🏢 Merchant Name (from API): ${merchantName.value}');
          debugPrint('🏪 Business Name (from API): ${businessName.value}');

          // Save to storage
          await AuthStorage.saveMerchantName(merchantName.value);
          if (businessName.value.isNotEmpty) {
            await AuthStorage.saveBusinessName(businessName.value);
          }
          debugPrint('💾 Merchant data saved to storage');
        }
      } else {
        debugPrint('❌ Failed to fetch merchant details from API: ${_apiFetcher.errorMessage}');
        merchantName.value = 'Aukra'; // Default name on error
      }
    } catch (e) {
      debugPrint('❌ Error fetching merchant details: $e');
      merchantName.value = 'Aukra'; // Default name on exception
    }
  }

  /// Fetch all ledgers (customers, suppliers, employers) from GET api/ledger
  Future<void> fetchAllLedgers() async {
    // Prevent multiple simultaneous fetches
    if (isLoading.value) {
      debugPrint('⚠️ Already fetching ledgers, skipping duplicate request');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('📡 Fetching all ledgers from API...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      debugPrint('🏢 Merchant ID from storage: $merchantId');

      if (merchantId == null) {
        debugPrint('❌ No merchant ID found in storage');
        isLoading.value = false;
        return;
      }

      // Clear existing lists to prevent duplicates
      allLedgers.clear();
      customers.clear();
      suppliers.clear();
      employers.clear();

      // Fetch sequentially with delays to avoid rate limiting (429 errors)
      await _fetchLedgersByType(merchantId, 'CUSTOMER');
      await Future.delayed(const Duration(milliseconds: 300)); // Small delay

      await _fetchLedgersByType(merchantId, 'SUPPLIER');
      await Future.delayed(const Duration(milliseconds: 300)); // Small delay

      await _fetchLedgersByType(merchantId, 'EMPLOYEE');

      debugPrint('📊 Total ledgers: ${allLedgers.length}');
      debugPrint('👥 Customers: ${customers.length}');
      debugPrint('🏭 Suppliers: ${suppliers.length}');
      debugPrint('👔 Employers: ${employers.length}');
    } catch (e) {
      debugPrint('❌ Error fetching ledgers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch ledgers by party type
  Future<void> _fetchLedgersByType(int merchantId, String partyType) async {
    try {
      final fetcher = ApiFetcher();

      debugPrint('📡 Fetching $partyType ledgers...');

      // Call GET API with merchantId and partyType
      await fetcher.request(
        url: 'api/ledger/$merchantId?partyType=$partyType',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ $partyType API request timeout');
          return;
        },
      );

      if (fetcher.errorMessage != null) {
        debugPrint('❌ $partyType API Error: ${fetcher.errorMessage}');
        return;
      }

      if (fetcher.data != null) {
        debugPrint('✅ $partyType fetched successfully');
        debugPrint('📥 $partyType Response Type: ${fetcher.data.runtimeType}');
        debugPrint('📥 $partyType Full Response: ${fetcher.data}');
        debugPrint('═══════════════════════════════════════════════════');

        List<dynamic> ledgerList = [];

        // Parse response - handle both formats
        if (fetcher.data is Map && fetcher.data['data'] is List) {
          // Nested format: {count: 3, data: [...]}
          ledgerList = fetcher.data['data'] as List;
          debugPrint('📊 Nested format - Count: ${fetcher.data['count']}, Items: ${ledgerList.length}');

          // Print first item to see structure
          if (ledgerList.isNotEmpty) {
            debugPrint('🔍 First Item Sample: ${ledgerList[0]}');
          }
        } else if (fetcher.data is List) {
          // Direct array format: [...]
          ledgerList = fetcher.data as List;
          debugPrint('📊 Direct array format - Items: ${ledgerList.length}');

          // Print first item to see structure
          if (ledgerList.isNotEmpty) {
            debugPrint('🔍 First Item Sample: ${ledgerList[0]}');
          }
        } else {
          debugPrint('⚠️ Unexpected response format for $partyType');
          return;
        }

        // Process ledger items
        for (var ledgerJson in ledgerList) {
          if (ledgerJson is Map<String, dynamic>) {
            try {
              // Debug: Print raw JSON to see what fields are coming
              debugPrint('📦 Raw Ledger JSON: $ledgerJson');

              final ledger = LedgerModel.fromJson(ledgerJson);
              allLedgers.add(ledger);

              debugPrint('✅ Parsed ledger: ${ledger.name} (${ledger.partyType})');
              debugPrint('   📍 Address: "${ledger.address}", Area: "${ledger.area}"');

              // Sort by party type - Use actual ledger.partyType from API response
              switch (ledger.partyType.toUpperCase()) {
                case 'CUSTOMER':
                  customers.add(ledger);
                  break;
                case 'SUPPLIER':
                  suppliers.add(ledger);
                  break;
                case 'EMPLOYEE': // Changed from EMPLOYER to EMPLOYEE
                  employers.add(ledger);
                  break;
              }
            } catch (e) {
              debugPrint('❌ Error parsing ledger item: $e');
              debugPrint('❌ Failed item data: $ledgerJson');
            }
          }
        }

        debugPrint('📊 $partyType parsed - Total items: ${ledgerList.length}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching $partyType: $e');
    }
  }

  /// Refresh all data (with delays to avoid rate limiting)
  Future<void> refreshAll() async {
    await fetchMerchantDetails();
    await Future.delayed(const Duration(milliseconds: 300)); // Small delay
    await fetchAllLedgers();
  }

  /// Get ledgers by party type
  List<LedgerModel> getLedgersByType(String partyType) {
    switch (partyType.toUpperCase()) {
      case 'CUSTOMER':
        return customers;
      case 'SUPPLIER':
        return suppliers;
      case 'EMPLOYEE': // Changed from EMPLOYER to EMPLOYEE
      case 'EMPLOYER': // Keep backward compatibility
        return employers;
      default:
        return [];
    }
  }

  // ============================================================
  // FILTER METHODS (same pattern as SearchController/CustomerStatementController)
  // ============================================================

  /// Handle filters from AppBar
  void handleFiltersApplied(Map<String, dynamic> filters) {
    debugPrint('🔍 LedgerController: Filters applied: $filters');

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
    customers.refresh();
    suppliers.refresh();
    employers.refresh();

    debugPrint('✅ Filters applied - Customers: ${filteredCustomers.length}, Suppliers: ${filteredSuppliers.length}, Employees: ${filteredEmployers.length}');
  }

  /// Update flag to indicate if filters are active
  void _updateActiveFiltersFlag() {
    // Default is now transaction_date desc (recently updated first)
    final isSortActive = sortBy.value != 'transaction_date' || sortOrder.value != 'desc';

    hasActiveFilters.value = isSortActive ||
        dateFilter.value != 'all_time' ||
        transactionFilter.value != 'all_transaction' ||
        customDateFrom.value != null ||
        customDateTo.value != null;
  }

  /// Apply date filter to ledgers
  List<LedgerModel> _applyDateFilter(List<LedgerModel> ledgers) {
    if (dateFilter.value == 'all_time') return ledgers;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return ledgers.where((ledger) {
      final itemDate = ledger.updatedAt ?? ledger.createdAt;
      if (itemDate == null) return true; // Include items without date

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

  /// Apply transaction filter (IN/OUT based on transactionType)
  /// ✅ FIX: Use transactionType instead of currentBalance
  List<LedgerModel> _applyTransactionFilter(List<LedgerModel> ledgers) {
    switch (transactionFilter.value) {
      case 'in_transaction':
        // IN = Positive (Receivable) - Customer owes you
        return ledgers.where((l) => l.transactionType == 'IN').toList();
      case 'out_transaction':
        // OUT = Negative (Payable) - You owe customer
        return ledgers.where((l) => l.transactionType == 'OUT').toList();
      case 'all_transaction':
      default:
        return ledgers;
    }
  }

  /// Apply sorting to ledgers
  List<LedgerModel> _applySorting(List<LedgerModel> ledgers) {
    final isAsc = sortOrder.value == 'asc';

    switch (sortBy.value) {
      case 'name':
        ledgers.sort((a, b) => isAsc
            ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
            : b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;

      case 'amount':
        ledgers.sort((a, b) => isAsc
            ? a.currentBalance.compareTo(b.currentBalance)
            : b.currentBalance.compareTo(a.currentBalance));
        break;

      case 'transaction_date':
        ledgers.sort((a, b) {
          final dateA = a.updatedAt ?? a.createdAt ?? DateTime(1970);
          final dateB = b.updatedAt ?? b.createdAt ?? DateTime(1970);
          return isAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;

      default:
        // Default: sort by name ascending
        ledgers.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return ledgers;
  }

  /// Clear all filters (reset to defaults: sort by date descending)
  void clearFilters() {
    sortBy.value = 'transaction_date';
    sortOrder.value = 'desc';
    dateFilter.value = 'all_time';
    transactionFilter.value = 'all_transaction';
    customDateFrom.value = null;
    customDateTo.value = null;
    hasActiveFilters.value = false;

    // Trigger UI refresh
    customers.refresh();
    suppliers.refresh();
    employers.refresh();
  }

  // ============================================================
  // FILTERED GETTERS
  // ============================================================

  /// Get filtered customers based on active filters
  List<LedgerModel> get filteredCustomers {
    var result = customers.toList();
    result = _applyDateFilter(result);
    result = _applyTransactionFilter(result);
    result = _applySorting(result);
    return result;
  }

  /// Get filtered suppliers based on active filters
  List<LedgerModel> get filteredSuppliers {
    var result = suppliers.toList();
    result = _applyDateFilter(result);
    result = _applyTransactionFilter(result);
    result = _applySorting(result);
    return result;
  }

  /// Get filtered employers based on active filters
  List<LedgerModel> get filteredEmployers {
    var result = employers.toList();
    result = _applyDateFilter(result);
    result = _applyTransactionFilter(result);
    result = _applySorting(result);
    return result;
  }

  // ============================================================
  // LOCAL ACTIVITY UPDATE (for transaction edit fix)
  // ============================================================

  /// Update a specific ledger's last activity date locally
  /// Call this after transaction create/edit/delete to update the date in UI
  void updateLedgerLastActivity(int ledgerId, {DateTime? activityTime}) {
    final time = activityTime ?? DateTime.now();
    debugPrint('🔄 Updating ledger $ledgerId last activity to: $time');

    // Update in customers list
    final customerIndex = customers.indexWhere((l) => l.id == ledgerId);
    if (customerIndex != -1) {
      final updatedLedger = customers[customerIndex].copyWith(updatedAt: time);
      customers[customerIndex] = updatedLedger;
      customers.refresh();
      debugPrint('✅ Updated customer ledger $ledgerId updatedAt');
      return;
    }

    // Update in suppliers list
    final supplierIndex = suppliers.indexWhere((l) => l.id == ledgerId);
    if (supplierIndex != -1) {
      final updatedLedger = suppliers[supplierIndex].copyWith(updatedAt: time);
      suppliers[supplierIndex] = updatedLedger;
      suppliers.refresh();
      debugPrint('✅ Updated supplier ledger $ledgerId updatedAt');
      return;
    }

    // Update in employers list
    final employerIndex = employers.indexWhere((l) => l.id == ledgerId);
    if (employerIndex != -1) {
      final updatedLedger = employers[employerIndex].copyWith(updatedAt: time);
      employers[employerIndex] = updatedLedger;
      employers.refresh();
      debugPrint('✅ Updated employer ledger $ledgerId updatedAt');
      return;
    }

    debugPrint('⚠️ Ledger $ledgerId not found in any list');
  }
}
