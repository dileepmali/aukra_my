import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/responsive_layout/device_category.dart';

import '../app/constants/app_icons.dart';
import '../app/themes/app_colors.dart';
import '../app/themes/app_colors_light.dart';
import '../core/responsive_layout/font_size_hepler_class.dart';
import '../core/responsive_layout/helper_class_2.dart';
import '../core/responsive_layout/padding_navigation.dart';
import '../presentations/widgets/custom_border_widget.dart';
import 'app_button.dart';

class BottomActionBar extends StatelessWidget {
  final String primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final bool showBorder;
  final List<Color>? gradientColors;
  final double? buttonSpacing;
  final EdgeInsets? containerPadding;
  final bool isSecondaryLoading; // ✅ NEW: Loading state for secondary button
  final List<Color>? secondaryButtonGradientColors; // Custom gradient for secondary button

  const BottomActionBar({
    Key? key,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    required this.secondaryButtonText,
    required this.onSecondaryPressed,
    this.showBorder = false,
    this.gradientColors,
    this.buttonSpacing,
    this.containerPadding,
    this.isSecondaryLoading = false, // ✅ NEW: Default to false
    this.secondaryButtonGradientColors, // Optional custom gradient for secondary button
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultGradientColors = isDark
        ? [
            AppColors.containerDark,
            AppColors.containerLight,
            AppColors.containerLight,
          ]
        : [
            AppColorsLight.background,
            AppColorsLight.background,
            AppColorsLight.background,
          ];

    return SafeArea(
      child: showBorder
        ? BorderColor(
      isSelected: true,
      bottomWidth: 0,
      leftWidth: 0,
      rightWidth: 0,
      child: Container(
        height: responsive.hp(11),
        padding: containerPadding ?? EdgeInsets.all(responsive.spacing(25)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? defaultGradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
            children: [
              Expanded(
                child: AppButton(
                  height: responsive.hp(7),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  text: primaryButtonText,
                  onPressed: onPrimaryPressed,
                  enabled: onPrimaryPressed != null, // ✅ Explicitly enable button when callback exists
                  borderColor: isDark ? AppColors.driver : AppColorsLight.shadowLight,
                  gradientColors: isDark
                      ? [
                          AppColors.containerDark,
                          AppColors.containerLight,
                        ]
                      : [
                          AppColorsLight.gradientColor1,
                          AppColorsLight.gradientColor2,
                        ],
                  textColor: isDark ? AppColors.white : AppColorsLight.black,
                  fontSize: responsive.fontSize(18),
                  maxLines: 2, // ✅ Allow text to wrap to 2 lines for long text
                  leadingWidget: SvgPicture.asset(
                      AppIcons.arrowBackIc,
                    color: isDark ? AppColors.white : AppColorsLight.black,
                  ),
                ),
              ),
              SizedBox(width: buttonSpacing ?? responsive.spacing(12)),
              Expanded(
                child: AppButton(
                  height: responsive.hp(7),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  text: secondaryButtonText,
                  onPressed: onSecondaryPressed,
                  borderColor: isDark ? AppColors.driver : AppColors.driver,
                    gradientColors: secondaryButtonGradientColors ?? (isDark
                      ? [
                          AppColors.splaceSecondary1,
                          AppColors.splaceSecondary2,
                        ]
                      : [
                    AppColors.splaceSecondary1,
                    AppColors.splaceSecondary2,
                        ]),
                  enableSweepGradient: true,
                  textColor: isDark ? AppColors.buttonTextColor : AppColorsLight.black,
                  fontSize: responsive.fontSize(18),
                  maxLines: 2, // ✅ Allow text to wrap to 2 lines for long text
                  // ✅ NEW: Show loading indicator inside button
                  child: isSecondaryLoading
                      ? Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: isDark ? AppColors.white : AppColorsLight.white,
                              strokeWidth: 2.0,
                            ),
                          ),
                      )
                      : null,
                ),
              ),
            ],
          ),
        ),
      )
        : Container(
      height: responsive.hp(13),
      padding: containerPadding ?? EdgeInsets.all(responsive.spacing(25)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? defaultGradientColors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
          children: [
            Expanded(
              child: AppButton(
                height: responsive.hp(7),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                text: primaryButtonText,
                onPressed: onPrimaryPressed,
                enabled: onPrimaryPressed != null, // ✅ Explicitly enable button when callback exists
                borderColor: isDark ? AppColors.borderDark1 : AppColorsLight.border,
                gradientColors: isDark
                    ? [
                        AppColors.containerDark,
                        AppColors.containerLight,
                      ]
                    : [
                        AppColorsLight.background,
                        AppColorsLight.card,
                      ],
                textColor: isDark ? AppColors.white : AppColorsLight.black,
                fontSize: responsive.fontSize(14),
                maxLines: 2, // ✅ Allow text to wrap to 2 lines for long text
              ),
            ),
            SizedBox(width: buttonSpacing ?? responsive.spacing(12)),
            Expanded(
              child: AppButton(
                height: responsive.hp(7),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                text: secondaryButtonText,
                onPressed: onSecondaryPressed,
                gradientColors: secondaryButtonGradientColors ?? [
                  AppColors.splaceSecondary1,
                  AppColors.splaceSecondary2,
                ],
                textColor: AppColors.buttonTextColor,
                fontSize: responsive.fontSize(14),
                maxLines: 2, // ✅ Allow text to wrap to 2 lines for long text
                // ✅ NEW: Show loading indicator inside button
                child: isSecondaryLoading
                    ? Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: isDark ? AppColors.buttonTextColor : AppColorsLight.black,
                            strokeWidth: 2.5,
                          ),
                        ),
                    )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}