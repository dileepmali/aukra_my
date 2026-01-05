import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/utils/formatters.dart';
import '../custom_border_widget.dart';
import '../../../buttons/dialog_botton.dart';

class LedgerUpdateComparisonDialog {
  static Future<bool?> show({
    required BuildContext context,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _LedgerUpdateComparisonDialogContent(
        oldData: oldData,
        newData: newData,
      ),
    );
  }
}

class _LedgerUpdateComparisonDialogContent extends StatelessWidget {
  final Map<String, dynamic> oldData;
  final Map<String, dynamic> newData;

  const _LedgerUpdateComparisonDialogContent({
    required this.oldData,
    required this.newData,
  });

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
                        oldValue: oldData['name'] ?? '',
                        newValue: newData['name'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Mobile Number',
                        oldValue: oldData['mobileNumber'] ?? '',
                        newValue: newData['mobileNumber'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Area',
                        oldValue: oldData['area'] ?? '',
                        newValue: newData['area'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Pin Code',
                        oldValue: oldData['pinCode'] ?? '',
                        newValue: newData['pinCode'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Address',
                        oldValue: oldData['address'] ?? '',
                        newValue: newData['address'] ?? '',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Credit Days',
                        oldValue: '${oldData['creditDay'] ?? 0} days',
                        newValue: '${newData['creditDay'] ?? 0} days',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Credit Limit',
                        oldValue: '₹${Formatters.formatAmountWithCommas((oldData['creditLimit'] ?? 0).toString())}',
                        newValue: '₹${Formatters.formatAmountWithCommas((newData['creditLimit'] ?? 0).toString())}',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Interest Rate',
                        oldValue: '${oldData['interestRate'] ?? 0}%',
                        newValue: '${newData['interestRate'] ?? 0}%',
                        isDark: isDark,
                        responsive: responsive,
                      ),
                      _buildComparisonRow(
                        context: context,
                        label: 'Opening Balance',
                        oldValue: '₹${Formatters.formatAmountWithCommas((oldData['openingBalance'] ?? 0).toString())}',
                        newValue: '₹${Formatters.formatAmountWithCommas((newData['openingBalance'] ?? 0).toString())}',
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
                    onConfirm: () => Navigator.of(context).pop(true),
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
                ),]
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
