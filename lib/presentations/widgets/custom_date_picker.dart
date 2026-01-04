import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';

/// Custom Date Picker with theme support
class CustomDatePicker {
  /// Show custom date picker dialog
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      cancelText: 'Cancel',
      confirmText: 'OK',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: isDark ? ThemeData.dark() : ThemeData.light(),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: isDark
                  ? ColorScheme.dark(
                      primary: AppColors.splaceSecondary2, // Selected date background
                      onPrimary: AppColors.white, // Selected date text
                      surface: AppColors.containerDark, // Dialog background
                      onSurface: AppColors.white, // Unselected date text
                      outline: AppColors.splaceSecondary1, // Unselected date border
                    )
                  : ColorScheme.light(
                      primary: AppColorsLight.splaceSecondary1, // Selected date background
                      onPrimary: AppColorsLight.white, // Selected date text
                      surface: AppColorsLight.background, // Dialog background
                      onSurface: AppColorsLight.textPrimary, // Unselected date text
                      outline: AppColorsLight.splaceSecondary2, // Unselected date border
                    ),
              datePickerTheme: DatePickerThemeData(
                backgroundColor: isDark ? AppColors.containerDark : AppColorsLight.background,
                headerBackgroundColor: isDark ? AppColors.containerDark : AppColorsLight.splaceSecondary1,
                headerForegroundColor: isDark ? AppColors.white : AppColorsLight.black,
                // Today's date border color
                todayBorder: BorderSide(
                  color: isDark ? AppColors.white : AppColorsLight.splaceSecondary2,
                  width: 2,
                ),
                todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return isDark ? AppColors.buttonTextColor : AppColorsLight.black;
                  }
                  return isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary1;
                }),
                // Day foreground color (text color)
                dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return isDark ? AppColors.buttonTextColor : AppColorsLight.black;
                  }
                  return isDark ? AppColors.white : AppColorsLight.textPrimary;
                }),
                // Day background color
                dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary1;
                  }
                  return Colors.transparent;
                }),
                headerHeadlineStyle: TextStyle(
                  fontSize: responsive.fontSize(28),
                  fontWeight: FontWeight.w600,
                ),
                headerHelpStyle: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w500,
                ),
                yearStyle: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w500,
                ),
                dayStyle: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w500,
                ),
                weekdayStyle: TextStyle(
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary1,
                  backgroundColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.wp(6),
                    vertical: responsive.hp(1.5),
                  ),
                  textStyle: TextStyle(
                    fontSize: responsive.fontSize(18),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
