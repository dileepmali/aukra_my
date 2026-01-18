import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/user_preference_api_service.dart';
import '../core/services/error_service.dart';
import '../core/untils/error_types.dart';
import '../models/user_preference_model.dart';

/// Global GetX Controller for User Preferences
///
/// This controller manages all user preferences like:
/// - Language, Currency, Timezone
/// - Date/Time format
/// - Theme (light/dark)
/// - Notification settings
///
/// Usage:
/// - Get.put(UserPreferenceController(), permanent: true) on app start
/// - Get.find<UserPreferenceController>() anywhere in app
///
/// Key Features:
/// - Auto-loads preferences on init
/// - Syncs with server via API
/// - Provides reactive state management
class UserPreferenceController extends GetxController {
  final UserPreferenceApiService _apiService = UserPreferenceApiService();

  // ============================================================
  // OBSERVABLE STATE
  // ============================================================

  final Rx<UserPreferenceModel> _preference = UserPreferenceModel.initial().obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool hasLoaded = false.obs;

  // ============================================================
  // GETTERS
  // ============================================================

  /// Get current preference model
  UserPreferenceModel get preference => _preference.value;

  /// Current status
  UserPreferenceStatus get status => preference.status;

  /// Check if preference exists
  bool get hasPreference => preference.hasData;

  // Individual preference getters
  String get language => preference.language ?? 'en';
  String get currency => preference.currency ?? 'INR';
  String get timezone => preference.timezone ?? 'Asia/Kolkata';
  String get dateFormat => preference.dateFormat ?? 'DD/MM/YYYY';
  String get timeFormat => preference.timeFormat ?? '24h';
  String get theme => preference.theme ?? 'light';
  bool get notifications => preference.notifications;
  bool get emailNotifications => preference.emailNotifications;
  bool get smsNotifications => preference.smsNotifications;
  bool get pushNotifications => preference.pushNotifications;

  /// Check if dark theme
  bool get isDarkTheme => preference.isDarkTheme;

  /// Check if 24h time format
  bool get is24HourFormat => preference.is24HourFormat;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    debugPrint('⚙️ UserPreferenceController initialized');
    // ✅ DON'T auto-load here - preferences will be loaded after login in MainScreen
    // loadPreferences() requires auth token, so we call it only after successful login
  }

  @override
  void onClose() {
    debugPrint('🗑️ UserPreferenceController disposed');
    super.onClose();
  }

  // ============================================================
  // API METHODS
  // ============================================================

  /// Load preferences from server
  /// Called on app start
  Future<void> loadPreferences() async {
    try {
      isLoading.value = true;
      _updateStatus(UserPreferenceStatus.fetching);
      debugPrint('🔄 Loading user preferences...');

      final response = await _apiService.getPreference();

      if (response != null) {
        _preference.value = response.copyWith(
          status: UserPreferenceStatus.success,
        );
        hasLoaded.value = true;
        debugPrint('✅ Preferences loaded successfully');
        debugPrint('   Language: ${response.language}');
        debugPrint('   Theme: ${response.theme}');
        debugPrint('   Currency: ${response.currency}');
      } else {
        // Use default preferences if API fails
        _preference.value = UserPreferenceModel.initial().copyWith(
          status: UserPreferenceStatus.initial,
        );
        debugPrint('⚠️ Could not load preferences, using defaults');
      }
    } catch (e) {
      debugPrint('❌ Error loading preferences: $e');
      _preference.value = UserPreferenceModel.initial();
      errorMessage.value = 'Failed to load preferences';
    } finally {
      isLoading.value = false;
    }
  }

  /// Create new preference (first time setup)
  /// [silent] - If true, don't show error/success messages (for background operations)
  Future<bool> createPreference(UserPreferenceModel newPreference, {bool silent = false}) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      _updateStatus(UserPreferenceStatus.creating);
      debugPrint('🔄 Creating user preference...');

      final response = await _apiService.createPreference(
        preference: newPreference,
      );

      if (response != null && response.success) {
        _preference.value = newPreference.copyWith(
          status: UserPreferenceStatus.success,
        );
        hasLoaded.value = true;
        debugPrint('✅ Preference created successfully');
        if (!silent) _showSuccess('Preferences saved successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to create preference';
        errorMessage.value = error;
        _updateStatus(UserPreferenceStatus.error);
        if (!silent) _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error creating preference: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(UserPreferenceStatus.error);
      if (!silent) _showError('An error occurred while saving preferences');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Update existing preference
  /// [silent] - If true, don't show error/success messages (for background operations)
  Future<bool> updatePreference(UserPreferenceModel updatedPreference, {bool silent = false}) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      _updateStatus(UserPreferenceStatus.updating);
      debugPrint('🔄 Updating user preference...');

      final response = await _apiService.updatePreference(
        preference: updatedPreference,
      );

      if (response != null && response.success) {
        _preference.value = updatedPreference.copyWith(
          status: UserPreferenceStatus.success,
        );
        debugPrint('✅ Preference updated successfully');
        if (!silent) _showSuccess('Preferences updated successfully');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to update preference';
        errorMessage.value = error;
        _updateStatus(UserPreferenceStatus.error);
        if (!silent) _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error updating preference: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(UserPreferenceStatus.error);
      if (!silent) _showError('An error occurred while updating preferences');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Delete preference
  Future<bool> deletePreference() async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      _updateStatus(UserPreferenceStatus.deleting);
      debugPrint('🔄 Deleting user preference...');

      final success = await _apiService.deletePreference();

      if (success) {
        _preference.value = UserPreferenceModel.initial();
        hasLoaded.value = false;
        debugPrint('✅ Preference deleted successfully');
        _showSuccess('Preferences reset to defaults');
        return true;
      } else {
        final error = _apiService.errorMessage ?? 'Failed to delete preference';
        errorMessage.value = error;
        _updateStatus(UserPreferenceStatus.error);
        _showError(error);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting preference: $e');
      errorMessage.value = 'An error occurred';
      _updateStatus(UserPreferenceStatus.error);
      _showError('An error occurred while resetting preferences');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // ============================================================
  // CONVENIENCE UPDATE METHODS
  // ============================================================

  /// Update language
  /// [silent] - If true, don't show error/success messages (for background operations)
  Future<bool> setLanguage(String newLanguage, {bool silent = false}) async {
    debugPrint('🌐 Setting language to: $newLanguage');
    final updated = preference.copyWith(language: newLanguage);
    return hasLoaded.value
        ? await updatePreference(updated, silent: silent)
        : await createPreference(updated, silent: silent);
  }

  /// Update theme
  Future<bool> setTheme(String newTheme) async {
    debugPrint('🎨 Setting theme to: $newTheme');
    final updated = preference.copyWith(theme: newTheme);
    return hasLoaded.value
        ? await updatePreference(updated)
        : await createPreference(updated);
  }

  /// Toggle dark mode
  Future<bool> toggleDarkMode() async {
    final newTheme = isDarkTheme ? 'light' : 'dark';
    return await setTheme(newTheme);
  }

  /// Update currency
  Future<bool> setCurrency(String newCurrency) async {
    debugPrint('💰 Setting currency to: $newCurrency');
    final updated = preference.copyWith(currency: newCurrency);
    return hasLoaded.value
        ? await updatePreference(updated)
        : await createPreference(updated);
  }

  /// Update timezone
  Future<bool> setTimezone(String newTimezone) async {
    debugPrint('🕐 Setting timezone to: $newTimezone');
    final updated = preference.copyWith(timezone: newTimezone);
    return hasLoaded.value
        ? await updatePreference(updated)
        : await createPreference(updated);
  }

  /// Update date format
  Future<bool> setDateFormat(String newDateFormat) async {
    debugPrint('📅 Setting date format to: $newDateFormat');
    final updated = preference.copyWith(dateFormat: newDateFormat);
    return hasLoaded.value
        ? await updatePreference(updated)
        : await createPreference(updated);
  }

  /// Update time format
  Future<bool> setTimeFormat(String newTimeFormat) async {
    debugPrint('⏰ Setting time format to: $newTimeFormat');
    final updated = preference.copyWith(timeFormat: newTimeFormat);
    return hasLoaded.value
        ? await updatePreference(updated)
        : await createPreference(updated);
  }

  /// Toggle 24-hour format
  Future<bool> toggle24HourFormat() async {
    final newFormat = is24HourFormat ? '12h' : '24h';
    return await setTimeFormat(newFormat);
  }

  /// Update all notification settings
  /// [silent] - If true, don't show error/success messages (for background operations)
  Future<bool> setNotifications({
    bool? all,
    bool? email,
    bool? sms,
    bool? push,
    bool silent = false,
  }) async {
    debugPrint('🔔 Updating notification settings...');
    final updated = preference.copyWith(
      notifications: all ?? preference.notifications,
      emailNotifications: email ?? preference.emailNotifications,
      smsNotifications: sms ?? preference.smsNotifications,
      pushNotifications: push ?? preference.pushNotifications,
    );
    return hasLoaded.value
        ? await updatePreference(updated, silent: silent)
        : await createPreference(updated, silent: silent);
  }

  /// Toggle all notifications
  Future<bool> toggleAllNotifications() async {
    final newValue = !notifications;
    return await setNotifications(
      all: newValue,
      email: newValue,
      sms: newValue,
      push: newValue,
    );
  }

  /// Toggle email notifications
  Future<bool> toggleEmailNotifications() async {
    return await setNotifications(email: !emailNotifications);
  }

  /// Toggle SMS notifications
  Future<bool> toggleSmsNotifications() async {
    return await setNotifications(sms: !smsNotifications);
  }

  /// Toggle push notifications
  Future<bool> togglePushNotifications() async {
    return await setNotifications(push: !pushNotifications);
  }

  // ============================================================
  // LOCAL STATE UPDATES (No API call)
  // ============================================================

  /// Update local preference without API call
  /// Useful for temporary UI changes before saving
  void updateLocalPreference(UserPreferenceModel newPreference) {
    _preference.value = newPreference;
    debugPrint('📝 Local preference updated');
  }

  /// Set local language (no API call)
  void setLocalLanguage(String newLanguage) {
    _preference.value = preference.copyWith(language: newLanguage);
  }

  /// Set local theme (no API call)
  void setLocalTheme(String newTheme) {
    _preference.value = preference.copyWith(theme: newTheme);
  }

  // ============================================================
  // PRIVATE HELPERS
  // ============================================================

  /// Update status
  void _updateStatus(UserPreferenceStatus newStatus) {
    _preference.value = preference.copyWith(status: newStatus);
    debugPrint('📊 Preference Status: $newStatus');
  }

  /// Show error message
  void _showError(String message) {
    AdvancedErrorService.showError(
      message,
      category: ErrorCategory.network,
      severity: ErrorSeverity.high,
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
    _preference.value = UserPreferenceModel.initial();
    isLoading.value = false;
    isSaving.value = false;
    errorMessage.value = '';
    hasLoaded.value = false;
    debugPrint('🔄 UserPreferenceController reset');
  }

  /// Refresh preferences from server
  Future<void> refresh() async {
    debugPrint('🔄 Refreshing preferences...');
    await loadPreferences();
  }
}
