import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/recovery_mobile_api_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../core/utils/formatters.dart';
import '../core/utils/dialog_transition_helper.dart';
import '../models/recovery_mobile_model.dart';
import '../presentations/widgets/dialogs/pin_verification_dialog.dart';
import '../presentations/widgets/dialogs/new_number_otp_dialog.dart';
import '../presentations/widgets/dialogs/mobile_number_dialog.dart';
import 'privacy_setting_controller.dart';

/// Professional GetX Controller for Recovery Mobile Feature
/// Manages state and business logic for changing user's recovery/backup mobile number
class RecoveryMobileController extends GetxController {
  final RecoveryMobileApiService _apiService = RecoveryMobileApiService();

  // Observable state
  final Rx<RecoveryMobileModel> _recoveryMobileModel = RecoveryMobileModel().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  RecoveryMobileModel get model => _recoveryMobileModel.value;
  String? get sessionId => model.sessionId;
  String? get currentNumber => model.currentNumber;
  String? get newRecoveryNumber => model.newRecoveryNumber;
  RecoveryMobileStatus get status => model.status;

  /// Set current number
  void setCurrentNumber(String number) {
    _recoveryMobileModel.value = model.copyWith(currentNumber: number);
    debugPrint('📱 Recovery: Current number set: ${_maskNumber(number)}');
  }

  /// Set new recovery number
  void setNewRecoveryNumber(String number) {
    _recoveryMobileModel.value = model.copyWith(newRecoveryNumber: number);
    debugPrint('📱 Recovery: New recovery number set: ${_maskNumber(number)}');
  }

  /// API 1: Send OTP to current number
  /// Endpoint: PUT /api/user/recovery-mobile/initiate-update/sendOtp
  Future<bool> sendOtpToCurrentNumber(String pin) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(RecoveryMobileStatus.sendingOtpToCurrent);

      debugPrint('🔄 Recovery Step 1: Sending OTP to current number...');

      final response = await _apiService.sendOtpToCurrentNumber(
        securityKey: pin,
      );

      if (response != null) {
        _recoveryMobileModel.value = model.copyWith(pin: pin);
        _updateStatus(RecoveryMobileStatus.otpSentToCurrent);
        debugPrint('✅ Recovery Step 1: OTP sent successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to send OTP';
        errorMessage.value = error;
        _updateStatus(RecoveryMobileStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Recovery Step 1 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(RecoveryMobileStatus.error);
      _showError('An error occurred while sending OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 2: Verify current number OTP and get sessionId
  /// Endpoint: PUT /api/user/recovery-mobile/initiate-update
  Future<bool> verifyCurrentNumberOtp(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(RecoveryMobileStatus.verifyingCurrentOtp);

      debugPrint('🔄 Recovery Step 2: Verifying current number OTP...');

      final response = await _apiService.verifyCurrentNumberOtp(otp: otp);

      if (response != null && response.sessionId > 0) {
        _recoveryMobileModel.value = model.copyWith(
          currentOtp: otp,
          sessionId: response.sessionId.toString(),
        );
        _updateStatus(RecoveryMobileStatus.currentOtpVerified);
        debugPrint('✅ Recovery Step 2: OTP verified, Session ID: ${response.sessionId}');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Invalid OTP';
        errorMessage.value = error;
        _updateStatus(RecoveryMobileStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Recovery Step 2 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(RecoveryMobileStatus.error);
      _showError('An error occurred while verifying OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 3: Send OTP to new recovery mobile number
  /// Endpoint: PUT /api/user/recovery-mobile/initiate-update/{sessionId}/new-mobile
  Future<bool> sendOtpToNewNumber(String mobileNumber) async {
    try {
      if (sessionId == null) {
        debugPrint('❌ Session ID is null, cannot proceed');
        _showError('Session expired. Please try again');
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(RecoveryMobileStatus.sendingOtpToNew);

      debugPrint('🔄 Recovery Step 3: Sending OTP to new recovery number...');

      final response = await _apiService.sendOtpToNewNumber(
        sessionId: sessionId!,
        mobileNumber: mobileNumber,
      );

      if (response != null) {
        _recoveryMobileModel.value = model.copyWith(newRecoveryNumber: mobileNumber);
        _updateStatus(RecoveryMobileStatus.otpSentToNew);
        debugPrint('✅ Recovery Step 3: OTP sent to new recovery number successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to send OTP to new number';
        errorMessage.value = error;
        _updateStatus(RecoveryMobileStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Recovery Step 3 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(RecoveryMobileStatus.error);
      _showError('An error occurred while sending OTP to new number');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 4: Verify new recovery number OTP and complete change
  /// Endpoint: PUT /api/user/recovery-mobile/initiate-update/{sessionId}/verify-otp
  Future<bool> verifyNewNumberOtp(String otp) async {
    try {
      if (sessionId == null || newRecoveryNumber == null) {
        debugPrint('❌ Session ID or new recovery number is null');
        _showError('Session expired. Please try again');
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(RecoveryMobileStatus.verifyingNewOtp);

      debugPrint('🔄 Recovery Step 4: Verifying new recovery number OTP...');

      final response = await _apiService.verifyNewNumberOtp(
        sessionId: sessionId!,
        mobileNumber: newRecoveryNumber!,
        otp: otp,
      );

      if (response != null) {
        _recoveryMobileModel.value = model.copyWith(newOtp: otp);
        _updateStatus(RecoveryMobileStatus.completed);
        debugPrint('✅ Recovery Step 4: Recovery mobile changed successfully!');
        _showSuccess('Recovery mobile updated successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to verify OTP';
        errorMessage.value = error;
        _updateStatus(RecoveryMobileStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Recovery Step 4 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(RecoveryMobileStatus.error);
      _showError('An error occurred while verifying OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Full Recovery Mobile Flow - All 4 steps
  /// Call this method from screen with BuildContext
  Future<bool> startRecoveryMobileFlow({
    required BuildContext context,
    required String currentMobileNumber,
    VoidCallback? onSuccess,
  }) async {
    debugPrint('');
    debugPrint('🔐 ========== RECOVERY MOBILE FLOW STARTED ==========');

    // Reset and set current number
    reset();
    setCurrentNumber(currentMobileNumber);

    final maskedNumber = Formatters.formatMaskedPhone(currentMobileNumber);
    debugPrint('📱 Current number (masked): $maskedNumber');

    // Prepare for dialog sequence - hide any existing keyboard
    await DialogTransitionHelper.prepareForDialogSequence(context);

    // STEP 1: Use global PIN check - skip if PIN is disabled
    debugPrint('');
    debugPrint('📍 STEP 1: Check Security PIN...');

    String? pin;
    try {
      final privacyController = Get.find<PrivacySettingController>();
      final result = await privacyController.requirePinIfEnabled(
        context,
        title: 'Enter Security PIN',
        subtitle: 'Enter your 4-digit PIN to change recovery mobile',
        confirmButtonText: 'Send OTP',
      );

      if (result == null) {
        debugPrint('❌ User cancelled PIN entry or validation failed');
        return false;
      }

      pin = result == 'SKIP' ? '' : result;
    } catch (e) {
      // Controller not registered, show PIN dialog as fallback
      debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
      final pinResult = await PinVerificationDialog.show(
        context: context,
        title: 'Enter Security Pin',
        subtitle: 'Enter your 4-digit pin to verify',
        maskedPhoneNumber: maskedNumber,
        requireOtp: false,
        confirmButtonText: 'Send OTP',
      );

      final pinValue = pinResult?['pin'];
      if (pinResult == null || pinValue == null) {
        debugPrint('❌ User cancelled PIN entry');
        return false;
      }
      pin = pinValue;
    }

    debugPrint('✅ PIN verified or skipped');

    // Wait for keyboard to close before API call
    await DialogTransitionHelper.waitForDialogTransition();

    // API 1: Send OTP to current number
    debugPrint('📡 API 1: Sending OTP to current number...');
    final otpSentToCurrent = await sendOtpToCurrentNumber(pin);

    if (!otpSentToCurrent) {
      debugPrint('❌ API 1 Failed: Could not send OTP');
      return false;
    }

    debugPrint('✅ API 1 Success: OTP sent to current number');

    if (!context.mounted) return false;

    // Wait for smooth transition before showing next dialog
    await DialogTransitionHelper.waitForDialogTransition();

    // STEP 2: Show OTP Dialog for current number
    debugPrint('');
    debugPrint('📍 STEP 2: Enter OTP received on current number...');

    final currentOtp = await NewNumberOtpDialog.show(
      context: context,
      newPhoneNumber: maskedNumber,
      title: 'Enter OTP',
      subtitle: 'Enter OTP received on your phone\n$maskedNumber',
      confirmButtonText: 'Verify',
      onResendOtp: () async {
        debugPrint('🔄 Resending OTP to current number...');
        return await sendOtpToCurrentNumber('');
      },
    );

    if (currentOtp == null) {
      debugPrint('❌ User cancelled OTP entry');
      return false;
    }

    // Wait for keyboard to close before API call
    await DialogTransitionHelper.waitForDialogTransition();

    // API 2: Verify current OTP
    debugPrint('📡 API 2: Verifying current number OTP...');
    final currentOtpVerified = await verifyCurrentNumberOtp(currentOtp);

    if (!currentOtpVerified) {
      debugPrint('❌ API 2 Failed: Invalid OTP');
      return false;
    }

    debugPrint('✅ API 2 Success: OTP verified, session created');

    if (!context.mounted) return false;

    // Wait for smooth transition before showing next dialog
    await DialogTransitionHelper.waitForDialogTransition();

    // STEP 3: Show Mobile Number Dialog for new recovery number
    debugPrint('');
    debugPrint('📍 STEP 3: Enter new recovery mobile number...');

    final newRecoveryMobile = await MobileNumberDialog.show(
      context: context,
      title: 'Enter Recovery Mobile',
      subtitle: 'Enter your new 10-digit recovery mobile number',
      confirmButtonText: 'Send OTP',
    );

    if (newRecoveryMobile == null || newRecoveryMobile.isEmpty) {
      debugPrint('❌ User cancelled or no mobile provided');
      return false;
    }

    debugPrint('✅ New recovery mobile entered');

    // Wait for keyboard to close before API call
    await DialogTransitionHelper.waitForDialogTransition();

    // API 3: Send OTP to new recovery number
    debugPrint('📡 API 3: Sending OTP to new recovery number...');
    final otpSentToNew = await sendOtpToNewNumber(newRecoveryMobile);

    if (!otpSentToNew) {
      debugPrint('❌ API 3 Failed: Could not send OTP to new number');
      return false;
    }

    debugPrint('✅ API 3 Success: OTP sent to new recovery number');

    if (!context.mounted) return false;

    // Wait for smooth transition before showing next dialog
    await DialogTransitionHelper.waitForDialogTransition();

    // STEP 4: Show OTP Dialog for new recovery number
    debugPrint('');
    debugPrint('📍 STEP 4: Enter OTP received on new recovery number...');

    final formattedNewMobile = Formatters.formatPhoneWithCountryCode('+91$newRecoveryMobile');

    final newOtp = await NewNumberOtpDialog.show(
      context: context,
      newPhoneNumber: formattedNewMobile,
      title: 'Enter OTP',
      subtitle: 'Enter OTP received on your new recovery number\n$formattedNewMobile',
      confirmButtonText: 'Confirm',
      onResendOtp: () async {
        debugPrint('🔄 Resending OTP to new recovery number...');
        return await sendOtpToNewNumber(newRecoveryMobile);
      },
    );

    if (newOtp == null) {
      debugPrint('❌ User cancelled new number OTP entry');
      return false;
    }

    // Wait for keyboard to close before API call
    await DialogTransitionHelper.waitForDialogTransition();

    // API 4: Verify new recovery number OTP
    debugPrint('📡 API 4: Verifying new recovery number OTP...');
    final success = await verifyNewNumberOtp(newOtp);

    if (success) {
      debugPrint('✅ API 4 Success: Recovery mobile updated successfully!');
      debugPrint('');
      debugPrint('🎉 ========== RECOVERY MOBILE FLOW COMPLETED ==========');

      // Call success callback if provided
      if (onSuccess != null) {
        onSuccess();
      }

      return true;
    } else {
      debugPrint('❌ API 4 Failed: Could not verify new recovery OTP');
      return false;
    }
  }

  /// Reset controller state
  void reset() {
    _recoveryMobileModel.value = RecoveryMobileModel();
    isLoading.value = false;
    errorMessage.value = '';
    debugPrint('🔄 Recovery Controller reset');
  }

  /// Update status
  void _updateStatus(RecoveryMobileStatus newStatus) {
    _recoveryMobileModel.value = model.copyWith(status: newStatus);
    debugPrint('📊 Recovery Status: $newStatus');
  }

  /// Show error message
  void _showError(String message) {
    AdvancedErrorService.showError(
      message,
      category: ErrorCategory.network,
      severity: ErrorSeverity.high,
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    AdvancedErrorService.showSuccess(
      message,
      type: SuccessType.snackbar,
    );
  }

  /// Mask phone number for logging
  String _maskNumber(String number) {
    if (number.length > 4) {
      return '${number.substring(0, 2)}******${number.substring(number.length - 2)}';
    }
    return '****';
  }

  @override
  void onClose() {
    debugPrint('🗑️ RecoveryMobileController disposed');
    super.onClose();
  }
}