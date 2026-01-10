import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/user_profile_api_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/user_profile_model.dart';

/// GetX Controller for User Profile Management
/// Handles profile name updates via /api/use/profile
class UserProfileController extends GetxController {
  final UserProfileApiService _apiService = UserProfileApiService();

  // Observable state
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString profileName = ''.obs;
  final Rx<List<UserProfileModel>> profiles = Rx<List<UserProfileModel>>([]);

  /// Update profile name
  /// Returns true on success, false on failure
  Future<bool> updateProfileName(String newName) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('');
      debugPrint('🔵 ========== CONTROLLER: Update Profile Name ==========');
      debugPrint('📝 Updating name to: $newName');

      final response = await _apiService.updateProfileName(name: newName);

      if (response != null && response.success) {
        profileName.value = newName;
        debugPrint('✅ Profile name updated successfully');
        _showSuccess('Profile name updated successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to update profile name';
        errorMessage.value = error;
        debugPrint('❌ Failed to update profile name: $error');
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception in updateProfileName: $e');
      errorMessage.value = 'An error occurred while updating profile';
      _showError('An error occurred while updating profile');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch user profile data
  Future<void> fetchUserProfile() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint('');
      debugPrint('🔵 ========== CONTROLLER: Fetch User Profile ==========');

      final result = await _apiService.getUserProfile();

      if (result != null) {
        profiles.value = result;
        debugPrint('✅ Fetched ${result.length} profile sessions');
      } else {
        final error = _apiService.errorMessage ?? 'Failed to fetch profile';
        errorMessage.value = error;
        debugPrint('❌ Failed to fetch profile: $error');
      }
    } catch (e) {
      debugPrint('❌ Exception in fetchUserProfile: $e');
      errorMessage.value = 'An error occurred while fetching profile';
    } finally {
      isLoading.value = false;
    }
  }

  /// Set profile name (local update)
  void setProfileName(String name) {
    profileName.value = name;
    debugPrint('📝 Profile name set to: $name');
  }

  /// Show error message
  void _showError(String message) {
    AdvancedErrorService.showError(
      message,
      category: ErrorCategory.network,
      severity: ErrorSeverity.medium,
    );
  }

  /// Show success message
  void _showSuccess(String message) {
    AdvancedErrorService.showSuccess(
      message,
      type: SuccessType.snackbar,
    );
  }

  /// Reset controller state
  void reset() {
    isLoading.value = false;
    errorMessage.value = '';
    profileName.value = '';
    profiles.value = [];
    debugPrint('🔄 UserProfileController reset');
  }

  @override
  void onClose() {
    debugPrint('🗑️ UserProfileController disposed');
    super.onClose();
  }
}