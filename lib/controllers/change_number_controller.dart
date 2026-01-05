import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/change_number_api_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/change_number_model.dart';

/// Professional GetX Controller for Change Number Feature
/// Manages state and business logic for changing mobile number
class ChangeNumberController extends GetxController {
  final ChangeNumberApiService _apiService = ChangeNumberApiService();

  // Observable state
  final Rx<ChangeNumberModel> _changeNumberModel = ChangeNumberModel().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Getters
  ChangeNumberModel get model => _changeNumberModel.value;
  String? get sessionId => model.sessionId;
  String? get currentNumber => model.currentNumber;
  String? get newNumber => model.newNumber;
  ChangeNumberStatus get status => model.status;

  /// Set current number
  void setCurrentNumber(String number) {
    _changeNumberModel.value = model.copyWith(currentNumber: number);
    debugPrint('📱 Current number set: ${_maskNumber(number)}');
  }

  /// Set new number
  void setNewNumber(String number) {
    _changeNumberModel.value = model.copyWith(newNumber: number);
    debugPrint('📱 New number set: ${_maskNumber(number)}');
  }

  /// API 1: Send OTP to current number
  Future<bool> sendOtpToCurrentNumber(String pin) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(ChangeNumberStatus.sendingOtpToCurrent);

      debugPrint('🔄 Step 1: Sending OTP to current number...');

      final response = await _apiService.sendOtpToCurrentNumber(
        securityKey: pin,
      );

      if (response != null) {
        _changeNumberModel.value = model.copyWith(pin: pin);
        _updateStatus(ChangeNumberStatus.otpSentToCurrent);
        debugPrint('✅ Step 1: OTP sent successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to send OTP';
        errorMessage.value = error;
        _updateStatus(ChangeNumberStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Step 1 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(ChangeNumberStatus.error);
      _showError('An error occurred while sending OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 2: Verify current number OTP and get sessionId
  Future<bool> verifyCurrentNumberOtp(String otp) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(ChangeNumberStatus.verifyingCurrentOtp);

      debugPrint('🔄 Step 2: Verifying current number OTP...');

      final response = await _apiService.verifyCurrentNumberOtp(otp: otp);

      if (response != null && response.sessionId > 0) {
        _changeNumberModel.value = model.copyWith(
          currentOtp: otp,
          sessionId: response.sessionId.toString(),
        );
        _updateStatus(ChangeNumberStatus.currentOtpVerified);
        debugPrint('✅ Step 2: OTP verified, Session ID: ${response.sessionId}');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Invalid OTP';
        errorMessage.value = error;
        _updateStatus(ChangeNumberStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Step 2 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(ChangeNumberStatus.error);
      _showError('An error occurred while verifying OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 3: Send OTP to new mobile number
  Future<bool> sendOtpToNewNumber(String mobileNumber) async {
    try {
      if (sessionId == null) {
        debugPrint('❌ Session ID is null, cannot proceed');
        _showError('Session expired. Please try again');
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(ChangeNumberStatus.sendingOtpToNew);

      debugPrint('🔄 Step 3: Sending OTP to new number...');

      final response = await _apiService.sendOtpToNewNumber(
        sessionId: sessionId!,
        mobileNumber: mobileNumber,
      );

      if (response != null) {
        _changeNumberModel.value = model.copyWith(newNumber: mobileNumber);
        _updateStatus(ChangeNumberStatus.otpSentToNew);
        debugPrint('✅ Step 3: OTP sent to new number successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to send OTP to new number';
        errorMessage.value = error;
        _updateStatus(ChangeNumberStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Step 3 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(ChangeNumberStatus.error);
      _showError('An error occurred while sending OTP to new number');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 4: Verify new number OTP and complete change
  Future<bool> verifyNewNumberOtp(String otp) async {
    try {
      if (sessionId == null || newNumber == null) {
        debugPrint('❌ Session ID or new number is null');
        _showError('Session expired. Please try again');
        return false;
      }

      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(ChangeNumberStatus.verifyingNewOtp);

      debugPrint('🔄 Step 4: Verifying new number OTP...');

      final response = await _apiService.verifyNewNumberOtp(
        sessionId: sessionId!,
        mobileNumber: newNumber!,
        otp: otp,
      );

      if (response != null) {
        _changeNumberModel.value = model.copyWith(newOtp: otp);
        _updateStatus(ChangeNumberStatus.completed);
        debugPrint('✅ Step 4: Number changed successfully!');
        // Success message shown in change_number_screen.dart
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to verify OTP';
        errorMessage.value = error;
        _updateStatus(ChangeNumberStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Step 4 Exception: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(ChangeNumberStatus.error);
      _showError('An error occurred while verifying OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset controller state
  void reset() {
    _changeNumberModel.value = ChangeNumberModel();
    isLoading.value = false;
    errorMessage.value = '';
    debugPrint('🔄 Controller reset');
  }

  /// Update status
  void _updateStatus(ChangeNumberStatus newStatus) {
    _changeNumberModel.value = model.copyWith(status: newStatus);
    debugPrint('📊 Status: $newStatus');
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
    debugPrint('🗑️ ChangeNumberController disposed');
    super.onClose();
  }
}
