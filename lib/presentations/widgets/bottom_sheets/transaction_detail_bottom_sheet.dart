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
import '../../../controllers/ledger_controller.dart';
import '../../../controllers/privacy_setting_controller.dart';
import '../../../core/utils/formatters.dart';

class TransactionDetailBottomSheet extends StatelessWidget {
  final int? transactionId;
  final int? ledgerId;
  final String partyName;
  final String location;
  final double amount;
  final String transactionDate; // ISO date string for formatting
  final String entryDate; // ISO date string for formatting
  final String? rawTransactionDate; // Original ISO date for API calls
  final String? remarks;
  final bool isPositive;
  final double? closingBalance; // Closing balance after this transaction
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
    this.closingBalance,
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
    double? closingBalance,
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
        closingBalance: closingBalance,
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
                      AppText.searchbar1(
                        isPositive ? 'In transaction entry' : 'Out transaction entry',
                        color: isPositive
                            ? (isDark ? AppColors.white : AppColorsLight.splaceSecondary1)
                            : AppColors.textDisabled,
                        fontWeight: FontWeight.w600,
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
                            child: AppText.displayMedium(
                              getInitials(partyName),
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: responsive.hp(0.5)),

                        // Party Name
                        AppText.searchbar2(
                          partyName,
                          color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                        ),
                        SizedBox(height: responsive.hp(0.2)),

                        // Location (if available)
                        if (location.isNotEmpty) ...[
                          AppText.headlineLarge1(
                            location,
                            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                            fontWeight: FontWeight.w400,
                            maxLines: 1,
                          ),
                          SizedBox(height: responsive.hp(0.2)),
                        ],

                        // Closing Balance (if available) - shown under name/address
                        if (closingBalance != null) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppText.headlineLarge1(
                                'Closing Bal. ',
                                color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                              SvgPicture.asset(
                                AppIcons.vectoeIc3,
                                width: responsive.iconSizeSmall - 2,
                                height: responsive.iconSizeSmall - 2,
                                colorFilter: ColorFilter.mode(
                                  isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: responsive.wp(0.3)),
                              AppText.headlineLarge1(
                                NumberFormat('#,##,##0.00', 'en_IN').format(closingBalance!.abs()),
                                color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: responsive.hp(2)),

                        // Amount with Currency Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: responsive.hp(1.5)),
                              child: SvgPicture.asset(
                                AppIcons.vectoeIc3,
                                width: responsive.iconSizeLarge,
                                height: responsive.iconSizeLarge,
                                colorFilter: ColorFilter.mode(
                                  isDark ? AppColors.white : AppColorsLight.textPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            SizedBox(width: responsive.wp(1)),
                            AppText.displayLarge(
                              NumberFormat('#,##,##0.00', 'en_IN').format(amount),
                              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                              fontWeight: FontWeight.bold,
                              maxLines: 1,
                              minFontSize: 15,
                              letterSpacing: 1.2,
                            ),
                          ],
                        ),
                        SizedBox(height: responsive.hp(0.9)),

                        // Transaction Date (formatted: d MMM yyyy, HH:mm)
                        AppText.searchbar1(
                          'Transaction on : ${Formatters.formatStringToDateAndTime(rawTransactionDate ?? transactionDate)}',
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: responsive.hp(2.6)),

                        // Entry Date (formatted: d MMM yyyy, HH:mm)
                        AppText.searchbar1(
                          'Entry on : ${Formatters.formatStringToDateAndTime(entryDate)}',
                          color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w500,
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
                            child: AppText.searchbar1(
                              remarks!,
                              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                              fontWeight: FontWeight.w400,
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
                primaryButtonText: 'Edit',
                onPrimaryPressed: () async {
                  // Use global PIN check - skip if PIN is disabled
                  String? pin;
                  try {
                    final privacyController = Get.find<PrivacySettingController>();
                    final result = await privacyController.requirePinIfEnabled(
                      context,
                      title: 'Enter Security PIN',
                      subtitle: 'Enter your 4-digit PIN to edit transaction',
                    );

                    if (result == null) {
                      return; // User cancelled or PIN validation failed
                    }

                    pin = result == 'SKIP' ? '' : result;
                  } catch (e) {
                    // Controller not registered, show PIN dialog as fallback
                    debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
                    final dialogResult = await PinVerificationDialog.show(
                      context: context,
                      title: 'Enter Security Pin',
                      subtitle: 'Enter your 4-digit pin to edit transaction',
                      requireOtp: false,
                    );
                    if (dialogResult == null || dialogResult['pin'] == null) {
                      return;
                    }
                    pin = dialogResult['pin'];
                  }

                  // PIN verified or skipped, proceed with edit
                  // Close bottom sheet first
                  Navigator.pop(context);

                  // Navigate to Add Transaction screen in edit mode
                  final navigationResult = await Get.toNamed(
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

                  // If update was successful, call onEdit callback to refresh data
                  if (navigationResult == true) {
                    debugPrint('✅ Transaction updated successfully - triggering refresh');
                    // Call onEdit callback to refresh LedgerDetailController
                    onEdit?.call();

                    // Also refresh LedgerController (main list) if it exists
                    try {
                      final ledgerController = Get.find<LedgerController>();
                      debugPrint('🔄 Also refreshing LedgerController (main list)...');
                      await ledgerController.refreshAll();
                      debugPrint('✅ LedgerController refreshed successfully');
                    } catch (e) {
                      debugPrint('⚠️ LedgerController not found, skipping main list refresh');
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

                  // Use global PIN check - skip if PIN is disabled
                  String? pin;
                  try {
                    final privacyController = Get.find<PrivacySettingController>();
                    final result = await privacyController.requirePinIfEnabled(
                      context,
                      title: 'Enter Security PIN',
                      subtitle: 'Enter your 4-digit PIN to delete transaction',
                      confirmGradientColors: [AppColors.red800, AppColors.red500],
                    );

                    if (result == null) {
                      return; // User cancelled or PIN validation failed
                    }

                    pin = result == 'SKIP' ? '' : result;
                  } catch (e) {
                    // Controller not registered, show PIN dialog as fallback
                    debugPrint('⚠️ PrivacySettingController not found, using fallback PIN dialog');
                    final dialogResult = await PinVerificationDialog.show(
                      context: context,
                      title: 'Enter Security Pin',
                      subtitle: 'Enter your 4-digit pin to delete transaction',
                      requireOtp: false,
                      confirmGradientColors: [AppColors.red800, AppColors.red500],
                      confirmTextColor: AppColors.white,
                    );
                    if (dialogResult == null || dialogResult['pin'] == null) {
                      return;
                    }
                    pin = dialogResult['pin'];
                  }

                  // PIN verified or skipped, proceed with deletion
                  try {
                    // Call Delete API
                    final api = LedgerTransactionApi();
                    final response = await api.deleteTransaction(
                      transactionId: transactionId!,
                      securityKey: pin!,
                    );

                    // Close bottom sheet
                    Navigator.pop(context);

                    // Show success message
                    AdvancedErrorService.showSuccess(
                      response.message,
                      type: SuccessType.snackbar,
                      customDuration: Duration(seconds: 2),
                    );

                    debugPrint('✅ Transaction deleted successfully - triggering refresh');

                    // Call onDelete callback to refresh LedgerDetailController
                    onDelete?.call();

                    // Also refresh LedgerController (main list) if it exists
                    try {
                      final ledgerController = Get.find<LedgerController>();
                      debugPrint('🔄 Also refreshing LedgerController (main list)...');
                      await ledgerController.refreshAll();
                      debugPrint('✅ LedgerController refreshed successfully');
                    } catch (e) {
                      debugPrint('⚠️ LedgerController not found, skipping main list refresh');
                    }
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
