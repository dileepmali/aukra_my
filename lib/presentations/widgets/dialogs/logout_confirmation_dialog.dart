
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/localizations/l10n/app_localizations.dart';
import '../../../core/api/auth_storage.dart';
import '../../../core/api/logout_api.dart';
import '../../../core/api/user_profile_api_service.dart';
import '../../../controllers/localization_controller.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_border_widget.dart';

/// Enum for different logout types
enum LogoutType {
  currentDevice,    // POST /api/auth/logout
  specificDevice,   // POST /api/auth/logout/{sessionId}
  allDevices,       // POST /api/auth/all-device-logout
}

class LogoutConfirmationDialog extends StatefulWidget {
  final LogoutType logoutType;
  final String? sessionId;    // Required for specificDevice logout
  final String? deviceName;   // Device name to show in subtitle

  const LogoutConfirmationDialog({
    Key? key,
    this.logoutType = LogoutType.currentDevice,
    this.sessionId,
    this.deviceName,
  }) : super(key: key);

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isLoggingOut = false;
  final UserProfileApiService _userProfileApi = UserProfileApiService();

  /// Get subtitle based on logout type
  String get _subtitleText {
    switch (widget.logoutType) {
      case LogoutType.currentDevice:
        return 'Are you sure you want to logout from current device?';
      case LogoutType.specificDevice:
        return 'Are you sure you want to logout from ${widget.deviceName ?? 'this device'}?';
      case LogoutType.allDevices:
        return 'Are you sure you want to logout from all devices?';
    }
  }

  /// Handle logout with proper cleanup
  Future<void> _handleLogout() async {
    try {
      print('🔴 Starting logout process... Type: ${widget.logoutType}');

      // Show loading state
      setState(() {
        _isLoggingOut = true;
      });

      bool apiSuccess = false;

      // ✅ STEP 1: Call appropriate logout API based on type
      switch (widget.logoutType) {
        case LogoutType.currentDevice:
          // POST /api/auth/logout
          print('📡 Calling current device logout API...');
          final apiResponse = await LogoutApi.logout();
          apiSuccess = apiResponse['success'] == true;
          if (apiSuccess) {
            print('✅ Current device logout successful: ${apiResponse['message']}');
          } else {
            print('⚠️ Current device logout failed: ${apiResponse['message']}');
          }
          break;

        case LogoutType.specificDevice:
          // POST /api/auth/logout/{sessionId}
          print('📡 Calling specific device logout API for sessionId: ${widget.sessionId}');
          if (widget.sessionId != null) {
            apiSuccess = await _userProfileApi.logoutDevice(widget.sessionId!);
            if (apiSuccess) {
              print('✅ Specific device logout successful');
            } else {
              print('⚠️ Specific device logout failed');
            }
          }
          break;

        case LogoutType.allDevices:
          // POST /api/auth/all-device-logout
          print('📡 Calling all devices logout API...');
          apiSuccess = await _userProfileApi.logoutAllDevices();
          if (apiSuccess) {
            print('✅ All devices logout successful');
          } else {
            print('⚠️ All devices logout failed');
          }
          break;
      }

      // For specificDevice logout, just close dialog and return result
      // Don't clear local storage or navigate (user stays logged in on current device)
      if (widget.logoutType == LogoutType.specificDevice) {
        if (mounted) {
          Get.back(result: apiSuccess);
        }
        return;
      }

      // For currentDevice and allDevices, proceed with full logout

      // ✅ STEP 2: RESET LANGUAGE TO ENGLISH ON LOGOUT (GetStorage)
      if (Get.isRegistered<LocalizationController>()) {
        final localizationController = Get.find<LocalizationController>();
        await localizationController.resetToDefaultLanguage();
        print('🌐 Language reset to English on logout (GetStorage cleared)');
      }

      // ✅ STEP 3: ALSO CLEAR SHARED PREFERENCES LANGUAGE
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('selected_language');
        print('🌐 SharedPreferences language cleared on logout');
      } catch (e) {
        print('⚠️ Error clearing SharedPreferences language: $e');
      }

      // ✅ STEP 4: Logout without clearing controllers immediately
      await AuthStorage.logout(clearControllers: false);
      print('🔴 User logged out successfully - local data cleared');

      // Small delay for smooth UX
      await Future.delayed(Duration(milliseconds: 300));

      // Close dialog
      if (mounted) {
        Get.back(result: true);
      }

      // ✅ Navigate to language selection screen
      Get.offAllNamed('/select-language');
      print('🔄 Navigated to language selection screen');

    } catch (e) {
      print('❌ Logout error: $e');

      // For specificDevice logout, just close dialog on error
      if (widget.logoutType == LogoutType.specificDevice) {
        if (mounted) {
          Get.back(result: false);
        }
        return;
      }

      // For currentDevice and allDevices, navigate to language selection even on error
      if (mounted) {
        Get.back(result: true);
      }
      Get.offAllNamed('/select-language');
      print('🔄 Navigated to language selection screen (error fallback)');
    } finally {
      // Reset loading state if still mounted
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          responsive.borderRadiusSmall ?? 8,
        ),
      ),
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      content: BorderColor(
        isSelected: true,
        borderRadius: 1.5,
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    colors: [
                      AppColors.containerDark ?? Colors.black,
                      AppColors.containerLight ?? Colors.grey.shade800,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  )
                : null,
            color: isDark ? null : AppColorsLight.white,
            borderRadius: BorderRadius.circular(
              responsive.borderRadiusSmall ?? 8,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5),
            vertical: responsive.hp(3),
          ),
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message
              AppText.searchbar(
                'Confirm',
                color: isDark ? Colors.white : AppColorsLight.textPrimary,
                maxLines: 1,
                minFontSize: 14,
              ),
              SizedBox(height: responsive.space2XSS ?? 16),
              AppText.headlineLarge1(
                _subtitleText,
                color: isDark ? AppColors.textDisabled : AppColorsLight.textPrimary,
                maxLines: 3,
                minFontSize: 10,
              ),
              SizedBox(height: responsive.spaceLG ?? 16),

              // Buttons
              DialogButtonRow(
                cancelText: localizations?.cancel ?? "Cancel",
                confirmText:  "Yes, Log out",
                onCancel: () {
                  print('❌ Cancel button pressed - staying logged in');
                  Get.back(result: false);
                },
                onConfirm: _isLoggingOut ? null : () => _handleLogout(),
                cancelGradientColors: isDark
                    ? [
                        AppColors.containerDark ?? Colors.black,
                        AppColors.containerLight ?? Colors.grey.shade800,
                      ]
                    : [
                        AppColorsLight.scaffoldBackground,
                        AppColorsLight.scaffoldBackground,
                      ],
                confirmGradientColors: [
                  AppColors.deletedDialog1 ,
                  AppColors.deletedDialog2 ,
                ],
                confirmTextColor: AppColors.white,
                isLoading: _isLoggingOut,
                enableSweepGradient: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Helper function to show logout dialog with animations
/// Returns true if logout was successful, false if cancelled or failed
Future<bool?> showLogoutConfirmationDialog(
  BuildContext context, {
  LogoutType logoutType = LogoutType.currentDevice,
  String? sessionId,
  String? deviceName,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Logout Confirmation',
    barrierColor: Colors.black.withValues(alpha: 0.5),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext dialogContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,  // ✅ Open animation (bounce effect)
          reverseCurve: Curves.easeInOutQuart,  // ✅ Close animation (smooth fade)
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,  // ✅ Open fade
            reverseCurve: Curves.easeInOutQuart,  // ✅ Close fade
          ),
          child: LogoutConfirmationDialog(
            logoutType: logoutType,
            sessionId: sessionId,
            deviceName: deviceName,
          ),
        ),
      );
    },
  );
}
