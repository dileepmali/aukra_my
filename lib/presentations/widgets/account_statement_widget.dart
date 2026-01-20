import 'package:aukra_anantkaya_space/core/responsive_layout/padding_navigation.dart';
import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../controllers/account_statement_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/utils/formatters.dart';
import '../../models/grouped_transaction_model.dart';

/// Account Statement Widget - UI Only (Logic in Controller)
class AccountStatementWidget extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onViewDetails;

  const AccountStatementWidget({
    Key? key,
    required this.isDark,
    this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final controller = Get.find<AccountStatementController>();
    final borderColor = isDark ? AppColors.black : AppColorsLight.border;
    final borderColor1 = isDark ? AppColors.containerDark : AppColorsLight.container;
    final bgColor = isDark ? AppColors.containerLight : AppColorsLight.background;
    final bgColor1 = isDark ? AppColors.containerDark : AppColorsLight.container;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Month Button
              GestureDetector(
                onTap: controller.previousMonth,
                child: ResponsiveContainer(
                  widthPercent: 15,
                  heightPercent: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [
                        AppColors.containerLight,
                        AppColors.containerLight
                      ]:
                      [
                        AppColorsLight.white,
                        AppColorsLight.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: borderColor1, width: 1.4),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                      Icons.arrow_back,
                    color: isDark ? AppColors.white : AppColorsLight.black,
                  ),
                ),
              ),
              // Next Month Button
              BorderColor(
                isSelected: true,
                borderRadius: 0.1,
                leftWidth: 0.9,
                topWidth: 1.5,
                rightWidth: 0.9,
                child: ResponsiveContainer(
                  widthPercent: 61,
                  heightPercent: 6.6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [
                        AppColors.containerLight,
                        AppColors.containerLight
                      ]:
                      [
                        AppColorsLight.white,
                        AppColorsLight.white,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  alignment: Alignment.center,
                  child: Obx(() => AppText.headlineLarge1(
                    controller.getMonthRangeText(),
                    color: isDark ? AppColors.white : AppColorsLight.black,
                    fontWeight: FontWeight.w600,
                  )),
                ),
              ),

              // Month Display
              GestureDetector(
                onTap: controller.nextMonth,
                child: ResponsiveContainer(
                  widthPercent: 15,
                  heightPercent: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark ? [
                        AppColors.containerLight,
                        AppColors.containerLight
                      ]:
                      [
                        AppColorsLight.white,
                        AppColorsLight.white,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    border: Border.all(color: borderColor1, width: 1.4),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                      Icons.arrow_forward,
                    color: isDark ? AppColors.white : AppColorsLight.black,
                  ),
                ),
              ),


            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date Header
              ResponsiveContainer(
                widthPercent: 23,
                heightPercent: 6,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 0.4),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.calendarIc,
                      width: responsive.iconSizeMedium - 5,
                      height: responsive.iconSizeMedium - 5,
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                    SizedBox(width: responsive.wp(1)),
                    AppText.headlineLarge1(
                        "DATE",
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                  ],
                ),
              ),
              // IN Header
              ResponsiveContainer(
                widthPercent: 23,
                heightPercent: 6,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 0.4),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowInIc,
                      width: responsive.iconSizeMedium - 5,
                      height: responsive.iconSizeMedium - 5,
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                    SizedBox(width: responsive.wp(1)),
                    AppText.headlineLarge1("IN",
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                  ],
                ),
              ),
              // OUT Header
              ResponsiveContainer(
                widthPercent: 23,
                heightPercent: 6,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 0.4),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowOutIc,
                      width: responsive.iconSizeMedium - 5,
                      height: responsive.iconSizeMedium - 5,
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                    SizedBox(width: responsive.wp(1)),
                    AppText.headlineLarge1(
                        "OUT",
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                  ],
                ),
              ),
              // BAL Header
              ResponsiveContainer(
                widthPercent: 23,
                heightPercent: 6,
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 0.4),
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowInIc,
                      width: responsive.iconSizeMedium - 5,
                      height: responsive.iconSizeMedium - 5,
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                    SizedBox(width: responsive.wp(1)),
                    AppText.headlineLarge1("BAL.",
                      color: isDark ? AppColors.white : AppColorsLight.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Dynamic Transaction Rows (Grouped by Date)
          Obx(() {
            // Show loading indicator
            if (controller.isLoading.value) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: responsive.hp(4)),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.0,
                  ),
                ),
              );
            }

            // Show error message if any
            if (controller.errorMessage.value.isNotEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: responsive.hp(4)),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'Failed to load data',
                        style: TextStyle(color: AppColors.white, fontSize: responsive.fontSize(14)),
                      ),
                      SizedBox(height: responsive.hp(1)),
                      GestureDetector(
                        onTap: controller.refresh,
                        child: Text(
                          'Tap to retry',
                          style: TextStyle(
                            color: AppColors.primeryamount,
                            fontSize: responsive.fontSize(12),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final dailyGroups = controller.groupedDailyTransactions;

            if (dailyGroups.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: responsive.hp(4)),
                child: Center(
                  child: Text(
                    'No transactions for this month',
                    style: TextStyle(color: AppColors.white, fontSize: responsive.fontSize(14)),
                  ),
                ),
              );
            }

            return Column(
              children: List.generate(dailyGroups.length, (index) {
                final dailyGroup = dailyGroups[index];
                final isOddRow = index % 2 == 0; // 0-indexed, so 0,2,4 are "odd" visually

                // Alternating gradients
                final gradient = isOddRow
                    ? LinearGradient(
                        colors: isDark
                            ? [AppColors.containerDark, AppColors.containerDark]
                            : [AppColorsLight.white, AppColorsLight.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: isDark
                            ? [AppColors.containerLight, AppColors.containerLight]
                            : [AppColorsLight.background, AppColorsLight.background],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date Cell
                    ResponsiveContainer(
                      widthPercent: 23,
                      heightPercent: 6,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        border: Border.all(color: borderColor, width: 0.4),
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dailyGroup.formattedDate,
                        style: TextStyle(
                            color: isDark ? AppColors.white : AppColorsLight.black,
                            fontSize: responsive.fontSize(12)),
                      ),
                    ),
                    // IN Cell (Total IN for the day) - GREEN color
                    ResponsiveContainer(
                      widthPercent: 23,
                      heightPercent: 6,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        border: Border.all(color: borderColor, width: 0.4),
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dailyGroup.inAmount > 0
                            ? '₹${Formatters.formatAmountWithCommas(dailyGroup.inAmount.toString())}'
                            : '-',
                        style: TextStyle(
                          color: dailyGroup.inAmount > 0
                              ? AppColors.successPrimary
                              : AppColors.white,
                          fontSize: responsive.fontSize(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // OUT Cell (Total OUT for the day) - RED color
                    ResponsiveContainer(
                      widthPercent: 23,
                      heightPercent: 6,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        border: Border.all(color: borderColor, width: 0.4),
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        dailyGroup.outAmount > 0
                            ? '₹${Formatters.formatAmountWithCommas(dailyGroup.outAmount.toString())}'
                            : '-',
                        style: TextStyle(
                          color: dailyGroup.outAmount > 0
                              ? AppColors.red500
                              : AppColors.white,
                          fontSize: responsive.fontSize(12),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    // BAL Cell (Final balance at end of day) - KHATABOOK LOGIC
                    ResponsiveContainer(
                      widthPercent: 23,
                      heightPercent: 6,
                      decoration: BoxDecoration(
                        gradient: gradient,
                        border: Border.all(color: borderColor, width: 0.4),
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '₹${Formatters.formatAmountWithCommas(dailyGroup.balance.abs().toString())}',
                        style: TextStyle(
                          // ✅ KHATABOOK LOGIC:
                          // Positive (> 0) = RED (Customer owes you - You will RECEIVE)
                          // Negative (< 0) = GREEN (You owe customer - You will GIVE)
                          color: dailyGroup.balance > 0
                              ? AppColors.red500         // RED - Receivable
                              : dailyGroup.balance < 0
                                  ? AppColors.successPrimary  // GREEN - Payable
                                  : AppColors.white,          // Neutral for zero
                          fontSize: responsive.fontSize(12),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            );
          }),
        ],
      ),
    );
  }

}

/// Responsive Container Widget
/// Use this to create containers with responsive width and height
class ResponsiveContainer extends StatelessWidget {
  final Widget? child;
  final double? widthPercent; // Width as percentage of screen (0-100)
  final double? heightPercent; // Height as percentage of screen (0-100)
  final double? width; // Fixed width
  final double? height; // Fixed height
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    Key? key,
    this.child,
    this.widthPercent,
    this.heightPercent,
    this.width,
    this.height,
    this.color,
    this.padding,
    this.margin,
    this.decoration,
    this.alignment,
    this.constraints,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    // Calculate responsive width
    double? finalWidth;
    if (widthPercent != null) {
      finalWidth = responsive.wp(widthPercent!);
    } else if (width != null) {
      finalWidth = width;
    }

    // Calculate responsive height
    double? finalHeight;
    if (heightPercent != null) {
      finalHeight = responsive.hp(heightPercent!);
    } else if (height != null) {
      finalHeight = height;
    }

    return Container(
      width: finalWidth,
      height: finalHeight,
      padding: padding,
      margin: margin,
      decoration: decoration,
      alignment: alignment,
      constraints: constraints,
      color: decoration == null ? color : null,
      child: child,
    );
  }
}
