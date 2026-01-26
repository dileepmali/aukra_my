import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/global_api_function.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../core/services/connectivity_service.dart';
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

  // 🗄️ Offline-first repository
  LedgerRepository? _ledgerRepository;
  LedgerRepository get ledgerRepository {
    if (_ledgerRepository == null) {
      // Check if repository is registered
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

  // ============================================================
  // PAGINATION STATE
  // ============================================================
  final int _limit = 10;

  // Customer pagination
  final ScrollController customersScrollController = ScrollController();
  var customersCurrentSkip = 0.obs;
  var customersTotalCount = 0.obs;
  var customersHasMoreData = true.obs;
  var customersIsLoadingMore = false.obs;

  // Supplier pagination
  final ScrollController suppliersScrollController = ScrollController();
  var suppliersCurrentSkip = 0.obs;
  var suppliersTotalCount = 0.obs;
  var suppliersHasMoreData = true.obs;
  var suppliersIsLoadingMore = false.obs;

  // Employee pagination
  final ScrollController employeesScrollController = ScrollController();
  var employeesCurrentSkip = 0.obs;
  var employeesTotalCount = 0.obs;
  var employeesHasMoreData = true.obs;
  var employeesIsLoadingMore = false.obs;

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
    _setupScrollListeners();
    fetchMerchantDetails();
    fetchAllLedgers();
  }

  @override
  void onClose() {
    customersScrollController.dispose();
    suppliersScrollController.dispose();
    employeesScrollController.dispose();
    super.onClose();
  }

  /// Setup scroll listeners for infinite scrolling (80% threshold)
  void _setupScrollListeners() {
    // Customers scroll listener
    customersScrollController.addListener(() {
      if (customersScrollController.hasClients) {
        final maxScroll = customersScrollController.position.maxScrollExtent;
        final currentScroll = customersScrollController.position.pixels;
        final threshold = maxScroll * 0.8;

        if (currentScroll >= threshold &&
            !customersIsLoadingMore.value &&
            customersHasMoreData.value) {
          debugPrint('📜 Customers scroll reached 80% - Loading more...');
          loadMoreCustomers();
        }
      }
    });

    // Suppliers scroll listener
    suppliersScrollController.addListener(() {
      if (suppliersScrollController.hasClients) {
        final maxScroll = suppliersScrollController.position.maxScrollExtent;
        final currentScroll = suppliersScrollController.position.pixels;
        final threshold = maxScroll * 0.8;

        if (currentScroll >= threshold &&
            !suppliersIsLoadingMore.value &&
            suppliersHasMoreData.value) {
          debugPrint('📜 Suppliers scroll reached 80% - Loading more...');
          loadMoreSuppliers();
        }
      }
    });

    // Employees scroll listener
    employeesScrollController.addListener(() {
      if (employeesScrollController.hasClients) {
        final maxScroll = employeesScrollController.position.maxScrollExtent;
        final currentScroll = employeesScrollController.position.pixels;
        final threshold = maxScroll * 0.8;

        if (currentScroll >= threshold &&
            !employeesIsLoadingMore.value &&
            employeesHasMoreData.value) {
          debugPrint('📜 Employees scroll reached 80% - Loading more...');
          loadMoreEmployees();
        }
      }
    });
  }

  /// Fetch merchant details - OFFLINE FIRST
  /// 1. Load from AuthStorage first (instant, works offline)
  /// 2. If online, fetch fresh from API and update storage
  Future<void> fetchMerchantDetails() async {
    try {
      debugPrint('📡 Fetching merchant details (OFFLINE-FIRST)...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      debugPrint('🏢 Merchant ID from storage: $merchantId');

      // 🗄️ OFFLINE-FIRST: Load cached merchant data first
      final cachedMerchantName = await AuthStorage.getMerchantName();
      final cachedBusinessName = await AuthStorage.getBusinessName();

      if (cachedMerchantName != null && cachedMerchantName.isNotEmpty) {
        merchantName.value = cachedMerchantName;
        debugPrint('📦 Loaded cached merchant name: $cachedMerchantName');
      }
      if (cachedBusinessName != null && cachedBusinessName.isNotEmpty) {
        businessName.value = cachedBusinessName;
        debugPrint('📦 Loaded cached business name: $cachedBusinessName');
      }

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Is Online: $isOnline');

      // If offline, use cached data
      if (!isOnline) {
        debugPrint('📴 Offline - Using cached merchant details');
        if (merchantName.value.isEmpty) {
          merchantName.value = 'Aukra'; // Default if no cached data
        }
        return;
      }

      // 🌐 ONLINE: Fetch fresh from API
      debugPrint('🔄 Online - Fetching fresh merchant data from API...');
      await _apiFetcher.request(
        url: 'api/merchant/all',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⏱️ Merchant API request timeout - using cached data');
          // Keep using cached data on timeout
          if (merchantName.value.isEmpty) {
            merchantName.value = 'Aukra';
          }
          return;
        },
      );

      debugPrint('📥 Merchant API Response from /api/merchant/all');
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ Merchant API Error: ${_apiFetcher.errorMessage}');
        // Keep using cached data on error
        return;
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

            // Save to storage for offline use
            await AuthStorage.saveMerchantName(merchantName.value);
            if (businessName.value.isNotEmpty) {
              await AuthStorage.saveBusinessName(businessName.value);
            }
            debugPrint('💾 Merchant data saved to storage for offline use');
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

          // Save to storage for offline use
          await AuthStorage.saveMerchantName(merchantName.value);
          if (businessName.value.isNotEmpty) {
            await AuthStorage.saveBusinessName(businessName.value);
          }
          debugPrint('💾 Merchant data saved to storage for offline use');
        }
      } else {
        debugPrint('⚠️ API returned no data - keeping cached merchant details');
        // Keep using cached data
      }
    } catch (e) {
      debugPrint('❌ Error fetching merchant details: $e');
      // Keep using cached data on exception
      if (merchantName.value.isEmpty) {
        merchantName.value = 'Aukra'; // Default name on exception
      }
    }
  }

  /// Fetch all ledgers (customers, suppliers, employers) - OFFLINE FIRST
  /// 1. Load from local SQLite database first (instant)
  /// 2. If online, sync with server in background
  Future<void> fetchAllLedgers() async {
    // Prevent multiple simultaneous fetches
    if (isLoading.value) {
      debugPrint('⚠️ Already fetching ledgers, skipping duplicate request');
      return;
    }

    try {
      isLoading.value = true;
      debugPrint('');
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📡 LEDGER_CONTROLLER: fetchAllLedgers() - OFFLINE-FIRST');
      debugPrint('═══════════════════════════════════════════════════════');

      // Check database initialization status
      debugPrint('🔍 ConnectivityService registered: ${Get.isRegistered<ConnectivityService>()}');
      debugPrint('🔍 LedgerRepository registered: ${Get.isRegistered<LedgerRepository>()}');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      debugPrint('🏢 Merchant ID from storage: $merchantId');

      if (merchantId == null) {
        debugPrint('❌ No merchant ID found in storage');
        isLoading.value = false;
        return;
      }

      // Clear existing lists and reset pagination
      allLedgers.clear();
      customers.clear();
      suppliers.clear();
      employers.clear();

      // Reset pagination state
      customersCurrentSkip.value = 0;
      customersHasMoreData.value = true;
      suppliersCurrentSkip.value = 0;
      suppliersHasMoreData.value = true;
      employeesCurrentSkip.value = 0;
      employeesHasMoreData.value = true;

      // 🗄️ OFFLINE-FIRST: Fetch from repository (local DB + API sync)
      await _fetchLedgersOfflineFirst(merchantId, 'CUSTOMER');
      await _fetchLedgersOfflineFirst(merchantId, 'SUPPLIER');
      await _fetchLedgersOfflineFirst(merchantId, 'EMPLOYEE');

      debugPrint('📊 Total ledgers: ${allLedgers.length}');
      debugPrint('👥 Customers: ${customers.length}/${customersTotalCount.value}');
      debugPrint('🏭 Suppliers: ${suppliers.length}/${suppliersTotalCount.value}');
      debugPrint('👔 Employers: ${employers.length}/${employeesTotalCount.value}');
    } catch (e) {
      debugPrint('❌ Error fetching ledgers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🗄️ OFFLINE-FIRST: Fetch ledgers from repository
  Future<void> _fetchLedgersOfflineFirst(int merchantId, String partyType) async {
    try {
      debugPrint('');
      debugPrint('🟢🟢🟢 LEDGER_CONTROLLER: _fetchLedgersOfflineFirst() 🟢🟢🟢');
      debugPrint('   merchantId: $merchantId, partyType: $partyType');

      // Check if repository is registered
      final isRepoRegistered = Get.isRegistered<LedgerRepository>();
      debugPrint('   📦 LedgerRepository registered: $isRepoRegistered');

      // Repository handles: local DB first, then API sync if online
      final ledgers = await ledgerRepository.getLedgersByPartyType(merchantId, partyType);

      debugPrint('   ✅ Got ${ledgers.length} $partyType from repository');

      // Add to appropriate list
      for (final ledger in ledgers) {
        allLedgers.add(ledger);

        switch (ledger.partyType.toUpperCase()) {
          case 'CUSTOMER':
            customers.add(ledger);
            break;
          case 'SUPPLIER':
            suppliers.add(ledger);
            break;
          case 'EMPLOYEE':
            employers.add(ledger);
            break;
        }
      }

      // Update counts
      switch (partyType.toUpperCase()) {
        case 'CUSTOMER':
          customersTotalCount.value = ledgers.length;
          customersHasMoreData.value = false; // Repository returns all
          break;
        case 'SUPPLIER':
          suppliersTotalCount.value = ledgers.length;
          suppliersHasMoreData.value = false;
          break;
        case 'EMPLOYEE':
          employeesTotalCount.value = ledgers.length;
          employeesHasMoreData.value = false;
          break;
      }
    } catch (e) {
      debugPrint('❌ Error fetching $partyType from repository: $e');
      // Fallback to direct API call if repository fails
      await _fetchLedgersByType(merchantId, partyType, skip: 0, limit: _limit);
    }
  }

  /// Fetch ledgers by party type with pagination (FALLBACK - Direct API)
  Future<void> _fetchLedgersByType(int merchantId, String partyType, {int skip = 0, int limit = 10}) async {
    try {
      final fetcher = ApiFetcher();

      debugPrint('');
      debugPrint('🔴🔴🔴 FALLBACK: _fetchLedgersByType() 🔴🔴🔴');
      debugPrint('   ⚠️ Using DIRECT API call (not repository)');
      debugPrint('📡 Fetching $partyType ledgers (skip: $skip, limit: $limit)...');

      // Call GET API with merchantId, partyType, and pagination
      await fetcher.request(
        url: 'api/ledger/$merchantId?partyType=$partyType&skip=$skip&limit=$limit',
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

        List<dynamic> ledgerList = [];
        int totalCount = 0;

        // Parse response - handle both formats
        if (fetcher.data is Map && fetcher.data['data'] is List) {
          // Nested format: {count: 3, totalCount: 14, data: [...]}
          ledgerList = fetcher.data['data'] as List;
          // Use totalCount if available, otherwise use count
          totalCount = fetcher.data['totalCount'] ?? fetcher.data['count'] ?? ledgerList.length;
          debugPrint('📊 $partyType - Fetched: ${ledgerList.length}, Total: $totalCount');
        } else if (fetcher.data is List) {
          // Direct array format: [...]
          ledgerList = fetcher.data as List;
          totalCount = ledgerList.length;
          debugPrint('📊 $partyType Direct array format - Items: ${ledgerList.length}');
        } else {
          debugPrint('⚠️ Unexpected response format for $partyType');
          return;
        }

        // Update total count and hasMoreData based on party type
        switch (partyType.toUpperCase()) {
          case 'CUSTOMER':
            customersTotalCount.value = totalCount;
            customersHasMoreData.value = customers.length + ledgerList.length < totalCount;
            break;
          case 'SUPPLIER':
            suppliersTotalCount.value = totalCount;
            suppliersHasMoreData.value = suppliers.length + ledgerList.length < totalCount;
            break;
          case 'EMPLOYEE':
            employeesTotalCount.value = totalCount;
            employeesHasMoreData.value = employers.length + ledgerList.length < totalCount;
            break;
        }

        // Process ledger items
        for (var ledgerJson in ledgerList) {
          if (ledgerJson is Map<String, dynamic>) {
            try {
              final ledger = LedgerModel.fromJson(ledgerJson);
              allLedgers.add(ledger);

              // Sort by party type - Use actual ledger.partyType from API response
              switch (ledger.partyType.toUpperCase()) {
                case 'CUSTOMER':
                  customers.add(ledger);
                  break;
                case 'SUPPLIER':
                  suppliers.add(ledger);
                  break;
                case 'EMPLOYEE':
                  employers.add(ledger);
                  break;
              }
            } catch (e) {
              debugPrint('❌ Error parsing ledger item: $e');
            }
          }
        }

        debugPrint('📊 $partyType loaded: ${ledgerList.length} items');
      }
    } catch (e) {
      debugPrint('❌ Error fetching $partyType: $e');
    }
  }

  // ============================================================
  // LOAD MORE METHODS (Infinite Scrolling)
  // ============================================================

  /// Load more customers
  Future<void> loadMoreCustomers() async {
    if (customersIsLoadingMore.value || !customersHasMoreData.value) {
      debugPrint('⏸️ Skip loading more customers: isLoading=${customersIsLoadingMore.value}, hasMore=${customersHasMoreData.value}');
      return;
    }

    try {
      customersIsLoadingMore.value = true;
      final nextSkip = customersCurrentSkip.value + _limit;

      debugPrint('🔄 Loading more customers - skip: $nextSkip');

      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) return;

      await _fetchLedgersByType(merchantId, 'CUSTOMER', skip: nextSkip, limit: _limit);

      // Update skip after successful fetch
      customersCurrentSkip.value = nextSkip;

      debugPrint('✅ Customers loaded: ${customers.length}/${customersTotalCount.value}');
    } catch (e) {
      debugPrint('❌ Error loading more customers: $e');
    } finally {
      customersIsLoadingMore.value = false;
    }
  }

  /// Load more suppliers
  Future<void> loadMoreSuppliers() async {
    if (suppliersIsLoadingMore.value || !suppliersHasMoreData.value) {
      debugPrint('⏸️ Skip loading more suppliers: isLoading=${suppliersIsLoadingMore.value}, hasMore=${suppliersHasMoreData.value}');
      return;
    }

    try {
      suppliersIsLoadingMore.value = true;
      final nextSkip = suppliersCurrentSkip.value + _limit;

      debugPrint('🔄 Loading more suppliers - skip: $nextSkip');

      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) return;

      await _fetchLedgersByType(merchantId, 'SUPPLIER', skip: nextSkip, limit: _limit);

      // Update skip after successful fetch
      suppliersCurrentSkip.value = nextSkip;

      debugPrint('✅ Suppliers loaded: ${suppliers.length}/${suppliersTotalCount.value}');
    } catch (e) {
      debugPrint('❌ Error loading more suppliers: $e');
    } finally {
      suppliersIsLoadingMore.value = false;
    }
  }

  /// Load more employees
  Future<void> loadMoreEmployees() async {
    if (employeesIsLoadingMore.value || !employeesHasMoreData.value) {
      debugPrint('⏸️ Skip loading more employees: isLoading=${employeesIsLoadingMore.value}, hasMore=${employeesHasMoreData.value}');
      return;
    }

    try {
      employeesIsLoadingMore.value = true;
      final nextSkip = employeesCurrentSkip.value + _limit;

      debugPrint('🔄 Loading more employees - skip: $nextSkip');

      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) return;

      await _fetchLedgersByType(merchantId, 'EMPLOYEE', skip: nextSkip, limit: _limit);

      // Update skip after successful fetch
      employeesCurrentSkip.value = nextSkip;

      debugPrint('✅ Employees loaded: ${employers.length}/${employeesTotalCount.value}');
    } catch (e) {
      debugPrint('❌ Error loading more employees: $e');
    } finally {
      employeesIsLoadingMore.value = false;
    }
  }

  /// Refresh all data - forces API sync if online
  Future<void> refreshAll() async {
    await fetchMerchantDetails();

    // Check if online for force refresh
    final isOnline = Get.isRegistered<ConnectivityService>()
        ? ConnectivityService.instance.isConnected.value
        : true;

    if (isOnline) {
      debugPrint('🔄 Online - forcing API refresh...');
      // Force sync from server
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId != null) {
        await ledgerRepository.fullSync(merchantId);
      }
    }

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

  /// Apply transaction filter (IN/OUT based on currentBalance sign)
  ///
  /// ✅ KHATABOOK COLOR LOGIC:
  /// - GREEN items = Negative balance = You owe customer = "IN" (paise aaye, balance kam hua)
  /// - RED items = Positive balance = Customer owes you = "OUT" (maal diya, balance badha)
  ///
  /// User expects:
  /// - "In transaction" filter → GREEN items (paise receive kiye)
  /// - "Out transaction" filter → RED items (maal/paise diye)
  List<LedgerModel> _applyTransactionFilter(List<LedgerModel> ledgers) {
    debugPrint('🔍 Applying transaction filter: ${transactionFilter.value}');
    debugPrint('   Input: ${ledgers.length} ledgers');

    // Debug: Show balance distribution
    final positiveItems = ledgers.where((l) => l.currentBalance > 0).length;
    final negativeItems = ledgers.where((l) => l.currentBalance < 0).length;
    final zeroItems = ledgers.where((l) => l.currentBalance == 0).length;
    debugPrint('   Distribution: RED(OUT/Positive)=$positiveItems, GREEN(IN/Negative)=$negativeItems, Zero=$zeroItems');

    List<LedgerModel> filtered;
    switch (transactionFilter.value) {
      case 'in_transaction':
        // IN = Negative balance (< 0) = GREEN items = You owe customer (paise aaye)
        filtered = ledgers.where((l) => l.currentBalance < 0).toList();
        debugPrint('   ✅ Filtering IN (negative balance = GREEN): ${filtered.length} results');
        for (var l in filtered.take(5)) {
          debugPrint('      - ${l.name}: ₹${l.currentBalance} (GREEN)');
        }
        return filtered;
      case 'out_transaction':
        // OUT = Positive balance (> 0) = RED items = Customer owes you (maal diya)
        filtered = ledgers.where((l) => l.currentBalance > 0).toList();
        debugPrint('   ❌ Filtering OUT (positive balance = RED): ${filtered.length} results');
        for (var l in filtered.take(5)) {
          debugPrint('      - ${l.name}: ₹${l.currentBalance} (RED)');
        }
        return filtered;
      case 'all_transaction':
      default:
        debugPrint('   📋 No filter (all transactions): ${ledgers.length} results');
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

  /// Remove a ledger from local lists (for deactivation)
  /// Call this after deactivating a ledger to immediately update UI
  void removeLedgerFromLists(int ledgerId) {
    debugPrint('🗑️ Removing ledger $ledgerId from local lists...');

    // Remove from customers list
    final customerIndex = customers.indexWhere((l) => l.id == ledgerId);
    if (customerIndex != -1) {
      final removedName = customers[customerIndex].name;
      customers.removeAt(customerIndex);
      customers.refresh();
      debugPrint('✅ Removed customer ledger $ledgerId ($removedName) from list');
      return;
    }

    // Remove from suppliers list
    final supplierIndex = suppliers.indexWhere((l) => l.id == ledgerId);
    if (supplierIndex != -1) {
      final removedName = suppliers[supplierIndex].name;
      suppliers.removeAt(supplierIndex);
      suppliers.refresh();
      debugPrint('✅ Removed supplier ledger $ledgerId ($removedName) from list');
      return;
    }

    // Remove from employers list
    final employerIndex = employers.indexWhere((l) => l.id == ledgerId);
    if (employerIndex != -1) {
      final removedName = employers[employerIndex].name;
      employers.removeAt(employerIndex);
      employers.refresh();
      debugPrint('✅ Removed employer ledger $ledgerId ($removedName) from list');
      return;
    }

    // Also remove from allLedgers
    allLedgers.removeWhere((l) => l.id == ledgerId);
    allLedgers.refresh();

    debugPrint('⚠️ Ledger $ledgerId not found in any list');
  }

  /// Add a ledger to local lists (for activation)
  /// Call this after activating a ledger to immediately update UI
  void addLedgerToLists(LedgerModel ledger) {
    debugPrint('➕ Adding ledger ${ledger.id} (${ledger.name}) to local lists...');

    // Check if already exists to avoid duplicates
    final existsInAll = allLedgers.any((l) => l.id == ledger.id);
    if (existsInAll) {
      debugPrint('⚠️ Ledger ${ledger.id} already exists in lists');
      return;
    }

    // Add to allLedgers
    allLedgers.add(ledger);

    // Add to appropriate list based on party type
    switch (ledger.partyType.toUpperCase()) {
      case 'CUSTOMER':
        customers.add(ledger);
        customers.refresh();
        debugPrint('✅ Added customer ledger ${ledger.id} (${ledger.name}) to list');
        break;
      case 'SUPPLIER':
        suppliers.add(ledger);
        suppliers.refresh();
        debugPrint('✅ Added supplier ledger ${ledger.id} (${ledger.name}) to list');
        break;
      case 'EMPLOYEE':
      case 'EMPLOYER':
        employers.add(ledger);
        employers.refresh();
        debugPrint('✅ Added employer ledger ${ledger.id} (${ledger.name}) to list');
        break;
      default:
        debugPrint('⚠️ Unknown party type: ${ledger.partyType}');
    }

    allLedgers.refresh();
  }

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
