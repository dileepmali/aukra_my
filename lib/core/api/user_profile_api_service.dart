import 'package:flutter/material.dart';
import '../../models/user_profile_model.dart';
import 'global_api_function.dart';

/// API Service for User Profile operations
/// Endpoint: /api/user/profile
/// GET - Fetch user profile
/// PUT - Update user profile (username)
class UserProfileApiService {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// Get error message from last API call
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Update user profile name
  /// PUT /api/user/profile
  Future<UpdateProfileResponse?> updateProfileName({
    required String name,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== UPDATE PROFILE NAME ==========');
      debugPrint('📝 New name: $name');

      await _apiFetcher.request(
        url: 'api/user/profile',
        method: 'PUT',
        body: {
          'username': name,
        },
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        return null;
      }

      // Check if data is null
      if (_apiFetcher.data == null) {
        debugPrint('⚠️ No data received, but request may have succeeded');
        // Return success even if no data (some APIs return empty body on success)
        return UpdateProfileResponse(success: true, message: 'Profile updated successfully');
      }

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // Parse response
      if (_apiFetcher.data is Map<String, dynamic>) {
        final response = UpdateProfileResponse.fromJson(_apiFetcher.data as Map<String, dynamic>);
        debugPrint('✅ Profile name updated successfully');
        return response;
      } else if (_apiFetcher.data is List) {
        // Handle list response (as shown in the provided JSON)
        debugPrint('✅ Profile updated, received list response');
        return UpdateProfileResponse(
          success: true,
          message: 'Profile updated successfully',
        );
      }

      // Default success response
      return UpdateProfileResponse(success: true, message: 'Profile updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating profile name: $e');
      return null;
    }
  }

  /// Get user profile data
  /// GET /api/user/profile
  /// Returns single UserProfileModel (API returns single object with username, mobileNumber, etc.)
  Future<UserProfileModel?> getUserProfileSingle() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== GET USER PROFILE (SINGLE) ==========');

      await _apiFetcher.request(
        url: 'api/user/profile',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        return null;
      }

      if (_apiFetcher.data == null) {
        debugPrint('⚠️ No profile data received');
        return null;
      }

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // ✅ Handle single object response (API returns single user profile)
      if (_apiFetcher.data is Map<String, dynamic>) {
        final profile = UserProfileModel.fromJson(_apiFetcher.data as Map<String, dynamic>);
        debugPrint('✅ User Profile loaded:');
        debugPrint('   username: ${profile.username}');
        debugPrint('   mobileNumber: ${profile.mobileNumber}');
        debugPrint('   userId: ${profile.userId}');
        return profile;
      }

      debugPrint('⚠️ Unexpected response format');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Get user profile data (Legacy - returns list for device sessions)
  /// GET /api/user/profile
  Future<List<UserProfileModel>?> getUserProfile() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== GET USER PROFILE ==========');

      await _apiFetcher.request(
        url: 'api/user/profile',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        return null;
      }

      if (_apiFetcher.data == null) {
        debugPrint('⚠️ No profile data received');
        return null;
      }

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // ✅ Handle single object response (wrap in list for compatibility)
      if (_apiFetcher.data is Map<String, dynamic>) {
        final profile = UserProfileModel.fromJson(_apiFetcher.data as Map<String, dynamic>);
        debugPrint('✅ User Profile loaded (single object):');
        debugPrint('   username: ${profile.username}');
        return [profile];
      }

      // Handle list response
      if (_apiFetcher.data is List) {
        final List<dynamic> profilesJson = _apiFetcher.data as List<dynamic>;
        final profiles = profilesJson
            .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Fetched ${profiles.length} profile sessions');
        return profiles;
      } else if (_apiFetcher.data is Map && _apiFetcher.data['data'] != null) {
        final List<dynamic> profilesJson = _apiFetcher.data['data'] as List<dynamic>;
        final profiles = profilesJson
            .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Fetched ${profiles.length} profile sessions');
        return profiles;
      }

      debugPrint('⚠️ Unexpected response format');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching user profile: $e');
      return null;
    }
  }

  /// Get active devices/sessions
  /// GET /api/user/devices
  Future<List<UserProfileModel>?> getActiveDevices() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== GET ACTIVE DEVICES ==========');

      await _apiFetcher.request(
        url: 'api/user/devices',
        method: 'GET',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        return null;
      }

      if (_apiFetcher.data == null) {
        debugPrint('⚠️ No devices data received');
        return null;
      }

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // Parse response - handle list response
      if (_apiFetcher.data is List) {
        final List<dynamic> devicesJson = _apiFetcher.data as List<dynamic>;
        final devices = devicesJson
            .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Fetched ${devices.length} active devices');
        return devices;
      } else if (_apiFetcher.data is Map && _apiFetcher.data['data'] != null) {
        final List<dynamic> devicesJson = _apiFetcher.data['data'] as List<dynamic>;
        final devices = devicesJson
            .map((json) => UserProfileModel.fromJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('✅ Fetched ${devices.length} active devices');
        return devices;
      }

      debugPrint('⚠️ Unexpected response format');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching active devices: $e');
      return null;
    }
  }

  /// Logout from a specific device/session
  /// POST /api/auth/logout/{sessionId}
  Future<bool> logoutDevice(String sessionId) async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== LOGOUT DEVICE ==========');
      debugPrint('📱 Session ID: $sessionId');

      await _apiFetcher.request(
        url: 'api/auth/logout/$sessionId',
        method: 'POST',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        return false;
      }

      debugPrint('✅ Device logged out successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error logging out device: $e');
      return false;
    }
  }

  /// Logout from all devices
  /// POST /api/auth/all-device-logout
  Future<bool> logoutAllDevices() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== LOGOUT ALL DEVICES ==========');

      await _apiFetcher.request(
        url: 'api/auth/all-device-logout',
        method: 'POST',
        requireAuth: true,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Please try again.');
        },
      );

      // Check for errors
      if (_apiFetcher.errorMessage != null) {
        debugPrint('❌ API Error: ${_apiFetcher.errorMessage}');
        return false;
      }

      debugPrint('✅ All devices logged out successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error logging out all devices: $e');
      return false;
    }
  }
}