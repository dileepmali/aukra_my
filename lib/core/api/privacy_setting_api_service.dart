import 'package:flutter/material.dart';
import '../../models/privacy_setting_model.dart';
import 'global_api_function.dart';

/// Professional API Service for Privacy Settings / Security PIN Feature
///
/// Handles all 4 API endpoints:
/// - POST /api/privacy-setting/user/sendOtp - Send OTP to verify mobile
/// - POST /api/privacy-setting/user - Update privacy settings (enable/disable PIN)
/// - GET /api/privacy-setting/user - Get current privacy settings
/// - GET /api/privacy-setting/user/validate/{key} - Validate security PIN
class PrivacySettingApiService {
  final ApiFetcher _apiFetcher = ApiFetcher();

  // ============================================================
  // API 1: SEND OTP
  // ============================================================

  /// Send OTP to user's mobile number for verification
  /// Endpoint: POST /api/privacy-setting/user/sendOtp
  ///
  /// Used when:
  /// - Enabling security PIN for first time
  /// - Disabling security PIN
  /// - Changing security PIN
  Future<SendOtpResponse?> sendOtp() async {
    try {
      debugPrint('');
      debugPrint('🔐 ═══════════════════════════════════════════');
      debugPrint('📤 PRIVACY API 1: Sending OTP...');
      debugPrint('   Endpoint: POST /api/privacy-setting/user/sendOtp');
      debugPrint('═══════════════════════════════════════════════');

      await _apiFetcher.request(
        url: 'api/privacy-setting/user/sendOtp',
        method: 'POST',
        body: {}, // Empty body required for POST request
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ PRIVACY API 1: OTP sent successfully');
        debugPrint('   Response: ${_apiFetcher.data}');
        return SendOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ PRIVACY API 1 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ PRIVACY API 1 Exception: $e');
      return null;
    }
  }

  // ============================================================
  // API 2: UPDATE PRIVACY SETTINGS
  // ============================================================

  /// Update privacy settings (enable/disable security PIN)
  /// Endpoint: POST /api/privacy-setting/user
  ///
  /// Request Body:
  /// {
  ///   "securityKey": "1234",  // 4-digit PIN (empty if disabling)
  ///   "isEnabled": true,       // true = enable, false = disable
  ///   "otp": "5678"           // OTP received on mobile
  /// }
  Future<UpdatePrivacySettingResponse?> updatePrivacySetting({
    required String securityKey,
    required bool isEnabled,
    required String otp,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔐 ═══════════════════════════════════════════');
      debugPrint('📤 PRIVACY API 2: Updating Privacy Settings...');
      debugPrint('   Endpoint: POST /api/privacy-setting/user');
      debugPrint('   isEnabled: $isEnabled');
      debugPrint('   securityKey: ${securityKey.isNotEmpty ? '****' : '(empty)'}');
      debugPrint('   otp: ****');
      debugPrint('═══════════════════════════════════════════════');

      final request = UpdatePrivacySettingRequest(
        securityKey: securityKey,
        isEnabled: isEnabled,
        otp: otp,
      );

      await _apiFetcher.request(
        url: 'api/privacy-setting/user',
        method: 'POST',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ PRIVACY API 2: Settings updated successfully');
        debugPrint('   Response: ${_apiFetcher.data}');
        return UpdatePrivacySettingResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ PRIVACY API 2 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ PRIVACY API 2 Exception: $e');
      return null;
    }
  }

  // ============================================================
  // API 3: GET PRIVACY SETTINGS
  // ============================================================

  /// Get current privacy settings
  /// Endpoint: GET /api/privacy-setting/user
  ///
  /// Response:
  /// {
  ///   "isEnabled": true,  // PIN feature ON/OFF
  ///   "isValid": true     // PIN is set properly
  /// }
  ///
  /// Used on app start to check if PIN is enabled
  Future<PrivacySettingResponse?> getPrivacySetting() async {
    try {
      debugPrint('');
      debugPrint('🔐 ═══════════════════════════════════════════');
      debugPrint('📥 PRIVACY API 3: Getting Privacy Settings...');
      debugPrint('   Endpoint: GET /api/privacy-setting/user');
      debugPrint('═══════════════════════════════════════════════');

      await _apiFetcher.request(
        url: 'api/privacy-setting/user',
        method: 'GET',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ PRIVACY API 3: Settings retrieved successfully');
        debugPrint('   Response: ${_apiFetcher.data}');
        return PrivacySettingResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ PRIVACY API 3 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ PRIVACY API 3 Exception: $e');
      return null;
    }
  }

  // ============================================================
  // API 4: VALIDATE SECURITY PIN
  // ============================================================

  /// Validate security PIN entered by user
  /// Endpoint: GET /api/privacy-setting/user/validate/{key}
  ///
  /// Response:
  /// {
  ///   "isEnabled": true,
  ///   "isValid": true     // true = correct PIN, false = wrong PIN
  /// }
  ///
  /// Used when user enters PIN for any action (transaction, edit, etc.)
  Future<PrivacySettingResponse?> validateSecurityKey({
    required String securityKey,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔐 ═══════════════════════════════════════════');
      debugPrint('📥 PRIVACY API 4: Validating Security PIN...');
      debugPrint('   Endpoint: GET /api/privacy-setting/user/validate/****');
      debugPrint('═══════════════════════════════════════════════');

      await _apiFetcher.request(
        url: 'api/privacy-setting/user/validate/$securityKey',
        method: 'GET',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        final response = PrivacySettingResponse.fromJson(_apiFetcher.data);
        debugPrint('✅ PRIVACY API 4: Validation complete');
        debugPrint('   isValid: ${response.isValid}');
        return response;
      } else {
        debugPrint('❌ PRIVACY API 4 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ PRIVACY API 4 Exception: $e');
      return null;
    }
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  /// Get error message from last API call
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Parse error response from API
  PrivacySettingErrorResponse? parseErrorResponse(dynamic errorData) {
    try {
      if (errorData is Map<String, dynamic>) {
        return PrivacySettingErrorResponse.fromJson(errorData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error parsing error response: $e');
      return null;
    }
  }
}