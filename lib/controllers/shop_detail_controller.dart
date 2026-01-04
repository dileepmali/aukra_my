import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/global_api_function.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/merchant_model.dart';

class ShopDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSendingOtp = false.obs;
  final RxBool isOtpSent = false.obs;
  final RxBool isOwnerOtpVerified = false.obs;
  final RxBool isResendAvailable = false.obs;
  final RxBool isOtpExpired = false.obs; // ✅ NEW: Track OTP expiry
  final RxInt resendTimer = 30.obs;
  final RxString registeredPhone = ''.obs;
  final RxString receivedOtp = ''.obs; // Store OTP received from API

  Timer? _resendTimer;
  final ApiFetcher _apiFetcher = ApiFetcher();
  String ownerPhone = '';

  @override
  void onInit() {
    super.onInit();
    _loadRegisteredPhone();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadRegisteredPhone() async {
    debugPrint('🔍 ShopDetailController: Loading registered phone...');
    final phone = await AuthStorage.getPhoneNumber();
    debugPrint('📱 ShopDetailController: Retrieved phone from storage: $phone');
    if (phone != null) {
      registeredPhone.value = phone;
      debugPrint('✅ ShopDetailController: Registered phone set to: ${registeredPhone.value}');
    } else {
      debugPrint('❌ ShopDetailController: No phone number found in storage');
    }
  }

  Future<void> sendOwnerOtp(String phone) async {
    try {
      debugPrint('');
      debugPrint('🚀 ==================== SEND OTP STARTED ====================');
      debugPrint('📱 Input phone: "$phone"');

      isSendingOtp.value = true;
      debugPrint('✅ isSendingOtp set to: ${isSendingOtp.value}');

      ownerPhone = phone;
      debugPrint('✅ ownerPhone saved: "$ownerPhone"');

      // Prepare phone number (remove +91 if present, API expects just 10 digits)
      String formattedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      debugPrint('🔢 Extracted digits: "$formattedPhone"');

      if (formattedPhone.startsWith('91') && formattedPhone.length == 12) {
        formattedPhone = formattedPhone.substring(2);
        debugPrint('✂️ Removed +91 prefix: "$formattedPhone"');
      }

      final payload = {
        'mobileNumber': formattedPhone,
      };

      debugPrint('📡 API Endpoint: api/auth/send-otp');
      debugPrint('📦 Payload: $payload');
      debugPrint('⏳ Making API call...');

      await _apiFetcher.request(
        url: 'api/auth/send-otp',
        method: 'POST',
        body: payload,
        requireAuth: false,
      );

      debugPrint('');
      debugPrint('📥 ========== API RESPONSE ==========');
      debugPrint('📊 Response Data: ${_apiFetcher.data}');
      debugPrint('❌ Error Message: ${_apiFetcher.errorMessage}');
      debugPrint('====================================');
      debugPrint('');

      debugPrint('🔍 Checking API response...');
      debugPrint('   errorMessage == null? ${_apiFetcher.errorMessage == null}');
      debugPrint('   data != null? ${_apiFetcher.data != null}');

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ API call SUCCESSFUL!');

        // Extract OTP from response (if API returns it in development)
        String? otp;

        if (_apiFetcher.data is Map) {
          debugPrint('📋 Response is a Map, checking for OTP...');
          debugPrint('   Keys in response: ${_apiFetcher.data.keys.toList()}');

          // Try direct access first
          if (_apiFetcher.data.containsKey('otp')) {
            otp = _apiFetcher.data['otp'].toString();
            debugPrint('🔑 OTP found (direct): $otp');
          }
          // Try nested access
          else if (_apiFetcher.data.containsKey('data') &&
                   _apiFetcher.data['data'] is Map &&
                   _apiFetcher.data['data'].containsKey('otp')) {
            otp = _apiFetcher.data['data']['otp'].toString();
            debugPrint('🔑 OTP found (nested): $otp');
          } else {
            debugPrint('⚠️ No OTP key found in response');
          }
        }

        // Store OTP if received, otherwise leave empty (user will type manually)
        if (otp != null) {
          receivedOtp.value = otp;
          debugPrint('✅ receivedOtp set to: "${receivedOtp.value}"');
          debugPrint('✅ OTP will be auto-filled');
        } else {
          receivedOtp.value = '';
          debugPrint('✅ receivedOtp set to: "" (empty)');
          debugPrint('📝 No OTP in response - User will type manually');
        }

        debugPrint('');
        debugPrint('🔔 CRITICAL: Setting isOtpSent to TRUE');
        debugPrint('   Before: isOtpSent = ${isOtpSent.value}');
        isOtpSent.value = true;
        debugPrint('   After: isOtpSent = ${isOtpSent.value}');
        debugPrint('   This should trigger _buildOtpSection to show!');
        debugPrint('');

        _startResendTimer();
        debugPrint('✅ Resend timer started');

        AdvancedErrorService.showSuccess(
          'OTP sent to +91$formattedPhone',
          type: SuccessType.snackbar,
        );
        debugPrint('✅ Success message shown');
        debugPrint('🏁 ==================== SEND OTP COMPLETED SUCCESSFULLY ====================');
        debugPrint('');
      } else {
        debugPrint('❌ API call FAILED!');
        debugPrint('   Error: ${_apiFetcher.errorMessage}');
        debugPrint('🏁 ==================== SEND OTP FAILED ====================');
        debugPrint('');
        throw Exception(_apiFetcher.errorMessage ?? 'Failed to send OTP');
      }
    } catch (e) {
      debugPrint('');
      debugPrint('💥 ========== EXCEPTION CAUGHT ==========');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      debugPrint('🔍 Current State:');
      debugPrint('   isOtpSent: ${isOtpSent.value}');
      debugPrint('   isSendingOtp: ${isSendingOtp.value}');
      debugPrint('   receivedOtp: "${receivedOtp.value}"');
      debugPrint('=========================================');
      debugPrint('');

      AdvancedErrorService.showError(
        'Failed to send OTP: $e',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.network,
      );
    } finally {
      debugPrint('🔄 Finally block executing...');
      debugPrint('   Setting isSendingOtp to false');
      isSendingOtp.value = false;
      debugPrint('✅ isSendingOtp = ${isSendingOtp.value}');
      debugPrint('🏁 ==================== SEND OTP FUNCTION ENDED ====================');
      debugPrint('');
    }
  }

  Future<void> verifyOwnerOtp(String otp) async {
    try {
      // ✅ Check if OTP is expired
      if (isOtpExpired.value) {
        debugPrint('⏰ OTP verification failed - OTP has expired');
        AdvancedErrorService.showError(
          'OTP has expired. Please request a new OTP.',
          severity: ErrorSeverity.medium,
          category: ErrorCategory.validation,
        );
        return;
      }

      isLoading.value = true;

      debugPrint('🔐 Verifying OTP: $otp');
      debugPrint('📱 Owner phone: $ownerPhone');

      // Prepare phone number (remove +91 if present, API expects just 10 digits)
      String formattedPhone = ownerPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (formattedPhone.startsWith('91') && formattedPhone.length == 12) {
        formattedPhone = formattedPhone.substring(2);
      }

      final payload = {
        'mobileNumber': formattedPhone,
        'otp': otp,
      };

      debugPrint('📡 Calling verify-otp API with payload: $payload');

      await _apiFetcher.request(
        url: 'api/auth/verify-otp',
        method: 'POST',
        body: payload,
        requireAuth: false,
      );

      debugPrint('📥 API Response: ${_apiFetcher.data}');
      debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ OTP verified successfully! Owner number verified');

        // Mark as verified
        isOwnerOtpVerified.value = true;

        AdvancedErrorService.showSuccess(
          'Master mobile number verified successfully',
          type: SuccessType.snackbar,
        );
      } else {
        throw Exception(_apiFetcher.errorMessage ?? 'Invalid OTP');
      }
    } catch (e) {
      debugPrint('❌ Error verifying OTP: $e');
      AdvancedErrorService.showError(
        'Invalid OTP. Please try again.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendTimer() {
    isResendAvailable.value = false;
    isOtpExpired.value = false; // ✅ Reset expiry flag
    resendTimer.value = 30;

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        isResendAvailable.value = true;
        isOtpExpired.value = true; // ✅ Mark OTP as expired
        debugPrint('⏰ OTP EXPIRED after 30 seconds');
        timer.cancel();
      }
    });
  }

  Future<bool> submitMerchantDetails(MerchantModel merchant) async {
    try {
      debugPrint('');
      debugPrint('🚀 ==================== SUBMIT MERCHANT STARTED ====================');
      debugPrint('📝 Submitting merchant details...');
      debugPrint('   Merchant: ${merchant.toString()}');

      // ✅ FIRST: Check if merchant already exists
      debugPrint('');
      debugPrint('🔍 Step 1: Checking if merchant already exists...');
      await _fetchExistingMerchant();

      final existingMerchantId = await AuthStorage.getMerchantId();
      if (existingMerchantId != null) {
        debugPrint('✅ Merchant already exists with ID: $existingMerchantId');
        debugPrint('✅ Skipping POST - using existing merchant');
        return true;
      }
      debugPrint('📝 No existing merchant found - proceeding with creation...');
      debugPrint('');

      final payload = merchant.toJson();
      debugPrint('');
      debugPrint('📡 ========== API PAYLOAD DETAILS ==========');
      debugPrint('📦 Full Payload (JSON): ${payload.toString()}');
      debugPrint('📋 Payload Keys: ${payload.keys.toList()}');
      debugPrint('📋 Payload Values: ${payload.values.toList()}');
      debugPrint('📊 Payload Size: ${payload.length} fields');

      // Log each field individually for clarity
      payload.forEach((key, value) {
        debugPrint('   [$key] = "$value" (${value.runtimeType})');
      });
      debugPrint('==========================================');
      debugPrint('');

      // Verify token exists before making API call
      final token = await AuthStorage.getValidToken();
      debugPrint('');
      debugPrint('🔐 ========== AUTHENTICATION CHECK ==========');
      if (token == null) {
        debugPrint('❌ CRITICAL: No valid auth token found!');
        debugPrint('   User needs to login again');
        throw Exception('Authentication token missing or expired');
      } else {
        debugPrint('✅ Auth token exists: ${token.substring(0, 20)}...');
        final expiryTime = await AuthStorage.getTokenExpirationTime();
        if (expiryTime != null) {
          debugPrint('⏰ Token expires at: $expiryTime');
          final timeLeft = expiryTime.difference(DateTime.now());
          debugPrint('⏳ Time left: ${timeLeft.inMinutes} minutes');
        }
      }
      debugPrint('==========================================');
      debugPrint('');

      // Make the actual API call
      debugPrint('📡 Calling POST api/merchant...');
      debugPrint('🌐 Full URL: ${_apiFetcher.baseUri}api/merchant');
      debugPrint('🔐 Auth Required: true');
      await _apiFetcher.request(
        url: 'api/merchant',
        method: 'POST',
        body: payload,
        requireAuth: true,
      );

      debugPrint('📥 API Response (Full): ${_apiFetcher.data}');
      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');

      // Check if merchant already exists (handle both "already exists" and "can't be change" messages)
      if (_apiFetcher.errorMessage != null &&
          (_apiFetcher.errorMessage!.toLowerCase().contains('already exists') ||
           _apiFetcher.errorMessage!.toLowerCase().contains("can't be change") ||
           _apiFetcher.errorMessage!.toLowerCase().contains("cannot be change"))) {
        debugPrint('⚠️ Merchant already exists or mobile number cannot be changed');

        // Try to get existing merchant data
        await _fetchExistingMerchant();

        debugPrint('✅ Merchant already registered, proceeding to main screen');
        return true;
      }

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Merchant details submitted successfully');
        debugPrint('📥 POST Response Full Data: ${_apiFetcher.data}');
        debugPrint('📥 POST Response Type: ${_apiFetcher.data.runtimeType}');
        debugPrint('🔍 Response data keys: ${_apiFetcher.data is Map ? _apiFetcher.data.keys.toList() : 'Not a map'}');

        // Extract and save merchantId from response
        int? merchantId;

        if (_apiFetcher.data is Map) {
          // Try different possible field names
          if (_apiFetcher.data['merchantId'] != null) {
            merchantId = int.tryParse(_apiFetcher.data['merchantId'].toString());
          } else if (_apiFetcher.data['id'] != null) {
            merchantId = int.tryParse(_apiFetcher.data['id'].toString());
          } else if (_apiFetcher.data['_id'] != null) {
            merchantId = int.tryParse(_apiFetcher.data['_id'].toString());
          } else if (_apiFetcher.data['data'] is Map && _apiFetcher.data['data']['merchantId'] != null) {
            // Check nested data object
            merchantId = int.tryParse(_apiFetcher.data['data']['merchantId'].toString());
          }
        }

        if (merchantId != null) {
          await AuthStorage.saveMerchantId(merchantId);
          debugPrint('🏢 Merchant ID saved from POST response: $merchantId');
        } else {
          debugPrint('⚠️ No merchantId in POST response, fetching from GET api/merchant...');
          // Fetch merchant data to get the ID
          await _fetchExistingMerchant();
        }

        return true;
      } else {
        // ✅ Enhanced error message for debugging
        String detailedError = _apiFetcher.errorMessage ?? 'Failed to submit merchant details';
        debugPrint('');
        debugPrint('🔴 ========== MERCHANT API FAILED ==========');
        debugPrint('❌ Error Message: $detailedError');
        debugPrint('📊 Error Response Data: ${_apiFetcher.data}');
        debugPrint('🔍 Error Type: ${_apiFetcher.data.runtimeType}');

        if (_apiFetcher.data is Map) {
          debugPrint('📋 Error Data Keys: ${_apiFetcher.data.keys.toList()}');
          debugPrint('📋 Status Code: ${_apiFetcher.data['statusCode']}');
          debugPrint('📋 Message: ${_apiFetcher.data['message']}');
        }
        debugPrint('==========================================');
        debugPrint('');

        throw Exception(detailedError);
      }
    } catch (e) {
      debugPrint('❌ Error submitting merchant details: $e');

      // Check if error message contains "already exists" or "can't be change"
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already exists') ||
          errorStr.contains("can't be change") ||
          errorStr.contains("cannot be change")) {
        debugPrint('⚠️ Merchant already exists (caught in exception), proceeding anyway');

        // Try to fetch existing merchant data
        await _fetchExistingMerchant();

        return true;
      }

      return false;
    }
  }

  /// Fetch existing merchant data from GET api/merchant
  Future<void> _fetchExistingMerchant() async {
    try {
      debugPrint('📡 Fetching existing merchant details...');

      await _apiFetcher.request(
        url: 'api/merchant',
        method: 'GET',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Existing merchant data fetched successfully');
        debugPrint('📊 Response data type: ${_apiFetcher.data.runtimeType}');
        debugPrint('📊 Response data: ${_apiFetcher.data}');

        dynamic merchantData;

        // Handle different response formats
        if (_apiFetcher.data is List && (_apiFetcher.data as List).isNotEmpty) {
          // Response is an array, get first item
          merchantData = (_apiFetcher.data as List)[0];
          debugPrint('📋 Extracted merchant from array: $merchantData');
        } else if (_apiFetcher.data is Map) {
          // Response is a map
          merchantData = _apiFetcher.data;
        } else if (_apiFetcher.data is List && (_apiFetcher.data as List).isEmpty) {
          debugPrint('❌ CRITICAL: API returned empty array - merchant does NOT exist in database');
          debugPrint('⚠️ This should NOT happen after successful merchant creation');
          debugPrint('💡 Please check backend logs - merchant creation might have failed silently');

          // DO NOT use phone number as fallback - this causes permission errors
          // The merchant must exist in database for ledger operations to work
          throw Exception('Merchant not found in database after creation. Please contact support.');
        }

        // Extract and save merchantId from merchant data
        if (merchantData != null && merchantData is Map) {
          int? merchantId;

          if (merchantData['merchantId'] != null) {
            merchantId = int.tryParse(merchantData['merchantId'].toString());
            if (merchantId != null) {
              await AuthStorage.saveMerchantId(merchantId);
              debugPrint('🏢 Existing Merchant ID saved: $merchantId');
            }
          } else if (merchantData['id'] != null) {
            // Try 'id' field if 'merchantId' not found
            merchantId = int.tryParse(merchantData['id'].toString());
            if (merchantId != null) {
              await AuthStorage.saveMerchantId(merchantId);
              debugPrint('🏢 Existing Merchant ID saved (from id field): $merchantId');
            }
          } else if (merchantData['_id'] != null) {
            // Try '_id' field (MongoDB style)
            merchantId = int.tryParse(merchantData['_id'].toString());
            if (merchantId != null) {
              await AuthStorage.saveMerchantId(merchantId);
              debugPrint('🏢 Existing Merchant ID saved (from _id field): $merchantId');
            }
          }

          // If no merchantId found or couldn't parse, use phone number as fallback
          if (merchantId == null) {
            debugPrint('⚠️ No merchantId found in response data');
            debugPrint('📋 Available keys: ${merchantData.keys.toList()}');

            // Use phone number as fallback
            final phoneNumber = await AuthStorage.getPhoneNumber();
            if (phoneNumber != null) {
              final phoneDigits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
              final fallbackId = int.tryParse(phoneDigits) ?? 0;
              if (fallbackId > 0) {
                await AuthStorage.saveMerchantId(fallbackId);
                debugPrint('🏢 Saved phone number as merchant ID fallback: $fallbackId');
              }
            }
          }
        }
      } else {
        debugPrint('⚠️ Could not fetch existing merchant data: ${_apiFetcher.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching existing merchant: $e');
      // Don't throw - this is a fallback, merchant already exists anyway
    }
  }
}
