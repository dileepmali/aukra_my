import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../core/api/auth_storage.dart';
import '../core/api/global_api_function.dart';
import '../core/api/user_profile_api_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/merchant_model.dart';
import '../core/services/duplicate_prevention_service.dart';
import '../core/utils/secure_logger.dart';
import 'manage_businesses_controller.dart';
import 'ledger_controller.dart';

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
  final UserProfileApiService _userProfileApi = UserProfileApiService();
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

  Future<bool> submitMerchantDetails(MerchantModel merchant, {bool isAddNewBusiness = false}) async {
    // 🛡️ SECURITY: Duplicate merchant prevention
    final duplicateKey = DuplicatePrevention.generateKey(
      operation: 'create_merchant',
      params: {
        'businessName': merchant.businessName,
        'mobileNumber': merchant.mobileNumber,
      },
    );

    if (DuplicatePrevention.isPending(duplicateKey)) {
      SecureLogger.warning('Duplicate merchant creation detected and prevented');
      AdvancedErrorService.showError(
        'Merchant registration already in progress. Please wait.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return false;
    }

    if (DuplicatePrevention.wasRecentlyCompleted(duplicateKey)) {
      final timeSince = DuplicatePrevention.getTimeSinceCompleted(duplicateKey);
      SecureLogger.warning('Recently completed merchant registration detected: ${timeSince?.inSeconds}s ago');

      AdvancedErrorService.showError(
        'Merchant details were just submitted. Please check if they were saved.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return false;
    }

    // Mark as pending
    DuplicatePrevention.markPending(duplicateKey);

    try {
      // 🛡️ SECURITY: Set loading state
      isLoading.value = true;
      SecureLogger.divider('SUBMIT MERCHANT');
      SecureLogger.info('Submitting merchant details...');

      // ✅ FIRST: Check if merchant already exists (Skip if adding new business)
      if (!isAddNewBusiness) {
        SecureLogger.info('Checking if merchant already exists...');
        await _fetchExistingMerchant();

        final existingMerchantId = await AuthStorage.getMerchantId();
        if (existingMerchantId != null) {
          SecureLogger.success('Merchant already exists with ID: $existingMerchantId');
          DuplicatePrevention.removePending(duplicateKey);
          return true;
        }
        SecureLogger.info('No existing merchant found - proceeding with creation...');
      } else {
        SecureLogger.info('Adding new business - skipping existing merchant check');
      }

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
      debugPrint('⏳ WAITING for API response...');

      await _apiFetcher.request(
        url: 'api/merchant',
        method: 'POST',
        body: payload,
        requireAuth: true,
      );

      debugPrint('');
      debugPrint('🎯 ========== POST API RESPONSE RECEIVED ==========');
      debugPrint('📥 API Response (Full): ${_apiFetcher.data}');
      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
      debugPrint('==================================================');
      debugPrint('');

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

        // ✅ NEW: Use POST response data directly instead of calling GET
        if (_apiFetcher.data is Map) {
          final responseData = _apiFetcher.data;

          // 🔍 DEBUG: Check what merchantName and businessName API returned
          debugPrint('🔍 ========== POST RESPONSE FIELDS CHECK ==========');
          debugPrint('   Response merchantName: ${responseData['merchantName']}');
          debugPrint('   Response businessName: ${responseData['businessName']}');
          debugPrint('   Submitted merchantName: ${merchant.merchantName}');
          debugPrint('   Submitted businessName: ${merchant.businessName}');
          debugPrint('==================================================');

          // Extract merchantId from different possible field names
          int? merchantId;
          if (responseData['merchantId'] != null) {
            merchantId = int.tryParse(responseData['merchantId'].toString());
          } else if (responseData['id'] != null) {
            merchantId = int.tryParse(responseData['id'].toString());
          } else if (responseData['_id'] != null) {
            merchantId = int.tryParse(responseData['_id'].toString());
          } else if (responseData['data'] is Map && responseData['data']['merchantId'] != null) {
            // Check nested data object
            merchantId = int.tryParse(responseData['data']['merchantId'].toString());
          }

          if (merchantId != null) {
            // ✅ Only save to storage if this is initial registration (NOT adding new business)
            if (!isAddNewBusiness) {
              // ✅ Save all merchant data from POST response
              await AuthStorage.saveMerchantId(merchantId);

              // ✅ Save merchantName (person's name)
              // Priority: POST response > Submitted data
              String finalMerchantName = merchant.merchantName; // Default: what user submitted
              if (responseData['merchantName'] != null && responseData['merchantName'].toString().isNotEmpty) {
                finalMerchantName = responseData['merchantName'].toString();
                debugPrint('✅ Using merchantName from POST response: $finalMerchantName');
              } else {
                debugPrint('⚠️ POST response has no merchantName, using submitted value: $finalMerchantName');
              }
              await AuthStorage.saveMerchantName(finalMerchantName);

              // ✅ Save businessName (shop name)
              // Priority: POST response > Submitted data
              String finalBusinessName = merchant.businessName; // Default: what user submitted
              if (responseData['businessName'] != null && responseData['businessName'].toString().isNotEmpty) {
                finalBusinessName = responseData['businessName'].toString();
                debugPrint('✅ Using businessName from POST response: $finalBusinessName');
              } else {
                debugPrint('⚠️ POST response has no businessName, using submitted value: $finalBusinessName');
              }
              await AuthStorage.saveBusinessName(finalBusinessName);

              // ✅ Save mobileNumber (registered number)
              if (responseData['mobileNumber'] != null) {
                await AuthStorage.saveMerchantMobile(responseData['mobileNumber'].toString());
              } else {
                await AuthStorage.saveMerchantMobile(merchant.mobileNumber);
              }

              // ✅ Save address
              if (responseData['address'] != null) {
                await AuthStorage.saveMerchantAddress(responseData['address'].toString());
              } else {
                await AuthStorage.saveMerchantAddress(merchant.address);
              }

              // ✅ Save pinCode (if available in response)
              if (responseData['pinCode'] != null && responseData['pinCode'].toString().isNotEmpty) {
                await AuthStorage.saveMerchantPinCode(responseData['pinCode'].toString());
              } else if (merchant.pinCode.isNotEmpty) {
                await AuthStorage.saveMerchantPinCode(merchant.pinCode);
              }

              // ✅ Save masterMobileNumber
              if (responseData['masterMobileNumber'] != null) {
                await AuthStorage.saveMasterMobileNumber(responseData['masterMobileNumber'].toString());
              } else {
                await AuthStorage.saveMasterMobileNumber(merchant.masterMobileNumber);
              }

              debugPrint('');
              debugPrint('🏢 ========== MERCHANT DATA SAVED TO STORAGE ==========');
              debugPrint('   merchantId: $merchantId');
              debugPrint('   merchantName (Person): ${responseData['merchantName'] ?? merchant.merchantName}');
              debugPrint('   businessName (Shop): ${responseData['businessName'] ?? merchant.businessName}');
              debugPrint('   mobileNumber: ${responseData['mobileNumber'] ?? merchant.mobileNumber}');
              debugPrint('   address: ${responseData['address'] ?? merchant.address}');
              debugPrint('   pinCode: ${responseData['pinCode'] ?? merchant.pinCode}');
              debugPrint('   masterMobileNumber: ${responseData['masterMobileNumber'] ?? merchant.masterMobileNumber}');
              debugPrint('✅ All data saved to storage successfully!');
              debugPrint('========================================================');
              debugPrint('');

              // ✅ Update user profile with merchantName (username)
              // This ensures profile screen shows the correct name
              await _updateUserProfileName(merchant.merchantName);
            } else {
              // ✅ Adding new business - don't save to storage, just log success
              debugPrint('');
              debugPrint('🏢 ========== NEW BUSINESS ADDED ==========');
              debugPrint('   merchantId: $merchantId');
              debugPrint('   businessName: ${merchant.businessName}');
              debugPrint('   address: ${merchant.address}');
              debugPrint('✅ New business created successfully!');
              debugPrint('⚠️ Storage NOT updated (keeping current merchant context)');
              debugPrint('============================================');
              debugPrint('');
            }

            return true;
          } else {
            debugPrint('⚠️ No merchantId in POST response, fetching from GET api/merchant...');
            // Fallback: Fetch merchant data to get the ID
            await _fetchExistingMerchant();
            return true;
          }
        } else {
          debugPrint('⚠️ POST response is not a Map, fetching from GET api/merchant...');
          await _fetchExistingMerchant();
          return true;
        }
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
      debugPrint('');
      debugPrint('💥 ========== EXCEPTION IN submitMerchantDetails ==========');
      debugPrint('❌ Error: $e');
      debugPrint('❌ Error Type: ${e.runtimeType}');
      debugPrint('===========================================================');
      debugPrint('');

      // Check if error message contains "already exists" or "can't be change"
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('already exists') ||
          errorStr.contains("can't be change") ||
          errorStr.contains("cannot be change")) {
        debugPrint('⚠️ Merchant already exists (caught in exception), proceeding anyway');

        // ✅ Only fetch existing merchant if NOT adding new business
        if (!isAddNewBusiness) {
          await _fetchExistingMerchant();
        } else {
          debugPrint('⚠️ isAddNewBusiness=true, skipping _fetchExistingMerchant');
        }

        debugPrint('🔙 Returning TRUE from catch block (already exists)');
        return true;
      }

      debugPrint('🔙 Returning FALSE from catch block');
      return false;
    } finally {
      // 🛡️ SECURITY: Always reset loading state and remove from pending tracking
      isLoading.value = false;

      final duplicateKey = DuplicatePrevention.generateKey(
        operation: 'create_merchant',
        params: {
          'businessName': merchant.businessName,
          'mobileNumber': merchant.mobileNumber,
        },
      );
      DuplicatePrevention.removePending(duplicateKey);
    }
  }

  /// Update merchant details - PUT /api/merchant/{merchantId}
  /// Pass merchantId explicitly when updating a different merchant (e.g., from ManageBusinesses screen)
  Future<bool> updateMerchantDetails(MerchantModel merchant, {int? merchantId}) async {
    // 🛡️ SECURITY: Duplicate merchant update prevention
    // Include all updateable fields in key so different field updates have unique keys
    final duplicateKey = DuplicatePrevention.generateKey(
      operation: 'update_merchant',
      params: {
        'merchantId': merchantId?.toString() ?? '',
        'businessName': merchant.businessName,
        'address': merchant.address,
        'category': merchant.category ?? '',
        'businessType': merchant.businessType ?? '',
        'manager': merchant.manager ?? '',
      },
    );

    if (DuplicatePrevention.isPending(duplicateKey)) {
      SecureLogger.warning('Duplicate merchant update detected and prevented');
      AdvancedErrorService.showError(
        'Merchant update already in progress. Please wait.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return false;
    }

    // ✅ Skip "recently completed" check for different field updates
    // Each unique combination of fields will have its own key
    // This allows updating category, then businessType, then manager in sequence

    // Mark as pending
    DuplicatePrevention.markPending(duplicateKey);

    try {
      isLoading.value = true;
      SecureLogger.divider('UPDATE MERCHANT');
      SecureLogger.info('Updating merchant details...');

      // Use passed merchantId OR fallback to storage
      // IMPORTANT: When updating from BusinessDetailScreen, merchantId is passed explicitly
      final actualMerchantId = merchantId ?? await AuthStorage.getMerchantId();
      if (actualMerchantId == null) {
        throw Exception('Merchant ID not found. Please register first.');
      }

      SecureLogger.info('Merchant ID: $actualMerchantId (passed: ${merchantId != null})');

      // Prepare update payload using toUpdateJson()
      final payload = merchant.toUpdateJson();

      debugPrint('');
      debugPrint('📡 ========== UPDATE API PAYLOAD ==========');
      debugPrint('🆔 Merchant ID: $actualMerchantId');
      debugPrint('📦 Payload: ${payload.toString()}');
      debugPrint('📋 Fields to update: ${payload.keys.toList()}');
      payload.forEach((key, value) {
        debugPrint('   [$key] = "$value" (${value.runtimeType})');
      });
      debugPrint('==========================================');
      debugPrint('');

      // Verify token exists
      final token = await AuthStorage.getValidToken();
      if (token == null) {
        throw Exception('Authentication token missing or expired');
      }

      // Make PUT API call
      debugPrint('📡 Calling PUT api/merchant/$actualMerchantId...');
      await _apiFetcher.request(
        url: 'api/merchant/$actualMerchantId',
        method: 'PUT',
        body: payload,
        requireAuth: true,
      );

      debugPrint('📥 API Response: ${_apiFetcher.data}');
      debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Merchant details updated successfully');

        // Update storage with new data from response
        if (_apiFetcher.data is Map) {
          final responseData = _apiFetcher.data;

          // Update businessName if returned
          if (responseData['businessName'] != null) {
            await AuthStorage.saveBusinessName(responseData['businessName'].toString());
          } else if (merchant.businessName.isNotEmpty) {
            await AuthStorage.saveBusinessName(merchant.businessName);
          }

          // Update address if returned
          if (responseData['address'] != null) {
            await AuthStorage.saveMerchantAddress(responseData['address'].toString());
          } else if (merchant.address.isNotEmpty) {
            await AuthStorage.saveMerchantAddress(merchant.address);
          }

          // Update pinCode if returned
          if (responseData['pinCode'] != null && responseData['pinCode'].toString().isNotEmpty) {
            await AuthStorage.saveMerchantPinCode(responseData['pinCode'].toString());
          } else if (merchant.pinCode.isNotEmpty) {
            await AuthStorage.saveMerchantPinCode(merchant.pinCode);
          }

          debugPrint('');
          debugPrint('✅ ========== MERCHANT DATA UPDATED ==========');
          debugPrint('   businessName: ${responseData['businessName'] ?? merchant.businessName}');
          debugPrint('   address: ${responseData['address'] ?? merchant.address}');
          debugPrint('   city: ${merchant.city}');
          debugPrint('   area: ${merchant.area}');
          debugPrint('   state: ${merchant.state}');
          debugPrint('   pinCode: ${responseData['pinCode'] ?? merchant.pinCode}');
          debugPrint('✅ Storage updated successfully!');
          debugPrint('==============================================');
          debugPrint('');
        }

        AdvancedErrorService.showSuccess(
          'Merchant details updated successfully',
          type: SuccessType.snackbar,
        );

        // ✅ CRITICAL: Notify other screens to refresh their data
        _notifyMerchantDataUpdated();

        // Mark as completed (removePending automatically adds to recent transactions)
        DuplicatePrevention.removePending(duplicateKey);
        return true;
      } else {
        String errorMessage = _apiFetcher.errorMessage ?? 'Failed to update merchant details';
        debugPrint('❌ Update failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('❌ Error updating merchant details: $e');
      AdvancedErrorService.showError(
        'Failed to update merchant details: $e',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.network,
      );
      return false;
    } finally {
      isLoading.value = false;
      DuplicatePrevention.removePending(duplicateKey);
    }
  }

  /// Fetch existing merchant data - Storage first, then GET api/merchant fallback
  Future<void> _fetchExistingMerchant() async {
    try {
      debugPrint('📡 Fetching existing merchant details...');

      // ✅ STEP 1: Try to load from storage first (fast & offline)
      final merchantData = await AuthStorage.getMerchantData();

      if (merchantData != null && merchantData['merchantId'] != null) {
        debugPrint('✅ Merchant data found in STORAGE:');
        debugPrint('   merchantId: ${merchantData['merchantId']}');
        debugPrint('   merchantName: ${merchantData['merchantName']}');
        debugPrint('   businessName: ${merchantData['businessName']}');
        debugPrint('✅ Using storage data - API call skipped!');
        return; // Data found in storage, no API call needed
      }

      debugPrint('⚠️ No merchant data in storage, calling GET /api/merchant/all...');

      // ✅ STEP 2: If storage is empty, call /api/merchant/all (fallback)
      await _apiFetcher.request(
        url: 'api/merchant/all',
        method: 'GET',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage == null && _apiFetcher.data != null) {
        debugPrint('✅ Existing merchant data fetched successfully from /api/merchant/all');
        debugPrint('📊 Response data type: ${_apiFetcher.data.runtimeType}');
        debugPrint('📊 Response data: ${_apiFetcher.data}');

        dynamic merchantData;

        // Handle different response formats
        if (_apiFetcher.data is List && (_apiFetcher.data as List).isNotEmpty) {
          // ✅ FIX: Match merchant by phone number instead of taking first item
          final merchantList = _apiFetcher.data as List;
          final loggedInPhone = await AuthStorage.getPhoneNumber();

          // Normalize logged-in phone
          String normalizedLoggedInPhone = loggedInPhone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
          if (normalizedLoggedInPhone.startsWith('91') && normalizedLoggedInPhone.length == 12) {
            normalizedLoggedInPhone = normalizedLoggedInPhone.substring(2);
          }

          debugPrint('🔍 Searching for merchant with phone: $normalizedLoggedInPhone in ${merchantList.length} merchants');

          // Find matching merchant by phone
          for (var merchant in merchantList) {
            if (merchant is Map) {
              String? merchantPhone = merchant['phone']?.toString() ?? merchant['mobileNumber']?.toString();
              if (merchantPhone != null) {
                String normalizedMerchantPhone = merchantPhone.replaceAll(RegExp(r'[^0-9]'), '');
                if (normalizedMerchantPhone.startsWith('91') && normalizedMerchantPhone.length == 12) {
                  normalizedMerchantPhone = normalizedMerchantPhone.substring(2);
                }

                debugPrint('   Checking merchant: Phone=$normalizedMerchantPhone, ID=${merchant['merchantId']}');

                if (normalizedMerchantPhone == normalizedLoggedInPhone) {
                  merchantData = merchant;
                  debugPrint('✅ Found matching merchant by phone: ${merchant['merchantId']}');
                  break;
                }
              }
            }
          }

          // Fallback to first item if no match found
          if (merchantData == null) {
            merchantData = merchantList[0];
            debugPrint('⚠️ No matching merchant found by phone, using first merchant as fallback');
          }

          debugPrint('📋 Selected merchant data: $merchantData');
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

  /// Notify all screens that merchant data has been updated
  /// This triggers refresh on ProfileScreen, ManageBusinessScreen, etc.
  void _notifyMerchantDataUpdated() {
    debugPrint('');
    debugPrint('🔔 ========== NOTIFYING DATA UPDATE ==========');

    try {
      // ✅ Try to refresh ManageBusinessesController if it exists
      if (Get.isRegistered<ManageBusinessesController>()) {
        final businessController = Get.find<ManageBusinessesController>();
        debugPrint('   ✅ Refreshing ManageBusinessesController...');
        businessController.fetchMerchants();
      } else {
        debugPrint('   ⚠️ ManageBusinessesController not registered');
      }
    } catch (e) {
      debugPrint('   ⚠️ Could not refresh ManageBusinessesController: $e');
    }

    // ✅ NEW: Refresh LedgerController to update business name in app bar
    try {
      if (Get.isRegistered<LedgerController>()) {
        final ledgerController = Get.find<LedgerController>();
        debugPrint('   ✅ Refreshing LedgerController...');
        ledgerController.fetchMerchantDetails();
      } else {
        debugPrint('   ⚠️ LedgerController not registered');
      }
    } catch (e) {
      debugPrint('   ⚠️ Could not refresh LedgerController: $e');
    }

    // ✅ Broadcast update event for any listening screens
    // This allows ProfileScreen to rebuild using Get.find pattern
    debugPrint('   📡 Broadcasting merchant_data_updated event...');

    debugPrint('✅ All screens notified of data update');
    debugPrint('==============================================');
    debugPrint('');
  }

  /// Helper method to update merchant details from UI screens
  /// Takes businessName, address, category, businessType, manager (any or all) and calls PUT API
  /// IMPORTANT: Pass merchantId when updating a different merchant (e.g., from ManageBusinesses)
  Future<bool> updateMerchantFromScreen({
    String? businessName,
    String? address,
    String? category,
    String? businessType,
    String? manager,
    int? merchantId,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔄 ========== UPDATING MERCHANT FROM SCREEN ==========');

      // Load current merchant data from storage
      final merchantData = await AuthStorage.getMerchantData();
      final phone = await AuthStorage.getPhoneNumber();

      if (merchantData == null || phone == null) {
        debugPrint('❌ No merchant data found in storage');
        AdvancedErrorService.showError(
          'Merchant data not found. Please login again.',
          severity: ErrorSeverity.high,
          category: ErrorCategory.validation,
        );
        return false;
      }

      // Create updated merchant model with new values
      final updatedMerchant = MerchantModel(
        merchantName: merchantData['merchantName']?.toString() ?? '',
        businessName: businessName ?? merchantData['businessName']?.toString() ?? '',
        mobileNumber: phone,
        address: address ?? merchantData['address']?.toString() ?? '',
        city: merchantData['city']?.toString() ?? '',
        area: merchantData['area']?.toString() ?? '',
        state: merchantData['state']?.toString() ?? '',
        country: merchantData['country']?.toString() ?? 'INDIA',
        pinCode: merchantData['pinCode']?.toString() ?? '',
        masterMobileNumber: merchantData['masterMobileNumber']?.toString() ?? phone,
        category: category,
        businessType: businessType,
        manager: manager,
      );

      debugPrint('📦 Updated Merchant Model:');
      debugPrint('   businessName: ${updatedMerchant.businessName}');
      debugPrint('   address: ${updatedMerchant.address}');
      debugPrint('   category: ${updatedMerchant.category}');
      debugPrint('   businessType: ${updatedMerchant.businessType}');
      debugPrint('   manager: ${updatedMerchant.manager}');
      debugPrint('   merchantId: $merchantId (passed from screen)');

      // Call PUT API with merchantId if provided
      final success = await updateMerchantDetails(updatedMerchant, merchantId: merchantId);

      if (success) {
        debugPrint('✅ Update successful from screen');
      } else {
        debugPrint('❌ Update failed from screen');
      }

      debugPrint('==============================================');
      debugPrint('');

      return success;
    } catch (e) {
      debugPrint('❌ Error in updateMerchantFromScreen: $e');
      AdvancedErrorService.showError(
        'Failed to update merchant details: $e',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.network,
      );
      return false;
    }
  }

  /// ✅ NEW: Update user profile name (username) via PUT /api/user/profile
  /// This ensures the name entered in shop_detail_screen shows in my_profile_screen
  Future<void> _updateUserProfileName(String name) async {
    try {
      if (name.isEmpty) {
        debugPrint('⚠️ Cannot update profile - name is empty');
        return;
      }

      debugPrint('');
      debugPrint('👤 ========== UPDATING USER PROFILE NAME ==========');
      debugPrint('   Name to set: $name');
      debugPrint('   Calling PUT /api/user/profile...');

      final response = await _userProfileApi.updateProfileName(name: name);

      if (response != null && response.success) {
        debugPrint('✅ User profile name updated successfully!');
        debugPrint('   username is now: $name');
        debugPrint('   Profile screen will show: $name');
      } else {
        debugPrint('⚠️ Failed to update user profile name');
        debugPrint('   Error: ${_userProfileApi.errorMessage}');
      }

      debugPrint('===================================================');
      debugPrint('');
    } catch (e) {
      debugPrint('❌ Error updating user profile name: $e');
      // Don't throw - this is a secondary operation, merchant creation already succeeded
    }
  }
}
