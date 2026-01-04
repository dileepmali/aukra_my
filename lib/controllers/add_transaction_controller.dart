import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/transaction_model.dart';
import '../core/api/ledger_transaction_api.dart';
import '../core/api/image_upload_api.dart';
import '../core/api/auth_storage.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';

class AddTransactionController extends GetxController {
  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // Focus nodes
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();

  // Reactive variables
  final selectedType = 'OUT'.obs; // "IN" or "OUT"
  final selectedDate = DateTime.now().obs;
  final selectedImages = <XFile>[].obs;
  final isSubmitting = false.obs;
  final isEditMode = false.obs; // Track if we're in edit mode

  // Arguments from navigation
  int? ledgerId;
  int? transactionId; // For edit mode
  String? customerName;
  String? customerLocation;
  String accountType = 'CUSTOMER'; // CUSTOMER or SUPPLIER

  // API instances
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();
  final ImageUploadApi _imageUploadApi = ImageUploadApi();

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupListeners();
  }

  void _initializeData() {
    // Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    ledgerId = args?['ledgerId'] as int?;
    transactionId = args?['transactionId'] as int?;
    customerName = args?['customerName'] as String? ?? 'Customer';
    customerLocation = args?['customerLocation'] as String? ?? 'Location';
    accountType = args?['accountType'] as String? ?? 'CUSTOMER';

    // Check if we're in edit mode
    isEditMode.value = transactionId != null;

    // Pre-fill data if in edit mode
    if (isEditMode.value) {
      final amount = args?['amount'] as double?;
      final type = args?['transactionType'] as String?;
      final date = args?['transactionDate'] as String?;
      final note = args?['comments'] as String?;

      if (amount != null) {
        amountController.text = amount.toStringAsFixed(2);
      }
      if (type != null) {
        selectedType.value = type;
      }
      if (date != null) {
        try {
          selectedDate.value = DateTime.parse(date);
        } catch (e) {
          debugPrint('⚠️ Failed to parse date: $e');
        }
      }
      if (note != null && note.isNotEmpty) {
        noteController.text = note;
      }

      debugPrint('🔧 Initialized in EDIT mode');
      debugPrint('   - Transaction ID: $transactionId');
    } else {
      debugPrint('🔧 Initialized in ADD mode');
    }

    debugPrint('   - Ledger ID: $ledgerId');
    debugPrint('   - Customer: $customerName');
    debugPrint('   - Account Type: $accountType');
  }

  void _setupListeners() {
    // Add listener to format amount input while typing
    amountController.addListener(_onAmountChanged);
    // Add listener to format with .00 when focus is lost
    amountFocusNode.addListener(_onAmountFocusChanged);
  }

  void _onAmountFocusChanged() {
    if (!amountFocusNode.hasFocus) {
      // Delay formatting to avoid keyboard flickering
      Future.delayed(Duration(milliseconds: 100), () {
        if (!amountFocusNode.hasFocus) {
          final text = amountController.text;
          if (text.isNotEmpty) {
            final parts = text.split('.');
            String formattedText = text;

            if (parts.length == 1) {
              // No decimal point, add .00
              formattedText = '$text.00';
            } else if (parts.length == 2 && parts[1].length == 1) {
              // One decimal place, add extra 0
              formattedText = '${text}0';
            }

            // Only update if text actually changed
            if (formattedText != text) {
              amountController.value = TextEditingValue(
                text: formattedText,
                selection: TextSelection.collapsed(offset: formattedText.length),
              );
            }
          }
        }
      });
    }
  }

  void _onAmountChanged() {
    final text = amountController.text;
    if (text.isEmpty) return;

    // Remove all non-digit and non-decimal characters
    String sanitized = text.replaceAll(RegExp(r'[^\d.]'), '');

    // Handle multiple decimal points - keep only the first one
    final parts = sanitized.split('.');
    if (parts.length > 2) {
      sanitized = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit to 2 decimal places
    if (parts.length == 2 && parts[1].length > 2) {
      sanitized = '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    // Update text only if it changed
    if (text != sanitized) {
      amountController.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }
  }

  // Change transaction type
  void setTransactionType(String type) {
    selectedType.value = type;
  }

  // Select date
  void setSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  // Add images
  void addImages(List<XFile> images) {
    selectedImages.addAll(images);
  }

  // Remove image
  void removeImage(int index) {
    if (index >= 0 && index < selectedImages.length) {
      selectedImages.removeAt(index);
    }
  }

  // Validate form
  String? validateForm() {
    if (ledgerId == null) {
      return 'Ledger ID not found. Please go back and try again.';
    }

    if (amountController.text.trim().isEmpty) {
      return 'Please enter transaction amount';
    }

    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      return 'Please enter valid amount';
    }

    return null; // Validation passed
  }

  // Main method to submit transaction (Create or Update)
  Future<void> submitTransaction(String pin) async {
    if (isEditMode.value) {
      await updateTransaction(pin);
    } else {
      await createTransaction(pin);
    }
  }

  // Create new transaction
  Future<void> createTransaction(String pin) async {
    // Validate form
    final validationError = validateForm();
    if (validationError != null) {
      // Show validation error using AdvancedErrorService
      AdvancedErrorService.showError(
        validationError,
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
        customDuration: Duration(seconds: 3),
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Get merchant ID from auth storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found. Please login again.');
      }

      // Upload images if any
      List<int> uploadedKeys = [];
      if (selectedImages.isNotEmpty) {
        debugPrint('📤 Uploading ${selectedImages.length} images...');
        final imageFiles = selectedImages.map((xfile) => File(xfile.path)).toList();
        uploadedKeys = await _imageUploadApi.uploadMultipleImages(imageFiles);
        debugPrint('✅ Uploaded ${uploadedKeys.length} images: $uploadedKeys');
      }

      // Prepare transaction data
      final transactionAmount = double.parse(amountController.text.trim());
      final transactionDate = selectedDate.value.toUtc().toIso8601String();
      final comments = noteController.text.trim();

      debugPrint('💰 Creating transaction:');
      debugPrint('   - Ledger ID: $ledgerId');
      debugPrint('   - Merchant ID: $merchantId');
      debugPrint('   - Amount: $transactionAmount');
      debugPrint('   - Type: ${selectedType.value}');
      debugPrint('   - Account Type: $accountType');
      debugPrint('   - Date: $transactionDate');

      // Create transaction model
      final transaction = TransactionModel(
        ledgerId: ledgerId!,
        merchantId: merchantId,
        transactionAmount: transactionAmount,
        transactionType: selectedType.value,
        transactionDate: transactionDate,
        comments: comments.isNotEmpty ? comments : null,
        partyMerchantAction: 'VIEW',
        uploadedKeys: uploadedKeys.isNotEmpty ? uploadedKeys : null,
        securityKey: pin,
      );

      // Call API
      final response = await _transactionApi.createTransaction(
        ledgerId: transaction.ledgerId,
        merchantId: transaction.merchantId,
        transactionAmount: transaction.transactionAmount,
        transactionType: transaction.transactionType,
        transactionDate: transaction.transactionDate,
        comments: transaction.comments,
        partyMerchantAction: transaction.partyMerchantAction,
        uploadedKeys: transaction.uploadedKeys,
        securityKey: transaction.securityKey,
      );

      // Success - Show success message using AdvancedErrorService
      AdvancedErrorService.showSuccess(
        response.message,
        type: SuccessType.snackbar,
        customDuration: Duration(seconds: 2),
      );

      // Navigate back after delay
      Future.delayed(Duration(seconds: 1), () {
        Get.back(result: true); // Return true to indicate success
      });
    } catch (e) {
      debugPrint('❌ Transaction Error: $e');

      // Show error using AdvancedErrorService
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
        customDuration: Duration(seconds: 3),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Update existing transaction
  Future<void> updateTransaction(String pin) async {
    // Validate form
    final validationError = validateForm();
    if (validationError != null) {
      AdvancedErrorService.showError(
        validationError,
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
        customDuration: Duration(seconds: 3),
      );
      return;
    }

    // Check if transaction ID exists
    if (transactionId == null) {
      AdvancedErrorService.showError(
        'Transaction ID not found. Cannot update.',
        severity: ErrorSeverity.high,
        category: ErrorCategory.validation,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      // Upload images if any new images are added
      List<int> uploadedKeys = [];
      if (selectedImages.isNotEmpty) {
        debugPrint('📤 Uploading ${selectedImages.length} images...');
        final imageFiles = selectedImages.map((xfile) => File(xfile.path)).toList();
        uploadedKeys = await _imageUploadApi.uploadMultipleImages(imageFiles);
        debugPrint('✅ Uploaded ${uploadedKeys.length} images: $uploadedKeys');
      }

      // Prepare transaction data
      final transactionAmount = double.parse(amountController.text.trim());
      final transactionDate = selectedDate.value.toUtc().toIso8601String();
      final comments = noteController.text.trim();

      debugPrint('💰 Updating transaction:');
      debugPrint('   - Transaction ID: $transactionId');
      debugPrint('   - Amount: $transactionAmount');
      debugPrint('   - Date: $transactionDate');

      // Call Update API
      final response = await _transactionApi.updateTransaction(
        transactionId: transactionId!,
        transactionAmount: transactionAmount,
        transactionDate: transactionDate,
        comments: comments.isNotEmpty ? comments : null,
        uploadedKeys: uploadedKeys.isNotEmpty ? uploadedKeys : null,
        securityKey: pin,
      );

      // Success - Show success message
      AdvancedErrorService.showSuccess(
        response.message,
        type: SuccessType.snackbar,
        customDuration: Duration(seconds: 2),
      );

      // Navigate back after delay
      Future.delayed(Duration(seconds: 1), () {
        Get.back(result: true); // Return true to indicate success
      });
    } catch (e) {
      debugPrint('❌ Update Transaction Error: $e');

      // Show error using AdvancedErrorService
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
        customDuration: Duration(seconds: 3),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    amountFocusNode.dispose();
    noteFocusNode.dispose();
    super.onClose();
  }
}
