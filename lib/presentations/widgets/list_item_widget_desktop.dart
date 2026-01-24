import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/helper_class_2.dart';

/// Desktop version of ListItemWidget with desktop-appropriate font sizes and spacing
/// Use this for desktop/widescreen layouts instead of ListItemWidget
class ListItemWidgetDesktop extends StatelessWidget {
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
  final Widget? subtitleSuffix;
  final Color? subtitleBackgroundColor;
  final EdgeInsets? subtitlePadding;

  // Optional padding and margin properties
  final EdgeInsets? itemPadding;
  final EdgeInsets? itemMargin;

  const ListItemWidgetDesktop({
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

    // Desktop-specific sizes (smaller percentages for larger screens)
    final avatarSize = responsive.wp(2.5); // Smaller percentage for desktop
    final horizontalPadding = responsive.wp(1.5);
    final verticalPadding = responsive.hp(1.0);
    final iconSize = responsive.wp(0.7);
    final spacing = responsive.wp(0.5);

    return Container(
      margin: itemMargin,
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: height,
              padding: itemPadding ?? EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              color: backgroundColor ?? Colors.transparent,
              child: Row(
                children: [
                  // Leading: Avatar, Custom Widget, or Icon
                  if (customLeading != null)
                    Padding(
                      padding: EdgeInsets.only(right: spacing * 2),
                      child: customLeading!,
                    )
                  else if (showAvatar)
                    Padding(
                      padding: EdgeInsets.only(right: spacing * 1.5),
                      child: Container(
                        width: avatarSize,
                        height: avatarSize,
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
                          child: Text(
                            avatarText ?? title[0].toUpperCase(),
                            style: TextStyle(
                              color: avatarTextColor ?? (isDark ? AppColors.white : AppColorsLight.black),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    )
                  else if (leadingIcon != null)
                    Container(
                      margin: EdgeInsets.only(right: spacing * 1.5),
                      child: SvgPicture.asset(
                        leadingIcon!,
                        width: iconSize * 1.5,
                        height: iconSize * 1.5,
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
                              SizedBox(width: spacing),
                            ],
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: titleColor ?? (isDark ? AppColors.white.withOpacity(0.9) : AppColorsLight.textPrimary),
                                  fontSize: titleFontSize ?? 14,
                                  fontWeight: titleFontWeight ?? FontWeight.w500,
                                  letterSpacing: titleLetterSpacing ?? 0.5,
                                  decoration: titleDecoration,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Amount on the right side
                            if (amount != null) ...[
                              SizedBox(width: spacing),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Rupee symbol icon
                                  Padding(
                                    padding: EdgeInsets.only(top: 1),
                                    child: SvgPicture.asset(
                                      AppIcons.vectoeIc3,
                                      width: 10,
                                      height: 10,
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
                                  SizedBox(width: 3),
                                  // Amount number
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: responsive.wp(10)),
                                    child: Text(
                                      amount!.replaceAll('₹', '').trim(),
                                      style: TextStyle(
                                        color: isPositiveAmount == true
                                            ? AppColors.primeryamount
                                            : isPositiveAmount == false
                                                ? AppColors.red500
                                                : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        if (subtitle != null) ...[
                          SizedBox(height: 4),
                          Container(
                            padding: subtitlePadding,
                            decoration: subtitleBackgroundColor != null
                                ? BoxDecoration(
                                    color: subtitleBackgroundColor,
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                : null,
                            child: Row(
                              children: [
                                if (titlePrefixIcon != null) ...[
                                  SizedBox(width: iconSize + spacing * 2),
                                ],
                                Expanded(
                                  child: Text(
                                    subtitle!,
                                    style: TextStyle(
                                      color: subtitleColor ?? (isDark
                                          ? AppColors.textDisabled
                                          : AppColorsLight.textSecondary),
                                      fontSize: subtitleFontSize ?? 12,
                                      fontWeight: subtitleFontWeight ?? FontWeight.w400,
                                      letterSpacing: subtitleLetterSpacing ?? 0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (subtitleSuffix != null) ...[
                                  SizedBox(width: spacing),
                                  subtitleSuffix!,
                                ],
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing: Custom Widget or Icon
                  if (customTrailing != null)
                    customTrailing!
                  else if (trailingIcon != null)
                    SvgPicture.asset(
                      trailingIcon!,
                      width: iconSize * 1.2,
                      height: iconSize * 1.2,
                      color: isDark ? AppColors.white : AppColorsLight.iconPrimary,
                    ),
                ],
              ),
            ),
          ),
          // Divider line between items
          if (showBorder)
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? AppColors.driver
                  : AppColorsLight.shadowMedium,
            ),
        ],
      ),
    );
  }
}