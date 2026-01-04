import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_string.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../buttons/row_app_bar.dart';
import '../custom_single_border_color.dart';
import '../dialogs/pin_verification_dialog.dart';
import '../../routes/app_routes.dart';
import '../../../core/api/ledger_transaction_api.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final int? transactionId;
  final int? ledgerId;
  final String partyName;
  final String location;
  final double amount;
  final String transactionDate; // Formatted date for display
  final String entryDate; // Formatted date for display
  final String? rawTransactionDate; // Original ISO date for API calls
  final String? remarks;
  final bool isPositive;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionDetailBottomSheet({
    Key? key,
    this.transactionId,
    this.ledgerId,
    required this.partyName,
    required this.location,
    required this.amount,
    required this.transactionDate,
    required this.entryDate,
    this.rawTransactionDate,
    this.remarks,
    required this.isPositive,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    int? transactionId,
    int? ledgerId,
    required String partyName,
    required String location,
    required double amount,
    required String transactionDate,
    required String entryDate,
    String? rawTransactionDate,
    String? remarks,
    required bool isPositive,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailBottomSheet(
        transactionId: transactionId,
        ledgerId: ledgerId,
        partyName: partyName,
        location: location,
        amount: amount,
        transactionDate: transactionDate,
        entryDate: entryDate,
        rawTransactionDate: rawTransactionDate,
        remarks: remarks,
        isPositive: isPositive,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get initials from name
    String getInitials(String name) {
      final parts = name.trim().split(' ');
      if (parts.isEmpty) return 'U';
      if (parts.length == 1) {
        return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'U';
      }
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    return Stack(
      children: [
        Container(
          constraints: BoxConstraints(
            maxHeight: responsive.hp(85),
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.overlay : AppColorsLight.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(responsive.borderRadiusExtraLarge),
              topRight: Radius.circular(responsive.borderRadiusExtraLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Transaction Type Indicator
              SizedBox(height: responsive.hp(1.5)),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
                padding: EdgeInsets.symmetric(
                  vertical: responsive.hp(1.0),
                    horizontal: responsive.wp(2)
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.black : AppColorsLight.scaffoldBackground,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: responsive.hp(1.5),horizontal: responsive.wp(2)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPositive
                          ? isDark
                          ? [
                        AppColors.splaceSecondary1,
                        AppColors.splaceSecondary2,
                      ]
                          : [
                        AppColorsLight.gradientColor2,
                        AppColorsLight.gradientColor2,
                      ]
                          : [
                        AppColors.red800,
                        AppColors.red500,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        isPositive ? AppIcons.arrowInIc : AppIcons.arrowOutIc,
                        width: responsive.iconSizeMedium,
                        height: responsive.iconSizeMedium,
                        colorFilter: ColorFilter.mode(
                          isPositive
                              ? (isDark ? AppColors.white : AppColorsLight.splaceSecondary1)
                              : AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: responsive.wp(2)),
                      AppText.custom(
                        isPositive ? 'In transaction entry' : 'Out transaction entry',
                        style: TextStyle(
                          color: isPositive
                              ? (isDark ? AppColors.white : AppColorsLight.splaceSecondary1)
                              : AppColors.textDisabled,
                          fontSize: responsive.fontSize(16),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(responsive.wp(6)),
                    child: Column(
                      children: [
                        SizedBox(height: responsive.hp(1)),
                        // Avatar and Name
                        Container(
                          width: responsive.wp(19),
                          height: responsive.wp(19),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: isDark
                                  ? [
                                      AppColors.splaceSecondary1,
                                      AppColors.splaceSecondary2,
                                    ]
                                  : [
                                      AppColorsLight.gradientColor1,
                                      AppColorsLight.gradientColor2,
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Center(
                            child: AppText.custom(
                              getInitials(partyName),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: responsive.fontSize(22),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.hp(0.5)),

                        // Party Name
                        AppText.custom(
                          partyName,
                          style: TextStyle(
                            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            fontSize: responsive.fontSize(21),
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: responsive.hp(0.2)),

                        // Location
                        AppText.custom(
                          location,
                          style: TextStyle(
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                            fontSize: responsive.fontSize(16),
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: responsive.hp(2)),

                        // Amount
                        AppText.custom(
                          '₹ ${NumberFormat('#,##,##0.00', 'en_IN').format(amount)}',
                          style: TextStyle(
                            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            fontSize: responsive.fontSize(45),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: responsive.hp(0.5)),

                        // Transaction Date
                        AppText.custom(
                          'Transaction on : $transactionDate',
                          style: TextStyle(
                            color: isDark ? AppColors.background : AppColorsLight.textSecondary,
                            fontSize: responsive.fontSize(16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: responsive.hp(1.2)),

                        // Entry Date
                        AppText.custom(
                          'Entry on : $entryDate',
                          style: TextStyle(
                            color: isDark ? AppColors.background : AppColorsLight.textSecondary,
                            fontSize: responsive.fontSize(16),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: responsive.hp(3)),

                        // Remarks (if available)
                        if (remarks != null && remarks!.isNotEmpty) ...[
                          Container(
                            alignment: Alignment.center,
                            height: responsive.hp(5),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.black.withOpacity(0.5)
                                  : AppColorsLight.containerLight.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            ),
                            child: AppText.custom(
                              remarks!,
                              style: TextStyle(
                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                fontSize: responsive.fontSize(16),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Action Bar - Fixed at bottom
              BottomActionBar(
                gradientColors: [
                  isDark ? AppColors.containerDark : AppColorsLight.white,
                  isDark ? AppColors.containerLight : AppColorsLight.white,
                ],
                showBorder: true,
                primaryButtonText: 'Exit',
                onPrimaryPressed: () async {
                  // Show PIN verification dialog for Exit/Edit
                  final pin = await PinVerificationDialog.show(
                    context: context,
                    title: 'Enter Security Pin',
                    subtitle: 'Enter your 4-digit pin to edit transaction',
                  );

                  // If PIN is entered (not null), proceed with edit
                  if (pin != null && pin.isNotEmpty) {
                    Navigator.pop(context);

                    // Navigate to Add Transaction screen in edit mode
                    final result = await Get.toNamed(
                      AppRoutes.addTransaction,
                      arguments: {
                        'transactionId': transactionId,
                        'ledgerId': ledgerId,
                        'customerName': partyName,
                        'customerLocation': location,
                        'amount': amount,
                        'transactionType': isPositive ? 'IN' : 'OUT',
                        'transactionDate': rawTransactionDate ?? transactionDate, // Use raw ISO date if available
                        'comments': remarks,
                      },
                    );

                    // If update was successful, call onEdit callback
                    if (result == true) {
                      debugPrint('✅ Transaction updated successfully - triggering refresh');
                      onEdit?.call();
                    }
                  }
                },
                secondaryButtonText: 'Delete',
                secondaryButtonGradientColors: isDark
                    ? [
                        AppColors.red800,
                        AppColors.red500,
                      ]
                    : [
                        AppColorsLight.gradientColor1,
                        AppColorsLight.gradientColor2,
                      ],
                buttonSpacing: responsive.spacing(16),
                containerPadding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(16),
                  vertical: responsive.spacing(16),
                ),
                onSecondaryPressed: () async {
                  // Check if transaction ID exists
                  if (transactionId == null) {
                    AdvancedErrorService.showError(
                      'Transaction ID not found. Cannot delete.',
                      severity: ErrorSeverity.high,
                      category: ErrorCategory.validation,
                    );
                    return;
                  }

                  // Show PIN verification dialog
                  final pin = await PinVerificationDialog.show(
                    context: context,
                    title: 'Enter Security Pin',
                    subtitle: 'Enter your 4-digit pin to delete transaction',
                    confirmGradientColors: isDark
                        ? [
                            AppColors.red800,
                            AppColors.red500,
                          ]
                        : [
                            AppColors.red800,
                            AppColors.red500,
                          ],
                    confirmTextColor: AppColors.white,
                  );

                  // If PIN is entered (not null), proceed with deletion
                  if (pin != null && pin.isNotEmpty) {
                    try {
                      // Call Delete API
                      final api = LedgerTransactionApi();
                      final response = await api.deleteTransaction(
                        transactionId: transactionId!,
                        securityKey: pin,
                      );

                      // Close bottom sheet
                      Navigator.pop(context);

                      // Show success message
                      AdvancedErrorService.showSuccess(
                        response.message,
                        type: SuccessType.snackbar,
                        customDuration: Duration(seconds: 2),
                      );

                      // Call onDelete callback if provided
                      onDelete?.call();
                    } catch (e) {
                      debugPrint('❌ Delete Transaction Error: $e');

                      // Show error message
                      AdvancedErrorService.showError(
                        e.toString().replaceAll('Exception: ', ''),
                        severity: ErrorSeverity.high,
                        category: ErrorCategory.network,
                        customDuration: Duration(seconds: 3),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: CustomSingleBorderWidget(
            position: BorderPosition.top,
            borderWidth: isDark ? 1.0 : 2.0,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        ),
      ]
    );
  }
}
