import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/merchant_dashboard_model.dart';
import '../core/api/merchant_dashboard_api.dart';
import '../core/api/auth_storage.dart';
import '../core/database/repositories/ledger_repository.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import 'ledger_controller.dart';

class AccountController extends GetxController {
  // API instance
  final MerchantDashboardApi _dashboardApi = MerchantDashboardApi();

  // 🗄️ Offline-first repositories
  LedgerRepository? _ledgerRepository;
  LedgerRepository get ledgerRepository {
    if (_ledgerRepository == null) {
      if (Get.isRegistered<LedgerRepository>()) {
        _ledgerRepository = Get.find<LedgerRepository>();
      } else {
        _ledgerRepository = LedgerRepository();
      }
    }
    return _ledgerRepository!;
  }

  TransactionRepository? _transactionRepository;
  TransactionRepository get transactionRepository {
    if (_transactionRepository == null) {
      if (Get.isRegistered<TransactionRepository>()) {
        _transactionRepository = Get.find<TransactionRepository>();
      } else {
        _transactionRepository = TransactionRepository();
      }
    }
    return _transactionRepository!;
  }

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

  /// Fetch merchant dashboard data - OFFLINE FIRST
  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('📊 Fetching account dashboard (OFFLINE-FIRST)...');

      // Check connectivity
      final isOnline = Get.isRegistered<ConnectivityService>()
          ? ConnectivityService.instance.isConnected.value
          : true;

      debugPrint('🌐 Is Online: $isOnline');

      // 🗄️ OFFLINE-FIRST: Calculate from cached data first
      await _calculateDashboardFromCachedData();

      if (!isOnline) {
        debugPrint('📴 Offline - Using cached dashboard data');
        return;
      }

      // 🌐 If online, fetch fresh data from API
      try {
        debugPrint('🔄 Online - Fetching fresh dashboard from API...');
        final data = await _dashboardApi.getMerchantDashboard();
        dashboardData.value = data;

        debugPrint('✅ Account dashboard loaded from API successfully');
        debugPrint('   - Total Net Balance: ₹$totalNetBalance');
        debugPrint('   - Customer Balance: ₹$customerNetBalance');
        debugPrint('   - Supplier Balance: ₹$supplierNetBalance');
        debugPrint('   - Employee Balance: ₹$employeeNetBalance');
        debugPrint('   - Total Customers: $totalCustomers');
        debugPrint('   - Total Suppliers: $totalSuppliers');
        debugPrint('   - Total Employees: $totalEmployees');
      } catch (apiError) {
        debugPrint('⚠️ API fetch failed: $apiError');
        // If API fails, we already have cached data calculated above
        if (dashboardData.value == null) {
          errorMessage.value = apiError.toString().replaceAll('Exception: ', '');
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching account dashboard: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// 🗄️ Calculate dashboard from cached ledger data
  Future<void> _calculateDashboardFromCachedData() async {
    try {
      final merchantId = await _getMerchantId();
      if (merchantId == null) {
        debugPrint('⚠️ Cannot calculate cached dashboard - no merchant ID');
        return;
      }

      debugPrint('📦 Calculating dashboard from cached data...');

      // Get cached ledgers by party type
      final customers = await ledgerRepository.getLedgersByPartyType(merchantId, 'CUSTOMER');
      final suppliers = await ledgerRepository.getLedgersByPartyType(merchantId, 'SUPPLIER');
      final employees = await ledgerRepository.getLedgersByPartyType(merchantId, 'EMPLOYEE');

      debugPrint('📦 Cached counts: Customers=${customers.length}, Suppliers=${suppliers.length}, Employees=${employees.length}');

      // Calculate net balance for each party type
      double customerGiven = 0, customerReceived = 0;
      double supplierGiven = 0, supplierReceived = 0;
      double employeeGiven = 0, employeeReceived = 0;

      // Customer balances
      for (final ledger in customers) {
        if (ledger.currentBalance >= 0) {
          customerGiven += ledger.currentBalance; // They owe you
        } else {
          customerReceived += ledger.currentBalance.abs(); // You owe them
        }
      }

      // Supplier balances
      for (final ledger in suppliers) {
        if (ledger.currentBalance >= 0) {
          supplierGiven += ledger.currentBalance;
        } else {
          supplierReceived += ledger.currentBalance.abs();
        }
      }

      // Employee balances
      for (final ledger in employees) {
        if (ledger.currentBalance >= 0) {
          employeeGiven += ledger.currentBalance;
        } else {
          employeeReceived += ledger.currentBalance.abs();
        }
      }

      // Calculate net balances
      final customerNet = customerGiven - customerReceived;
      final supplierNet = supplierGiven - supplierReceived;
      final employeeNet = employeeGiven - employeeReceived;
      final totalNet = customerNet + supplierNet + employeeNet;

      // Calculate today's IN/OUT
      double todayIn = 0, todayOut = 0;

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Sum transactions from all ledgers
      final allLedgers = [...customers, ...suppliers, ...employees];
      for (final ledger in allLedgers) {
        if (ledger.id != null) {
          try {
            final todayTransactions = await transactionRepository.getTransactionsByDateRange(
              ledger.id!,
              todayStart,
              todayEnd,
            );

            for (final tx in todayTransactions) {
              if (!tx.isDelete) {
                if (tx.transactionType == 'IN') {
                  todayIn += tx.amount;
                } else {
                  todayOut += tx.amount;
                }
              }
            }
          } catch (e) {
            // Skip if error getting transactions for this ledger
          }
        }
      }

      // Create dashboard model from cached data
      dashboardData.value = MerchantDashboardModel(
        todayIn: todayIn,
        todayOut: todayOut,
        overallGiven: customerGiven + supplierGiven + employeeGiven,
        overallReceived: customerReceived + supplierReceived + employeeReceived,
        netBalance: totalNet.abs(),
        netBalanceType: totalNet >= 0 ? 'OUT' : 'IN',
        party: MerchantPartyBreakdown(
          customer: MerchantPartyData(
            total: customers.length,
            netBalance: customerNet.abs(),
            netBalanceType: customerNet >= 0 ? 'OUT' : 'IN',
            overallGiven: customerGiven,
            overallReceived: customerReceived,
          ),
          supplier: MerchantPartyData(
            total: suppliers.length,
            netBalance: supplierNet.abs(),
            netBalanceType: supplierNet >= 0 ? 'OUT' : 'IN',
            overallGiven: supplierGiven,
            overallReceived: supplierReceived,
          ),
          employee: MerchantPartyData(
            total: employees.length,
            netBalance: employeeNet.abs(),
            netBalanceType: employeeNet >= 0 ? 'OUT' : 'IN',
            overallGiven: employeeGiven,
            overallReceived: employeeReceived,
          ),
        ),
      );

      debugPrint('📦 Dashboard calculated from cached data:');
      debugPrint('   - Total Net Balance: ₹${totalNet.abs()} (${totalNet >= 0 ? "OUT" : "IN"})');
      debugPrint('   - Customer: ₹${customerNet.abs()} (${customers.length} ledgers)');
      debugPrint('   - Supplier: ₹${supplierNet.abs()} (${suppliers.length} ledgers)');
      debugPrint('   - Employee: ₹${employeeNet.abs()} (${employees.length} ledgers)');
      debugPrint('   - Today IN: ₹$todayIn, Today OUT: ₹$todayOut');
    } catch (e) {
      debugPrint('⚠️ Error calculating cached dashboard: $e');
    }
  }

  /// Get merchant ID from storage
  Future<int?> _getMerchantId() async {
    try {
      return await AuthStorage.getMerchantId();
    } catch (e) {
      debugPrint('⚠️ Could not get merchant ID: $e');
      return null;
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboard() async {
    await fetchDashboard();
  }

  /// 🧪 TEST METHOD: Simulates no data state for testing UI visibility
  Future<void> _simulateNoDataForTesting() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    // Don't set dashboardData - it will remain null, showing default values (₹0, 0 count)
    isLoading.value = false;
  }
}
