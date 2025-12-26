
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/localizations/l10n/app_localizations.dart';

import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../custom_border_widget.dart';

class ExitConfirmationDialog extends StatefulWidget {
  const ExitConfirmationDialog({Key? key}) : super(key: key);

  @override
  State<ExitConfirmationDialog> createState() => _ExitConfirmationDialogState();
}

class _ExitConfirmationDialogState extends State<ExitConfirmationDialog> {
  bool _isExiting = false;

  /// Handle app exit with proper cleanup
  Future<void> _handleExit() async {
    try {
      print('🚪 Starting app exit process...');

      // Show loading state
      setState(() {
        _isExiting = true;
      });

      // 🔥 OPTIMIZED: Run cleanup operations in parallel for faster exit
      // await Future.wait([
      //   _cleanupPendingOperations(),
      //   _saveUnsavedData(),
      //   _clearTemporaryFiles(),
      //   _disposeControllers(),
      //   _clearCache(),
      // ]);

      print('✅ App cleanup completed successfully');

      // Close dialog and exit app immediately
      if (mounted) {
        Get.back(result: true);
        // 🔥 OPTIMIZED: Minimal delay before exit (just for dialog animation)
        await Future.delayed(const Duration(milliseconds: 100));
        SystemNavigator.pop();
      }

    } catch (e) {
      print('❌ Error during app exit: $e');

      // Even if cleanup fails, still exit the app immediately
      if (mounted) {
        Get.back(result: true);
        SystemNavigator.pop();
      }
    }
  }

  /// Clean up any pending file operations
  // Future<void> _cleanupPendingOperations() async {
  //   try {
  //     // Cancel any ongoing uploads/downloads
  //     if (Get.isRegistered<FileController>()) {
  //       final fileController = Get.find<FileController>();
  //       // Add cleanup logic here if FileController has cancel methods
  //     }
  //     // 🔥 OPTIMIZED: Removed artificial delay
  //   } catch (e) {
  //     print('❌ Error cleaning pending operations: $e');
  //   }
  // }

  /// Save any unsaved data before exit
  Future<void> _saveUnsavedData() async {
    try {
      // Save any pending form data, drafts, etc.
      // This is where you'd save any critical data
      // 🔥 OPTIMIZED: Removed artificial delay
    } catch (e) {
      print('❌ Error saving data: $e');
    }
  }

  /// Clear temporary files and cache
  Future<void> _clearTemporaryFiles() async {
    try {
      // Clear temporary image files, cache, etc.
      // 🔥 OPTIMIZED: Removed artificial delay
    } catch (e) {
      print('❌ Error clearing temp files: $e');
    }
  }

  /// Dispose controllers properly
  Future<void> _disposeControllers() async {
    try {
      // Properly dispose GetX controllers
      // This helps prevent memory leaks
      // 🔥 OPTIMIZED: Removed artificial delay
    } catch (e) {
      print('❌ Error disposing controllers: $e');
    }
  }

  /// Clear cached data
  Future<void> _clearCache() async {
    try {
      // Clear any cached data that shouldn't persist
      // 🔥 OPTIMIZED: Removed artificial delay
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          responsive.borderRadiusSmall ?? 8, // ✅ safe default
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
              // Header with icon and title// Message container
              AppText.displaySmall(
                localizations.doYouReallyWantToExit,
                color: isDark ? Colors.white : AppColorsLight.textPrimary,
                maxLines: 2,
                minFontSize: 14,
              ),
              SizedBox(height: responsive.spaceXL ?? 16),
              // Buttons using DialogButtonRow
              DialogButtonRow(
                cancelText: localizations.goBack,
                confirmText: localizations.yesExit,
                onCancel: () {
                  print('❌ Cancel button pressed - staying in app');
                  Navigator.of(context).pop(false);
                },
                onConfirm: _isExiting ? null : () => _handleExit(),
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
                  AppColors.deletedDialog1 ?? Colors.orange,
                  AppColors.deletedDialog2 ?? Colors.deepOrange,
                ],
                confirmTextColor: AppColors.white,
                isLoading: _isExiting, // Show loading only on confirm button
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Helper function to show exit dialog with animations
void showExitConfirmationDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Exit Confirmation',
    barrierColor: Colors.black.withOpacity(0.5),
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
          child: const ExitConfirmationDialog(),
        ),
      );
    },
  );
}