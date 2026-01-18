import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/merchant_dashboard_model.dart';
import '../core/api/merchant_dashboard_api.dart';
import 'ledger_controller.dart';

class AccountController extends GetxController {
  // API instance
  final MerchantDashboardApi _dashboardApi = MerchantDashboardApi();

  // Reactive variables
  final dashboardData = Rxn<MerchantDashboardModel>();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Get LedgerController for counts
  LedgerController get _ledgerController => Get.find<LedgerController>();

  // Computed properties - Use API total count
  int get totalCustomers => dashboardData.value?.party.customer.total ?? _ledgerController.customers.length;
  int get totalSuppliers => dashboardData.value?.party.supplier.total ?? _ledgerController.suppliers.length;
  int get totalEmployees => dashboardData.value?.party.employee.total ?? _ledgerController.employers.length;

  // Net Balance from Dashboard API (directly from API response)
  double get totalNetBalance => dashboardData.value?.netBalance ?? 0.0;
  double get customerNetBalance => dashboardData.value?.party.customer.netBalance ?? 0.0;
  double get supplierNetBalance => dashboardData.value?.party.supplier.netBalance ?? 0.0;
  double get employeeNetBalance => dashboardData.value?.party.employee.netBalance ?? 0.0;

  // Balance type from Dashboard API (directly from API response)
  String get totalBalanceType => dashboardData.value?.netBalanceType ?? 'OUT';
  String get customerBalanceType => dashboardData.value?.party.customer.netBalanceType ?? 'OUT';
  String get supplierBalanceType => dashboardData.value?.party.supplier.netBalanceType ?? 'OUT';
  String get employeeBalanceType => dashboardData.value?.party.employee.netBalanceType ?? 'OUT';

  @override
  void onInit() {
    super.onInit();
    // Refresh both dashboard and ledger data
    refreshDashboard();
  }

  /// Fetch merchant dashboard data
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('📊 Fetching account dashboard...');

      // Fetch dashboard data
      final data = await _dashboardApi.getMerchantDashboard();
      dashboardData.value = data;

      debugPrint('✅ Account dashboard loaded successfully');
      debugPrint('   - Total Net Balance: ₹$totalNetBalance');
      debugPrint('   - Customer Balance: ₹$customerNetBalance');
      debugPrint('   - Supplier Balance: ₹$supplierNetBalance');
      debugPrint('   - Employee Balance: ₹$employeeNetBalance');
      debugPrint('   - Total Customers: $totalCustomers');
      debugPrint('   - Total Suppliers: $totalSuppliers');
      debugPrint('   - Total Employees: $totalEmployees');
    } catch (e) {
      debugPrint('❌ Error fetching account dashboard: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await Future.wait([
      fetchDashboard(),
      _ledgerController.refreshAll(),
    ]);
  }
}
