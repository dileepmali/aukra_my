import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/ledger_detail_api.dart';
import '../models/deactivated_ledger_model.dart';

class DeactivatedAccountsController extends GetxController {
  final LedgerDetailApi _api = LedgerDetailApi();

  // Observable states
  final isLoading = true.obs;
  final isActivating = false.obs;
  final errorMessage = ''.obs;

  // Deactivated accounts list
  final deactivatedAccounts = <DeactivatedLedgerModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDeactivatedAccounts();
  }

  /// Fetch deactivated accounts from API
  Future<void> fetchDeactivatedAccounts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found');
      }

      debugPrint('📋 Fetching deactivated accounts for merchant: $merchantId');

      final response = await _api.getDeactivatedLedgers(
        merchantId: merchantId,
      );

      deactivatedAccounts.value = response.data;

      debugPrint('✅ Fetched ${deactivatedAccounts.length} deactivated accounts');

      // Debug: Print each account's details
      for (var account in deactivatedAccounts) {
        debugPrint('📋 Account: ${account.partyName}, Mobile: ${account.mobileNumber}, Type: ${account.partyType}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching deactivated accounts: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh deactivated accounts
  Future<void> refresh() async {
    await fetchDeactivatedAccounts();
  }

  /// Activate (restore) a deactivated ledger
  /// Calls PATCH /api/ledger/{ledgerId}/status with isActive: true
  Future<bool> activateLedger(int ledgerId, String securityKey) async {
    try {
      isActivating.value = true;
      debugPrint('🔓 Activating ledger: $ledgerId');

      final response = await _api.updateLedgerStatus(
        ledgerId: ledgerId,
        isActive: true,
        securityKey: securityKey,
      );

      debugPrint('✅ Ledger activated: ${response.message}');

      // Remove from local list
      deactivatedAccounts.removeWhere((account) => account.id == ledgerId);

      return true;
    } catch (e) {
      debugPrint('❌ Error activating ledger: $e');
      errorMessage.value = 'Unable to activate. Please try again.';
      return false;
    } finally {
      isActivating.value = false;
    }
  }
}