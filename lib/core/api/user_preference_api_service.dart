import 'package:flutter/material.dart';
import '../../models/user_preference_model.dart';
import 'global_api_function.dart';

/// API Service for User Preference operations
///
/// Endpoints:
/// - POST /api/user-preference - Create user preference
/// - GET /api/user-preference - Get user preference
/// - PUT /api/user-preference - Update user preference
/// - DELETE /api/user-preference - Delete user preference
class UserPreferenceApiService {
  final ApiFetcher _apiFetcher = ApiFetcher();

  /// API endpoint
  static const String _endpoint = 'api/user-preference';

  /// Get error message from last API call
  String? get errorMessage => _apiFetcher.errorMessage;

  /// Check if currently loading
  bool get isLoading => _apiFetcher.isLoading;

  // ============================================================
  // POST - Create User Preference
  // ============================================================

  /// Create user preference
  /// POST /api/user-preference
  ///
  /// Request Body:
  /// ```json
  /// {
  ///   "language": "en",
  ///   "currency": "INR",
  ///   "timezone": "Asia/Kolkata",
  ///   "dateFormat": "DD/MM/YYYY",
  ///   "timeFormat": "24h",
  ///   "theme": "light",
  ///   "notifications": true,
  ///   "emailNotifications": true,
  ///   "smsNotifications": true,
  ///   "pushNotifications": true
  /// }
  /// ```
  Future<UserPreferenceResponse?> createPreference({
    required UserPreferenceModel preference,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== CREATE USER PREFERENCE ==========');
      debugPrint('📝 Request: ${preference.toJson()}');

      await _apiFetcher.request(
        url: _endpoint,
        method: 'POST',
        body: preference.toJson(),
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

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // Parse response
      if (_apiFetcher.data == null) {
        debugPrint('✅ Preference created (no response body)');
        return UserPreferenceResponse(
          success: true,
          message: 'Preference created successfully',
          data: preference,
        );
      }

      if (_apiFetcher.data is Map<String, dynamic>) {
        final response = UserPreferenceResponse.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
        debugPrint('✅ Preference created successfully');
        return response;
      }

      return UserPreferenceResponse(
        success: true,
        message: 'Preference created successfully',
        data: preference,
      );
    } catch (e) {
      debugPrint('❌ Error creating preference: $e');
      return null;
    }
  }

  // ============================================================
  // GET - Fetch User Preference
  // ============================================================

  /// Get user preference
  /// GET /api/user-preference
  ///
  /// Response:
  /// ```json
  /// {
  ///   "language": "en",
  ///   "currency": "INR",
  ///   "timezone": "Asia/Kolkata",
  ///   "dateFormat": "DD/MM/YYYY",
  ///   "timeFormat": "24h",
  ///   "theme": "light",
  ///   "notifications": true,
  ///   "emailNotifications": true,
  ///   "smsNotifications": true,
  ///   "pushNotifications": true
  /// }
  /// ```
  Future<UserPreferenceModel?> getPreference() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== GET USER PREFERENCE ==========');

      await _apiFetcher.request(
        url: _endpoint,
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
        debugPrint('⚠️ No preference data received');
        return null;
      }

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // Parse response - Handle direct object
      if (_apiFetcher.data is Map<String, dynamic>) {
        final data = _apiFetcher.data as Map<String, dynamic>;

        // Check if data is nested under 'data' key
        if (data.containsKey('data') && data['data'] is Map<String, dynamic>) {
          final preference = UserPreferenceModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
          debugPrint('✅ Preference loaded from nested data');
          _logPreference(preference);
          return preference;
        }

        // Direct preference object
        final preference = UserPreferenceModel.fromJson(data);
        debugPrint('✅ Preference loaded successfully');
        _logPreference(preference);
        return preference;
      }

      debugPrint('⚠️ Unexpected response format');
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching preference: $e');
      return null;
    }
  }

  // ============================================================
  // PUT - Update User Preference
  // ============================================================

  /// Update user preference
  /// PUT /api/user-preference
  ///
  /// Request Body: Same as POST
  Future<UserPreferenceResponse?> updatePreference({
    required UserPreferenceModel preference,
  }) async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== UPDATE USER PREFERENCE ==========');
      debugPrint('📝 Request: ${preference.toJson()}');

      await _apiFetcher.request(
        url: _endpoint,
        method: 'PUT',
        body: preference.toJson(),
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

      debugPrint('📥 Response Type: ${_apiFetcher.data.runtimeType}');
      debugPrint('📥 Response: ${_apiFetcher.data}');

      // Parse response
      if (_apiFetcher.data == null) {
        debugPrint('✅ Preference updated (no response body)');
        return UserPreferenceResponse(
          success: true,
          message: 'Preference updated successfully',
          data: preference,
        );
      }

      if (_apiFetcher.data is Map<String, dynamic>) {
        final response = UserPreferenceResponse.fromJson(
          _apiFetcher.data as Map<String, dynamic>,
        );
        debugPrint('✅ Preference updated successfully');
        return response;
      }

      return UserPreferenceResponse(
        success: true,
        message: 'Preference updated successfully',
        data: preference,
      );
    } catch (e) {
      debugPrint('❌ Error updating preference: $e');
      return null;
    }
  }

  // ============================================================
  // DELETE - Delete User Preference
  // ============================================================

  /// Delete user preference
  /// DELETE /api/user-preference
  Future<bool> deletePreference() async {
    try {
      debugPrint('');
      debugPrint('🔵 ========== DELETE USER PREFERENCE ==========');

      await _apiFetcher.request(
        url: _endpoint,
        method: 'DELETE',
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

      debugPrint('✅ Preference deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting preference: $e');
      return false;
    }
  }

  // ============================================================
  // PARTIAL UPDATE METHODS (Convenience)
  // ============================================================

  /// Update only language preference
  Future<UserPreferenceResponse?> updateLanguage(String language) async {
    final current = await getPreference();
    if (current == null) {
      return await createPreference(
        preference: UserPreferenceModel.initial().copyWith(language: language),
      );
    }
    return await updatePreference(
      preference: current.copyWith(language: language),
    );
  }

  /// Update only theme preference
  Future<UserPreferenceResponse?> updateTheme(String theme) async {
    final current = await getPreference();
    if (current == null) {
      return await createPreference(
        preference: UserPreferenceModel.initial().copyWith(theme: theme),
      );
    }
    return await updatePreference(
      preference: current.copyWith(theme: theme),
    );
  }

  /// Update only currency preference
  Future<UserPreferenceResponse?> updateCurrency(String currency) async {
    final current = await getPreference();
    if (current == null) {
      return await createPreference(
        preference: UserPreferenceModel.initial().copyWith(currency: currency),
      );
    }
    return await updatePreference(
      preference: current.copyWith(currency: currency),
    );
  }

  /// Update notification settings
  Future<UserPreferenceResponse?> updateNotifications({
    bool? notifications,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
  }) async {
    final current = await getPreference();
    if (current == null) {
      return await createPreference(
        preference: UserPreferenceModel.initial().copyWith(
          notifications: notifications,
          emailNotifications: emailNotifications,
          smsNotifications: smsNotifications,
          pushNotifications: pushNotifications,
        ),
      );
    }
    return await updatePreference(
      preference: current.copyWith(
        notifications: notifications,
        emailNotifications: emailNotifications,
        smsNotifications: smsNotifications,
        pushNotifications: pushNotifications,
      ),
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Log preference details
  void _logPreference(UserPreferenceModel preference) {
    debugPrint('   language: ${preference.language}');
    debugPrint('   currency: ${preference.currency}');
    debugPrint('   timezone: ${preference.timezone}');
    debugPrint('   dateFormat: ${preference.dateFormat}');
    debugPrint('   timeFormat: ${preference.timeFormat}');
    debugPrint('   theme: ${preference.theme}');
    debugPrint('   notifications: ${preference.notifications}');
    debugPrint('   emailNotifications: ${preference.emailNotifications}');
    debugPrint('   smsNotifications: ${preference.smsNotifications}');
    debugPrint('   pushNotifications: ${preference.pushNotifications}');
  }
}
