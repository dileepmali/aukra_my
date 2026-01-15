import 'package:flutter/material.dart';
import '../app/themes/app_colors.dart';
import '../app/themes/app_colors_light.dart';
import '../core/responsive_layout/device_category.dart';
import '../core/responsive_layout/font_size_hepler_class.dart';
import '../core/responsive_layout/helper_class_2.dart';

/// A reusable custom radio button widget with consistent styling across the app.
///
/// Usage:
/// ```dart
/// CustomRadioButton(
///   isSelected: _selectedIndex == 0,
///   size: 20,
/// )
/// ```
class CustomRadioButton extends StatelessWidget {
  /// Whether the radio button is selected
  final bool isSelected;

  /// Size of the outer circle (default: 20)
  final double? size;

  /// Size of the inner dot when selected (default: size * 0.4)
  final double? innerSize;

  /// Border width when selected (default: 4.0)
  final double? selectedBorderWidth;

  /// Border width when not selected (default: 2.0)
  final double? unselectedBorderWidth;

  const CustomRadioButton({
    Key? key,
    required this.isSelected,
    this.size,
    this.innerSize,
    this.selectedBorderWidth,
    this.unselectedBorderWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double outerSize = size ?? responsive.fontSize(20);
    final double dotSize = innerSize ?? responsive.fontSize(8);
    final double selectedWidth = selectedBorderWidth ?? 4.5;
    final double unselectedWidth = unselectedBorderWidth ?? 2.0;

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? (isDark
                ? AppColors.containerDark
                : AppColorsLight.textPrimary.withOpacity(0.2))
            : AppColors.transparent,
        border: Border.all(
          color: isSelected
              ? (isDark
                  ? AppColors.white
                  : AppColorsLight.textPrimary.withOpacity(0.3))
              : (isDark
                  ? AppColors.white.withOpacity(0.2)
                  : AppColorsLight.textPrimary.withOpacity(0.4)),
          width: isSelected ? selectedWidth : unselectedWidth,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.backgroundDark : AppColorsLight.black,
                ),
              ),
            )
          : null,
    );
  }
}