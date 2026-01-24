import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/utils/formatters.dart';
import '../../models/transaction_list_model.dart';

/// Desktop Transaction Item Widget - Horizontal Row Layout
/// 5 columns: Date/Time | Narration | Amount IN | Amount OUT | Closing Balance
class TransactionItemWidgetDesktop extends StatelessWidget {
  final TransactionItemModel transaction;
  final VoidCallback? onTap;

  const TransactionItemWidgetDesktop({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isPositive = transaction.transactionType == 'IN';
    final formattedDate = Formatters.formatStringToTimeAndDate(transaction.transactionDate);
    final narration = (transaction.description != null && transaction.description.toString().trim().isNotEmpty)
        ? transaction.description.toString()
        : 'No note added';
    final isDeleted = transaction.isDelete;
    final balance = transaction.currentBalance;
    final isPositiveBalance = balance >= 0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(1),
              vertical: responsive.hp(1.2),
            ),
            color: isDark ? AppColors.black : AppColorsLight.white,
            child: Row(
          children: [
            // Column 1: Date/Time (flex: 2)
            Expanded(
              flex: 2,
              child: Text(
                formattedDate,
                style: TextStyle(
                  color: isDeleted
                      ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                      : (isDark ? AppColors.white : AppColorsLight.textPrimary),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  decoration: isDeleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Column 2: Narration (flex: 3)
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  SvgPicture.asset(
                    isPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
                    width: responsive.iconSizeSmall * 0.8,
                    height: responsive.iconSizeSmall * 0.8,
                    colorFilter: ColorFilter.mode(
                      isDeleted
                          ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                          : (isDark ? AppColors.white : AppColorsLight.black),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: responsive.wp(0.3)),
                  Expanded(
                    child: Text(
                      narration,
                      style: TextStyle(
                        color: isDeleted
                            ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                            : (isDark ? AppColors.white : AppColorsLight.textPrimary),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        decoration: isDeleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Column 3: Amount IN (flex: 2)
            Expanded(
              flex: 2,
              child: isPositive
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.vectoeIc3,
                          width: 10,
                          height: 10,
                          colorFilter: ColorFilter.mode(
                            isDeleted ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary) : AppColors.primeryamount,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          transaction.amount.toStringAsFixed(2),
                          style: TextStyle(
                            color: isDeleted ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary) : AppColors.primeryamount,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: isDeleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // Column 4: Amount OUT (flex: 2)
            Expanded(
              flex: 2,
              child: !isPositive
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.vectoeIc3,
                          width: 10,
                          height: 10,
                          colorFilter: ColorFilter.mode(
                            isDeleted ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary) : AppColors.red500,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          transaction.amount.toStringAsFixed(2),
                          style: TextStyle(
                            color: isDeleted ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary) : AppColors.red500,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: isDeleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // Column 5: Closing Balance (flex: 2)
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    AppIcons.vectoeIc3,
                    width: 10,
                    height: 10,
                    colorFilter: ColorFilter.mode(
                      isDeleted
                          ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                          : (isPositiveBalance ? AppColors.primeryamount : AppColors.red500),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 3),
                  Text(
                    balance.abs().toStringAsFixed(2),
                    style: TextStyle(
                      color: isDeleted
                          ? (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary)
                          : (isPositiveBalance ? AppColors.primeryamount : AppColors.red500),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: isDeleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
          ),
          // Divider with left/right padding
          Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.borderAccent : AppColorsLight.border,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header Row for Transaction List - Shows Column Titles
class TransactionListHeaderDesktop extends StatelessWidget {
  const TransactionListHeaderDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: responsive.wp(1),
        right: responsive.wp(1),
        top: responsive.hp(1.5),
        bottom: responsive.hp(1),
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.containerLight : AppColorsLight.inputBackground,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderAccent : AppColorsLight.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Column 1: Date/Time
          Expanded(
            flex: 2,
            child: Text(
              'Date/Time',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Column 2: Narration
          Expanded(
            flex: 3,
            child: Text(
              'Narration',
              style: TextStyle(
                color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Column 3: Amount IN
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.arrowInIc,
                  width: responsive.iconSizeMedium * 0.7,
                  height: responsive.iconSizeMedium * 0.7,
                  colorFilter: ColorFilter.mode(
                    isDark ? AppColors.white : AppColorsLight.black,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Amount IN',
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColorsLight.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Column 4: Amount OUT
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.arrowOutIc,
                  width: responsive.iconSizeMedium * 0.7,
                  height: responsive.iconSizeMedium * 0.7,
                  colorFilter: ColorFilter.mode(
                    isDark ? AppColors.white : AppColorsLight.black,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Amount OUT',
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColorsLight.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Column 5: Closing Balance
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SvgPicture.asset(
                  AppIcons.vectoeIc3,
                  width: responsive.iconSizeMedium * 0.7,
                  height: responsive.iconSizeMedium * 0.7,
                  colorFilter: ColorFilter.mode(
                    isDark ? AppColors.white : AppColorsLight.black,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  'Closing Balance',
                  style: TextStyle(
                    color: isDark ? AppColors.white : AppColorsLight.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}