import 'dart:ui';
import '../services/error_service.dart';
import 'error_types.dart';

/// Helper class to migrate from old Get.snackbar to new AdvancedErrorService
/// This provides easy migration methods for existing code
class ErrorMigrationHelper {

  /// Replace network-related errors
  static void showNetworkError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_no_internet',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.network,
      onRetry: onRetry,
    );
  }

  /// Replace server errors
  static void showServerError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_server_issue',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.server,
      onRetry: onRetry,
    );
  }

  /// Replace authentication errors
  static void showAuthError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_login_failed',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.authentication,
      onRetry: onRetry,
    );
  }

  /// Replace validation errors
  static void showValidationError({String? customMessage}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_required_field',
      severity: ErrorSeverity.low,
      category: ErrorCategory.validation,
    );
  }

  /// Replace upload errors
  static void showUploadError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_upload_failed',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.upload,
      onRetry: onRetry,
    );
  }

  /// Replace download errors
  static void showDownloadError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_download_failed',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.download,
      onRetry: onRetry,
    );
  }

  /// Replace general errors
  static void showGeneralError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_general',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.general,
      onRetry: onRetry,
    );
  }

  /// Replace OTP related errors
  static void showOtpError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_invalid_otp',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.validation,
      onRetry: onRetry,
    );
  }

  /// Replace phone number errors
  static void showPhoneError({String? customMessage}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error_phone_invalid',
      severity: ErrorSeverity.low,
      category: ErrorCategory.validation,
    );
  }

  /// Replace permission errors
  static void showPermissionError({String? customMessage, VoidCallback? onRetry}) {
    AdvancedErrorService.showError(
      customMessage ?? 'error camera permission',
      severity: ErrorSeverity.medium,
      category: ErrorCategory.permission,
      onRetry: onRetry,
    );
  }

  /// Show success messages - replaces success Get.snackbar calls
  static void showSuccess({String? customMessage, SuccessType type = SuccessType.snackbar}) {
    AdvancedErrorService.showSuccess(
      customMessage ?? 'success',
      type: type,
    );
  }

  /// Show login success
  static void showLoginSuccess() {
    AdvancedErrorService.showSuccess(
      'success_login',
      type: SuccessType.snackbar,
    );
  }

  /// Show upload success
  static void showUploadSuccess() {
    AdvancedErrorService.showSuccess(
      'success_upload',
      type: SuccessType.snackbar,
    );
  }

  /// Show OTP sent success
  static void showOtpSentSuccess() {
    AdvancedErrorService.showSuccess(
      'success_otp_sent',
      type: SuccessType.snackbar,
    );
  }

  /// Show copy success
  static void showCopySuccess() {
    AdvancedErrorService.showSuccess(
      'success_share',
      type: SuccessType.snackbar,
    );
  }

  /// Map old error messages to new error keys
  static String mapOldErrorToNewKey(String oldMessage) {
    Map<String, String> errorMapping = {
      // Network errors
      'network error': 'error_no_internet',
      'connection timeout': 'error_slow_internet',
      'no internet': 'error_no_internet',
      'server busy': 'error_server_busy',

      // Auth errors
      'invalid number': 'error_phone_invalid',
      'invalid otp': 'error_invalid_otp',
      'otp expired': 'error_otp_expired',
      'login failed': 'error_login_failed',
      'verification failed': 'error_invalid_otp',

      // File errors
      'upload failed': 'error_upload_failed',
      'download failed': 'error_download_failed',
      'file too large': 'error_file_too_large',
      'invalid format': 'error_invalid_format',
      'storage full': 'error_storage_full',

      // Permission errors
      'permission denied': 'error_camera_permission',

      // General errors
      'error occurred': 'error_general',
      'something went wrong': 'error_general',
      'try again': 'error_general',
    };

    String lowerMessage = oldMessage.toLowerCase();

    // Check for partial matches
    for (String key in errorMapping.keys) {
      if (lowerMessage.contains(key)) {
        return errorMapping[key]!;
      }
    }

    return 'error_general'; // Default fallback
  }

  /// Easy migration method - converts old Get.snackbar parameters to new system
  static void migrateOldError({
    required String title,
    required String message,
    VoidCallback? onRetry,
    String? screen,
  }) {
    // Determine error category from title
    ErrorCategory category = ErrorCategory.general;
    if (title.toLowerCase().contains('network') || title.toLowerCase().contains('connection')) {
      category = ErrorCategory.network;
    } else if (title.toLowerCase().contains('server')) {
      category = ErrorCategory.server;
    } else if (title.toLowerCase().contains('auth') || title.toLowerCase().contains('login')) {
      category = ErrorCategory.authentication;
    } else if (title.toLowerCase().contains('upload')) {
      category = ErrorCategory.upload;
    } else if (title.toLowerCase().contains('download')) {
      category = ErrorCategory.download;
    } else if (title.toLowerCase().contains('permission')) {
      category = ErrorCategory.permission;
    } else if (title.toLowerCase().contains('validation') || title.toLowerCase().contains('invalid')) {
      category = ErrorCategory.validation;
    }

    // Map old message to new key
    String errorKey = mapOldErrorToNewKey(message);

    AdvancedErrorService.showError(
      errorKey,
      severity: ErrorSeverity.medium,
      category: category,
      onRetry: onRetry,
      screen: screen,
    );
  }
}