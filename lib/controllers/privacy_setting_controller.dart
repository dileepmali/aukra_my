import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/privacy_setting_api_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/privacy_setting_model.dart';
import '../presentations/widgets/dialogs/pin_verification_dialog.dart';

/// Global GetX Controller for Privacy Settings / Security PIN Feature
///
/// This controller is registered globally on app start and manages:
/// - Security PIN enabled/disabled state
/// - PIN validation across the entire app
/// - All privacy setting API calls
///
/// Usage:
/// - Get.put(PrivacySettingController(), permanent: true) on app start
/// - Get.find<PrivacySettingController>() anywhere in app
///
/// Key Features:
/// - If PIN is disabled, all PIN dialogs are skipped throughout the app
/// - If PIN is enabled, PIN is validated via API before any action
class PrivacySettingController extends GetxController {
  final PrivacySettingApiService _apiService = PrivacySettingApiService();

  // ============================================================
  // OBSERVABLE STATE
  // ============================================================

  final Rx<PrivacySettingModel> _privacyModel = PrivacySettingModel.initial().obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Temporary storage for PIN setup flow
  String? _tempSecurityKey;
  String? _tempOtp;

  // ============================================================
  // GETTERS
  // ============================================================

  PrivacySettingModel get model => _privacyModel.value;

  /// Check if security PIN is enabled
  /// Returns false by default (first time login = PIN disabled)
  bool get isPinEnabled => model.isEnabled;

  /// Check if PIN is valid/set properly
  bool get isPinValid => model.isValid;

  /// Current status
  PrivacySettingStatus get status => model.status;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔐 PrivacySettingController initialized');
    // Load privacy settings on init
    loadPrivacySettings();
  }

  @override
  void onClose() {
    debugPrint('🗑️ PrivacySettingController disposed');
    super.onClose();
  }

  // ============================================================
  // API METHODS
  // ============================================================

  /// Load privacy settings from server
  /// Called on app start to check if PIN is enabled
  Future<void> loadPrivacySettings() async {
    try {
      _updateStatus(PrivacySettingStatus.loading);
      debugPrint('🔄 Loading privacy settings...');

      final response = await _apiService.getPrivacySetting();

      if (response != null) {
        _privacyModel.value = PrivacySettingModel(
          isEnabled: response.isEnabled,
          isValid: response.isValid,
          status: PrivacySettingStatus.success,
        );
        debugPrint('✅ Privacy settings loaded:');
        debugPrint('   isEnabled: ${response.isEnabled}');
        debugPrint('   isValid: ${response.isValid}');
      } else {
        // Default to disabled if API fails (first time login)
        _privacyModel.value = PrivacySettingModel(
          isEnabled: false,
          isValid: false,
          status: PrivacySettingStatus.initial,
        );
        debugPrint('⚠️ Could not load privacy settings, defaulting to disabled');
      }
    } catch (e) {
      debugPrint('❌ Error loading privacy settings: $e');
      // Default to disabled on error
      _privacyModel.value = PrivacySettingModel.initial();
    }
  }

  /// API 1: Send OTP for PIN setup/change/disable
  Future<bool> sendOtp() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(PrivacySettingStatus.sendingOtp);

      debugPrint('🔄 Sending OTP for privacy setting...');

      final response = await _apiService.sendOtp();

      if (response != null) {
        _updateStatus(PrivacySettingStatus.otpSent);
        debugPrint('✅ OTP sent successfully');
        _showSuccess('OTP sent successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to send OTP';
        errorMessage.value = error;
        _updateStatus(PrivacySettingStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception sending OTP: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(PrivacySettingStatus.error);
      _showError('An error occurred while sending OTP');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 2: Update privacy settings (enable/disable PIN)
  Future<bool> updatePrivacySetting({
    required String securityKey,
    required bool isEnabled,
    required String otp,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(PrivacySettingStatus.updatingSettings);

      debugPrint('🔄 Updating privacy settings...');
      debugPrint('   isEnabled: $isEnabled');

      final response = await _apiService.updatePrivacySetting(
        securityKey: securityKey,
        isEnabled: isEnabled,
        otp: otp,
      );

      if (response != null) {
        // Update local state
        _privacyModel.value = model.copyWith(
          isEnabled: isEnabled,
          isValid: isEnabled,
          status: PrivacySettingStatus.settingsUpdated,
        );

        // Clear temp storage
        _tempSecurityKey = null;
        _tempOtp = null;

        debugPrint('✅ Privacy settings updated successfully');
        _showSuccess(isEnabled ? 'Security PIN enabled' : 'Security PIN disabled');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to update settings';
        errorMessage.value = error;
        _updateStatus(PrivacySettingStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception updating settings: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(PrivacySettingStatus.error);
      _showError('An error occurred while updating settings');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// API 4: Validate security PIN
  /// Returns true if PIN is valid, false otherwise
  Future<bool> validateSecurityKey(String securityKey) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      _updateStatus(PrivacySettingStatus.validatingPin);

      debugPrint('🔄 Validating security PIN...');

      final response = await _apiService.validateSecurityKey(
        securityKey: securityKey,
      );

      if (response != null && response.isValid) {
        _updateStatus(PrivacySettingStatus.pinValidated);
        debugPrint('✅ PIN validated successfully');
        return true;
      } else {
        final error = 'Invalid PIN';
        errorMessage.value = error;
        _updateStatus(PrivacySettingStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception validating PIN: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(PrivacySettingStatus.error);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // GLOBAL PIN CHECK - USE THIS EVERYWHERE
  // ============================================================

  /// Global PIN check method
  /// Call this before any action that requires PIN verification
  ///
  /// Returns:
  /// - null: PIN verification cancelled or failed
  /// - 'SKIP': PIN is disabled, proceed without PIN
  /// - PIN string: PIN validated successfully
  ///
  /// Usage:
  /// ```dart
  /// final controller = Get.find<PrivacySettingController>();
  /// final result = await controller.requirePinIfEnabled(context);
  /// if (result == null) return; // Cancelled or failed
  /// // Proceed with action (result is 'SKIP' or validated PIN)
  /// ```
  Future<String?> requirePinIfEnabled(
    BuildContext context, {
    String title = 'Enter Security PIN',
    String subtitle = 'Enter your 4-digit PIN to proceed',
    String? maskedPhoneNumber,
    String confirmButtonText = 'Confirm',
    List<Color>? confirmGradientColors,
  }) async {
    // If PIN is disabled, skip dialog and return 'SKIP'
    if (!isPinEnabled) {
      debugPrint('🔓 Security PIN is disabled, skipping verification');
      return 'SKIP';
    }

    debugPrint('🔐 Security PIN is enabled, showing verification dialog');

    // Show PIN verification dialog
    final pinResult = await PinVerificationDialog.show(
      context: context,
      title: title,
      subtitle: subtitle,
      maskedPhoneNumber: maskedPhoneNumber,
      requireOtp: false,
      confirmButtonText: confirmButtonText,
      confirmGradientColors: confirmGradientColors,
    );

    if (pinResult == null || pinResult['pin'] == null) {
      debugPrint('❌ PIN verification cancelled');
      return null;
    }

    final pin = pinResult['pin'] as String;

    // Validate PIN via API
    final isValid = await validateSecurityKey(pin);

    if (isValid) {
      debugPrint('✅ PIN validated, proceeding with action');
      return pin;
    } else {
      debugPrint('❌ Invalid PIN');
      return null;
    }
  }

  /// Quick check if PIN is required
  /// Use this for UI elements that need to show/hide based on PIN status
  bool get isPinRequired => isPinEnabled;

  // ============================================================
  // HELPER METHODS FOR PIN SETUP FLOW
  // ============================================================

  /// Store temporary security key during setup flow
  void setTempSecurityKey(String key) {
    _tempSecurityKey = key;
    debugPrint('📝 Temp security key stored');
  }

  /// Store temporary OTP during setup flow
  void setTempOtp(String otp) {
    _tempOtp = otp;
    debugPrint('📝 Temp OTP stored');
  }

  /// Get stored temp security key
  String? get tempSecurityKey => _tempSecurityKey;

  /// Get stored temp OTP
  String? get tempOtp => _tempOtp;

  /// Clear temporary storage
  void clearTempData() {
    _tempSecurityKey = null;
    _tempOtp = null;
    debugPrint('🗑️ Temp data cleared');
  }

  // ============================================================
  // ENABLE/DISABLE PIN FLOW
  // ============================================================

  /// Enable security PIN
  /// Flow: Send OTP → Enter PIN + OTP → Update settings
  Future<bool> enablePin({
    required String securityKey,
    required String otp,
  }) async {
    return await updatePrivacySetting(
      securityKey: securityKey,
      isEnabled: true,
      otp: otp,
    );
  }

  /// Disable security PIN (legacy - use disablePinWithKey instead)
  /// Flow: Send OTP → Enter OTP → Update settings
  Future<bool> disablePin({
    required String otp,
  }) async {
    return await updatePrivacySetting(
      securityKey: '',
      isEnabled: false,
      otp: otp,
    );
  }

  /// Disable security PIN with current key verification
  /// Flow: Enter current PIN → Send OTP → Enter OTP → Update settings
  /// API requires current securityKey for verification even when disabling
  Future<bool> disablePinWithKey({
    required String securityKey,
    required String otp,
  }) async {
    return await updatePrivacySetting(
      securityKey: securityKey,
      isEnabled: false,
      otp: otp,
    );
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Update status
  void _updateStatus(PrivacySettingStatus newStatus) {
    _privacyModel.value = model.copyWith(status: newStatus);
    debugPrint('📊 Privacy Setting Status: $newStatus');
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

  /// Reset controller state
  void reset() {
    _privacyModel.value = PrivacySettingModel.initial();
    isLoading.value = false;
    errorMessage.value = '';
    _tempSecurityKey = null;
    _tempOtp = null;
    debugPrint('🔄 PrivacySettingController reset');
  }
}