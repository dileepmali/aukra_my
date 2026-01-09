import 'package:flutter/material.dart';
import '../app/themes/app_colors.dart';
import '../app/themes/app_colors_light.dart';
import '../core/responsive_layout/device_category.dart';
import '../core/responsive_layout/font_size_hepler_class.dart';
import '../core/responsive_layout/helper_class_2.dart';
import '../core/responsive_layout/padding_navigation.dart';

class CustomToggleButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomToggleButton({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: responsive.fontSize(50),
        height: responsive.fontSize(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.borderRadiusExtraLarge1),
          gradient: value
              ? LinearGradient(
                  colors: isDark
                      ? [
                          AppColors.containerLight,
                          AppColors.containerDark,
                        ]
                      : [
                          AppColorsLight.gradientColor1,
                          AppColorsLight.gradientColor2,
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: value
              ? null
              : isDark
                  ? AppColors.containerDark
                  : AppColorsLight.textSecondary.withOpacity(0.3),
          border: Border.all(
            color: value
                ? (isDark ? AppColors.white.withOpacity(0.2) : AppColorsLight.gradientColor1)
                : (isDark ? AppColors.border1 : AppColorsLight.textSecondary.withOpacity(0.5)),
            width: 1.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: responsive.fontSize(22),
            height: responsive.fontSize(22),
            margin: EdgeInsets.symmetric(horizontal: responsive.spacing(3)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value
                  ? AppColors.white
                  : (isDark ? AppColors.textDisabled : AppColorsLight.white),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
