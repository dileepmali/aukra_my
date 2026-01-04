import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../controllers/account_statement_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/utils/formatters.dart';

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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.custom(
                'Account statement',
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                ),
              ),
              if (onViewDetails != null)
                TextButton(
                  onPressed: onViewDetails,
                  child: AppText.custom(
                    'View details',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: AppColorsLight.splaceSecondary1,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: responsive.hp(1)),

          // Month Navigation Row
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(4),
              vertical: responsive.hp(1.5),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.containerDark : AppColorsLight.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(responsive.borderRadiusSmall),
                topRight: Radius.circular(responsive.borderRadiusSmall),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Month Button
                IconButton(
                  onPressed: controller.previousMonth,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    size: responsive.iconSizeMedium,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),

                // Month Range Display
                Obx(() => AppText.custom(
                      controller.getMonthRangeText(),
                      style: TextStyle(
                        fontSize: responsive.fontSize(14),
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      ),
                    )),

                // Next Month Button
                IconButton(
                  onPressed: controller.nextMonth,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    size: responsive.iconSizeMedium,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.wp(4),
              vertical: responsive.hp(1),
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.containerDark : AppColorsLight.gradientColor1,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppText.custom(
                      'DATE',
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    flex: 2,
                    child: AppText.custom(
                      'IN',
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    flex: 2,
                    child: AppText.custom(
                      'OUT',
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                  Expanded(
                    flex: 2,
                    child: AppText.custom(
                      'BAL.',
                      style: TextStyle(
                        fontSize: responsive.fontSize(12),
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Table Body - Transaction Rows
          Obx(() {
            final transactions = controller.monthTransactions;

            return Container(
              constraints: BoxConstraints(
                maxHeight: responsive.hp(40), // Max height for scrolling
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.containerDark : AppColorsLight.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(responsive.borderRadiusSmall),
                  bottomRight: Radius.circular(responsive.borderRadiusSmall),
                ),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColorsLight.border,
                  width: 1,
                ),
              ),
              child: transactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(responsive.wp(8)),
                        child: AppText.custom(
                          'No transactions for this month',
                          style: TextStyle(
                            fontSize: responsive.fontSize(14),
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark ? AppColors.borderDark : AppColorsLight.border,
                      ),
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        final isIn = controller.isInTransaction(transaction);

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.wp(4),
                            vertical: responsive.hp(1.5),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                // Date Column
                                Expanded(
                                  flex: 3,
                                  child: AppText.custom(
                                    controller.formatDate(transaction.transactionDate),
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(13),
                                      fontWeight: FontWeight.w400,
                                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                    ),
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  color: isDark ? AppColors.borderDark : AppColorsLight.border,
                                ),

                                // IN Column
                                Expanded(
                                  flex: 2,
                                  child: AppText.custom(
                                    isIn
                                        ? '₹${Formatters.formatAmountWithCommas(controller.getInAmount(transaction).toString())}'
                                        : '-',
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(13),
                                      fontWeight: FontWeight.w500,
                                      color: isIn
                                          ? AppColors.primeryamount
                                          : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  color: isDark ? AppColors.borderDark : AppColorsLight.border,
                                ),

                                // OUT Column
                                Expanded(
                                  flex: 2,
                                  child: AppText.custom(
                                    !isIn
                                        ? '₹${Formatters.formatAmountWithCommas(controller.getOutAmount(transaction).toString())}'
                                        : '-',
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(13),
                                      fontWeight: FontWeight.w500,
                                      color: !isIn
                                          ? AppColors.red500
                                          : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),

                                Container(
                                  width: 1,
                                  color: isDark ? AppColors.borderDark : AppColorsLight.border,
                                ),

                                // BAL Column
                                Expanded(
                                  flex: 2,
                                  child: AppText.custom(
                                    '₹${Formatters.formatAmountWithCommas(controller.getBalance(transaction).toString())}',
                                    style: TextStyle(
                                      fontSize: responsive.fontSize(13),
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            );
          }),
        ],
      ),
    );
  }
}
