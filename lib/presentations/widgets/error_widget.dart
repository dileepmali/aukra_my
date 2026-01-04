import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_fonts.dart';
import '../../app/themes/app_text.dart';
import '../../app/localizations/l10n/app_localizations.dart';
import '../../buttons/app_button.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../app/constants/app_images.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/untils/error_types.dart';
import '../../core/services/error_service.dart';

/// ErrorType - Different types of errors to display
enum ErrorType {
  offline,    // No internet connection
  server,     // Server error (internet available but server not responding)
  custom,     // Custom error with user-defined content
}

/// ErrorWidget - Reusable widget for showing different error states
///
/// Usage:
/// ```dart
/// // Offline error
/// ErrorWidget(
///   type: ErrorType.offline,
///   onRetry: () => controller.refreshData(),
/// );
///
/// // Server error
/// ErrorWidget(
///   type: ErrorType.server,
///   description: "Unable to load your files",
///   onRetry: () => controller.refreshData(),
/// );
///
/// // Custom error
/// ErrorWidget(
///   type: ErrorType.custom,
///   title: "Custom Title",
///   description: "Custom description",
///   imagePath: AppImages.customError,
///   onRetry: () => controller.refreshData(),
/// );
/// ```
class AppErrorWidget extends StatefulWidget {
  /// Type of error to display
  final ErrorType type;

  /// Optional callback for screen-specific refresh logic
  final Future<void> Function()? onRetry;

  /// Custom title (overrides default based on type)
  final String? title;

  /// Custom description text
  final String? description;

  /// Custom image path (overrides default based on type)
  final String? imagePath;

  /// Optional error message for debugging
  final String? errorMessage;

  const AppErrorWidget({
    Key? key,
    this.type = ErrorType.offline,
    this.onRetry,
    this.title,
    this.description,
    this.imagePath,
    this.errorMessage,
  }) : super(key: key);

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget> {
  bool _isLoading = false;

  // ✅ Get global connectivity service
  // final ConnectivityService _connectivityService = Get.find<ConnectivityService>();

  // Get default title based on error type
  String _getDefaultTitle(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (widget.type) {
      case ErrorType.offline:
        return localizations?.youreOffline ?? "You're Offline";
      case ErrorType.server:
        return localizations?.somethingWentWrong ?? "Something Went Wrong";
      case ErrorType.custom:
        return localizations?.errorOccurred ?? "Error";
    }
  }

  // Get default description based on error type
  String _getDefaultDescription(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (widget.type) {
      case ErrorType.offline:
        return localizations?.checkInternetConnection ?? "Check your internet connection and\ntry again to access your cloud files";
      case ErrorType.server:
        return localizations?.serversUnavailable ?? "Our servers are temporarily\nunavailable. Please try again later";
      case ErrorType.custom:
        return localizations?.anErrorOccurred ?? "An error occurred";
    }
  }

  // Get default image based on error type
  String get _defaultImage {
    switch (widget.type) {
      case ErrorType.offline:
        return AppImages.offlineIm;
      case ErrorType.server:
        return AppImages.errorIm;
      case ErrorType.custom:
        return AppImages.offlineIm;
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDesktop = responsive.deviceType == DeviceType.desktop;

    // ✅ Desktop: Simple layout without Scaffold/Container/Padding
    if (isDesktop) {
      return _buildDesktopErrorWidget(responsive, isDark);
    }

    // ✅ Mobile: Error widget is rendered inside screen content
    // Only need small bottom padding since parent screen handles bottom nav bar
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: responsive.wp(3),
            right: responsive.wp(3),
            top: responsive.hp(1.2),
            bottom: responsive.hp(1.2), // Small padding only
          ),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            color: isDark ? AppColors.containerDark : AppColorsLight.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Error Image - shifted down and left
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: responsive.wp(5),
                  ),
                  child: Image.asset(
                    widget.imagePath ?? _defaultImage,
                    width: responsive.wp(30),
                    height: responsive.hp(15),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: responsive.hp(2)),

              // Error Title Text
              Padding(
                padding: EdgeInsets.only(
                  left: responsive.wp(5),
                ),
                child: AppText.displayMedium1(
                  widget.title ?? _getDefaultTitle(context),
                  color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                  maxLines: 2,
                  minFontSize: 14,
                ),
              ),

              SizedBox(height: responsive.hp(1)),

              // Description Text
              Padding(
                padding: EdgeInsets.only(
                  left: responsive.wp(5),
                ),
                child: AppText.searchbar2(
                  widget.description ?? _getDefaultDescription(context),
                  color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                  maxLines: 3,
                  minFontSize: 10,
                ),
              ),

              // Optional error message (for debugging)

              SizedBox(height: responsive.hp(4)),

              // Retry Button
              Padding(
                padding: EdgeInsets.only(
                  left: responsive.wp(5),
                ),
                child: AppButton(
                  height: responsive.hp(6.5),
                  text: AppLocalizations.of(context)?.reload ?? "Reload",
                  width: responsive.wp(70),
                  isLoading: _isLoading,
                  gradientColors: isDark
                    ? [
                        AppColors.splaceSecondary1,
                        AppColors.splaceSecondary2,
                      ]
                    : [
                        AppColorsLight.gradientColor1,
                        AppColorsLight.gradientColor2,
                      ],
                  textStyle: AppFonts.button(
                    color: isDark ? AppColors.buttonTextColor : AppColorsLight.buttonTextColor,
                  ),
                  borderColor: isDark ? AppColors.border1 : AppColorsLight.gradientColor1,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  onPressed: () async {
                    if (_isLoading) return; // Prevent multiple clicks

                    setState(() {
                      _isLoading = true;
                    });

                    await _handleGlobalRefresh();

                    // Call screen-specific refresh if provided
                    if (widget.onRetry != null) {
                      await widget.onRetry!();
                    }

                    // Add small delay to ensure refresh completes
                    await Future.delayed(Duration(milliseconds: 300));

                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ),
            ],
                          ),
          ),
        ),
      ),
    );
  }

  /// 🖥️ DESKTOP: Simple error widget without Scaffold/Container (same alignment as mobile)
  Widget _buildDesktopErrorWidget(AdvancedResponsiveHelper responsive, bool isDark) {
    // Desktop: Responsive sizes that scale across all desktop sizes (laptops to large monitors)
    final iconWidth = responsive.wp(15);  // 8% of screen width
    final iconHeight = responsive.hp(15); // 8% of screen height
    final buttonWidth = responsive.wp(20); // 20% of screen width

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start, // ✅ Left aligned like mobile
        children: [
          // Error Image - shifted down and left (same as mobile)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: responsive.wp(5)),
              child: Image.asset(
                widget.imagePath ?? _defaultImage,
                width: iconWidth,
                height: iconHeight,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SizedBox(height: responsive.hp(2)),

          // Error Title Text - Using smaller headlineMedium for desktop
          Padding(
            padding: EdgeInsets.only(left: responsive.wp(8)),
            child: AppText.headlineMedium(
              widget.title ?? _getDefaultTitle(context),
              color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
              maxLines: 2,
              minFontSize: 12,
            ),
          ),

          SizedBox(height: responsive.hp(1)),

          // Description Text - Using smaller bodyMedium for desktop
          Padding(
            padding: EdgeInsets.only(left: responsive.wp(8)),
            child: AppText.bodyMedium(
              widget.description ?? _getDefaultDescription(context),
              color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
              maxLines: 3,
              minFontSize: 12,
            ),
          ),

          SizedBox(height: responsive.hp(3)),

          // Retry Button - Responsive width
          Padding(
            padding: EdgeInsets.only(left: responsive.wp(8)),
            child: AppButton(
              height: responsive.hp(6),
              text: AppLocalizations.of(context)?.reload ?? "Reload",
              width: buttonWidth,
              isLoading: _isLoading,
              gradientColors: isDark
                  ? [
                      AppColors.splaceSecondary1,
                      AppColors.splaceSecondary2,
                    ]
                  : [
                      AppColorsLight.gradientColor1,
                      AppColorsLight.gradientColor2,
                    ],
              textStyle: AppFonts.button(
                color: isDark ? AppColors.buttonTextColor : AppColorsLight.buttonTextColor,
              ),
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              onPressed: () async {
                if (_isLoading) return;

                setState(() {
                  _isLoading = true;
                });

                await _handleGlobalRefresh();

                if (widget.onRetry != null) {
                  await widget.onRetry!();
                }

                await Future.delayed(Duration(milliseconds: 300));

                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 GLOBAL APP REFRESH: Refreshes all app data when user clicks retry
  Future<void> _handleGlobalRefresh() async {
    try {
      // Simple refresh - just wait a moment to simulate network check
      await Future.delayed(const Duration(milliseconds: 500));

      // TODO: Add connectivity check and controller refresh when available
      // Example:
      // if (Get.isRegistered<StorageCloudController>()) {
      //   final storageController = Get.find<StorageCloudController>();
      //   await storageController.forceRefresh();
      // }
    } catch (e) {
      // Show server error message if something goes wrong
      if (mounted) {
        AdvancedErrorService.showError(
          AppLocalizations.of(context)?.serversUnavailable ??
            "Our servers are temporarily unavailable. Please try again later",
          severity: ErrorSeverity.high,
          category: ErrorCategory.server,
        );
      }
    }
  }
}
