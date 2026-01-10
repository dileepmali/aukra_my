import 'package:flutter/material.dart';
import '../../models/change_master_number_model.dart';
import 'global_api_function.dart';
import 'auth_storage.dart';

/// Professional API Service for Change Master Number Feature
/// Handles all 4 API endpoints for changing merchant's master/admin mobile number
class ChangeMasterNumberApiService {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// API 1: Send OTP to current mobile number
  /// Endpoint: PUT /api/merchant/{merchantId}/admin-mobile/initiate-update/sendOtp
  Future<SendOtpResponse?> sendOtpToCurrentNumber({
    required String securityKey,
  }) async {
    try {
      debugPrint('📤 API 1: Sending OTP to current number...');
      debugPrint('   Security Key: ${securityKey.replaceAll(RegExp(r'.'), '*')}');

      // Get merchant ID from auth storage
      final merchantId = await AuthStorage.getMerchantId();
      if (merchantId == null) {
        debugPrint('❌ Merchant ID not found');
        return null;
      }

      final request = SendOtpToCurrentRequest(securityKey: securityKey);

      await _apiFetcher.request(
        url: 'api/merchant/$merchantId/admin-mobile/initiate-update/sendOtp',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ API 1: OTP sent to current number successfully');
        return SendOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ API 1 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ API 1 Exception: $e');
      return null;
    }
  }

  /// API 2: Verify current mobile number OTP and get sessionId
  /// Endpoint: PUT /api/merchant/admin-mobile/initiate-update
  Future<VerifyCurrentOtpResponse?> verifyCurrentNumberOtp({
    required String otp,
  }) async {
    try {
      debugPrint('📤 API 2: Verifying current number OTP...');
      debugPrint('   OTP: ${otp.replaceAll(RegExp(r'.'), '*')}');

      final request = VerifyCurrentOtpRequest(otp: otp);

      await _apiFetcher.request(
        url: 'api/merchant/admin-mobile/initiate-update',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ API 2: Current OTP verified successfully');
        debugPrint('   Session ID: ${_apiFetcher.data['sessionId']}');
        return VerifyCurrentOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ API 2 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ API 2 Exception: $e');
      return null;
    }
  }

  /// API 3: Send OTP to new mobile number
  /// Endpoint: PUT /api/merchant/admin-mobile/initiate-update/{sessionId}/new-mobile
  Future<SendOtpResponse?> sendOtpToNewNumber({
    required String sessionId,
    required String mobileNumber,
  }) async {
    try {
      debugPrint('📤 API 3: Sending OTP to new number...');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   New Mobile: ${mobileNumber.substring(0, 2)}******${mobileNumber.substring(mobileNumber.length - 2)}');

      final request = SendOtpToNewRequest(mobileNumber: mobileNumber);

      await _apiFetcher.request(
        url: 'api/merchant/admin-mobile/initiate-update/$sessionId/new-mobile',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ API 3: OTP sent to new number successfully');
        return SendOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ API 3 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ API 3 Exception: $e');
      return null;
    }
  }

  /// API 4: Verify new mobile number OTP and complete change
  /// Endpoint: PUT /api/merchant/admin-mobile/initiate-update/{sessionId}/verify-otp
  Future<VerifyNewOtpResponse?> verifyNewNumberOtp({
    required String sessionId,
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      debugPrint('📤 API 4: Verifying new number OTP...');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   Mobile: ${mobileNumber.substring(0, 2)}******${mobileNumber.substring(mobileNumber.length - 2)}');
      debugPrint('   OTP: ${otp.replaceAll(RegExp(r'.'), '*')}');

      final request = VerifyNewOtpRequest(
        mobileNumber: mobileNumber,
        otp: otp,
      );

      await _apiFetcher.request(
        url: 'api/merchant/admin-mobile/initiate-update/$sessionId/verify-otp',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ API 4: New number verified and changed successfully');
        return VerifyNewOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ API 4 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ API 4 Exception: $e');
      return null;
    }
  }

  /// Get error message from API response
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Parse error response
  ChangeMasterNumberErrorResponse? parseErrorResponse(dynamic errorData) {
    try {
      if (errorData is Map<String, dynamic>) {
        return ChangeMasterNumberErrorResponse.fromJson(errorData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error parsing error response: $e');
      return null;
    }
  }
}
