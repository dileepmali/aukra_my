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

  // Computed properties
  int get totalCustomers => _ledgerController.customers.length;
  int get totalSuppliers => _ledgerController.suppliers.length;
  int get totalEmployees => _ledgerController.employers.length;

  // Dashboard data getters
  double get totalNetBalance {
    if (dashboardData.value == null) return 0.0;
    return dashboardData.value!.totalNetBalance;
  }

  double get customerNetBalance {
    if (dashboardData.value == null) return 0.0;
    return dashboardData.value!.party.customer.netBalance;
  }

  double get supplierNetBalance {
    if (dashboardData.value == null) return 0.0;
    return dashboardData.value!.party.supplier.netBalance;
  }

  double get employeeNetBalance {
    if (dashboardData.value == null) return 0.0;
    return dashboardData.value!.party.employee.netBalance;
  }

  // Balance type getters for consistent positive/negative logic
  String get totalBalanceType {
    if (dashboardData.value == null) return 'OUT';
    return dashboardData.value!.balanceType;
  }

  String get customerBalanceType {
    if (dashboardData.value == null) return 'OUT';
    return dashboardData.value!.party.customer.balanceType;
  }

  String get supplierBalanceType {
    if (dashboardData.value == null) return 'OUT';
    return dashboardData.value!.party.supplier.balanceType;
  }

  String get employeeBalanceType {
    if (dashboardData.value == null) return 'OUT';
    return dashboardData.value!.party.employee.balanceType;
  }

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
