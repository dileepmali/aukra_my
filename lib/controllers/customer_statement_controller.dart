import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/customer_statement_api.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/customer_statement_model.dart';

/// Controller for Customer Statement Screen
class CustomerStatementController extends GetxController {
  final CustomerStatementApi _statementApi = CustomerStatementApi();

  // Observable variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final statementData = Rxn<CustomerStatementModel>();
  final searchQuery = ''.obs;

  // Party type: 'CUSTOMER', 'SUPPLIER', 'EMPLOYEE'
  String partyType = 'CUSTOMER';
  String partyTypeLabel = 'Customer';

  @override
  void onInit() {
    super.onInit();

    // Get party type from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      partyType = args['partyType'] ?? 'CUSTOMER';
      partyTypeLabel = args['partyTypeLabel'] ?? 'Customer';
    }

    debugPrint('📊 CustomerStatementController initialized for: $partyType');

    // Fetch statement data
    fetchStatement();
  }

  /// Fetch statement data
  Future<void> fetchStatement() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('📡 Fetching $partyType statement...');

      final data = await _statementApi.getCustomerStatement(
        partyType: partyType,
      );

      statementData.value = data;

      debugPrint('✅ Statement loaded successfully');
      debugPrint('   - Net Balance: ₹${data.netBalance}');
      debugPrint('   - Total ${partyTypeLabel}s: ${data.totalCustomers}');
      debugPrint('   - Yesterday IN: ₹${data.yesterdayTotalIn}');
      debugPrint('   - Yesterday OUT: ₹${data.yesterdayTotalOut}');
    } catch (e) {
      debugPrint('❌ Error fetching statement: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh statement data
  Future<void> refreshStatement() async {
    await fetchStatement();
  }

  /// Get filtered customers based on search query
  List<CustomerStatementItem> get filteredCustomers {
    if (statementData.value == null) return [];

    final customers = statementData.value!.customers;

    if (searchQuery.value.isEmpty) {
      return customers;
    }

    return customers.where((customer) {
      final query = searchQuery.value.toLowerCase();
      return customer.name.toLowerCase().contains(query) ||
          customer.location.toLowerCase().contains(query) ||
          (customer.mobileNumber?.contains(query) ?? false);
    }).toList();
  }

  /// Download statement (placeholder)
  Future<void> downloadStatement() async {
    try {
      debugPrint('📥 Downloading $partyType statement...');

      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      // Simulate download delay
      await Future.delayed(const Duration(seconds: 2));

      // Close loading
      Get.back();

      // Show success message using error service
      AdvancedErrorService.showSuccess(
        'Statement downloaded successfully',
        type: SuccessType.snackbar,
        customDuration: const Duration(seconds: 3),
      );

      debugPrint('✅ Statement downloaded');

      // TODO: Implement actual PDF/Excel generation and download
      // You can use packages like pdf, excel, or flutter_downloader
    } catch (e) {
      Get.back(); // Close loading
      debugPrint('❌ Error downloading statement: $e');

      // Show error message using error service
      AdvancedErrorService.showError(
        'Failed to download statement',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.download,
        customDuration: const Duration(seconds: 3),
      );
    }
  }

  /// Get screen title based on party type
  String get screenTitle {
    switch (partyType) {
      case 'CUSTOMER':
        return 'Customers account statements';
      case 'SUPPLIER':
        return 'Suppliers account statements';
      case 'EMPLOYEE':
        return 'Employees account statements';
      default:
        return 'Account statements';
    }
  }

  /// Get label text
  String get customerLabel {
    switch (partyType) {
      case 'CUSTOMER':
        return 'customers';
      case 'SUPPLIER':
        return 'suppliers';
      case 'EMPLOYEE':
        return 'employees';
      default:
        return 'entries';
    }
  }
}
