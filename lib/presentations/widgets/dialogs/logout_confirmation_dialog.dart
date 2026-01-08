
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
import '../../../controllers/localization_controller.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_border_widget.dart';

class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({Key? key}) : super(key: key);

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isLoggingOut = false;

  /// Handle logout with proper cleanup
  Future<void> _handleLogout() async {
    try {
      print('🔴 Starting logout process...');

      // Show loading state
      setState(() {
        _isLoggingOut = true;
      });

      // ✅ STEP 1: Call logout API
      print('📡 Calling logout API...');
      final apiResponse = await LogoutApi.logout();

      if (apiResponse['success'] == true) {
        print('✅ Logout API call successful: ${apiResponse['message']}');
      } else {
        print('⚠️ Logout API failed: ${apiResponse['message']}');
        // Continue with local logout even if API fails
      }

      // ✅ STEP 2: RESET LANGUAGE TO ENGLISH ON LOGOUT (GetStorage)
      // This ensures language resets to default when user logs out
      if (Get.isRegistered<LocalizationController>()) {
        final localizationController = Get.find<LocalizationController>();
        await localizationController.resetToDefaultLanguage();
        print('🌐 Language reset to English on logout (GetStorage cleared)');
      }

      // ✅ STEP 3: ALSO CLEAR SHARED PREFERENCES LANGUAGE (TolgeeLocalizationService)
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

      // ✅ FIX: Navigate to language selection screen (start of onboarding flow)
      // This ensures user goes through: Language → Verify Number → OTP → Shop Details
      Get.offAllNamed('/select-language');
      print('🔄 Navigated to language selection screen');

      // ✅ FIX: Don't clear controllers at all!
      // GetX will handle controller lifecycle automatically
      // Clearing controllers causes "LocalizationController not found" error
      print('✅ Keeping controllers alive - GetX will manage lifecycle');

    } catch (e) {
      print('❌ Logout error: $e');

      // Even if logout fails, still navigate to language selection
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
                'Are you sour you want to logout from current device?',
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
void showLogoutConfirmationDialog(BuildContext context) {
  showGeneralDialog(
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
          child: const LogoutConfirmationDialog(),
        ),
      );
    },
  );
}
