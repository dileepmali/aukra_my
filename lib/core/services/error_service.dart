import 'dart:async'; // 🔥 NEW: For Timer
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart'; // 🔥 NEW: Import for light theme gradient colors
import '../../app/themes/app_text.dart'; // 🔥 NEW: Import for AppText (flexible, overflow-resistant text)
import '../../app/constants/app_images.dart'; // 🔥 NEW: Import for app logo
import '../responsive_layout/device_category.dart';
import '../responsive_layout/font_size_hepler_class.dart';
import '../responsive_layout/padding_navigation.dart';
import '../untils/error_types.dart';

/// Advanced Error Handling Service for Dark Theme App
/// Handles errors like Google, Instagram, JioCinema
class AdvancedErrorService {
  // Error Queue System - prevents duplicate and spam errors
  static final Queue<ErrorModel> _errorQueue = Queue();
  static bool _isProcessing = false;
  static String? _lastErrorKey;
  static DateTime? _lastErrorTime;
  static int _errorCount = 0;
  static const Duration _cooldownPeriod = Duration(seconds: 5);
  static const Duration _spamThreshold = Duration(seconds: 2);

  // Offline mode error tracking
  static bool _offlineErrorShown = false;



  // Progress tracking
  static bool _isProgressShowing = false;
  static double _currentProgress = 0.0;
  static String? _currentProgressTitle;
  static String? _currentProgressMessage;
  static bool _isProgressExpanded = false; // Track expanded/collapsed state
  static bool _isProgressComplete = false; // Track if progress is complete
  static bool _isDarkTheme = true; // Track theme for progress UI
  static Timer? _progressHideTimer; // 🔥 NEW: Track the auto-hide timer
  static bool _isProgressMinimized = false; // 🔥 NEW: Track minimized state (circular badge)
  static RouteObserver<PageRoute>? _routeObserver; // 🔥 NEW: Track navigation changes

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
    print('   Progress showing: $_isProgressShowing');

    // 🔥 FIX: Smart error blocking - only block during ACTIVE uploads, not after completion
    // ✅ NEVER block validation errors (login, OTP, form validation)
    // Check if progress message indicates uploads are still running (contains "Uploading")
    // If progress shows completion message (e.g., "430 succeeded, 14 failed"), allow error to show
    if (_isProgressShowing &&
        (_currentProgressMessage?.contains('Uploading') ?? false) &&
        category != ErrorCategory.validation) { // ✅ Don't block validation errors
      if (kDebugMode) {
        print('⚠️ Uploads in progress - blocking error toast to avoid hijacking progress');
        print('   Current progress message: $_currentProgressMessage');
        print('   Error will be shown after uploads complete');
      }
      return; // Block only during active uploads (except validation errors)
    }

    // ✅ If progress is showing BUT uploads are complete (message doesn't contain "Uploading"),
    // OR if progress is not showing at all, allow error to show

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
    print('   Progress showing: $_isProgressShowing');

    // 🔥 FIX: Don't hijack progress bar for single file success messages
    // Only individual upload success messages should be shown as separate toasts
    // The upload controller will handle showing "Upload Complete ✓" when ALL files are done
    // This prevents premature "Upload Complete" messages during batch uploads
    if (_isProgressShowing) {
      if (kDebugMode) {
        print('⚠️ Progress is showing - skipping success toast to avoid hijacking progress');
        print('   The upload controller will show completion message when ready');
      }
      return; // Don't show separate success toast or hijack progress
    }

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

    switch (type) {
      case SuccessType.toast:
        _showSuccessToast(message, responsive);
        break;
      case SuccessType.snackbar:
        _showSuccessSnackbar(message, responsive, customDuration, onTap);
        break;
      case SuccessType.dialog:
        _showSuccessDialog(message, responsive, onTap);
        break;
    }

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
        // Show as snackbar instead of dialog (2000 milliseconds duration)
        _showErrorSnackbar(message, category, responsive, onRetry, Duration(milliseconds: 5000));
        break;
      case ErrorSeverity.critical:
        Get.to(() => _ErrorScreen(
          message: message,
          category: category,
          onRetry: onRetry,
        ));
        break;
      // Legacy severity values - default to medium
      case ErrorSeverity.success:
      case ErrorSeverity.info:
      case ErrorSeverity.warning:
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

  /// Check if error is duplicate within cooldown period
  static bool _isDuplicate(String errorKey) {
    if (_lastErrorKey != errorKey) return false;
    if (_lastErrorTime == null) return false;

    Duration timeSinceLastError = DateTime.now().difference(_lastErrorTime!);
    bool isDuplicate = timeSinceLastError < _cooldownPeriod;

    if (isDuplicate && kDebugMode) {
      print('🚫 Duplicate error within cooldown: $errorKey (${timeSinceLastError.inSeconds}s ago)');
    }

    return isDuplicate;
  }

  /// Check if user is spamming same error
  static bool _isSpamming(String errorKey) {
    if (_lastErrorKey == errorKey && _lastErrorTime != null) {
      Duration timeSinceLastError = DateTime.now().difference(_lastErrorTime!);
      if (timeSinceLastError < _spamThreshold) {
        _errorCount++;
        if (_errorCount > 3) {
          // Show help message instead of same error
          showError(
            'error_too_many_attempts',
            severity: ErrorSeverity.medium,
            category: ErrorCategory.general,
          );
          _errorCount = 0;
          return true;
        }
      } else {
        _errorCount = 0;
      }
    }
    return false;
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

  /// Helper function to calculate fixed top margin consistently
  /// Uses screen height percentage for consistent positioning across all screens
  /// Independent of AppBar height and bottom navigation bar presence
  static double _calculateFixedTopMargin(BuildContext ctx, AdvancedResponsiveHelper responsive, {double extra = 20}) {
    final screenHeight = MediaQuery.of(ctx).size.height;
    // 🔥 FIX: Use fixed percentage of screen height (12%) for consistent positioning
    // This ensures snackbar appears at same visual position regardless of:
    // - AppBar height (14 in FolderScreen, 20 in GenericFolderScreen)
    // - Bottom navigation bar presence (FolderScreen has it, GenericFolderScreen doesn't)
    final fixedTopMargin = screenHeight * 0.12;
    return fixedTopMargin;
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
                          AppColors.containerDark ,
                          AppColors.containerLight ,
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
                borderRadius: BorderRadius.circular(16), // 🔥 More rounded corners
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
                          AppColors.containerDark ,
                          AppColors.containerLight ,
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
                borderRadius: BorderRadius.circular(16), // 🔥 More rounded corners
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

  /// Show success toast
  static void _showSuccessToast(String message, AdvancedResponsiveHelper responsive) {
    // Close any existing snackbar first

    Get.rawSnackbar(
      message: message,
      backgroundColor: AppColors.splaceSecondary1,
      borderRadius: responsive.borderRadiusSmall,
      margin: EdgeInsets.all(responsive.spacing(16)),
      duration: Duration(milliseconds: 5000),
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

  /// Show success dialog
  static void _showSuccessDialog(String message, AdvancedResponsiveHelper responsive, VoidCallback? onTap) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          side: BorderSide(color: AppColors.splaceSecondary1, width: 1),
        ),
        title: Container(
          padding: EdgeInsets.all(responsive.spacing(8)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.splaceSecondary1, AppColors.splaceSecondary2],
            ),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: AppText.headlineLarge(
            'success'.tr,
            color: Colors.black,
            maxLines: 1,
            minFontSize: 12,
            textAlign: TextAlign.center,
          ),
        ),
        content: AppText.bodyLarge(
          message,
          color: Colors.white.withOpacity(0.9),
          maxLines: 3,
          minFontSize: 12,
          textAlign: TextAlign.start,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              if (onTap != null) onTap();
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.splaceSecondary1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              ),
            ),
            child: AppText.button(
              'ok'.tr,
              color: Colors.black,
              maxLines: 1,
              minFontSize: 10,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
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

  // ✅ Removed _getCategoryTitle() - not needed anymore (no category titles displayed)

  /// Get default duration based on severity
  /// ALL messages show for 3 seconds (3000ms) for consistency
  static Duration _getDefaultDuration(ErrorSeverity severity) {
    return Duration(milliseconds: 3000);
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

  /// Clear error queue (for testing or reset)
  static void clearQueue() {
    _errorQueue.clear();
    _isProcessing = false;
    _lastErrorKey = null;
    _lastErrorTime = null;
    _errorCount = 0;
    _offlineErrorShown = false; // Reset offline error flag
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

  // ==================== PROGRESS BAR METHODS ====================

  /// Show progress notification with progress bar at top
  static void showProgress({
    required String title,
    required String message,
    double progress = 0.0,
    bool showProgressBar = true,
  }) {
    // 🔥 ALWAYS PRINT - to debug multiple upload issue
    print('═══════════════════════════════════════════════════════');
    print('📊 showProgress() CALLED');
    print('   Title: $title');
    print('   Message: $message');
    print('   Progress: ${(progress * 100).toStringAsFixed(1)}%');
    print('   CURRENT STATE:');
    print('     _isProgressShowing: $_isProgressShowing');
    print('     _isProgressComplete: $_isProgressComplete');
    print('     _currentProgress: ${(_currentProgress * 100).toStringAsFixed(1)}%');
    print('     _progressHideTimer: ${_progressHideTimer != null ? "ACTIVE" : "NULL"}');
    print('     _progressOverlayEntry: ${_progressOverlayEntry != null ? "EXISTS" : "NULL"}');
    print('═══════════════════════════════════════════════════════');

    // 🔥 FIX: Only force reset if message explicitly says "All uploads completed"
    // Do NOT reset for mixed file types (videos + images) where progress might drop temporarily
    if (_isProgressComplete && message.contains('All uploads completed')) {
      if (kDebugMode) {
        print('🔄 Detected complete upload - forcing progress reset for new batch');
        print('   _isProgressComplete: $_isProgressComplete');
        print('   Current progress: ${(_currentProgress * 100).toStringAsFixed(1)}%');
        print('   New progress: ${(progress * 100).toStringAsFixed(1)}%');
        print('   Message: $message');
      }

      // 🔥 FIX: Cancel any pending hide timer to prevent race conditions
      if (_progressHideTimer != null) {
        _progressHideTimer!.cancel();
        _progressHideTimer = null;
        if (kDebugMode) {
          print('✅ Cancelled pending hide timer');
        }
      }

      // Force reset all progress state
      _isProgressComplete = false;
      _isProgressShowing = false;
      _currentProgress = 0.0;
      _progressStateSetter = null;

      // Remove old overlay entry if it still exists
      try {
        if (_progressOverlayEntry != null) {
          _progressOverlayEntry!.remove();
          _progressOverlayEntry = null;
          if (kDebugMode) {
            print('✅ Removed old progress overlay');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error removing old progress overlay: $e');
        }
      }

      // Now proceed to create new overlay below
    }

    // 🔥 FIX: If already showing AND actively uploading (not complete), ONLY update
    // This ensures snackbar persists across multiple concurrent uploads
    if (_isProgressShowing && !_isProgressComplete) {
      // Update existing progress using updateProgress method
      updateProgress(
        progress: progress,
        message: message,
        title: title,
      );
      if (kDebugMode) {
        print('📊 Progress updated (persistent): $title - ${(progress * 100).toStringAsFixed(1)}%');
      }
      return;
    }

    // 🔥 NEW: Reset completion flag when showing new progress
    _isProgressComplete = false;

    _isProgressShowing = true;
    _currentProgress = progress;
    _currentProgressTitle = title;
    _currentProgressMessage = message;

    // ✅ FIX: Removed Get.closeCurrentSnackbar() to prevent LateInitializationError
    // Let GetX handle snackbar lifecycle automatically

    // Use the new improved progress snackbar
    _showProgressSnackbar();

    if (kDebugMode) {
      print('📊 Progress shown (new): $title - ${(progress * 100).toStringAsFixed(1)}%');
    }
  }

  // Progress notification widget reference for real-time updates
  static Widget? _progressWidget;
  static StateSetter? _progressStateSetter;

  /// Update progress notification in real-time
  static void updateProgress({
    required double progress,
    String? message,
    String? title,
  }) {
    // 🔥 ALWAYS PRINT - to debug multiple upload issue
    if (kDebugMode) {
      print('📈 updateProgress() CALLED');
      print('   New progress: ${(progress * 100).toStringAsFixed(1)}%');
      print('   New message: $message');
      print('   _isProgressShowing: $_isProgressShowing');
    }

    // Only update if progress is currently showing
    if (!_isProgressShowing) {
      if (kDebugMode) {
        print('⚠️ updateProgress() IGNORED - progress not showing!');
      }
      return;
    }

    // Update stored values
    _currentProgress = progress;
    if (message != null) _currentProgressMessage = message;
    if (title != null) _currentProgressTitle = title;

    // 🔥 FIX: Auto-close ONLY when uploads are truly complete
    // CRITICAL: Don't rely on progress >= 1.0 alone - can be false positive during multi-upload
    // ONLY trust explicit completion messages that don't contain "Uploading"
    final isCompleteMessage = message != null &&
                              (message.contains('All uploads completed') ||
                               (message.contains('succeeded') && !message.contains('Uploading')) ||
                               (message.contains('failed') && !message.contains('Uploading')));

    // 🔥 REMOVED: progress >= 1.0 check - unreliable during concurrent uploads
    // Progress can temporarily hit 100% due to rounding or calculation issues

    if (isCompleteMessage) {
      _isProgressComplete = true;

      if (kDebugMode) {
        print('✅ ALL uploads completed - scheduling auto-close in 5 seconds');
        print('   Message: $message');
        print('   Progress: ${(progress * 100).toStringAsFixed(1)}%');
      }

      // Cancel any existing timer
      _progressHideTimer?.cancel();

      // Schedule auto-close after 5 seconds (force = true because completion is confirmed)
      _progressHideTimer = Timer(const Duration(seconds: 5), () {
        if (kDebugMode) {
          print('⏰ Auto-closing progress after 5 seconds (all uploads complete)');
        }
        hideProgress(force: true); // Force hide since we confirmed completion
      });
    }
    // 🔥 REMOVED: Don't mark completion at 100% progress
    // Progress can temporarily reach 100% for one file type while others are still uploading
    // Only mark complete when message explicitly says "All uploads completed"

    // If we have a progress widget state setter, use it for smooth updates
    if (_progressStateSetter != null) {
      _progressStateSetter!(() {
        // This will trigger a rebuild of the progress widget
      });
    } else {
      // Fallback to recreating the snackbar (less smooth but works)

    }

    if (kDebugMode) {
      print('📊 Progress updated: ${(progress * 100).toStringAsFixed(1)}%');
      if (progress >= 1.0) {
        print('🎉 Progress reached 100% - showing completion message');
      }
    }
  }

  // Progress overlay entry reference for removal
  static OverlayEntry? _progressOverlayEntry;

  // 🔥 NEW: Error overlay entry reference for removal (ensures new error replaces old)
  static OverlayEntry? _errorOverlayEntry;

  /// Show progress snackbar with custom overlay (same as error/success toast)
  static void _showProgressSnackbar() {
    final responsive = AdvancedResponsiveHelper(Get.context!);

    try {
      print('📊 _showProgressSnackbar called');
      print('   Title: $_currentProgressTitle');
      print('   Message: $_currentProgressMessage');
      print('   Progress: ${(_currentProgress * 100).toStringAsFixed(1)}%');

      // 🔥 FIX: Use global overlay context that persists across navigation
      // This ensures progress snackbar stays visible when navigating between screens
      final ctx = Get.overlayContext ?? Get.context ?? Get.key.currentState?.overlay?.context;
      if (ctx == null) {
        print('❌ No valid context for progress toast');
        return;
      }

      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      _isDarkTheme = isDark; // Store theme for progress UI builders

      // 🔥 FIX: Get root overlay state that persists across navigation
      // Using findRootAncestorStateOfType ensures we get the app's root overlay,
      // not the current screen's overlay which gets destroyed on navigation
      OverlayState? overlayState;
      try {
        overlayState = ctx.findRootAncestorStateOfType<OverlayState>() ??
                      Get.key.currentState?.overlay;
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error finding root overlay: $e - falling back to Get overlay');
        }
        overlayState = Get.key.currentState?.overlay;
      }

      if (overlayState == null) {
        print('❌ No overlay state available for progress');
        return;
      }

      if (kDebugMode) {
        print('✅ Using root overlay - progress will persist across navigation');
      }

      // 🔥 FIX: Use custom overlay entry with StatefulBuilder for real-time updates
      // ✅ BACKGROUND UPLOAD: Progress bar positioned at bottom, doesn't block UI
      // User can rename, delete, move, share files while upload runs in background
      _progressOverlayEntry = OverlayEntry(
        builder: (context) => StatefulBuilder(
          builder: (context, setState) {
            // Store the setState function for real-time updates
            _progressStateSetter = setState;

            // 🔥 FIXED: Get theme dynamically from context for runtime theme changes
            final isDark = Theme.of(context).brightness == Brightness.dark;

            // 🔥 FIXED: Detect theme change and update static variable
            if (_isDarkTheme != isDark) {
              _isDarkTheme = isDark;
              // Force rebuild on next frame when theme changes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_progressStateSetter != null) {
                  _progressStateSetter!(() {});
                }
              });
            }

            // 🔥 NEW: Stack with Listener to detect taps without blocking underlying widgets
            return Stack(
              children: [
                // 🔥 NEW: Listener detects taps but lets them pass through to underlying widgets
                Positioned.fill(
                  child: Listener(
                    onPointerDown: (_) {
                      // Auto-minimize when user taps anywhere on screen
                      // Listener doesn't consume the event, so underlying widgets still work
                      if (!_isProgressMinimized) {
                        setState(() {
                          autoMinimizeOnInteraction();
                        });
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                    child: IgnorePointer(
                      child: Container(color: Colors.transparent),
                    ),
                  ),
                ),
                // 🔥 Progress bar overlay (positioned at top)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 140, // 🔥 Progress at 140 (lower than toast at 50)
                  left: _isProgressMinimized ? null : 16, // Minimized: right-aligned, Full: full width
                  right: 16, // Always right margin
                  bottom: null, // 🔥 REMOVED: No longer at bottom
                  child: GestureDetector(
                    onTap: () {
                      // Prevent tap from passing through to background detector
                    },
                    child: Material(
                      color: Colors.transparent,
                      child: _isProgressMinimized
                          ? _buildMinimizedProgress(responsive, setState)
                          : Container(
                              padding: EdgeInsets.all(responsive.spacing(16)),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          AppColors.containerDark ?? Colors.black,
                                          AppColors.containerLight ?? Colors.grey.shade800,
                                        ]
                                      : [
                                          AppColorsLight.scaffoldBackground,
                                          AppColorsLight.scaffoldBackground,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: isDark ? AppColors.backgroundDark : AppColorsLight.scaffoldBackground,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge ?? 8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: _isProgressExpanded
                                  ? _buildExpandedProgress(responsive)
                                  : _buildCollapsedProgress(responsive, setState),
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      overlayState.insert(_progressOverlayEntry!);

      print('✅ Progress toast shown successfully with custom overlay');
    } catch (e, stackTrace) {
      print('❌ Error showing progress toast: $e');
      print('   Stack trace: $stackTrace');
    }
  }

  /// Minimize progress to circular badge
  static void minimizeProgress() {
    if (!_isProgressShowing) return;

    _isProgressMinimized = true;

    // Trigger UI update
    if (_progressStateSetter != null) {
      _progressStateSetter!(() {});
    }

    if (kDebugMode) {
      print('📊 Progress minimized to circular badge');
    }
  }

  /// 🔥 NEW: Auto-minimize progress when user interacts with UI
  /// Call this from dialogs, bottom sheets, navigation, etc.
  static void autoMinimizeOnInteraction() {
    if (!_isProgressShowing || _isProgressMinimized) return;

    if (kDebugMode) {
      print('🔄 Auto-minimizing progress due to user interaction');
    }

    minimizeProgress();
  }

  /// Expand progress from circular badge to full bar
  static void expandProgress() {
    if (!_isProgressShowing) return;

    _isProgressMinimized = false;

    // Trigger UI update
    if (_progressStateSetter != null) {
      _progressStateSetter!(() {});
    }

    if (kDebugMode) {
      print('📊 Progress expanded to full bar');
    }
  }

  /// Hide progress notification
  /// ⚠️ CRITICAL: Only hides if progress is truly complete OR force = true
  static void hideProgress({bool force = false}) {
    if (!_isProgressShowing) return;

    // 🔥 CRITICAL FIX: Check if progress is actually complete before hiding
    // ONLY hide if either:
    // 1. force = true (explicit manual hide)
    // 2. OR _isProgressComplete = true (all uploads done)
    // This prevents premature hiding when uploads are still in progress
    if (!force && !_isProgressComplete) {
      if (kDebugMode) {
        print('⚠️ hideProgress() BLOCKED - uploads still in progress');
        print('   force: $force');
        print('   _isProgressComplete: $_isProgressComplete');
        print('   Current message: $_currentProgressMessage');
      }
      return; // Don't hide - uploads still running!
    }

    // 🔥 FIX: Cancel any pending hide timer
    _progressHideTimer?.cancel();
    _progressHideTimer = null;

    _isProgressShowing = false;
    _currentProgress = 0.0;
    _currentProgressTitle = null;
    _currentProgressMessage = null;
    _progressStateSetter = null; // Clear the state setter
    _isProgressComplete = false; // 🔥 FIX: Also reset completion flag
    _isProgressMinimized = false; // 🔥 NEW: Reset minimized state

    // 🔥 NEW: Remove custom overlay entry (same as error/success toast)
    try {
      if (_progressOverlayEntry != null) {
        _progressOverlayEntry!.remove();
        _progressOverlayEntry = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error removing progress overlay: $e');
      }
    }

    if (kDebugMode) {
      print('📊 Progress hidden (force: $force)');
    }
  }

  /// Check if progress is currently showing
  static bool get isProgressShowing => _isProgressShowing;

  /// Check if progress is complete (100%)
  static bool get isProgressComplete => _isProgressComplete;

  /// Get current progress value (0.0 to 1.0)
  static double get currentProgress => _currentProgress;

  // ==================== PROGRESS UI BUILDERS ====================

  /// Extract completed count from message "45/200" → 45
  static int _extractCompletedCount(String? message) {
    if (message == null || message.isEmpty) return 0;
    final match = RegExp(r'(\d+)/\d+').firstMatch(message);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  /// Build minimized circular badge (FAB-sized)
  /// Shows only uploaded count (e.g., "45" not "45/200")
  static Widget _buildMinimizedProgress(AdvancedResponsiveHelper responsive, StateSetter setState) {
    final completedCount = _extractCompletedCount(_currentProgressMessage);

    return GestureDetector(
      onTap: () {
        setState(() {
          _isProgressMinimized = false; // Expand back to full bar
        });
      },
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 🔥 NEW: Circular progress indicator with shimmer animation
            if (_currentProgress > 0 && _currentProgress < 1.0)
              _CircularShimmerProgress(
                progress: _currentProgress,
                isDarkTheme: _isDarkTheme,
              )
            else
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: _currentProgress < 1.0 ? _currentProgress : null,
                  strokeWidth: 2.5,
                  backgroundColor: _isDarkTheme
                      ? Colors.white.withOpacity(0.2)
                      : AppColorsLight.textSecondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isDarkTheme
                        ? AppColors.splaceSecondary1 // 🌑 Dark theme golden
                        : AppColorsLight.splaceSecondary1, // ☀️ Light theme golden
                  ),
                ),
              ),
            // Background circle container
            Container(
              width: 48, // Slightly smaller than outer circle
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isDarkTheme
                      ? [
                          AppColors.containerDark ?? Colors.grey.shade800,
                          AppColors.containerLight ?? Colors.grey.shade700,
                        ]
                      : [
                          AppColorsLight.white,
                          AppColorsLight.white,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: AppText.searchbar(
                  '$completedCount',
                  color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                  maxLines: 1,
                  minFontSize: 8,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build collapsed progress view
  /// Layout: [Logo] Uploading 1/5 [Icon↓]
  ///                [Progress Bar]
  static Widget _buildCollapsedProgress(AdvancedResponsiveHelper responsive, StateSetter setState) {
    // 🔥 NEW: Clean title - only show "Uploading" or "Upload Complete ✓", ignore other text
    String cleanTitle = _currentProgressTitle ?? 'Progress';
    // If title contains "Upload Complete", keep it as is, otherwise show "Uploading"
    if (!cleanTitle.contains('Upload Complete') && !cleanTitle.contains('✓')) {
      cleanTitle = 'Uploading';
    }

    // 🔥 NEW: Extract only the counter (e.g., "4/10") from message, removing any prefix text
    String cleanMessage = _currentProgressMessage ?? '';
    final counterMatch = RegExp(r'\d+/\d+').firstMatch(cleanMessage);
    if (counterMatch != null) {
      cleanMessage = counterMatch.group(0) ?? cleanMessage;
    } else {
      // If no counter found, show empty string (no file name or other text)
      cleanMessage = '';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // App Logo (left)
        Image.asset(
          AppImages.AukraIm,
          width: responsive.iconSizeExtraLarge1,
          height: responsive.iconSizeExtraLarge1,
        ),
        SizedBox(width: responsive.spacing(10)),
        // Progress content
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and file counter row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AppText.searchbar2(
                      cleanTitle, // 🔥 Use cleaned title (only "Uploading" or "Upload Complete ✓")
                      color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                      maxLines: 1,
                      minFontSize: 10,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(width: 8),
                  AppText.searchbar2(
                    cleanMessage, // 🔥 Use cleaned message (only "4/10" format)
                    color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                    maxLines: 1,
                    minFontSize: 10,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(4)),
              // 🔥 NEW: Windows-style animated progress bar with shimmer effect
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      // Layer 1: Background track
                      Container(
                        width: double.infinity,
                        color: _isDarkTheme
                            ? Colors.white.withOpacity(0.3)
                            : AppColorsLight.textSecondary.withOpacity(0.2),
                      ),
                      // Layer 2: Determinate progress (0-100% fill)
                      FractionallySizedBox(
                        widthFactor: _currentProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isDarkTheme
                                  ? [
                                      AppColors.splaceSecondary1.withOpacity(0.8), // 🟡 Golden start
                                      AppColors.splaceSecondary2.withOpacity(0.8), // 🟡 Golden end
                                    ]
                                  : [
                                      AppColorsLight.splaceSecondary1.withOpacity(0.8), // 🟡 Golden start
                                      AppColorsLight.splaceSecondary2.withOpacity(0.8), // 🟡 Golden end
                                    ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      // Layer 3: Animated shimmer line (Windows-style)
                      if (_currentProgress > 0 && _currentProgress < 1.0)
                        FractionallySizedBox(
                          widthFactor: _currentProgress,
                          child: ClipRect(
                            child: _WindowsShimmerAnimation(
                              isDarkTheme: _isDarkTheme,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: responsive.spacing(12)),
        // 🔥 FIX: Minimize and Expand icons in COLUMN (vertical layout)
        // Top: Expand/Collapse icon, Bottom: Minimize icon
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expand icon (TOP)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isProgressExpanded = true;
                });
              },
              child: Icon(
                Icons.keyboard_arrow_down,
                color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                size: 24,
              ),
            ),
            SizedBox(height: responsive.spacing(4)), // 🔥 Vertical spacing
            // Minimize to circular badge (BOTTOM)
            GestureDetector(
              onTap: () {
                setState(() {
                  _isProgressMinimized = true;
                });
              },
              child: Icon(
                Icons.remove_circle_outline,
                color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build expanded progress view
  /// Layout: [Logo] AnantSpace 45.5% [Icon↑]
  ///                Uploading    1/5
  ///                [Progress Bar]
  static Widget _buildExpandedProgress(AdvancedResponsiveHelper responsive) {
    // 🔥 NEW: Clean title and message for expanded view too
    String cleanTitle = _currentProgressTitle ?? 'Progress';
    if (!cleanTitle.contains('Upload Complete') && !cleanTitle.contains('✓')) {
      cleanTitle = 'Uploading';
    }

    String cleanMessage = _currentProgressMessage ?? '';
    final counterMatch = RegExp(r'\d+/\d+').firstMatch(cleanMessage);
    if (counterMatch != null) {
      cleanMessage = counterMatch.group(0) ?? cleanMessage;
    } else {
      cleanMessage = '';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App Logo (left)
        Image.asset(
          AppImages.AukraIm,
          width: responsive.iconSizeExtraLarge1,
          height: responsive.iconSizeExtraLarge1,
        ),
        SizedBox(width: responsive.spacing(10)),
        // Progress content
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AnantSpace and percentage row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AppText.searchbar2(
                      'AnantSpace',
                      color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                      maxLines: 1,
                      minFontSize: 10,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(width: 8),
                  AppText.searchbar2(
                    '${(_currentProgress * 100).toStringAsFixed(1)}%',
                    color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                    maxLines: 1,
                    minFontSize: 10,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(4)),
              // Uploading and file counter row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AppText.searchbar1(
                      cleanTitle, // 🔥 Use cleaned title (only "Uploading" or "Upload Complete ✓")
                      color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                      maxLines: 1,
                      minFontSize: 10,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(width: 8),
                  AppText.searchbar1(
                    cleanMessage, // 🔥 Use cleaned message (only counter "4/10")
                    color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
                    maxLines: 1,
                    minFontSize: 10,
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
              SizedBox(height: responsive.spacing(8)),
              // 🔥 NEW: Windows-style animated progress bar with shimmer effect
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      // Layer 1: Background track
                      Container(
                        width: double.infinity,
                        color: _isDarkTheme
                            ? Colors.white.withOpacity(0.3)
                            : AppColorsLight.textSecondary.withOpacity(0.2),
                      ),
                      // Layer 2: Determinate progress (0-100% fill)
                      FractionallySizedBox(
                        widthFactor: _currentProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isDarkTheme
                                  ? [
                                      AppColors.splaceSecondary1.withOpacity(0.8), // 🟡 Golden start
                                      AppColors.splaceSecondary2.withOpacity(0.8), // 🟡 Golden end
                                    ]
                                  : [
                                      AppColorsLight.splaceSecondary1.withOpacity(0.8), // 🟡 Golden start
                                      AppColorsLight.splaceSecondary2.withOpacity(0.8), // 🟡 Golden end
                                    ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                      // Layer 3: Animated shimmer line (Windows-style)
                      if (_currentProgress > 0 && _currentProgress < 1.0)
                        FractionallySizedBox(
                          widthFactor: _currentProgress,
                          child: ClipRect(
                            child: _WindowsShimmerAnimation(
                              isDarkTheme: _isDarkTheme,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: responsive.spacing(12)),
        // Collapse icon (right)
        GestureDetector(
          onTap: () {
            if (_progressStateSetter != null) {
              _progressStateSetter!(() {
                _isProgressExpanded = false;
              });
            }
          },
          child: Icon(
            Icons.keyboard_arrow_up,
            color: _isDarkTheme ? Colors.white : AppColorsLight.textPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }
}

// ✅ Enums moved to ../utils/error_types.dart
// Import: import '../utils/error_types.dart';

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

/// Full screen error widget for critical errors
class _ErrorScreen extends StatelessWidget {
  final String message;
  final ErrorCategory category;
  final VoidCallback? onRetry;

  const _ErrorScreen({
    required this.message,
    required this.category,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppText.headlineLarge(
          'error occurred'.tr,
          color: Colors.white,
          maxLines: 1,
          minFontSize: 12,
          textAlign: TextAlign.start,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(responsive.spacing(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: responsive.spacing(64),
                color: AdvancedErrorService._getErrorColor(category),
              ),
              SizedBox(height: responsive.spacing(24)),
              AppText.bodyLarge(
                message,
                color: Colors.white,
                maxLines: 5,
                minFontSize: 12,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: responsive.spacing(32)),
              if (onRetry != null)
                ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdvancedErrorService._getErrorColor(category),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.spacing(32),
                      vertical: responsive.spacing(16),
                    ),
                  ),
                  child: AppText.button(
                    'try_again'.tr,
                    color: Colors.white,
                    maxLines: 1,
                    minFontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔥 Windows-style shimmer animation widget (infinite loop)
/// Used for animated progress bar effect
class _WindowsShimmerAnimation extends StatefulWidget {
  final bool isDarkTheme;

  const _WindowsShimmerAnimation({
    required this.isDarkTheme,
  });

  @override
  State<_WindowsShimmerAnimation> createState() => _WindowsShimmerAnimationState();
}

class _WindowsShimmerAnimationState extends State<_WindowsShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 🔥 OPTIMIZED: Faster animation (1000ms instead of 1500ms) for better visibility
    _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(); // ✅ Infinite loop

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (_animation.value * 150) - 150, // 🔥 Wider shimmer (150px instead of 120px)
            0,
          ),
          child: Container(
            width: 150, // 🔥 Wider shimmer for better visibility
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isDarkTheme
                    ? [
                        Colors.transparent,
                        // 🔥 DARK THEME: Golden gradient shimmer
                        AppColors.splaceSecondary1.withOpacity(0.9), // 🟡 Golden start
                        AppColors.splaceSecondary2.withOpacity(0.9), // 🟡 Golden end
                        Colors.transparent,
                      ]
                    : [
                        Colors.transparent,
                        // 🔥 LIGHT THEME: Golden gradient shimmer
                        AppColorsLight.splaceSecondary1.withOpacity(0.9), // 🟡 Golden start
                        AppColorsLight.splaceSecondary2.withOpacity(0.9), // 🟡 Golden end
                        Colors.transparent,
                      ],
                stops: [0.0, 0.33, 0.67, 1.0], // Gradient spread for shimmer effect
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 🔥 Circular shimmer progress indicator with golden gradient
/// Used for minimized circular progress badge
class _CircularShimmerProgress extends StatefulWidget {
  final double progress;
  final bool isDarkTheme;

  const _CircularShimmerProgress({
    required this.progress,
    required this.isDarkTheme,
  });

  @override
  State<_CircularShimmerProgress> createState() => _CircularShimmerProgressState();
}

class _CircularShimmerProgressState extends State<_CircularShimmerProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500), // Smooth rotation
      vsync: this,
    )..repeat(); // Infinite rotation

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularGradientProgressPainter(
              progress: widget.progress,
              rotation: _animation.value * 2 * 3.14159, // Full rotation in radians
              isDarkTheme: widget.isDarkTheme,
            ),
          );
        },
      ),
    );
  }
}

/// 🎨 Custom painter for circular gradient progress with shimmer
class _CircularGradientProgressPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final bool isDarkTheme;

  _CircularGradientProgressPainter({
    required this.progress,
    required this.rotation,
    required this.isDarkTheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 2.5;

    // Background track
    final backgroundPaint = Paint()
      ..color = isDarkTheme
          ? Colors.white.withOpacity(0.2)
          : AppColorsLight.textSecondary.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc with gradient
    if (progress > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
      final sweepAngle = 2 * 3.14159 * progress;

      // Gradient shader with rotation for shimmer effect
      final gradient = SweepGradient(
        colors: isDarkTheme
            ? [
                AppColors.splaceSecondary1.withOpacity(0.8), // 🟡 Golden start
                AppColors.splaceSecondary2.withOpacity(1.0), // 🟡 Golden bright (shimmer)
                AppColors.splaceSecondary1.withOpacity(0.8), // 🟡 Golden end
              ]
            : [
                AppColorsLight.splaceSecondary1.withOpacity(0.8), // 🟡 Golden start
                AppColorsLight.splaceSecondary2.withOpacity(1.0), // 🟡 Golden bright (shimmer)
                AppColorsLight.splaceSecondary1.withOpacity(0.8), // 🟡 Golden end
              ],
        stops: [0.0, 0.5, 1.0],
        transform: GradientRotation(rotation), // Rotate gradient for shimmer
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -3.14159 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularGradientProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.rotation != rotation ||
        oldDelegate.isDarkTheme != isDarkTheme;
  }
}