import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/api/ledger_api.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../../models/ledger_model.dart';
import '../custom_border_widget.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../controllers/ledger_dashboard_controller.dart';
import '../../../controllers/ledger_detail_controller.dart';
import '../../../controllers/ledger_controller.dart';

class LedgerUpdateComparisonDialog {
  static Future<bool?> show({
    required BuildContext context,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
    required int ledgerId,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _LedgerUpdateComparisonDialogContent(
        oldData: oldData,
        newData: newData,
        ledgerId: ledgerId,
      ),
    );
  }
}

class _LedgerUpdateComparisonDialogContent extends StatefulWidget {
  final Map<String, dynamic> oldData;
  final Map<String, dynamic> newData;
  final int ledgerId;

  const _LedgerUpdateComparisonDialogContent({
    required this.oldData,
    required this.newData,
    required this.ledgerId,
  });

  @override
  State<_LedgerUpdateComparisonDialogContent> createState() =>
      _LedgerUpdateComparisonDialogContentState();
}

class _LedgerUpdateComparisonDialogContentState
    extends State<_LedgerUpdateComparisonDialogContent> {
  final LedgerApi _ledgerApi = LedgerApi();
  bool _isUpdating = false;

  Future<void> _handleUpdate() async {
    setState(() {
      _isUpdating = true;
    });

    try {
      // Create LedgerModel from newData
      final ledgerModel = LedgerModel(
        id: widget.ledgerId,
        name: widget.newData['name'] ?? '',
        creditLimit: (widget.newData['creditLimit'] ?? 0).toDouble(),
        creditDay: widget.newData['creditDay'] ?? 0,
        interestType: widget.newData['interestType'] ?? 'MONTHLY',
        interestRate: (widget.newData['interestRate'] ?? 0).toDouble(),
        mobileNumber: widget.newData['mobileNumber'] ?? '',
        area: widget.newData['area'] ?? '',
        address: widget.newData['address'] ?? '',
        pinCode: widget.newData['pinCode'] ?? '',
        partyType: widget.newData['partyType'] ?? 'CUSTOMER',
        openingBalance: (widget.newData['openingBalance'] ?? 0).toDouble(),
        currentBalance: (widget.newData['currentBalance'] ?? 0).toDouble(),
        transactionType: widget.newData['transactionType'] ?? 'IN',
        merchantId: widget.newData['merchantId'] ?? 0,
      );

      debugPrint('🔄 Starting ledger update...');
      debugPrint('📦 Ledger ID: ${widget.ledgerId}');
      debugPrint('📦 Update data: ${ledgerModel.toUpdateJson()}');

      // Call API
      final response = await _ledgerApi.updateLedger(
        ledgerId: widget.ledgerId,
        ledger: ledgerModel,
      );

      debugPrint('✅ Ledger updated successfully: ${response.message}');

      if (mounted) {
        // Refresh all ledger-related controllers
        debugPrint('🔄 Refreshing ledger controllers after update...');

        // 1. Refresh LedgerController (main ledger list)
        try {
          final ledgerController = Get.find<LedgerController>();
          await ledgerController.fetchAllLedgers();
          debugPrint('✅ LedgerController refreshed');
        } catch (e) {
          debugPrint('⚠️ LedgerController not found or error: $e');
        }

        // 2. Refresh LedgerDashboardController if exists
        try {
          final dashboardController = Get.find<LedgerDashboardController>();
          await dashboardController.fetchDashboard();
          debugPrint('✅ LedgerDashboardController refreshed');
        } catch (e) {
          debugPrint('⚠️ LedgerDashboardController not found or error: $e');
        }

        // 3. Refresh LedgerDetailController if exists
        try {
          final detailController = Get.find<LedgerDetailController>();
          await detailController.fetchLedgerDetails();
          await detailController.fetchTransactions();
          debugPrint('✅ LedgerDetailController refreshed');
        } catch (e) {
          debugPrint('⚠️ LedgerDetailController not found or error: $e');
        }

        // Close dialog and return true
        if (context.mounted) {
          Navigator.of(context).pop(true);

          // Show success message using AdvancedErrorService
          AdvancedErrorService.showSuccess(
            response.message,
            type: SuccessType.snackbar,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error updating ledger: $e');

      if (mounted) {
        setState(() {
          _isUpdating = false;
        });

        // Show error message using AdvancedErrorService
        AdvancedErrorService.showError(
          e.toString().replaceAll('Exception: ', ''),
          severity: ErrorSeverity.high,
          category: ErrorCategory.network,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: BorderColor(
        isSelected: true,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: responsive.hp(70),
          ),
          padding: EdgeInsets.all(responsive.spacing(20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.containerLight, AppColors.containerLight]
                  : [AppColorsLight.background, AppColorsLight.container],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              AppText.custom(
                'Are you sour?',
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: responsive.hp(0.5)),

              // Subtitle
              AppText.custom(
                'you are about to update these details.check twice & confirm the action',
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : AppColorsLight.textSecondary,
                  fontSize: responsive.fontSize(16),
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
              ),
              SizedBox(height: responsive.hp(2.5)),

              // Column Headers
              Row(
                children: [
                  Expanded(
                    child: AppText.custom(
                      'Old',
                      style: TextStyle(
                        color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                        fontSize: responsive.fontSize(13),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  SizedBox(width: responsive.wp(2)),
                  Expanded(
                    child: AppText.custom(
                      'Updated Data',
                      style: TextStyle(
                        color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                        fontSize: responsive.fontSize(13),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.hp(1)),

              // Scrollable comparison list
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildComparisonRow(
                        context: context,
                        label: 'Name',
                        oldValue: widget.oldData['name'] ?? '',
                        newValue: widget.newData['name'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Mobile Number',
                        oldValue: widget.oldData['mobileNumber'] ?? '',
                        newValue: widget.newData['mobileNumber'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Area',
                        oldValue: widget.oldData['area'] ?? '',
                        newValue: widget.newData['area'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Pin Code',
                        oldValue: widget.oldData['pinCode'] ?? '',
                        newValue: widget.newData['pinCode'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Address',
                        oldValue: widget.oldData['address'] ?? '',
                        newValue: widget.newData['address'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Credit Days',
                        oldValue: '${widget.oldData['creditDay'] ?? 0} days',
                        newValue: '${widget.newData['creditDay'] ?? 0} days',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Credit Limit',
                        oldValue: '₹${Formatters.formatAmountWithCommas((widget.oldData['creditLimit'] ?? 0).toString())}',
                        newValue: '₹${Formatters.formatAmountWithCommas((widget.newData['creditLimit'] ?? 0).toString())}',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Interest Rate',
                        oldValue: '${widget.oldData['interestRate'] ?? 0}%',
                        newValue: '${widget.newData['interestRate'] ?? 0}%',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Opening Balance',
                        oldValue: '₹${Formatters.formatAmountWithCommas((widget.oldData['openingBalance'] ?? 0).toString())}',
                        newValue: '₹${Formatters.formatAmountWithCommas((widget.newData['openingBalance'] ?? 0).toString())}',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: responsive.hp(2)),

              // Dialog Button Row
              Stack(
                children:[
                  Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top)),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: responsive.hp(1)),
                    child: DialogButtonRow(
                      cancelText: 'Cancel',
                      confirmText: 'Save',
                      onCancel: () => Navigator.of(context).pop(false),
                      onConfirm: _handleUpdate,
                      isLoading: _isUpdating,
                      cancelGradientColors: isDark
                          ? [AppColors.containerDark, AppColors.containerLight]
                          : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                      confirmGradientColors: isDark
                          ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                          : [AppColorsLight.splaceSecondary1, AppColorsLight.splaceSecondary2],
                      confirmTextColor: Colors.white,
                      buttonSpacing: responsive.wp(3),
                      buttonHeight: responsive.hp(6),
                    ),
                  ),
                ]
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonRow({
    required BuildContext context,
    required String label,
    required String oldValue,
    required String newValue,
    required bool isDark,
    required AdvancedResponsiveHelper responsive,
  }) {
    final bool hasChanged = oldValue != newValue;

    return Padding(
      padding: EdgeInsets.only(bottom: responsive.hp(1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old Value
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: responsive.hp(5.5),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(2),
                vertical: responsive.hp(1),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.containerDark, AppColors.containerLight]
                      : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                border: Border.all(
                  color: isDark
                      ? AppColors.white.withOpacity(0.2)
                      : AppColorsLight.textSecondary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: AppText.rich(
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: TextStyle(
                      fontSize: responsive.fontSize(15),
                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      fontSize: responsive.fontSize(13),
                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: oldValue.isEmpty ? '---' : oldValue,
                    style: TextStyle(
                      fontSize: responsive.fontSize(15),
                      color: isDark ? AppColors.white : AppColors.white,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
                maxLines: 5,
                overflow: TextOverflow.fade,
              ),
            ),
          ),

          SizedBox(width: responsive.wp(2)),

          // New Value
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                minHeight: responsive.hp(5.5),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(2),
                vertical: responsive.hp(1),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.containerDark, AppColors.containerLight]
                      : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                border: Border.all(
                  color: hasChanged
                      ? (isDark ? AppColors.successText : AppColorsLight.splaceSecondary1)
                      : (isDark
                          ? AppColors.white.withOpacity(0.2)
                          : AppColorsLight.textSecondary.withOpacity(0.3)),
                  width: hasChanged ? 2 : 1,
                ),
              ),
              child: AppText.rich(
                children: [
                  TextSpan(
                    text: '$label : ',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      fontSize: responsive.fontSize(15),
                      color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextSpan(
                    text: newValue.isEmpty ? '---' : newValue,
                    style: TextStyle(
                      fontSize: responsive.fontSize(15),
                      color: isDark ? AppColors.white : AppColors.white,
                      fontWeight: hasChanged ? FontWeight.w600 : FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
                maxLines: 5,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
