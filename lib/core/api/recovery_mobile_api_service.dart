import 'package:flutter/material.dart';
import '../../models/recovery_mobile_model.dart';
import 'global_api_function.dart';

/// Professional API Service for Recovery Mobile Feature
/// Handles all 4 API endpoints for changing user's recovery/backup mobile number
/// TODO: Update API endpoints when backend provides them
class RecoveryMobileApiService {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// API 1: Send OTP to current mobile number
  /// Endpoint: PUT /api/user/mobile/initiate-recovery-mobile/sendOtp
  Future<RecoverySendOtpResponse?> sendOtpToCurrentNumber({
    required String securityKey,
  }) async {
    try {
      debugPrint('📤 Recovery API 1: Sending OTP to current number...');
      debugPrint('   Security Key: ${securityKey.replaceAll(RegExp(r'.'), '*')}');

      final request = RecoverySendOtpToCurrentRequest(securityKey: securityKey);

      await _apiFetcher.request(
        url: 'api/user/mobile/initiate-recovery-mobile/sendOtp',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Recovery API 1: OTP sent to current number successfully');
        return RecoverySendOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ Recovery API 1 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Recovery API 1 Exception: $e');
      return null;
    }
  }

  /// API 2: Verify current mobile number OTP and start recovery session
  /// Endpoint: PUT /api/user/mobile/initiate-recovery
  Future<RecoveryVerifyCurrentOtpResponse?> verifyCurrentNumberOtp({
    required String otp,
  }) async {
    try {
      debugPrint('📤 Recovery API 2: Verifying current number OTP...');
      debugPrint('   OTP: ${otp.replaceAll(RegExp(r'.'), '*')}');

      final request = RecoveryVerifyCurrentOtpRequest(otp: otp);

      await _apiFetcher.request(
        url: 'api/user/mobile/initiate-recovery',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Recovery API 2: Current OTP verified successfully');
        debugPrint('   Session ID: ${_apiFetcher.data['sessionId']}');
        return RecoveryVerifyCurrentOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ Recovery API 2 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Recovery API 2 Exception: $e');
      return null;
    }
  }

  /// API 3: Send OTP to new recovery mobile number
  /// Endpoint: PUT /api/user/mobile/initiate-recovery/{sessionId}/new-mobile
  Future<RecoverySendOtpResponse?> sendOtpToNewNumber({
    required String sessionId,
    required String mobileNumber,
  }) async {
    try {
      debugPrint('📤 Recovery API 3: Sending OTP to new recovery number...');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   New Mobile: ${mobileNumber.substring(0, 2)}******${mobileNumber.substring(mobileNumber.length - 2)}');

      final request = RecoverySendOtpToNewRequest(mobileNumber: mobileNumber);

      await _apiFetcher.request(
        url: 'api/user/mobile/initiate-recovery/$sessionId/new-mobile',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Recovery API 3: OTP sent to new recovery number successfully');
        return RecoverySendOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ Recovery API 3 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Recovery API 3 Exception: $e');
      return null;
    }
  }

  /// API 4: Verify new recovery mobile number OTP and finalize update
  /// Endpoint: PUT /api/user/mobile/initiate-recovery/{sessionId}/verify-otp
  Future<RecoveryVerifyNewOtpResponse?> verifyNewNumberOtp({
    required String sessionId,
    required String mobileNumber,
    required String otp,
  }) async {
    try {
      debugPrint('📤 Recovery API 4: Verifying new recovery number OTP...');
      debugPrint('   Session ID: $sessionId');
      debugPrint('   Mobile: ${mobileNumber.substring(0, 2)}******${mobileNumber.substring(mobileNumber.length - 2)}');
      debugPrint('   OTP: ${otp.replaceAll(RegExp(r'.'), '*')}');

      final request = RecoveryVerifyNewOtpRequest(
        mobileNumber: mobileNumber,
        otp: otp,
      );

      await _apiFetcher.request(
        url: 'api/user/mobile/initiate-recovery/$sessionId/verify-otp',
        method: 'PUT',
        body: request.toJson(),
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Recovery API 4: New recovery number verified and saved successfully');
        return RecoveryVerifyNewOtpResponse.fromJson(_apiFetcher.data);
      } else {
        debugPrint('❌ Recovery API 4 Error: ${_apiFetcher.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Recovery API 4 Exception: $e');
      return null;
    }
  }

  /// Get error message from API response
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Parse error response
  RecoveryMobileErrorResponse? parseErrorResponse(dynamic errorData) {
    try {
      if (errorData is Map<String, dynamic>) {
        return RecoveryMobileErrorResponse.fromJson(errorData);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error parsing error response: $e');
      return null;
    }
  }
}