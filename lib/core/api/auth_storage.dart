import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'dart:convert';

import 'package:get/get_core/src/get_main.dart';

class AuthStorage {
  static const _tokenKey = "auth_token";
  static const _phoneNumberKey = "phone_number";
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
      if (token == null || token.isEmpty) {
        return null;
      }

      if (_isTokenExpired(token)) {
        // Token is expired, remove it from storage
        await clearToken();
        return null;
      }

      return token;
    } catch (e) {
      print('Error getting valid token: $e');
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

      // Optionally clear other cached data
      // await _storage.deleteAll();  // अगर सारे keys clear करने हों

      // Clear GetX controllers (optional)
      if (clearControllers) {
        Get.deleteAll(force: true);
      }

      print("✅ User logged out successfully.");
      print("📱 Phone number cleared from storage.");
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }


  /// Check if JWT token is expired
  static bool _isTokenExpired(String token) {
    try {
      // Split JWT token into parts
      final parts = token.split('.');
      if (parts.length != 3) {
        return true; // Invalid token format
      }

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

      // Check expiration time
      final exp = payloadMap['exp'];
      if (exp == null) {
        return true; // No expiration time means invalid token
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final currentTime = DateTime.now();

      return currentTime.isAfter(expirationTime);
    } catch (e) {
      print('Error checking token expiration: $e');
      return true; // Assume expired if we can't parse
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
