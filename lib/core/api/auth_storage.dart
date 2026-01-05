import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:get/get_core/src/get_main.dart';

class AuthStorage {
  static const _tokenKey = "auth_token";
  static const _phoneNumberKey = "phone_number";
  static const _shopDetailsCompleteKey = "shop_details_complete";
  static const _merchantIdKey = "merchant_id";
  static const _userIdKey = "user_id";
  static const _merchantNameKey = "merchant_name";
  static const _businessNameKey = "business_name";
  // ✅ NEW: Additional merchant data fields (from POST response)
  static const _merchantMobileKey = "merchant_mobile";
  static const _merchantAddressKey = "merchant_address";
  static const _merchantPinCodeKey = "merchant_pincode";
  static const _masterMobileNumberKey = "master_mobile_number";
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Phone Number Methods
  static Future<void> savePhoneNumber(String phoneNumber) async {
    await _storage.write(key: _phoneNumberKey, value: phoneNumber);
  }

  static Future<String?> getPhoneNumber() async {
    return await _storage.read(key: _phoneNumberKey);
  }

  static Future<void> clearPhoneNumber() async {
    await _storage.delete(key: _phoneNumberKey);
  }

  // Shop Details Methods
  static Future<void> markShopDetailsComplete() async {
    await _storage.write(key: _shopDetailsCompleteKey, value: 'true');
  }

  static Future<bool> hasShopDetails() async {
    final value = await _storage.read(key: _shopDetailsCompleteKey);
    return value == 'true';
  }

  static Future<void> clearShopDetails() async {
    await _storage.delete(key: _shopDetailsCompleteKey);
  }

  // Merchant ID Methods
  static Future<void> saveMerchantId(int merchantId) async {
    await _storage.write(key: _merchantIdKey, value: merchantId.toString());
  }

  static Future<int?> getMerchantId() async {
    final value = await _storage.read(key: _merchantIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<void> clearMerchantId() async {
    await _storage.delete(key: _merchantIdKey);
  }

  // User ID Methods
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  static Future<void> clearUserId() async {
    await _storage.delete(key: _userIdKey);
  }

  // Merchant Name Methods
  static Future<void> saveMerchantName(String merchantName) async {
    await _storage.write(key: _merchantNameKey, value: merchantName);
  }

  static Future<String?> getMerchantName() async {
    return await _storage.read(key: _merchantNameKey);
  }

  static Future<void> clearMerchantName() async {
    await _storage.delete(key: _merchantNameKey);
  }

  // ✅ NEW: Business Name Methods
  static Future<void> saveBusinessName(String businessName) async {
    await _storage.write(key: _businessNameKey, value: businessName);
  }

  static Future<String?> getBusinessName() async {
    return await _storage.read(key: _businessNameKey);
  }

  static Future<void> clearBusinessName() async {
    await _storage.delete(key: _businessNameKey);
  }

  // ✅ NEW: Merchant Mobile Methods
  static Future<void> saveMerchantMobile(String mobile) async {
    await _storage.write(key: _merchantMobileKey, value: mobile);
  }

  static Future<String?> getMerchantMobile() async {
    return await _storage.read(key: _merchantMobileKey);
  }

  static Future<void> clearMerchantMobile() async {
    await _storage.delete(key: _merchantMobileKey);
  }

  // ✅ NEW: Merchant Address Methods
  static Future<void> saveMerchantAddress(String address) async {
    await _storage.write(key: _merchantAddressKey, value: address);
  }

  static Future<String?> getMerchantAddress() async {
    return await _storage.read(key: _merchantAddressKey);
  }

  static Future<void> clearMerchantAddress() async {
    await _storage.delete(key: _merchantAddressKey);
  }

  // ✅ NEW: Merchant PinCode Methods
  static Future<void> saveMerchantPinCode(String pinCode) async {
    await _storage.write(key: _merchantPinCodeKey, value: pinCode);
  }

  static Future<String?> getMerchantPinCode() async {
    return await _storage.read(key: _merchantPinCodeKey);
  }

  static Future<void> clearMerchantPinCode() async {
    await _storage.delete(key: _merchantPinCodeKey);
  }

  // ✅ NEW: Master Mobile Number Methods
  static Future<void> saveMasterMobileNumber(String mobile) async {
    await _storage.write(key: _masterMobileNumberKey, value: mobile);
  }

  static Future<String?> getMasterMobileNumber() async {
    return await _storage.read(key: _masterMobileNumberKey);
  }

  static Future<void> clearMasterMobileNumber() async {
    await _storage.delete(key: _masterMobileNumberKey);
  }

  // ✅ NEW: Get complete merchant data as Map (useful for replacing GET API calls)
  /// Returns complete merchant data from storage (alternative to GET api/merchant)
  /// Returns null if merchantId is not found
  static Future<Map<String, dynamic>?> getMerchantData() async {
    final merchantId = await getMerchantId();

    // If no merchantId, return null (merchant not registered yet)
    if (merchantId == null) {
      return null;
    }

    // Build merchant data map from storage
    final merchantData = <String, dynamic>{
      'merchantId': merchantId,
      'merchantName': await getMerchantName() ?? '',
      'businessName': await getBusinessName() ?? '',
      'mobileNumber': await getMerchantMobile() ?? '',
      'address': await getMerchantAddress() ?? '',
      'pinCode': await getMerchantPinCode() ?? '',
      'masterMobileNumber': await getMasterMobileNumber() ?? '',
    };

    return merchantData;
  }

  /// Check if JWT token exists and is valid (not expired)
  static Future<bool> isTokenValid() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      return !_isTokenExpired(token);
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  /// Get valid token or null if expired/invalid
  static Future<String?> getValidToken() async {
    try {
      final token = await getToken();

      print('🔍 ========== TOKEN VALIDATION ==========');
      print('Token exists: ${token != null}');

      if (token == null || token.isEmpty) {
        print('❌ No token found in storage');
        print('========================================');
        return null;
      }

      print('Token preview: ${token.substring(0, 20)}...');

      // Check if token is expired
      final isExpired = _isTokenExpired(token);
      print('Token expired: $isExpired');

      if (isExpired) {
        // Get expiry time for debugging
        final expiryTime = getTokenExpirationTime();
        print('❌ Token EXPIRED!');
        print('   Expiry time: ${expiryTime != null ? expiryTime.toString() : "unknown"}');
        print('   Current time: ${DateTime.now()}');
        print('   Clearing expired token from storage...');
        print('========================================');

        // Token is expired, remove it from storage
        await clearToken();
        return null;
      }

      print('✅ Token is VALID');
      print('========================================');
      return token;
    } catch (e) {
      print('');
      print('❌ ERROR in getValidToken: $e');
      print('   Clearing potentially corrupted token...');
      print('========================================');
      print('');
      await clearToken(); // Clear potentially corrupted token
      return null;
    }
  }

  static Future<void> logout({bool clearControllers = true}) async {
    try {
      // Clear JWT token
      await clearToken();

      // Clear phone number
      await clearPhoneNumber();

      // Clear shop details flag
      await clearShopDetails();

      // Clear merchant ID
      await clearMerchantId();

      // Clear user ID
      await clearUserId();

      // Clear merchant name
      await clearMerchantName();

      // Clear business name
      await clearBusinessName();

      // ✅ NEW: Clear all merchant data
      await clearMerchantMobile();
      await clearMerchantAddress();
      await clearMerchantPinCode();
      await clearMasterMobileNumber();

      // Optionally clear other cached data
      // await _storage.deleteAll();  // अगर सारे keys clear करने हों

      // Clear GetX controllers (optional)
      if (clearControllers) {
        Get.deleteAll(force: true);
      }

      print("✅ User logged out successfully.");
      print("📱 Phone number cleared from storage.");
      print("🏪 Shop details cleared from storage.");
      print("🏢 Merchant data cleared from storage.");
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }


  /// Check if JWT token is expired
  static bool _isTokenExpired(String token) {
    try {
      print('🔍 Checking token expiration...');

      // Split JWT token into parts
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid token format: Expected 3 parts, got ${parts.length}');
        return true; // Invalid token format
      }

      print('✅ Token format valid (3 parts)');

      // Decode payload (second part)
      final payload = parts[1];

      // Add padding if needed for base64 decoding
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      // Decode base64
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);
      final payloadMap = json.decode(decodedPayload) as Map<String, dynamic>;

      print('✅ Token decoded successfully');
      print('Payload keys: ${payloadMap.keys.toList()}');

      // Check expiration time
      final exp = payloadMap['exp'];
      if (exp == null) {
        print('❌ No expiration time in token payload');
        print('⚠️ WARNING: Token has no exp field - treating as VALID (no expiry)');
        return false; // ✅ FIXED: No expiration means token doesn't expire
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final currentTime = DateTime.now();
      final timeLeft = expirationTime.difference(currentTime);

      print('Token expiry time: $expirationTime');
      print('Current time: $currentTime');
      print('Time left: ${timeLeft.inMinutes} minutes (${timeLeft.inSeconds} seconds)');

      final isExpired = currentTime.isAfter(expirationTime);
      print('Is expired: $isExpired');

      return isExpired;
    } catch (e, stackTrace) {
      print('');
      print('❌ ERROR checking token expiration: $e');
      print('Stack trace: $stackTrace');
      print('⚠️ CRITICAL: Treating as VALID to avoid accidental logout');
      print('');
      // ✅ FIXED: Don't delete token on parsing error, treat as valid
      return false; // Assume VALID if we can't parse (safer than deleting)
    }
  }

  /// Get token expiration time
  static Future<DateTime?> getTokenExpirationTime() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      String normalizedPayload = payload;
      switch (payload.length % 4) {
        case 1:
          normalizedPayload += '===';
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
      }

      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedPayload = utf8.decode(decodedBytes);
      final payloadMap = json.decode(decodedPayload) as Map<String, dynamic>;

      final exp = payloadMap['exp'];
      if (exp == null) {
        return null;
      }

      return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    } catch (e) {
      print('Error getting token expiration time: $e');
      return null;
    }
  }
}
