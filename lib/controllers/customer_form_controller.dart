import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/ledger_api.dart';
import '../core/api/auth_storage.dart';
import '../models/ledger_model.dart';
import '../core/utils/formatters.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import 'ledger_controller.dart';
import '../presentations/widgets/dialogs/ledger_update_comparison_dialog.dart';
import '../core/services/duplicate_prevention_service.dart';
import '../core/utils/secure_logger.dart';

class CustomerFormController extends GetxController {
  // Text controllers - for both ledger and merchant modes
  late TextEditingController nameController; // Also used for businessName in merchant mode
  late TextEditingController phoneController; // Also used for backupPhoneNumber in merchant mode
  late TextEditingController areaController;
  late TextEditingController pinController;
  late TextEditingController addressController;
  late TextEditingController interestRateController;
  late TextEditingController creditDaysController;
  late TextEditingController openingBalanceController;
  late TextEditingController creditLimitController;

  // Merchant-specific controllers
  late TextEditingController categoryController;
  late TextEditingController emailController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;

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

  // Merchant-specific focus nodes
  late FocusNode categoryFocusNode;
  late FocusNode emailFocusNode;
  late FocusNode cityFocusNode;
  late FocusNode stateFocusNode;
  late FocusNode countryFocusNode;
  late FocusNode latitudeFocusNode;
  late FocusNode longitudeFocusNode;

  // Observable for quick selection chips
  var selectedCreditDays = Rx<int?>(null);
  var selectedCreditLimit = Rx<double?>(null);
  var selectedInterestType = 'YEARLY'.obs; // YEARLY or MONTHLY
  var selectedTransactionType = 'IN'.obs; // IN or OUT

  // Loading state
  var isLoading = false.obs;

  // Mode flags
  final bool isEditMode;
  final int? ledgerId;

  // Store original data for comparison
  Map<String, dynamic>? originalData;

  // API Service
  final LedgerApi _ledgerApi = LedgerApi();

  // Initial values from contact (for add mode)
  final String? initialName;
  final String? initialPhone;
  final String? partyType; // 'customer', 'supplier', 'employer'

  // Initial ledger data (for edit mode)
  final String? initialArea;
  final String? initialPinCode;
  final String? initialAddress;
  final String? initialCity;
  final String? initialCountry;
  final int? initialCreditDay;
  final double? initialCreditLimit;
  final double? initialInterestRate;
  final String? initialInterestType;
  final double? initialOpeningBalance;
  final String? initialTransactionType;

  CustomerFormController({
    this.initialName,
    this.initialPhone,
    this.partyType,
    this.isEditMode = false,
    this.ledgerId,
    this.initialArea,
    this.initialPinCode,
    this.initialAddress,
    this.initialCity,
    this.initialCountry,
    this.initialCreditDay,
    this.initialCreditLimit,
    this.initialInterestRate,
    this.initialInterestType,
    this.initialOpeningBalance,
    this.initialTransactionType,
  });

  @override
  void onInit() {
    super.onInit();

    debugPrint('🔧 CustomerFormController Init - Edit Mode: $isEditMode');
    debugPrint('📋 Initial Data: name=$initialName, phone=$initialPhone, area=$initialArea');

    // Initialize all controllers with data
    nameController = TextEditingController(text: initialName ?? '');
    phoneController = TextEditingController(text: initialPhone ?? '');
    areaController = TextEditingController(text: initialArea ?? '');
    pinController = TextEditingController(text: initialPinCode ?? '');
    addressController = TextEditingController(text: initialAddress ?? '');

    // Ledger-specific fields
    interestRateController = TextEditingController(
      text: initialInterestRate != null ? initialInterestRate!.toString() : ''
    );
    creditDaysController = TextEditingController(
      text: initialCreditDay != null ? initialCreditDay!.toString() : ''
    );
    openingBalanceController = TextEditingController(
      text: initialOpeningBalance != null ? initialOpeningBalance!.toStringAsFixed(2) : ''
    );
    creditLimitController = TextEditingController(
      text: initialCreditLimit != null ? initialCreditLimit!.toStringAsFixed(2) : ''
    );

    // Unused merchant controllers (initialize empty)
    categoryController = TextEditingController();
    emailController = TextEditingController();
    cityController = TextEditingController();
    stateController = TextEditingController();
    countryController = TextEditingController();
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();

    // Set initial selection values
    if (initialInterestType != null) {
      selectedInterestType.value = initialInterestType!;
    }
    if (initialTransactionType != null) {
      selectedTransactionType.value = initialTransactionType!;
    }

    // Store original data for comparison (only in edit mode)
    if (isEditMode) {
      originalData = {
        'name': initialName ?? '',
        'mobileNumber': initialPhone ?? '',
        'area': initialArea ?? '',
        'pinCode': initialPinCode ?? '',
        'address': initialAddress ?? '',
        'creditDay': initialCreditDay ?? 0,
        'creditLimit': initialCreditLimit ?? 0.0,
        'interestRate': initialInterestRate ?? 0.0,
        'openingBalance': initialOpeningBalance ?? 0.0,
      };
      debugPrint('📦 Original data stored for comparison');
      debugPrint('   initialCreditDay received: $initialCreditDay');
      debugPrint('   creditDaysController.text: ${creditDaysController.text}');
    }

    debugPrint('✅ Controllers initialized with values');
    debugPrint('   Name: ${nameController.text}');
    debugPrint('   Phone: ${phoneController.text}');
    debugPrint('   Area: ${areaController.text}');
    debugPrint('   Credit Days: ${creditDaysController.text}');
    debugPrint('   Credit Limit: ${creditLimitController.text}');

    // Initialize all focus nodes
    nameFocusNode = FocusNode();
    phoneFocusNode = FocusNode();
    areaFocusNode = FocusNode();
    pinFocusNode = FocusNode();
    addressFocusNode = FocusNode();
    interestRateFocusNode = FocusNode();
    creditDaysFocusNode = FocusNode();
    openingBalanceFocusNode = FocusNode();
    creditLimitFocusNode = FocusNode();
    categoryFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    cityFocusNode = FocusNode();
    stateFocusNode = FocusNode();
    countryFocusNode = FocusNode();
    latitudeFocusNode = FocusNode();
    longitudeFocusNode = FocusNode();

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
      final numericText = text.replaceAll(RegExp(r'\s*Days?\s*', caseSensitive: false), '').trim();
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
    categoryController.dispose();
    emailController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();

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
    categoryFocusNode.dispose();
    emailFocusNode.dispose();
    cityFocusNode.dispose();
    stateFocusNode.dispose();
    countryFocusNode.dispose();
    latitudeFocusNode.dispose();
    longitudeFocusNode.dispose();

    super.onClose();
  }

  // Select credit days from quick selection
  void selectCreditDays(int days) {
    selectedCreditDays.value = days;
    final suffix = days == 1 ? ' Day' : ' Days';
    creditDaysController.text = '$days$suffix';
    debugPrint('✅ Credit Days Selected: $days');
    debugPrint('   Controller text set to: "${creditDaysController.text}"');
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

  // Validate and submit form (Create or Update)
  Future<void> submitForm(BuildContext context) async {
    debugPrint('📝 Submit Form - Edit Mode: $isEditMode, Ledger ID: $ledgerId');
    debugPrint('📋 Current Controller Values:');
    debugPrint('   nameController: "${nameController.text}"');
    debugPrint('   phoneController: "${phoneController.text}"');
    debugPrint('   creditDaysController: "${creditDaysController.text}"');
    debugPrint('   creditLimitController: "${creditLimitController.text}"');
    debugPrint('   openingBalanceController: "${openingBalanceController.text}"');

    // Validate required fields
    if (nameController.text.trim().isEmpty) {
      AdvancedErrorService.showError(
        isEditMode ? 'Please enter name' : 'Please enter customer name',
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

    // 🛡️ DUPLICATE CHECK: Check if person already exists (by name OR phone)
    if (!isEditMode) {
      try {
        final ledgerController = Get.find<LedgerController>();

        final nameToCheck = nameController.text.trim().toLowerCase();
        final phoneToCheck = phone; // Already cleaned 10-digit phone

        debugPrint('🔍 ========== DUPLICATE CHECK START ==========');
        debugPrint('   Name to check: "$nameToCheck"');
        debugPrint('   Phone to check: "$phoneToCheck"');
        debugPrint('   Total ledgers: ${ledgerController.allLedgers.length}');
        debugPrint('🔍 ========== DUPLICATE CHECK END ==========');

        // Check if name OR phone already exists in any ledger
        final existingByName = ledgerController.allLedgers.firstWhereOrNull(
          (ledger) => ledger.name.toLowerCase() == nameToCheck,
        );

        final existingByPhone = ledgerController.allLedgers.firstWhereOrNull(
          (ledger) {
            final ledgerPhone = (ledger.mobileNumber ?? '').replaceAll(RegExp(r'[^0-9]'), '');
            // Handle +91 prefix
            final cleanLedgerPhone = ledgerPhone.length == 12 && ledgerPhone.startsWith('91')
                ? ledgerPhone.substring(2)
                : ledgerPhone;
            return cleanLedgerPhone == phoneToCheck;
          },
        );

        // Check name duplicate first
        if (existingByName != null) {
          final existingPartyType = existingByName.partyType.toUpperCase();
          String existingTypeName;
          String otherOptions;

          switch (existingPartyType) {
            case 'CUSTOMER':
              existingTypeName = 'Customer';
              otherOptions = 'Supplier or Employee';
              break;
            case 'SUPPLIER':
              existingTypeName = 'Supplier';
              otherOptions = 'Customer or Employee';
              break;
            case 'EMPLOYEE':
              existingTypeName = 'Employee';
              otherOptions = 'Customer or Supplier';
              break;
            default:
              existingTypeName = existingPartyType;
              otherOptions = 'other category';
          }

          debugPrint('⚠️ Name duplicate: ${existingByName.name} exists as $existingTypeName');
          AdvancedErrorService.showError(
            'Already Add $existingTypeName. Try $otherOptions',
            severity: ErrorSeverity.medium,
            category: ErrorCategory.validation,
          );
          return;
        }

        // Check phone duplicate
        if (existingByPhone != null) {
          final existingPartyType = existingByPhone.partyType.toUpperCase();
          String existingTypeName;
          String otherOptions;

          switch (existingPartyType) {
            case 'CUSTOMER':
              existingTypeName = 'Customer';
              otherOptions = 'Supplier or Employee';
              break;
            case 'SUPPLIER':
              existingTypeName = 'Supplier';
              otherOptions = 'Customer or Employee';
              break;
            case 'EMPLOYEE':
              existingTypeName = 'Employee';
              otherOptions = 'Customer or Supplier';
              break;
            default:
              existingTypeName = existingPartyType;
              otherOptions = 'other category';
          }

          debugPrint('⚠️ Phone duplicate: ${existingByPhone.name} exists as $existingTypeName');
          AdvancedErrorService.showError(
            'Number Already Add $existingTypeName. Try $otherOptions',
            severity: ErrorSeverity.medium,
            category: ErrorCategory.validation,
          );
          return;
        }
      } catch (e) {
        debugPrint('⚠️ Could not check for duplicates: $e');
        // Continue with submission if duplicate check fails
      }
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

    // 🛡️ SECURITY: Duplicate ledger prevention (only for create mode)
    if (!isEditMode) {
      final duplicateKey = DuplicatePrevention.generateLedgerKey(
        name: nameController.text.trim(),
        mobileNumber: phone,
      );

      if (DuplicatePrevention.isPending(duplicateKey)) {
        SecureLogger.warning('Duplicate ledger creation detected and prevented');
        AdvancedErrorService.showError(
          'Ledger creation already in progress. Please wait.',
          severity: ErrorSeverity.medium,
          category: ErrorCategory.validation,
        );
        return;
      }

      if (DuplicatePrevention.wasRecentlyCompleted(duplicateKey)) {
        final timeSince = DuplicatePrevention.getTimeSinceCompleted(duplicateKey);
        SecureLogger.warning('Recently completed ledger detected: ${timeSince?.inSeconds}s ago');

        AdvancedErrorService.showError(
          'This ledger was just created. Please check your customer list.',
          severity: ErrorSeverity.medium,
          category: ErrorCategory.validation,
        );
        return;
      }

      // Mark as pending
      DuplicatePrevention.markPending(duplicateKey);
    }

    try {
      // In edit mode, show comparison dialog first
      if (isEditMode && originalData != null) {
        // Parse credit days by removing "Day" or "Days" suffix
        final creditDayText = creditDaysController.text.trim().replaceAll(RegExp(r'\s*Days?\s*', caseSensitive: false), '').trim();
        debugPrint('🔍 Parsing Credit Days:');
        debugPrint('   Raw text: "${creditDaysController.text.trim()}"');
        debugPrint('   After removing suffix: "$creditDayText"');
        final creditDay = int.tryParse(creditDayText) ?? 0;
        debugPrint('   Parsed int: $creditDay');

        final creditLimit = double.tryParse(
              creditLimitController.text.trim().replaceAll(',', ''),
            ) ??
            0.0;

        final interestRate = double.tryParse(
              interestRateController.text.trim(),
            ) ??
            0.0;

        final openingBalance = double.tryParse(
              openingBalanceController.text.trim().replaceAll(',', ''),
            ) ??
            0.0;

        // Create new data map
        final newData = {
          'name': nameController.text.trim(),
          'mobileNumber': phoneController.text.trim(),
          'area': areaController.text.trim(),
          'pinCode': pinController.text.trim(),
          'address': addressController.text.trim(),
          'creditDay': creditDay,
          'creditLimit': creditLimit,
          'interestRate': interestRate,
          'interestType': selectedInterestType.value,
          'partyType': partyType ?? 'CUSTOMER',
          'openingBalance': openingBalance,
          'currentBalance': openingBalance,
          'transactionType': selectedTransactionType.value,
          'merchantId': await AuthStorage.getMerchantId() ?? 0,
        };

        debugPrint('📊 Showing comparison dialog');
        debugPrint('   Old Data: $originalData');
        debugPrint('   New Data: $newData');
        debugPrint('');
        debugPrint('📋 Field by Field Comparison:');
        debugPrint('   Name: "${originalData!['name']}" -> "${newData['name']}"');
        debugPrint('   Mobile: "${originalData!['mobileNumber']}" -> "${newData['mobileNumber']}"');
        debugPrint('   Area: "${originalData!['area']}" -> "${newData['area']}"');
        debugPrint('   Pin: "${originalData!['pinCode']}" -> "${newData['pinCode']}"');
        debugPrint('   Address: "${originalData!['address']}" -> "${newData['address']}"');
        debugPrint('   Credit Days: ${originalData!['creditDay']} -> ${newData['creditDay']}');
        debugPrint('   Credit Limit: ${originalData!['creditLimit']} -> ${newData['creditLimit']}');
        debugPrint('   Interest Rate: ${originalData!['interestRate']} -> ${newData['interestRate']}');
        debugPrint('   Opening Balance: ${originalData!['openingBalance']} -> ${newData['openingBalance']}');
        debugPrint('');

        // Show comparison dialog
        final confirmed = await LedgerUpdateComparisonDialog.show(
          context: context,
          oldData: originalData!,
          newData: newData,
          ledgerId: ledgerId!,
        );

        // If user cancels, return
        if (confirmed != true) {
          debugPrint('❌ User cancelled update');
          return;
        }

        debugPrint('✅ User confirmed update, proceeding with API call');
      }

      isLoading.value = true;

      // Get merchant ID from storage
      final merchantId = await AuthStorage.getMerchantId();
      debugPrint('🔑 ========== MERCHANT ID CHECK ==========');
      debugPrint('   merchantId from storage: $merchantId');

      if (merchantId == null) {
        AdvancedErrorService.showError(
          'Merchant ID not found. Please login again.',
          severity: ErrorSeverity.high,
          category: ErrorCategory.authentication,
        );
        isLoading.value = false;
        return;
      }

      // Also check what merchant data is stored
      final merchantData = await AuthStorage.getMerchantData();
      debugPrint('   Stored merchant data: $merchantData');
      debugPrint('========================================');

      // Parse numeric values with defaults
      final creditLimit = double.tryParse(
            creditLimitController.text.trim().replaceAll(',', ''),
          ) ??
          0.0;

      // Parse credit days by removing "Day" or "Days" suffix
      final rawCreditDays = creditDaysController.text.trim();
      // 🔥 FIX: Use Days? (optional s) instead of (Day|Days) to avoid leaving "s" behind
      final creditDayText = rawCreditDays.replaceAll(RegExp(r'\s*Days?\s*', caseSensitive: false), '').trim();
      debugPrint('🔍 Credit Days Parsing:');
      debugPrint('   Raw: "$rawCreditDays"');
      debugPrint('   After regex: "$creditDayText"');
      final creditDay = int.tryParse(creditDayText) ?? 0;
      debugPrint('   Parsed: $creditDay');

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

      // Debug: Print all values before creating ledger
      debugPrint('📋 Creating Ledger with values:');
      debugPrint('   name: "${nameController.text.trim()}"');
      debugPrint('   phone: "$phone"');
      debugPrint('   area: "${areaController.text.trim()}"');
      debugPrint('   address: "${addressController.text.trim()}"');
      debugPrint('   pinCode: "${pinController.text.trim()}"');
      debugPrint('   creditDay: $creditDay');
      debugPrint('   creditLimit: $creditLimit');
      debugPrint('   interestRate: $interestRate');
      debugPrint('   openingBalance: $openingBalance');

      // ✅ KHATABOOK LOGIC: Apply sign based on transactionType
      // OUT = Customer owes you (positive opening balance)
      // IN = You owe customer (negative opening balance)
      final signedCurrentBalance = selectedTransactionType.value == 'IN'
          ? -openingBalance  // Negative: You owe customer
          : openingBalance;  // Positive: Customer owes you

      debugPrint('💰 Opening Balance Sign Logic:');
      debugPrint('   Raw opening balance: ₹$openingBalance');
      debugPrint('   Transaction type: ${selectedTransactionType.value}');
      debugPrint('   Signed current balance: ₹$signedCurrentBalance');

      // Create ledger model
      final ledger = LedgerModel(
        name: nameController.text.trim(),
        creditLimit: creditLimit,
        creditDay: creditDay,
        interestType: selectedInterestType.value,
        openingBalance: openingBalance, // Store absolute value
        currentBalance: signedCurrentBalance, // ✅ FIXED: Store signed value based on transactionType
        transactionType: selectedTransactionType.value,
        interestRate: interestRate,
        mobileNumber: phone,
        area: areaController.text.trim(),
        address: addressController.text.trim(),
        merchantId: merchantId,
        pinCode: pinController.text.trim(),
        partyType: partyTypeUpperCase, // Dynamic partyType from arguments
      );

      debugPrint('📦 Ledger toJson(): ${ledger.toJson()}');

      // Call appropriate API based on mode
      final response = isEditMode && ledgerId != null
          ? await _ledgerApi.updateLedger(ledgerId: ledgerId!, ledger: ledger)
          : await _ledgerApi.createLedger(ledger);

      // Show success message
      AdvancedErrorService.showSuccess(
        response.message,
        type: SuccessType.snackbar,
      );

      // Navigate back - different behavior for edit vs create
      if (context.mounted) {
        if (isEditMode) {
          // Edit mode - just go back once (to ledger dashboard)
          Navigator.of(context).pop();
        } else {
          // Create mode - go back twice (close both form and contact list)
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      }

      // Refresh ledger controller after navigation to ensure UI is ready
      // Small delay to let navigation complete
      await Future.delayed(const Duration(milliseconds: 300));

      try {
        final ledgerController = Get.find<LedgerController>();
        debugPrint('🔄 Refreshing ledger data after ${isEditMode ? "update" : "creation"}...');
        await ledgerController.fetchAllLedgers();
        debugPrint('✅ Ledger data refreshed successfully');
      } catch (e) {
        debugPrint('⚠️ Could not refresh ledger controller: $e');
      }
    } catch (e) {
      SecureLogger.error('Ledger submission error: $e');
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
      );
    } finally {
      // 🛡️ SECURITY: Remove from pending tracking (only for create mode)
      if (!isEditMode) {
        final phone = phoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
        final duplicateKey = DuplicatePrevention.generateLedgerKey(
          name: nameController.text.trim(),
          mobileNumber: phone,
        );
        DuplicatePrevention.removePending(duplicateKey);
      }
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
