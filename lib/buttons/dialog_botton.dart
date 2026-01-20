import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';

import '../app/themes/app_colors_light.dart';
import '../app/themes/app_fonts.dart';
import '../core/responsive_layout/device_category.dart';
import '../core/responsive_layout/helper_class_2.dart';
import '../core/responsive_layout/padding_navigation.dart';
import 'app_button.dart';

class DialogButtonRow extends StatelessWidget {
  final String cancelText;
  final String confirmText;
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final Color? cancelBackgroundColor;
  final Color? cancelTextColor;
  final Color? confirmTextColor;
  final List<Color>? cancelGradientColors;
  final List<Color>? confirmGradientColors;
  final Color? cancelBorderColor;
  final Color? confirmBorderColor;
  final bool isLoading;
  final bool swapButtonPositions;
  final Widget? cancelIcon;
  final Widget? confirmIcon;
  final bool enableSweepGradient; // Enable sweep gradient for confirm button
  final double? progressPercentage; // Progress percentage (0.0 to 1.0) for loading state

  // Manual width controls (overrides flex if provided)
  final double? cancelWidth;
  final double? confirmWidth;
  final double cancelFlex;
  final double confirmFlex;

  // Button spacing
  final double? buttonSpacing;

  // Button height (optional - defaults to responsive height)
  final double? buttonHeight;

  // Button font size (optional - defaults to AppFonts.dialogButton size)
  final double? buttonFontSize;

  // Max lines for button text (optional - defaults to 2 for long text support)
  final int maxLines;

  // Icon spacing (gap between icon and text)
  final double? iconSpacing;

  const DialogButtonRow({
    Key? key,
    this.cancelText = "Go back",
    this.confirmText = "Confirm",
    this.onCancel,
    this.onConfirm,
    this.cancelBackgroundColor,
    this.cancelTextColor,
    this.confirmTextColor,
    this.cancelGradientColors,
    this.confirmGradientColors,
    this.cancelBorderColor,
    this.confirmBorderColor,
    this.isLoading = false,
    this.swapButtonPositions = false,
    this.cancelIcon,
    this.confirmIcon,
    this.enableSweepGradient = false,
    this.progressPercentage,
    this.cancelWidth,
    this.confirmWidth,
    this.cancelFlex = 1.0,
    this.confirmFlex = 1.0,
    this.buttonSpacing,
    this.buttonHeight,
    this.buttonFontSize,
    this.maxLines = 2, // ✅ Default to 2 lines for better text wrapping
    this.iconSpacing, // ✅ NEW: Icon spacing parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    // Build buttons with manual width or flex
    final Widget cancelButton = _buildButtonContainer(
      child: _buildCancelButton(context, responsive),
      width: cancelWidth,
      flex: cancelFlex,
      isManualWidth: cancelWidth != null,
    );

    final Widget confirmButton = _buildButtonContainer(
      child: _buildConfirmButton(context, responsive),
      width: confirmWidth,
      flex: confirmFlex,
      isManualWidth: confirmWidth != null,
    );

    return Row(
      children: swapButtonPositions
          ? [
        confirmButton,
        SizedBox(width: buttonSpacing ?? responsive.wp(4)),
        cancelButton,
      ]
          : [
        cancelButton,
        SizedBox(width: buttonSpacing ?? responsive.wp(4)),
        confirmButton,
      ],
    );
  }

  Widget _buildButtonContainer({
    required Widget child,
    double? width,
    required double flex,
    required bool isManualWidth,
  }) {
    if (isManualWidth && width != null) {
      // Use manual width
      return SizedBox(
        width: width,
        child: child,
      );
    } else {
      // Use flex (default behavior)
      return Expanded(
        flex: flex.round(),
        child: child,
      );
    }
  }

  Widget _buildCancelButton(BuildContext context, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? AppColors.white : AppColorsLight.textPrimary;

    return AppButton(
      height: buttonHeight ?? responsive.hp(6.5),
      text: cancelText,
      onPressed: isLoading ? null : onCancel,
      textColor: cancelTextColor ?? defaultTextColor,
      backgroundColor: cancelGradientColors == null ? (cancelBackgroundColor ?? const Color(0xff1f1f1f)) : null,
      gradientColors: cancelGradientColors,
      borderColor: cancelBorderColor ?? (isDark ? AppColors.driver : AppColorsLight.shadowLight),
      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5)),
      textStyle: buttonFontSize != null
          ? AppFonts.dialogButton(
              color: cancelTextColor ?? defaultTextColor,
              fontWeight: AppFonts.semiBold,
            ).copyWith(fontSize: buttonFontSize)
          : AppFonts.dialogButton(
              color: cancelTextColor ?? defaultTextColor,
              fontWeight: AppFonts.semiBold,
            ),
      maxLines: maxLines, // ✅ Pass maxLines to AppButton
      leadingWidget: cancelIcon, // Use leadingWidget for left side SVG icons
      iconSpacing: iconSpacing, // ✅ Pass iconSpacing to AppButton
    );
  }

  Widget _buildConfirmButton(BuildContext context, AdvancedResponsiveHelper responsive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTextColor = isDark ? AppColors.buttonTextColor : AppColorsLight.black;

    return AppButton(
      height: buttonHeight ?? responsive.hp(6.5),
      text: confirmText,
      onPressed: isLoading ? null : onConfirm,
      gradientColors: confirmGradientColors ?? [
        AppColors.splaceSecondary1,
        AppColors.splaceSecondary2,
      ],
      enableSweepGradient: enableSweepGradient,
      borderColor: cancelBorderColor ?? (isDark ? AppColors.driver : AppColorsLight.shadowLight),
      textColor: confirmTextColor ?? defaultTextColor,
      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5)),
      textStyle: buttonFontSize != null
          ? AppFonts.dialogButton(
              color: confirmTextColor ?? defaultTextColor,
              fontWeight: AppFonts.semiBold,
            ).copyWith(fontSize: buttonFontSize)
          : AppFonts.dialogButton(
              color: confirmTextColor ?? defaultTextColor,
              fontWeight: AppFonts.semiBold,
            ),
      isLoading: isLoading,
      progressPercentage: progressPercentage, // ✅ Pass progress percentage
      maxLines: maxLines, // ✅ Pass maxLines to AppButton
      leadingWidget: confirmIcon, // Use leadingWidget for left side SVG icons
      iconSpacing: iconSpacing, // ✅ Pass iconSpacing to AppButton
    );
  }
}