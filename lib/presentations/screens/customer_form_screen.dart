import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../controllers/customer_form_controller.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/text_filed/custom_text_field.dart';
import '../../buttons/dialog_botton.dart';
import '../../buttons/app_button.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/custom_single_border_color.dart';

class CustomerFormScreen extends StatelessWidget {
  const CustomerFormScreen({Key? key}) : super(key: key);

  // Get title based on party type and edit mode
  String _getTitle(String? partyType, bool isEditMode) {
    if (isEditMode) {
      // Edit mode
      switch (partyType?.toLowerCase()) {
        case 'supplier':
          return 'Edit Supplier';
        case 'Employeec':
          return 'Edit Employee';
        case 'customer':
        default:
          return 'Edit Customer';
      }
    } else {
      // Add mode
      switch (partyType?.toLowerCase()) {
        case 'supplier':
          return 'Add Supplier';
        case 'employee':
        case 'employer':
          return 'Add Employee';
        case 'customer':
        default:
          return 'Add Customer';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>?;

    // Check if edit mode or add mode
    final isEditMode = args?['isEditMode'] ?? false;
    final ledgerId = args?['ledgerId'] as int?;
    final partyType = args?['partyType'] as String?;

    debugPrint('📋 CustomerFormScreen - Edit Mode: $isEditMode');
    debugPrint('📋 CustomerFormScreen - partyType: $partyType');
    debugPrint('   Title will be: ${_getTitle(partyType, isEditMode)}');

    final controller = Get.put(CustomerFormController(
      isEditMode: isEditMode,
      ledgerId: ledgerId,
      partyType: partyType,
      // For edit mode - use ledger data
      initialName: isEditMode
          ? (args?['partyName'] as String?)
          : (args?['contactName'] as String?),
      initialPhone: isEditMode
          ? (args?['mobileNumber'] as String?)
          : (args?['contactPhone'] as String?),
      initialArea: args?['area'] as String?,
      initialPinCode: args?['pinCode'] as String?,
      initialAddress: args?['address'] as String?,
      initialCity: args?['city'] as String?,
      initialCountry: args?['country'] as String?,
      initialCreditDay: args?['creditDay'] as int?,
      initialCreditLimit: args?['creditLimit'] != null ? (args!['creditLimit'] as num).toDouble() : null,
      initialInterestRate: args?['interestRate'] != null ? (args!['interestRate'] as num).toDouble() : null,
      initialInterestType: args?['interestType'] as String?,
      initialOpeningBalance: args?['openingBalance'] != null ? (args!['openingBalance'] as num).toDouble() : null,
      initialTransactionType: args?['transactionType'] as String?,
    ));

    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow keyboard to resize properly
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          customPadding: EdgeInsets.symmetric(horizontal: responsive.wp(2)),
          leadingWidget: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  size: responsive.iconSizeLarge,
                ),
              ),
              SizedBox(width: responsive.wp(3),),
              AppText.searchbar2(
                _getTitle(partyType, isEditMode),
                color: isDark ? Colors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.0,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: responsive.wp(4),
          right: responsive.wp(4),
          top: responsive.hp(2),
          bottom: responsive.hp(2),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [AppColors.overlay, AppColors.overlay]
                  : [AppColorsLight.scaffoldBackground, AppColorsLight.container],
            ),
          ),
          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    _buildLabel(context, 'Name', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.nameController,
                      focusNode: controller.nameFocusNode,
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.phoneFocusNode.requestFocus(),
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Mobile Number Field
                    _buildLabel(context, 'Mobile number', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.phoneController,
                      focusNode: controller.phoneFocusNode,
                      keyboardType: TextInputType.phone,
                      prefixText: '+91-',
                      maxLength: 10,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.areaFocusNode.requestFocus(),
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Area and Pin Row
                    Row(
                      children: [
                        // Area Field
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, 'Area', responsive, isDark),
                              SizedBox(height: responsive.hp(0.8)),
                              CustomTextField(
                                controller: controller.areaController,
                                focusNode: controller.areaFocusNode,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => controller.pinFocusNode.requestFocus(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: responsive.wp(3)),
                        // Pin Field
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, 'Pin', responsive, isDark),
                              SizedBox(height: responsive.hp(0.8)),
                              CustomTextField(
                                controller: controller.pinController,
                                focusNode: controller.pinFocusNode,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                textInputAction: TextInputAction.next,
                                onSubmitted: (_) => controller.addressFocusNode.requestFocus(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Full Address Field
                    _buildLabel(context, 'Full address', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.addressController,
                      focusNode: controller.addressFocusNode,
                      keyboardType: TextInputType.streetAddress,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.interestRateFocusNode.requestFocus(),
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Annual Interest Rate Field
                    _buildLabel(context, 'Annual interest rate', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.interestRateController,
                      focusNode: controller.interestRateFocusNode,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      prefixBoxText: '%',
                      hintText: '0',
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.creditDaysFocusNode.requestFocus(),
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Credit Days Field
                    _buildLabel(context, 'Credit days', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.creditDaysController,
                      focusNode: controller.creditDaysFocusNode,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.openingBalanceFocusNode.requestFocus(),
                    ),
                    SizedBox(height: responsive.hp(1)),

                    // Quick Credit Days Chips
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCreditDayChip(context, '15 Days', 15, controller, responsive, isDark),
                        SizedBox(width: responsive.wp(2)),
                        _buildCreditDayChip(context, '30 Days', 30, controller, responsive, isDark),
                        SizedBox(width: responsive.wp(2)),
                        _buildCreditDayChip(context, '60 Days', 60, controller, responsive, isDark),
                        SizedBox(width: responsive.wp(2)),
                        _buildCreditDayChip(context, '90 Days', 90, controller, responsive, isDark),
                      ],
                    )),
                    SizedBox(height: responsive.hp(2)),

                    // Opening Balance Field
                    _buildLabel(context, 'Opening balance', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.openingBalanceController,
                      focusNode: controller.openingBalanceFocusNode,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      prefixBoxText: '₹',
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => controller.creditLimitFocusNode.requestFocus(),
                    ),
                    SizedBox(height: responsive.hp(2)),

                    // Credit Limit Field
                    _buildLabel(context, 'Credit limit', responsive, isDark),
                    SizedBox(height: responsive.hp(0.8)),
                    CustomTextField(
                      controller: controller.creditLimitController,
                      focusNode: controller.creditLimitFocusNode,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      prefixBoxText: '₹',
                      textInputAction: TextInputAction.done,
                    ),
                    SizedBox(height: responsive.hp(1)),

                    // Quick Credit Limit Chips
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCreditLimitChip(context, '10,000.00', 10000, controller, responsive, isDark),
                        SizedBox(width: responsive.wp(2)),
                        _buildCreditLimitChip(context, '20,000.00', 20000, controller, responsive, isDark),
                        SizedBox(width: responsive.wp(2)),
                        _buildCreditLimitChip(context, '50,000.00', 50000, controller, responsive, isDark),
                        SizedBox(width: responsive.wp(2)),
                        _buildCreditLimitChip(context, '99,000.00', 99000, controller, responsive, isDark),
                      ],
                    )),
                    SizedBox(height: responsive.hp(3)),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(4),
                vertical: responsive.hp(2),
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.containerDark : AppColorsLight.scaffoldBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Obx(() {
                if (isEditMode) {
                  // Edit Mode: Show Cancel + Update buttons
                  return DialogButtonRow(
                    cancelText: 'Go back',
                    confirmText: 'Update',
                    onCancel: () => Navigator.of(context).pop(),
                    onConfirm: () => controller.submitForm(context),
                    isLoading: controller.isLoading.value,
                    cancelGradientColors: isDark
                        ? [
                            AppColors.containerLight,
                            AppColors.containerDark,
                          ]
                        : [
                            AppColorsLight.textSecondary.withOpacity(0.1),
                            AppColorsLight.textSecondary.withOpacity(0.05),
                          ],
                    cancelTextColor: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    confirmTextColor: Colors.white,
                    confirmGradientColors: [
                      AppColors.splaceSecondary1,
                      AppColors.splaceSecondary2,
                    ],
                    buttonSpacing: responsive.wp(3),
                  );
                } else {
                  // Add Mode: Show Cancel + Confirm buttons
                  return DialogButtonRow(
                    cancelText: 'Go back',
                    confirmText: 'Confirm',
                    onCancel: () => Navigator.of(context).pop(),
                    onConfirm: () => controller.submitForm(context),
                    isLoading: controller.isLoading.value,
                    cancelGradientColors: isDark
                        ? [
                            AppColors.containerLight,
                            AppColors.containerDark,
                          ]
                        : [
                            AppColorsLight.textSecondary.withOpacity(0.1),
                            AppColorsLight.textSecondary.withOpacity(0.05),
                          ],
                    cancelTextColor: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    confirmTextColor: Colors.white,
                    confirmGradientColors: [
                      AppColors.splaceSecondary1,
                      AppColors.splaceSecondary2,
                    ],
                    buttonSpacing: responsive.wp(3),
                  );
                }
              }),
            ),
            Positioned.fill(
              child: CustomSingleBorderWidget(
                position: BorderPosition.top,
                borderWidth: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(
    BuildContext context,
    String text,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return AppText.headlineLarge1(
      text,
      color: isDark
          ? AppColors.white.withOpacity(0.7)
          : AppColorsLight.textSecondary,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.0,
    );
  }

  Widget _buildCreditDayChip(
    BuildContext context,
    String label,
    int days,
    CustomerFormController controller,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    final isSelected = controller.selectedCreditDays.value == days;

    return GestureDetector(
      onTap: () => controller.selectCreditDays(days),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(4),
          vertical: responsive.hp(1),
        ),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
            colors: [AppColors.containerLight, AppColors.containerDark],
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
                )
              : AppColorsLight.brandGradient,
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: AppText.headlineLarge1(
          label,
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildCreditLimitChip(
    BuildContext context,
    String label,
    double amount,
    CustomerFormController controller,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    final isSelected = controller.selectedCreditLimit.value == amount;

    return GestureDetector(
      onTap: () => controller.selectCreditLimit(amount),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(2.5),
          vertical: responsive.hp(1),
        ),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: [AppColors.containerLight, AppColors.containerDark],
                  begin: Alignment.topRight,
                  end: Alignment.bottomCenter,
                )
              : AppColorsLight.brandGradient,
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: AppText.headlineLarge1(
          label,
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}
