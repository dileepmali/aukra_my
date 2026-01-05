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

  @override
  void onInit() {
    super.onInit();
    fetchMerchantDetails();
    fetchAllLedgers();
  }

  /// Fetch merchant details from GET api/merchant
  Future<void> fetchMerchantDetails() async {
    try {
      debugPrint('📡 Fetching merchant details from API...');

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      debugPrint('🏢 Merchant ID from storage: $merchantId');

      if (merchantId == null) {
        debugPrint('❌ No merchant ID found in storage');
        merchantName.value = 'Aukra'; // Default name
        return;
      }

      // Call GET API with timeout
      await _apiFetcher.request(
        url: 'api/merchant',
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

      debugPrint('📥 Merchant API Response: ${_apiFetcher.data}');
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ Merchant API Error: ${_apiFetcher.errorMessage}');
      }

      // Check if we got valid merchant data
      if (_apiFetcher.data != null) {
        debugPrint('✅ Merchant details fetched successfully');

        if (_apiFetcher.data is List && (_apiFetcher.data as List).isNotEmpty) {
          // Response is an array, get first merchant
          final data = (_apiFetcher.data as List)[0] as Map<String, dynamic>;
          merchantName.value = data['businessName'] ?? 'Aukra';
          debugPrint('🏢 Merchant Name (from array): ${merchantName.value}');
        } else if (_apiFetcher.data is Map) {
          final data = _apiFetcher.data as Map<String, dynamic>;

          // Extract merchant name and business name
          merchantName.value = data['merchantName'] ?? data['name'] ?? 'Aukra';
          businessName.value = data['businessName'] ?? '';

          debugPrint('🏢 Merchant Name: ${merchantName.value}');
          debugPrint('🏪 Business Name: ${businessName.value}');
        }
      } else {
        debugPrint('❌ Failed to fetch merchant details: ${_apiFetcher.errorMessage}');
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
}
