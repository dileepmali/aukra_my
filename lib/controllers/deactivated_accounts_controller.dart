import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/ledger_detail_api.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../models/deactivated_ledger_model.dart';
import 'ledger_controller.dart';

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

      // Update local database - set isActive = true
      final ledgerRepository = Get.isRegistered<LedgerRepository>()
          ? Get.find<LedgerRepository>()
          : LedgerRepository();
      await ledgerRepository.updateLedgerStatus(ledgerId, true, securityKey);
      debugPrint('💾 Local DB updated: ledger $ledgerId isActive = true');

      // Remove from local deactivated list first
      deactivatedAccounts.removeWhere((account) => account.id == ledgerId);

      // Refresh LedgerController to fetch all active ledgers from API
      // This ensures the activated ledger appears in ledger_screen.dart
      if (Get.isRegistered<LedgerController>()) {
        final ledgerController = Get.find<LedgerController>();
        debugPrint('🔄 Refreshing LedgerController to show activated ledger...');
        await ledgerController.refreshAll();
        debugPrint('✅ LedgerController refreshed - ledger should now appear in ledger_screen.dart');
      }

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