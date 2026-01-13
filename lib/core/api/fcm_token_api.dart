import 'dart:io';
import 'package:flutter/material.dart';
import 'global_api_function.dart';
import '../../models/fcm_token_model.dart';
import '../services/device_info_service.dart';

class FcmTokenApi {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Register/Upload FCM Token for push notifications
  /// POST /api/fcm-token
  Future<FcmTokenModel?> registerToken({
    required String fcmToken,
  }) async {
    try {
      final body = {
        'fcmToken': fcmToken,
        'deviceId': DeviceInfoService.deviceId,
        'deviceName': DeviceInfoService.deviceName,
        'deviceType': 'MOBILE',
        'platform': Platform.isAndroid ? 'ANDROID' : 'IOS',
        'isActive': true,
      };

      debugPrint('📤 Registering FCM Token...');
      debugPrint('   - Device: ${DeviceInfoService.deviceName}');
      debugPrint('   - Platform: ${Platform.isAndroid ? 'ANDROID' : 'IOS'}');

      await _apiFetcher.request(
        url: 'api/fcm-token',
        method: 'POST',
        body: body,
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      if (_apiFetcher.data is Map) {
        final token = FcmTokenModel.fromJson(_apiFetcher.data);
        debugPrint('✅ FCM Token registered successfully');
        debugPrint('   - Token ID: ${token.id}');
        return token;
      }

      return null;
    } catch (e) {
      debugPrint('❌ FCM Token Registration Error: $e');
      rethrow;
    }
  }

  /// Get all FCM tokens for authenticated user
  /// GET /api/fcm-token
  Future<List<FcmTokenModel>> getAllTokens() async {
    try {
      debugPrint('📥 Fetching all FCM tokens...');

      await _apiFetcher.request(
        url: 'api/fcm-token',
        method: 'GET',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      if (_apiFetcher.data is List) {
        final tokens = (_apiFetcher.data as List)
            .map((item) => FcmTokenModel.fromJson(item))
            .toList();
        debugPrint('✅ Fetched ${tokens.length} FCM tokens');
        return tokens;
      }

      return [];
    } catch (e) {
      debugPrint('❌ Get FCM Tokens Error: $e');
      rethrow;
    }
  }

  /// Get FCM token for current device
  /// Returns the token matching current deviceId, or null if not found
  Future<FcmTokenModel?> getCurrentDeviceToken() async {
    try {
      final tokens = await getAllTokens();
      final currentDeviceId = DeviceInfoService.deviceId;

      // Find token for current device
      final currentToken = tokens.firstWhere(
        (token) => token.deviceId == currentDeviceId && token.isActive,
        orElse: () => FcmTokenModel(
          fcmToken: '',
          deviceId: '',
          deviceName: '',
          deviceType: '',
          platform: '',
        ),
      );

      if (currentToken.fcmToken.isEmpty) {
        debugPrint('⚠️ No FCM token found for current device');
        return null;
      }

      debugPrint('✅ Found FCM token for current device');
      debugPrint('   - Token ID: ${currentToken.id}');
      return currentToken;
    } catch (e) {
      debugPrint('❌ Get Current Device Token Error: $e');
      return null;
    }
  }

  /// Update FCM token information
  /// PUT /api/fcm-token/{tokenId}
  Future<FcmTokenModel?> updateToken({
    required int tokenId,
    required String fcmToken,
    bool? isActive,
  }) async {
    try {
      final body = {
        'fcmToken': fcmToken,
        'deviceId': DeviceInfoService.deviceId,
        'deviceName': DeviceInfoService.deviceName,
        'deviceType': 'MOBILE',
        'platform': Platform.isAndroid ? 'ANDROID' : 'IOS',
        if (isActive != null) 'isActive': isActive,
      };

      debugPrint('📤 Updating FCM Token: $tokenId');

      await _apiFetcher.request(
        url: 'api/fcm-token/$tokenId',
        method: 'PUT',
        body: body,
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      if (_apiFetcher.data is Map) {
        final token = FcmTokenModel.fromJson(_apiFetcher.data);
        debugPrint('✅ FCM Token updated successfully');
        return token;
      }

      return null;
    } catch (e) {
      debugPrint('❌ Update FCM Token Error: $e');
      rethrow;
    }
  }

  /// Delete FCM token
  /// DELETE /api/fcm-token/{tokenId}
  Future<bool> deleteToken({
    required int tokenId,
  }) async {
    try {
      debugPrint('📤 Deleting FCM Token: $tokenId');

      await _apiFetcher.request(
        url: 'api/fcm-token/$tokenId',
        method: 'DELETE',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      debugPrint('✅ FCM Token deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Delete FCM Token Error: $e');
      rethrow;
    }
  }

  /// Deactivate all FCM tokens (logout from all devices)
  /// POST /api/fcm-token/deactivate-all
  Future<bool> deactivateAllTokens() async {
    try {
      debugPrint('📤 Deactivating all FCM tokens...');

      await _apiFetcher.request(
        url: 'api/fcm-token/deactivate-all',
        method: 'POST',
        requireAuth: true,
      );

      if (_apiFetcher.errorMessage != null) {
        throw Exception(_apiFetcher.errorMessage);
      }

      debugPrint('✅ All FCM tokens deactivated successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Deactivate All Tokens Error: $e');
      rethrow;
    }
  }

  /// Get loading state
  bool get isLoading => _apiFetcher.isLoading;

  /// Get error message
  String? get errorMessage => _apiFetcher.errorMessage;
}
