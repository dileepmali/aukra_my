import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';

/// A reusable list item widget for displaying data in a card format
class ListItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? leadingIcon;
  final String? trailingIcon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showBorder;
  final double? height;
  final Widget? customTrailing;
  final Widget? customLeading;

  // CircleAvatar properties
  final bool showAvatar;
  final String? avatarText;
  final Color? avatarBackgroundColor;
  final Gradient? avatarBackgroundGradient;
  final Color? avatarTextColor;

  // Amount display properties
  final String? amount;
  final bool? isPositiveAmount; // true for positive (blue), false for negative (red)

  // Optional text styling properties
  final double? titleFontSize;
  final double? titleLetterSpacing;
  final double? subtitleFontSize;
  final double? subtitleLetterSpacing;
  final FontWeight? titleFontWeight;
  final FontWeight? subtitleFontWeight;
  final TextDecoration? titleDecoration;
  final Color? titleColor;
  final Color? subtitleColor;
  final Widget? titlePrefixIcon;
  final Widget? subtitleSuffix; // Can be text or SVG icon widget
  final Color? subtitleBackgroundColor; // Background color for subtitle row
  final EdgeInsets? subtitlePadding; // Padding for subtitle row

  // Optional padding and margin properties
  final EdgeInsets? itemPadding; // Custom padding for the item container
  final EdgeInsets? itemMargin; // Custom margin for the item container

  const ListItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.onTap,
    this.backgroundColor,
    this.showBorder = true,
    this.height,
    this.customTrailing,
    this.customLeading,
    this.showAvatar = false,
    this.avatarText,
    this.avatarBackgroundColor,
    this.avatarBackgroundGradient,
    this.avatarTextColor,
    this.amount,
    this.isPositiveAmount,
    this.titleFontSize,
    this.titleLetterSpacing,
    this.subtitleFontSize,
    this.subtitleLetterSpacing,
    this.titleFontWeight,
    this.subtitleFontWeight,
    this.titleDecoration,
    this.titleColor,
    this.subtitleColor,
    this.titlePrefixIcon,
    this.subtitleSuffix,
    this.subtitleBackgroundColor,
    this.subtitlePadding,
    this.itemPadding,
    this.itemMargin,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: itemMargin, // Optional custom margin
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: height,
              padding: itemPadding ?? EdgeInsets.symmetric(
                horizontal: responsive.wp(4),
                vertical: responsive.hp(1.0),
              ), // Optional custom padding, default if not provided
              color: backgroundColor ?? Colors.transparent,
            child: Row(
              children: [
                // Leading: Avatar, Custom Widget, or Icon
                if (customLeading != null)
                  Padding(
                    padding: EdgeInsets.only(right: responsive.spacing(16)),
                    child: customLeading!,
                  )
                else if (showAvatar)
                  Padding(
                    padding: EdgeInsets.only(right: responsive.spacing(10)),
                    child: Container(
                      width: responsive.iconSizeLarge * 1.6,
                      height: responsive.iconSizeLarge * 1.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: avatarBackgroundGradient,
                        color: avatarBackgroundGradient == null
                            ? (avatarBackgroundColor ??
                                (isDark
                                    ? AppColors.containerDark
                                    : AppColorsLight.white))
                            : null,
                      ),
                      child: Center(
                        child: AppText.headlineMedium(
                          avatarText ?? title[0].toUpperCase(),
                          color: avatarTextColor ?? (isDark ? AppColors.white : AppColorsLight.black),
                          maxLines: 1,
                          minFontSize: 14,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  )
                else if (leadingIcon != null)
                  Container(
                    margin: EdgeInsets.only(right: responsive.spacing(12)),
                    child: SvgPicture.asset(
                      leadingIcon!,
                      width: responsive.iconSizeLarge1,
                      height: responsive.iconSizeLarge1,
                      color: isDark ? AppColors.white : AppColorsLight.iconPrimary,
                    ),
                  ),

                // Title and subtitle with amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title row with amount on the right
                      Row(
                        children: [
                          if (titlePrefixIcon != null) ...[
                            titlePrefixIcon!,
                            SizedBox(width: responsive.spacing(6)),
                          ],
                          Expanded(
                            child: AppText.searchbar4(
                              title,
                              color: titleColor ?? (isDark ? AppColors.white.withOpacity(0.8) : AppColorsLight.textPrimary),
                              fontWeight: titleFontWeight ?? FontWeight.w500,
                              letterSpacing: titleLetterSpacing ?? 1.2,
                              decoration: titleDecoration,
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                          ),
                          // Amount on the right side of title with custom symbol and number styling
                          if (amount != null) ...[
                            SizedBox(width: responsive.spacing(8)),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Rupee symbol icon - aligned to bottom
                                Padding(
                                  padding: EdgeInsets.only(top: responsive.hp(0.7)),
                                  child: SvgPicture.asset(
                                    AppIcons.vectoeIc3,
                                    width: responsive.iconSizeSmall,
                                    height: responsive.iconSizeSmall,
                                    colorFilter: ColorFilter.mode(
                                      isPositiveAmount == true
                                          ? AppColors.primeryamount
                                          : isPositiveAmount == false
                                          ? AppColors.red500
                                              : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                                SizedBox(width: responsive.spacing(3)),
                                // Amount number - bigger font with auto-shrink
                                // Using ConstrainedBox to limit max width for auto-shrink
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: responsive.wp(25)),
                                  child: AppText.searchbar4(
                                    amount!.replaceAll('₹', '').trim(),
                                    color: isPositiveAmount == true
                                        ? AppColors.primeryamount
                                        : isPositiveAmount == false
                                            ? AppColors.red500
                                            : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                                    fontWeight: FontWeight.w600,
                                    maxLines: 1,
                                    minFontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: responsive.spacing(2)),
                        Container(
                          padding: subtitlePadding,
                          decoration: subtitleBackgroundColor != null
                              ? BoxDecoration(
                                  color: subtitleBackgroundColor,
                                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                )
                              : null,
                          child: Row(
                            children: [
                              // Add spacing to align subtitle with title text (after icon)
                              if (titlePrefixIcon != null) ...[
                                SizedBox(width: responsive.iconSizeSmall + responsive.spacing(15)),
                              ],
                              Expanded(
                                child: AppText.headlineMedium(
                                  subtitle!,
                                  color: subtitleColor ?? (isDark
                                      ? AppColors.textDisabled
                                      : AppColorsLight.black),
                                  maxLines: 2,
                                  minFontSize: 12,
                                ),
                              ),
                              if (subtitleSuffix != null) ...[
                                SizedBox(width: responsive.spacing(8)),
                                subtitleSuffix!,
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing: Custom Widget or Icon (but not amount anymore)
                if (customTrailing != null)
                  customTrailing!
                else if (trailingIcon != null)
                  SvgPicture.asset(
                    trailingIcon!,
                    width: responsive.iconSizeMedium,
                    height: responsive.iconSizeMedium,
                    color: isDark ? AppColors.white : AppColorsLight.iconPrimary,
                  ),
              ],
            ),
          ),
        ),
          // Divider line between items
          if (showBorder)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.wp(4.5)),
              child: Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? AppColors.driver
                    : AppColorsLight.black.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }
}

/// A specialized grid item widget for displaying data in a grid format
class GridItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool showBorder;
  final Widget? customContent;

  const GridItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.backgroundColor,
    this.showBorder = true,
    this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.spacing(12)),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
        ),
        child: customContent ??
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  SvgPicture.asset(
                    icon!,
                    width: responsive.iconSizeExtraLarge,
                    height: responsive.iconSizeExtraLarge,
                    color:
                        isDark ? AppColors.white : AppColorsLight.iconPrimary,
                  ),
                  SizedBox(height: responsive.spacing(8)),
                ],
                AppText.headlineSmall(
                  title,
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  maxLines: 2,
                  minFontSize: 12,
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null) ...[
                  SizedBox(height: responsive.spacing(4)),
                  AppText.bodySmall(
                    subtitle!,
                    color: isDark
                        ? AppColors.textSecondary
                        : AppColorsLight.textSecondary,
                    maxLines: 2,
                    minFontSize: 10,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
      ),
    );
  }
}
