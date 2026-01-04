import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/ledger_api.dart';
import '../core/api/auth_storage.dart';
import '../models/ledger_model.dart';
import '../core/utils/formatters.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import 'ledger_controller.dart';

class CustomerFormController extends GetxController {
  // Text controllers
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController areaController;
  late TextEditingController pinController;
  late TextEditingController addressController;
  late TextEditingController interestRateController;
  late TextEditingController creditDaysController;
  late TextEditingController openingBalanceController;
  late TextEditingController creditLimitController;

  // Focus nodes for all fields
  late FocusNode nameFocusNode;
  late FocusNode phoneFocusNode;
  late FocusNode areaFocusNode;
  late FocusNode pinFocusNode;
  late FocusNode addressFocusNode;
  late FocusNode interestRateFocusNode;
  late FocusNode creditDaysFocusNode;
  late FocusNode openingBalanceFocusNode;
  late FocusNode creditLimitFocusNode;

  // Observable for quick selection chips
  var selectedCreditDays = Rx<int?>(null);
  var selectedCreditLimit = Rx<double?>(null);
  var selectedInterestType = 'YEARLY'.obs; // YEARLY or MONTHLY
  var selectedTransactionType = 'IN'.obs; // IN or OUT

  // Loading state
  var isLoading = false.obs;

  // API Service
  final LedgerApi _ledgerApi = LedgerApi();

  // Initial values from contact
  final String? initialName;
  final String? initialPhone;
  final String? partyType; // 'customer', 'supplier', 'employer'

  CustomerFormController({
    this.initialName,
    this.initialPhone,
    this.partyType,
  });

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers with initial values if provided
    nameController = TextEditingController(text: initialName ?? '');
    phoneController = TextEditingController(text: initialPhone ?? '');
    areaController = TextEditingController();
    pinController = TextEditingController();
    addressController = TextEditingController();
    interestRateController = TextEditingController();
    creditDaysController = TextEditingController();
    openingBalanceController = TextEditingController();
    creditLimitController = TextEditingController();

    // Initialize focus nodes
    nameFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    areaFocusNode = FocusNode();
    pinFocusNode = FocusNode();
    addressFocusNode = FocusNode();
    interestRateFocusNode = FocusNode();
    creditDaysFocusNode = FocusNode();
    openingBalanceFocusNode = FocusNode();
    creditLimitFocusNode = FocusNode();

    // Add focus listeners for formatting on focus loss
    openingBalanceFocusNode.addListener(() {
      if (!openingBalanceFocusNode.hasFocus) {
        _formatOpeningBalance();
      }
    });

    creditLimitFocusNode.addListener(() {
      if (!creditLimitFocusNode.hasFocus) {
        _formatCreditLimit();
      }
    });

    creditDaysFocusNode.addListener(() {
      if (!creditDaysFocusNode.hasFocus) {
        _formatCreditDays();
      }
    });
  }

  // Format opening balance to decimal when focus is lost
  void _formatOpeningBalance() {
    final text = openingBalanceController.text.trim();
    if (text.isNotEmpty) {
      final formatted = Formatters.formatAmountToDecimal(text);
      openingBalanceController.text = formatted;
    }
  }

  // Format credit limit to decimal when focus is lost
  void _formatCreditLimit() {
    final text = creditLimitController.text.trim();
    if (text.isNotEmpty) {
      final formatted = Formatters.formatAmountToDecimal(text);
      creditLimitController.text = formatted;
    }
  }

  // Format credit days with "Day" or "Days" suffix when focus is lost
  void _formatCreditDays() {
    final text = creditDaysController.text.trim();
    if (text.isNotEmpty) {
      // Remove any existing "Day" or "Days" text
      final numericText = text.replaceAll(RegExp(r'\s*(Day|Days)\s*', caseSensitive: false), '');
      final days = int.tryParse(numericText);

      if (days != null && days > 0) {
        // Add "Day" for 1, "Days" for more than 1
        final suffix = days == 1 ? ' Day' : ' Days';
        creditDaysController.text = '$days$suffix';
      }
    }
  }

  @override
  void onClose() {
    // Dispose all controllers
    nameController.dispose();
    phoneController.dispose();
    areaController.dispose();
    pinController.dispose();
    addressController.dispose();
    interestRateController.dispose();
    creditDaysController.dispose();
    openingBalanceController.dispose();
    creditLimitController.dispose();

    // Dispose focus nodes
    nameFocusNode.dispose();
    phoneFocusNode.dispose();
    areaFocusNode.dispose();
    pinFocusNode.dispose();
    addressFocusNode.dispose();
    interestRateFocusNode.dispose();
    creditDaysFocusNode.dispose();
    openingBalanceFocusNode.dispose();
    creditLimitFocusNode.dispose();

    super.onClose();
  }

  // Select credit days from quick selection
  void selectCreditDays(int days) {
    selectedCreditDays.value = days;
    final suffix = days == 1 ? ' Day' : ' Days';
    creditDaysController.text = '$days$suffix';
  }

  // Select credit limit from quick selection
  void selectCreditLimit(double amount) {
    selectedCreditLimit.value = amount;
    creditLimitController.text = amount.toStringAsFixed(2);
  }

  // Toggle interest type
  void toggleInterestType(String type) {
    selectedInterestType.value = type;
  }

  // Toggle transaction type
  void toggleTransactionType(String type) {
    selectedTransactionType.value = type;
  }

  // Validate and submit form
  Future<void> submitForm(BuildContext context) async {
    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      AdvancedErrorService.showError(
        'Please enter customer name',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      AdvancedErrorService.showError(
        'Please enter mobile number',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    // Validate phone number (should be 10 digits)
    final phone = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
    if (phone.length != 10) {
      AdvancedErrorService.showError(
        'Mobile number must be 10 digits',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    // Validate pin code (should be 6 digits)
    if (pinController.text.trim().isNotEmpty) {
      final pin = pinController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (pin.length != 6) {
        AdvancedErrorService.showError(
          'Pin code must be 6 digits',
          severity: ErrorSeverity.medium,
          category: ErrorCategory.validation,
        );
        return;
      }
    }

    try {
      isLoading.value = true;

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        AdvancedErrorService.showError(
          'Merchant ID not found. Please login again.',
          severity: ErrorSeverity.high,
          category: ErrorCategory.authentication,
        );
        isLoading.value = false;
        return;
      }

      // Parse numeric values with defaults
      final creditLimit = double.tryParse(
            creditLimitController.text.trim().replaceAll(',', ''),
          ) ??
          0.0;

      // Parse credit days by removing "Day" or "Days" suffix
      final creditDayText = creditDaysController.text.trim().replaceAll(RegExp(r'\s*(Day|Days)\s*', caseSensitive: false), '');
      final creditDay = int.tryParse(creditDayText) ?? 0;

      final interestRate = double.tryParse(
            interestRateController.text.trim(),
          ) ??
          0.0;

      final openingBalance = double.tryParse(
            openingBalanceController.text.trim().replaceAll(',', ''),
          ) ??
          0.0;

      // Convert partyType to backend format
      // 'employer' -> 'EMPLOYEE' (API expects EMPLOYEE, not EMPLOYER)
      String partyTypeUpperCase;
      final normalizedPartyType = (partyType ?? 'customer').toLowerCase();

      if (normalizedPartyType == 'employer' || normalizedPartyType == 'employee') {
        partyTypeUpperCase = 'EMPLOYEE';
      } else if (normalizedPartyType == 'supplier') {
        partyTypeUpperCase = 'SUPPLIER';
      } else {
        partyTypeUpperCase = 'CUSTOMER';
      }

      debugPrint('📋 Creating ledger with partyType: $normalizedPartyType -> $partyTypeUpperCase');

      // Create ledger model
      final ledger = LedgerModel(
        name: nameController.text.trim(),
        creditLimit: creditLimit,
        creditDay: creditDay,
        interestType: selectedInterestType.value,
        openingBalance: openingBalance,
        transactionType: selectedTransactionType.value,
        interestRate: interestRate,
        mobileNumber: phone,
        area: areaController.text.trim(),
        address: addressController.text.trim(),
        merchantId: merchantId,
        pinCode: pinController.text.trim(),
        partyType: partyTypeUpperCase, // Dynamic partyType from arguments
      );

      // Call API
      final response = await _ledgerApi.createLedger(ledger);

      // Show success message
      AdvancedErrorService.showSuccess(
        response.message,
        type: SuccessType.snackbar,
      );

      // Navigate back to previous screens first (close both form and contact list)
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }

      // Refresh ledger controller after navigation to ensure UI is ready
      // Small delay to let navigation complete
      await Future.delayed(const Duration(milliseconds: 300));

      try {
        final ledgerController = Get.find<LedgerController>();
        debugPrint('🔄 Refreshing ledger data after customer creation...');
        await ledgerController.fetchAllLedgers();
        debugPrint('✅ Ledger data refreshed successfully');
      } catch (e) {
        debugPrint('⚠️ Could not refresh ledger controller: $e');
      }
    } catch (e) {
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear all fields
  void clearForm() {
    nameController.clear();
    phoneController.clear();
    areaController.clear();
    pinController.clear();
    addressController.clear();
    interestRateController.clear();
    creditDaysController.clear();
    openingBalanceController.clear();
    creditLimitController.clear();
    selectedCreditDays.value = null;
    selectedCreditLimit.value = null;
    selectedInterestType.value = 'YEARLY';
    selectedTransactionType.value = 'IN';
  }
}
