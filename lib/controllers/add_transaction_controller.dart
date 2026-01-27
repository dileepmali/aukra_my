import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../models/transaction_model.dart';
import '../core/api/ledger_transaction_api.dart';
import '../core/api/image_upload_api.dart';
import '../core/api/auth_storage.dart';
import '../core/database/repositories/transaction_repository.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../core/services/rate_limiter_service.dart';
import '../core/utils/secure_logger.dart';
import '../core/services/duplicate_prevention_service.dart';

class AddTransactionController extends GetxController {
  // ============================================================
  // AMOUNT VALIDATION CONSTANTS
  // ============================================================
  /// Maximum digits allowed for amount (8 digits = 9,99,99,999)
  static const int maxAmountDigits = 8;

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
  final selectedNoteChip = ''.obs; // Selected quick note chip (Cash, UPI, Goods)

  // Amount warning spam prevention
  DateTime? _lastAmountWarningTime;

  // Arguments from navigation
  int? ledgerId;
  int? transactionId; // For edit mode
  String? customerName;
  String? customerLocation; // Customer area/location
  double closingBalance = 0.0; // Closing balance amount
  String accountType = 'CUSTOMER'; // CUSTOMER or SUPPLIER

  // API instances
  final LedgerTransactionApi _transactionApi = LedgerTransactionApi();
  final ImageUploadApi _imageUploadApi = ImageUploadApi();

  // 🗄️ Offline-first repository
  TransactionRepository? _transactionRepository;
  TransactionRepository get transactionRepository {
    if (_transactionRepository == null) {
      if (Get.isRegistered<TransactionRepository>()) {
        _transactionRepository = Get.find<TransactionRepository>();
        debugPrint('✅ AddTransactionController: TransactionRepository found via GetX');
      } else {
        debugPrint('⚠️ AddTransactionController: TransactionRepository NOT registered - creating new instance');
        _transactionRepository = TransactionRepository();
      }
    }
    return _transactionRepository!;
  }

  // Check if device is online
  bool get isOnline {
    if (!Get.isRegistered<ConnectivityService>()) return true;
    return ConnectivityService.instance.isConnected.value;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    _setupListeners();
  }

  @override
  void onReady() {
    super.onReady();
    // ✅ Auto-focus amount field when screen opens (after widget is rendered)
    // Small delay ensures keyboard opens smoothly after screen transition
    Future.delayed(const Duration(milliseconds: 300), () {
      amountFocusNode.requestFocus();
    });
  }

  void _initializeData() {
    // Get arguments passed from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    ledgerId = args?['ledgerId'] as int?;
    transactionId = args?['transactionId'] as int?;
    customerName = args?['customerName'] as String? ?? 'Customer';
    customerLocation = args?['customerLocation'] as String?;
    closingBalance = (args?['closingBalance'] as num?)?.toDouble() ?? 0.0;
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
      // ✅ In ADD mode, check for defaultTransactionType argument
      final defaultType = args?['defaultTransactionType'] as String?;
      if (defaultType != null && (defaultType == 'IN' || defaultType == 'OUT')) {
        selectedType.value = defaultType;
        debugPrint('🔧 Pre-selected transaction type: $defaultType');
      }
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
    var parts = sanitized.split('.');
    if (parts.length > 2) {
      sanitized = '${parts[0]}.${parts.sublist(1).join('')}';
      parts = sanitized.split('.');
    }

    // ✅ LIMIT integer part to maxAmountDigits (8 digits)
    String integerPart = parts[0];
    if (integerPart.length > maxAmountDigits) {
      // Show warning and truncate
      _showAmountWarning(integerPart.length);
      integerPart = integerPart.substring(0, maxAmountDigits);

      // Rebuild sanitized with truncated integer part
      if (parts.length == 2) {
        sanitized = '$integerPart.${parts[1]}';
      } else {
        sanitized = integerPart;
      }
      parts = sanitized.split('.');
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

  /// Show amount limit warning (with spam prevention - once per 3 seconds)
  void _showAmountWarning(int digitCount) {
    final now = DateTime.now();

    // Prevent spam - show only once per 3 seconds
    if (_lastAmountWarningTime != null &&
        now.difference(_lastAmountWarningTime!).inSeconds < 3) {
      return;
    }

    _lastAmountWarningTime = now;

    AdvancedErrorService.showError(
      'Max $maxAmountDigits digits allowed',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.validation,
      customDuration: Duration(seconds: 2),
    );
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

    // ✅ NEW: Validate note field - REQUIRED
    if (noteController.text.trim().isEmpty) {
      return 'Please add a note for this transaction';
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
    // 🛡️ SECURITY: Rate limit check - Prevent spam transactions
    final rateLimitKey = 'create_transaction_${ledgerId}';
    if (!RateLimiter.isAllowed(
      rateLimitKey,
      maxAttempts: RateLimitConfig.createTransaction.maxAttempts,
      duration: RateLimitConfig.createTransaction.duration,
    )) {
      final cooldown = RateLimiter.getRemainingCooldown(
        rateLimitKey,
        maxAttempts: RateLimitConfig.createTransaction.maxAttempts,
        duration: RateLimitConfig.createTransaction.duration,
      );

      AdvancedErrorService.showError(
        'Too many transactions! Please wait ${RateLimiter.formatCooldown(cooldown)}.',
        severity: ErrorSeverity.high,
        category: ErrorCategory.validation,
        customDuration: Duration(seconds: 5),
      );
      return;
    }

    // ✅ Validation is now done in the screen BEFORE PIN dialog opens
    // No need to validate again here

    // Prevent double submission
    if (isSubmitting.value) {
      SecureLogger.warning('Already submitting transaction, ignoring duplicate request');
      return;
    }

    isSubmitting.value = true;

    // 🛡️ SECURITY: Duplicate prevention check
    final duplicateKey = DuplicatePrevention.generateTransactionKey(
      ledgerId: ledgerId!,
      amount: double.parse(amountController.text.trim()),
      type: selectedType.value,
    );

    if (DuplicatePrevention.isPending(duplicateKey)) {
      SecureLogger.warning('Duplicate transaction detected and prevented');
      AdvancedErrorService.showError(
        'Transaction already in progress. Please wait.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      isSubmitting.value = false;
      return;
    }

    if (DuplicatePrevention.wasRecentlyCompleted(duplicateKey)) {
      final timeSince = DuplicatePrevention.getTimeSinceCompleted(duplicateKey);
      SecureLogger.warning('Recently completed transaction detected: ${timeSince?.inSeconds}s ago');

      AdvancedErrorService.showError(
        'This transaction was just completed. Please wait before submitting again.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      isSubmitting.value = false;
      return;
    }

    // Mark as pending
    DuplicatePrevention.markPending(duplicateKey);

    try {
      // Get merchant ID from auth storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        throw Exception('Merchant ID not found. Please login again.');
      }

      // Prepare transaction data
      final transactionAmount = double.parse(amountController.text.trim());
      final transactionDate = selectedDate.value.toUtc().toIso8601String();
      final comments = noteController.text.trim();

      debugPrint('💰 Creating transaction (Online: $isOnline):');
      debugPrint('   - Ledger ID: $ledgerId');
      debugPrint('   - Merchant ID: $merchantId');
      debugPrint('   - Amount: $transactionAmount');
      debugPrint('   - Type: ${selectedType.value}');
      debugPrint('   - Account Type: $accountType');
      debugPrint('   - Date: $transactionDate');

      // 🗄️ OFFLINE-FIRST: Check connectivity
      if (!isOnline) {
        debugPrint('📴 OFFLINE MODE - Saving transaction locally...');

        // Create transaction model (without images for offline)
        final transaction = TransactionModel(
          ledgerId: ledgerId!,
          merchantId: merchantId,
          transactionAmount: transactionAmount,
          transactionType: selectedType.value,
          transactionDate: transactionDate,
          comments: comments,
          partyMerchantAction: 'VIEW',
          uploadedKeys: null, // Images not supported offline
          securityKey: pin,
        );

        // Save to local DB and queue for sync
        await transactionRepository.createTransaction(transaction);

        // Success - Show offline success message
        AdvancedErrorService.showSuccess(
          'Transaction saved offline. Will sync when online.',
          type: SuccessType.snackbar,
          customDuration: Duration(seconds: 3),
        );

        // Navigate back after delay
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true);
        });
        return;
      }

      // 🌐 ONLINE MODE - Upload images and call API
      List<int> uploadedKeys = [];
      if (selectedImages.isNotEmpty) {
        debugPrint('📤 Uploading ${selectedImages.length} images...');
        final imageFiles = selectedImages.map((xfile) => File(xfile.path)).toList();
        uploadedKeys = await _imageUploadApi.uploadMultipleImages(imageFiles);
        debugPrint('✅ Uploaded ${uploadedKeys.length} images: $uploadedKeys');
      }

      // Create transaction model
      final transaction = TransactionModel(
        ledgerId: ledgerId!,
        merchantId: merchantId,
        transactionAmount: transactionAmount,
        transactionType: selectedType.value,
        transactionDate: transactionDate,
        comments: comments,
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
      SecureLogger.error('Transaction Error: $e');

      // 🗄️ OFFLINE FALLBACK: If network error, save locally
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('socket') ||
          errorStr.contains('network') ||
          errorStr.contains('connection') ||
          errorStr.contains('internet')) {
        debugPrint('📴 Network error - falling back to offline save...');

        try {
          final merchantId = await AuthStorage.getMerchantId();
          final transactionAmount = double.parse(amountController.text.trim());
          final transactionDate = selectedDate.value.toUtc().toIso8601String();
          final comments = noteController.text.trim();

          final transaction = TransactionModel(
            ledgerId: ledgerId!,
            merchantId: merchantId ?? 0,
            transactionAmount: transactionAmount,
            transactionType: selectedType.value,
            transactionDate: transactionDate,
            comments: comments,
            partyMerchantAction: 'VIEW',
            uploadedKeys: null,
            securityKey: pin,
          );

          await transactionRepository.createTransaction(transaction);

          AdvancedErrorService.showSuccess(
            'Saved offline. Will sync when online.',
            type: SuccessType.snackbar,
            customDuration: Duration(seconds: 3),
          );

          Future.delayed(Duration(seconds: 1), () {
            Get.back(result: true);
          });
          return;
        } catch (offlineError) {
          SecureLogger.error('Offline save failed: $offlineError');
        }
      }

      // Show error using AdvancedErrorService
      AdvancedErrorService.showError(
        e.toString().replaceAll('Exception: ', ''),
        severity: ErrorSeverity.high,
        category: ErrorCategory.network,
        customDuration: Duration(seconds: 3),
      );
    } finally {
      // Remove from pending tracking
      DuplicatePrevention.removePending(duplicateKey);
      isSubmitting.value = false;
    }
  }

  // Update existing transaction - OFFLINE FIRST
  Future<void> updateTransaction(String pin) async {
    // ✅ Validation is now done in the screen BEFORE PIN dialog opens
    // No need to validate again here

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
      // Upload images if any new images are added (only when online)
      List<int> uploadedKeys = [];
      final currentlyOnline = isOnline; // Use the getter

      if (selectedImages.isNotEmpty && currentlyOnline) {
        debugPrint('📤 Uploading ${selectedImages.length} images...');
        final imageFiles = selectedImages.map((xfile) => File(xfile.path)).toList();
        uploadedKeys = await _imageUploadApi.uploadMultipleImages(imageFiles);
        debugPrint('✅ Uploaded ${uploadedKeys.length} images: $uploadedKeys');
      } else if (selectedImages.isNotEmpty && !currentlyOnline) {
        debugPrint('📴 Offline - Images will be uploaded when online');
        // TODO: Queue images for upload when online
      }

      // Prepare transaction data
      final transactionAmount = double.parse(amountController.text.trim());
      final transactionDate = selectedDate.value.toUtc().toIso8601String();
      final comments = noteController.text.trim();

      debugPrint('💰 Updating transaction (Online: $currentlyOnline):');
      debugPrint('   - Transaction ID: $transactionId');
      debugPrint('   - Amount: $transactionAmount');
      debugPrint('   - Date: $transactionDate');

      // Use Repository for OFFLINE-FIRST update
      final success = await transactionRepository.updateTransaction(
        transactionId: transactionId!,
        transactionAmount: transactionAmount,
        transactionDate: transactionDate,
        comments: comments,
        uploadedKeys: uploadedKeys.isNotEmpty ? uploadedKeys : null,
        securityKey: pin,
      );

      if (success) {
        // Show success message
        AdvancedErrorService.showSuccess(
          currentlyOnline ? 'Transaction updated successfully' : 'Transaction updated locally. Will sync when online.',
          type: SuccessType.snackbar,
          customDuration: Duration(seconds: 2),
        );

        // Navigate back after delay
        Future.delayed(Duration(seconds: 1), () {
          Get.back(result: true); // Return true to indicate success
        });
      }
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
