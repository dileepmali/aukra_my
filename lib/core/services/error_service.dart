import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../responsive_layout/device_category.dart';
import '../responsive_layout/font_size_hepler_class.dart';
import '../responsive_layout/padding_navigation.dart';
import '../untils/error_types.dart';

/// Advanced Error Handling Service for Dark Theme App
/// Handles errors like Google, Instagram, JioCinema
class AdvancedErrorService {
  // Error Queue System
  static final Queue<ErrorModel> _errorQueue = Queue();
  static bool _isProcessing = false;
  static String? _lastErrorKey;
  static DateTime? _lastErrorTime;

  // Offline mode error tracking
  static bool _offlineErrorShown = false;

  /// Main method to show errors with advanced handling
  static void showError(
      String errorKey, {
        ErrorSeverity severity = ErrorSeverity.medium,
        ErrorCategory category = ErrorCategory.general,
        Map<String, String>? params,
        VoidCallback? onRetry,
        String? screen,
        Duration? customDuration,
      }) async {
    // 🔥 ALWAYS PRINT - to verify error service is called
    print('🔥🔥🔥 ERROR SERVICE CALLED: $errorKey');
    print('   Severity: $severity');
    print('   Category: $category');
    print('   kDebugMode: $kDebugMode');

    // Check if we're in offline mode and handle accordingly
    if (!_isUsingRealAPI()) {
      _handleOfflineError(errorKey, category);
      return;
    }

    // 🚀 SESSION SUPPRESSION DISABLED - All errors will be shown
    // This allows errors to be displayed multiple times throughout the session
    if (kDebugMode) {
      print('🐛 Showing error: $errorKey - Category: $category');
    }

    // 🚀 DUPLICATE PREVENTION DISABLED - All errors will be shown immediately
    // This ensures users see errors even if they occur in quick succession
    if (kDebugMode) {
      print('🔍 Processing error without duplicate check: $errorKey');
    }

    // 3. Add to queue if another error is processing
    // 🔥 FIX: Validation errors should ALWAYS show immediately (skip queue)
    if (_isProcessing && category != ErrorCategory.validation) {
      _errorQueue.add(ErrorModel(
        key: errorKey,
        severity: severity,
        category: category,
        params: params,
        onRetry: onRetry,
        screen: screen,
      ));
      return;
    }

    // 🔥 FIX: For validation errors, reset processing flag to allow immediate display
    if (category == ErrorCategory.validation) {
      _isProcessing = false;
    }

    // 4. Process error immediately
    await _processError(
      errorKey,
      severity,
      category,
      params,
      onRetry,
      screen,
      customDuration,
    );
  }

  /// Show success messages with app gradient colors
  static void showSuccess(
      String successKey, {
        SuccessType type = SuccessType.snackbar,
        Map<String, String>? params,
        Duration? customDuration,
        VoidCallback? onTap,
      }) {
    // 🔥 ALWAYS PRINT - to verify success service is called
    print('🔥🔥🔥 SUCCESS SERVICE CALLED: $successKey');
    print('   Type: $type');
    print('   kDebugMode: $kDebugMode');

    // ✅ FIX: Check if context is available - use multiple fallbacks
    final context = Get.context ?? Get.key.currentContext;
    if (context == null) {
      print('⚠️ Cannot show success message: Get.context is null');
      print('   Message: $successKey');
      print('   Get.context: ${Get.context}');
      print('   Get.key.currentContext: ${Get.key.currentContext}');
      return;
    }

    // ✅ FIX: Removed Get.closeCurrentSnackbar() to prevent LateInitializationError
    // Let GetX handle snackbar lifecycle automatically

    // ✅ FIX: Allow success messages even if processing (don't block them)
    // Success messages should always show, especially after profile updates
    if (kDebugMode) {
      print('📢 Showing success message: $successKey');
      print('   Type: $type');
      print('   Duration: ${customDuration?.inSeconds ?? 0.3} seconds');
    }

    _isProcessing = true;

    final responsive = AdvancedResponsiveHelper(context);
    String message = _getLocalizedMessage(successKey, params);

    // Show success snackbar
    _showSuccessSnackbar(message, responsive, customDuration, onTap);

    // Reset processing flag after duration
    Future.delayed(Duration(milliseconds: 3000), () {
      _isProcessing = false;
      _processQueue();
    });
  }

  /// Process error with contextual intelligence
  static Future<void> _processError(
      String errorKey,
      ErrorSeverity severity,
      ErrorCategory category,
      Map<String, String>? params,
      VoidCallback? onRetry,
      String? screen,
      Duration? customDuration,
      ) async {
    // ✅ FIX: Check if context is available - use multiple fallbacks
    final context = Get.context ?? Get.key.currentContext;
    if (context == null) {
      if (kDebugMode) {
        print('⚠️ Cannot show error message: Get.context is null');
        print('   Error: $errorKey');
        print('   Category: $category');
        print('   Get.context: ${Get.context}');
        print('   Get.key.currentContext: ${Get.key.currentContext}');
        print('   Get.overlayContext: ${Get.overlayContext}');
      }
      return;
    }

    _isProcessing = true;
    _lastErrorKey = errorKey;
    _lastErrorTime = DateTime.now();

    final responsive = AdvancedResponsiveHelper(context);

    // Get contextual message based on screen and category
    String message = _getContextualMessage(errorKey, screen, category);
    message = _getLocalizedMessage(message, params);

    // Show error based on severity with dark theme colors
    switch (severity) {
      case ErrorSeverity.low:
        _showErrorToast(message, category, responsive);
        break;
      case ErrorSeverity.medium:
        _showErrorSnackbar(message, category, responsive, onRetry, customDuration);
        break;
      case ErrorSeverity.high:
        // Show as snackbar with longer duration (5 seconds)
        _showErrorSnackbar(message, category, responsive, onRetry, Duration(milliseconds: 5000));
        break;
      // Legacy severity values - default to medium
      case ErrorSeverity.error:
      case ErrorSeverity.network:
      case ErrorSeverity.auth:
      case ErrorSeverity.validation:
        _showErrorSnackbar(message, category, responsive, onRetry, customDuration);
        break;
    }

    // Reset processing flag with additional safety margin
    Duration duration = customDuration ?? Duration(milliseconds: 3000);
    Future.delayed(duration.inMilliseconds > 1000
        ? duration
        : Duration(milliseconds: duration.inMilliseconds + 500), () {
      _isProcessing = false;
      _processQueue();
    });

    // Track error for analytics
    _trackError(errorKey, category, screen);
  }

  /// Get contextual error message based on screen and category
  static String _getContextualMessage(String errorKey, String? screen, ErrorCategory category) {
    if (screen != null) {
      // Context-specific messages
      Map<String, Map<String, String>> contextMessages = {
        'login': {
          'network': 'error_login_network',
          'validation': 'error_login_validation',
        },
        'upload': {
          'network': 'error_upload_network',
          'storage': 'error_upload_storage',
        },
        'video_play': {
          'network': 'error_video_network',
          'server': 'error_video_server',
        },
      };

      String categoryKey = category.toString().split('.').last;
      return contextMessages[screen]?[categoryKey] ?? errorKey;
    }
    return errorKey;
  }

  /// Get localized message with parameter replacement
  static String _getLocalizedMessage(String key, Map<String, String>? params) {
    String message = key.tr;

    if (params != null) {
      params.forEach((key, value) {
        message = message.replaceAll('{$key}', value);
      });
    }

    return message;
  }

  /// Show error toast with dark theme
  static void _showErrorToast(String message, ErrorCategory category, AdvancedResponsiveHelper responsive) {
    Get.rawSnackbar(
      message: message,
      backgroundColor: _getErrorColor(category).withOpacity(0.9),
      borderRadius: responsive.borderRadiusSmall,
      margin: EdgeInsets.all(responsive.spacing(16)),
      duration: Duration(milliseconds: 5000),
      animationDuration: Duration(milliseconds: 500),
      snackPosition: SnackPosition.TOP,
      messageText: AppText.bodyMedium(
        message,
        color: Colors.white,
        maxLines: 2,
        minFontSize: 10,
        textAlign: TextAlign.start,
      ),
    );
  }

  /// Show error snackbar with retry action - dark theme
  static void _showErrorSnackbar(
      String message,
      ErrorCategory category,
      AdvancedResponsiveHelper responsive,
      VoidCallback? onRetry,
      Duration? customDuration,
      ) {
    if (kDebugMode) {
      print('🔴 _showErrorSnackbar called:');
      print('   Message: $message');
      print('   Category: $category');
      print('   Get.context: ${Get.context != null}');
      print('   Get.key.currentState: ${Get.key.currentState != null}');
    }

    _showActualSnackbar(message, category, responsive, onRetry, customDuration);
  }

  /// Internal method to show the actual error toast using custom overlay
  static void _showActualSnackbar(
      String message,
      ErrorCategory category,
      AdvancedResponsiveHelper responsive,
      VoidCallback? onRetry,
      Duration? customDuration,
      ) {
    print('🟠 _showActualSnackbar executing toast:');
    print('   Message: $message');
    print('   Category: $category');
    print('   Duration: ${customDuration?.inMilliseconds ?? 3000}ms');

    // 🚀 NEW: Use custom overlay toast with app gradient
    try {
      print('📱 Showing ERROR toast with custom overlay...');

      // Get context - use Navigator's context
      final ctx = Get.key.currentState?.overlay?.context ?? Get.context;
      if (ctx == null) {
        print('❌ No valid context for toast');
        return;
      }

      final isDark = Theme.of(ctx).brightness == Brightness.dark;

      // 🔥 FIX: Use root overlay that persists across navigation (same as progress)
      final overlayState = ctx.findRootAncestorStateOfType<OverlayState>() ??
                          Get.key.currentState?.overlay;
      if (overlayState == null) {
        print('❌ No overlay state available');
        return;
      }

      // 🔥 FIX: Remove previous error overlay before showing new one
      // This ensures validation errors always show, even on repeated clicks
      try {
        if (_errorOverlayEntry != null) {
          _errorOverlayEntry!.remove();
          _errorOverlayEntry = null;
          print('✅ Previous error overlay removed');
        }
      } catch (e) {
        print('⚠️ Error removing previous overlay: $e');
      }

      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 50, // Error toast stays at 50
          left: 16, // 🔥 Changed from 10 to 16 for better spacing
          right: 16, // 🔥 Changed from 10 to 16 for better spacing
          child: Material(
            color: Colors.transparent,
            child: Container(
              // 🔥 NEW: Minimum height for bigger toast
              constraints: BoxConstraints(
                minHeight: 70, // Minimum height
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 🔥 Increased padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.black ,
                          AppColors.black ,
                        ]
                      : [
                          AppColorsLight.scaffoldBackground, // Your gradient color 1
                          AppColorsLight.scaffoldBackground, // Your gradient color 2
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark ? AppColors.backgroundDark : AppColorsLight.scaffoldBackground,
                  width: 1, // 🔥 Slightly thicker border
                ),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall), // 🔥 More rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4), // 🔥 Stronger shadow
                    blurRadius: 15, // 🔥 More blur
                    spreadRadius: 2, // 🔥 Shadow spread
                    offset: Offset(0, 5), // 🔥 More vertical offset
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: isDark ? Colors.white : AppColorsLight.textPrimary,
                    size: responsive.iconSizeLarge,
                  ),
                  SizedBox(width: responsive.spacing(10)),
                  Expanded(
                    child: AppText.searchbar2(
                      message,
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      maxLines: 2,
                      minFontSize: 10,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      overlayState.insert(overlayEntry);

      // 🔥 FIX: Save reference for removal on next error
      _errorOverlayEntry = overlayEntry;

      // Auto remove after duration
      Future.delayed(customDuration ?? Duration(milliseconds: 3000), () {
        try {
          overlayEntry.remove();
          if (_errorOverlayEntry == overlayEntry) {
            _errorOverlayEntry = null;
          }
        } catch (e) {
          // Already removed, ignore
        }
      });

      print('✅ Error toast shown successfully with custom overlay');
    } catch (e, stackTrace) {
      print('❌ Error in _showActualSnackbar: $e');
      print('   Stack trace: $stackTrace');
    }
  }



  /// Show success toast using custom overlay
  static void _showSuccessSnackbar(
      String message,
      AdvancedResponsiveHelper responsive,
      Duration? customDuration,
      VoidCallback? onTap,
      ) {
    if (kDebugMode) {
      print('🎉 _showSuccessSnackbar called with message: $message');
      print('   Duration: ${customDuration?.inSeconds ?? 3} seconds');
    }

    // 🚀 NEW: Use custom overlay toast with app gradient
    try {
      print('📱 Showing SUCCESS toast with custom overlay...');

      // Get context - use Navigator's context
      final ctx = Get.key.currentState?.overlay?.context ?? Get.context;
      if (ctx == null) {
        print('❌ No valid context for toast');
        return;
      }

      final isDark = Theme.of(ctx).brightness == Brightness.dark;

      // 🔥 FIX: Use root overlay that persists across navigation (same as progress)
      final overlayState = ctx.findRootAncestorStateOfType<OverlayState>() ??
                          Get.key.currentState?.overlay;
      if (overlayState == null) {
        print('❌ No overlay state available');
        return;
      }
      final overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 50, // 🔥 Changed from 60 to 50
          left: 16, // 🔥 Changed from 10 to 16 for better spacing
          right: 16, // 🔥 Changed from 10 to 16 for better spacing
          child: Material(
            color: Colors.transparent,
            child: Container(
              // 🔥 NEW: Minimum height for bigger toast
              constraints: BoxConstraints(
                minHeight: 70, // Minimum height
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 🔥 Increased padding
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.black ,
                          AppColors.black ,
                        ]
                      : [
                          AppColorsLight.scaffoldBackground, // Your gradient color 1
                          AppColorsLight.scaffoldBackground, // Your gradient color 2
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark ? AppColors.backgroundDark : AppColorsLight.scaffoldBackground,
                  width: 1, // 🔥 Slightly thicker border
                ),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall), // 🔥 More rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4), // 🔥 Stronger shadow
                    blurRadius: 15, // 🔥 More blur
                    spreadRadius: 2, // 🔥 Shadow spread
                    offset: Offset(0, 5), // 🔥 More vertical offset
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: isDark ? Colors.white : AppColorsLight.textPrimary,
                    size: responsive.iconSizeLarge,
                  ),
                  SizedBox(width: responsive.spacing(10)),
                  Expanded(
                    child: AppText.searchbar2(
                      message,
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      maxLines: 2,
                      minFontSize: 10,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      overlayState.insert(overlayEntry);

      // Auto remove after duration
      Future.delayed(customDuration ?? Duration(milliseconds: 3000), () {
        overlayEntry.remove();
      });

      print('✅ Success toast shown successfully with custom overlay');
    } catch (e, stackTrace) {
      print('❌ Error showing SUCCESS toast: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// Get error color based on category - dark theme compatible
  static Color _getErrorColor(ErrorCategory category) {
    switch (category) {
      case ErrorCategory.network:
        return Color(0xFFFF6B35); // Orange for network issues
      case ErrorCategory.server:
        return Color(0xFFE53E3E); // Red for server errors
      case ErrorCategory.validation:
        return Color(0xFFED8936); // Amber for validation
      case ErrorCategory.authentication:
        return Color(0xFFE53E3E); // Red for auth issues
      case ErrorCategory.permission:
        return Color(0xFFED8936); // Amber for permissions
      case ErrorCategory.storage:
        return Color(0xFFFF6B35); // Orange for storage
      case ErrorCategory.upload:
        return Color(0xFFE53E3E); // Red for upload failures
      case ErrorCategory.download:
        return Color(0xFFE53E3E); // Red for download failures
      default:
        return Color(0xFFE53E3E); // Gray for general errors
    }
  }

  /// Process error queue
  static void _processQueue() {
    if (_errorQueue.isNotEmpty && !_isProcessing) {
      ErrorModel error = _errorQueue.removeFirst();
      _processError(
        error.key,
        error.severity,
        error.category,
        error.params,
        error.onRetry,
        error.screen,
        error.customDuration,
      );
    }
  }

  /// Track error for analytics
  static void _trackError(String errorKey, ErrorCategory category, String? screen) {
    // TODO: Implement analytics tracking
    print('📊 Error tracked: $errorKey, Category: $category, Screen: $screen');
  }

  /// Check if we're using real API server
  static bool _isUsingRealAPI() {
    // Mock mode disabled - always using real API now
    return true; // Real API mode enabled
  }

  /// Handle errors in offline mode - show only once at top
  static void _handleOfflineError(String errorKey, ErrorCategory category) {
    // Only show error once in offline mode
    if (_offlineErrorShown) return;

    // Only show network related errors in offline mode
    if (category != ErrorCategory.network &&
        category != ErrorCategory.server &&
        category != ErrorCategory.general) {
      return;
    }

    _offlineErrorShown = true;

    final responsive = AdvancedResponsiveHelper(Get.context!);

    // Show simple top snackbar for offline mode
    Get.rawSnackbar(
      title: 'Offline Mode',
      message: 'App is running in offline mode. Some features may not be available.',
      backgroundColor: AppColors.networkBackground, // Use AppColors
      borderRadius: responsive.borderRadiusSmall,
      margin: EdgeInsets.fromLTRB(16, 50, 16, 0), // Top margin for status bar
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 500),
      snackPosition: SnackPosition.TOP, // Force top position
      titleText: AppText.headlineLarge(
        'Offline Mode',
        color: AppColors.networkText,
        maxLines: 1,
        minFontSize: 12,
        textAlign: TextAlign.start,
      ),
      messageText: AppText.bodyMedium(
        'App is running in offline mode. Some features may not be available.',
        color: AppColors.networkText,
        maxLines: 2,
        minFontSize: 10,
        textAlign: TextAlign.start,
      ),
      icon: Icon(
        Icons.wifi_off,
        color: AppColors.networkIcon, // Use AppColors
        size: 24,
      ),
    );
  }

  // 🔥 Error overlay entry reference for removal (ensures new error replaces old)
  static OverlayEntry? _errorOverlayEntry;
}

/// Error model for queue system
class ErrorModel {
  final String key;
  final ErrorSeverity severity;
  final ErrorCategory category;
  final Map<String, String>? params;
  final VoidCallback? onRetry;
  final String? screen;
  final Duration? customDuration;

  ErrorModel({
    required this.key,
    required this.severity,
    required this.category,
    this.params,
    this.onRetry,
    this.screen,
    this.customDuration,
  });
}

