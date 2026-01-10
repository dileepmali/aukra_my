import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/merchant_list_api.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/merchant_list_model.dart';

/// Controller for Manage Businesses Screen
class ManageBusinessesController extends GetxController {
  final MerchantListApi _api = MerchantListApi();

  // Observable state
  final RxList<MerchantListModel> allMerchants = <MerchantListModel>[].obs;
  final RxList<MerchantListModel> filteredMerchants = <MerchantListModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMerchants();
  }

  /// Fetch all merchants from API
  Future<void> fetchMerchants() async {
    try {
      isLoading.value = true;
      debugPrint('📋 Fetching merchants...');

      final merchants = await _api.getAllMerchants();

      allMerchants.value = merchants;
      filteredMerchants.value = merchants;

      debugPrint('✅ Loaded ${merchants.length} merchants');
      debugPrint('📊 Business Counts:');
      debugPrint('   - Main Account Count: $mainAccountCount');
      debugPrint('   - Other Accounts Count: $otherAccountsCount');
      debugPrint('   - Total Count: $totalCount');

      // Log each merchant's isMainAccount status
      for (var merchant in merchants) {
        debugPrint('   📌 ${merchant.businessName}: isMainAccount=${merchant.isMainAccount}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching merchants: $e');
      AdvancedErrorService.showError(
        _api.errorMessage ?? 'Failed to load businesses',
        category: ErrorCategory.network,
        severity: ErrorSeverity.high,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Search/filter merchants by business name
  void searchMerchants(String query) {
    searchQuery.value = query;

    if (query.isEmpty) {
      filteredMerchants.value = allMerchants;
    } else {
      filteredMerchants.value = allMerchants.where((merchant) {
        return merchant.businessName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    debugPrint('🔍 Search: "$query" - Found ${filteredMerchants.length} results');
  }

  /// Get main account (isMainAccount = true)
  MerchantListModel? get mainAccount {
    try {
      return allMerchants.firstWhere((m) => m.isMainAccount);
    } catch (e) {
      return null;
    }
  }

  /// Get other accounts (isMainAccount = false)
  List<MerchantListModel> get otherAccounts {
    return allMerchants.where((m) => !m.isMainAccount).toList();
  }

  /// Get count of main account (1 or 0)
  int get mainAccountCount => mainAccount != null ? 1 : 0;

  /// Get count of other accounts
  int get otherAccountsCount => otherAccounts.length;

  /// Get total count
  int get totalCount => allMerchants.length;

  /// Get count of active businesses (isActive = true)
  int get activeCount => allMerchants.where((m) => m.isActive).length;

  /// Get count of inactive businesses (isActive = false)
  int get inactiveCount => allMerchants.where((m) => !m.isActive).length;

  @override
  void onClose() {
    debugPrint('🗑️ ManageBusinessesController disposed');
    super.onClose();
  }
}
