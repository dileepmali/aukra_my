import 'dart:io';
import 'package:aukra_anantkaya_space/app/constants/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../widgets/custom_app_bar/custom_app_bar.dart';
import '../widgets/custom_app_bar/model/app_bar_config.dart';
import '../widgets/custom_single_border_color.dart';
import '../widgets/text_filed/custom_text_field.dart';
import '../widgets/bottom_sheets/image_picker_bottom_sheet.dart';
import '../widgets/dialogs/pin_verification_dialog.dart';
import '../../buttons/app_button.dart';
import '../../buttons/dialog_botton.dart';
import '../../buttons/row_app_bar.dart';
import '../widgets/custom_date_picker.dart';
import '../../controllers/add_transaction_controller.dart';

class AddTransactionScreen extends GetView<AddTransactionController> {
  const AddTransactionScreen({Key? key}) : super(key: key);

  Future<void> _handleConfirmButton(BuildContext context) async {
    // Show PIN dialog
    final pin = await PinVerificationDialog.show(context: context);
    if (pin == null) {
      return; // User cancelled
    }

    // Submit transaction via controller
    await controller.submitTransaction(pin);
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await CustomDatePicker.show(
      context: context,
      initialDate: controller.selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      controller.setSelectedDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Scaffold(
      resizeToAvoidBottomInset: false, // Keep button at bottom when keyboard opens
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
              SizedBox(width: responsive.wp(3)),
              Obx(() => AppText.custom(
                controller.isEditMode.value ? 'Edit Transaction' : 'Add Transaction',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.0,
              )),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.containerLight, AppColors.containerLight]
                : [AppColorsLight.scaffoldBackground, AppColorsLight.container],
          ),
        ),
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + responsive.hp(10), // Dynamic padding for keyboard + button height
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [ // Security message
                    Stack(
                      children:[ 
                        Container(
                        height: responsive.hp(16),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(horizontal: responsive.wp(4),vertical: responsive.hp(2)),
                        decoration: BoxDecoration(
                          gradient: isDark
                              ? LinearGradient(
                            colors: [
                              AppColors.overlay,
                              AppColors.overlay
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : LinearGradient(
                            colors: [
                              AppColorsLight.gradientColor1,
                              AppColorsLight.gradientColor2
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                        ),
                        child: _buildSecurityMessage(responsive, isDark)),
                        Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.bottom))
                      ]
                    ),
                    SizedBox(height: responsive.hp(1.2)),

                    AppText.custom(
                        'Select transcation type',
                        style: TextStyle(
                          color: isDark ? AppColors.white : AppColorsLight.black,
                          fontSize: responsive.fontSize(17),
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center
                    ),
                    SizedBox(height: responsive.hp(1.2)),

                    // Transaction type selection (IN/OUT buttons)
                    _buildTransactionTypeButtons(responsive, isDark),

                    SizedBox(height: responsive.hp(3)),

                    // Customer Avatar and Details
                    _buildCustomerDetails(controller.customerName ?? 'Customer', controller.customerLocation ?? 'Location', responsive, isDark),

                    SizedBox(height: responsive.hp(3)),

                    // Amount Input
                    _buildAmountInput(responsive, isDark),

                    SizedBox(height: responsive.hp(3)),

                    // Add Note
                    _buildNoteInput(responsive, isDark),

                    SizedBox(height: responsive.hp(1)),

                    // Date and Photos Row
                    Obx(() => Padding(
                      padding:  EdgeInsets.symmetric(horizontal: responsive.wp(4)),
                      child: DialogButtonRow(
                        cancelText: DateFormat('d MMM yyyy').format(controller.selectedDate.value),
                        confirmText: 'Add photos',
                        onCancel: () => _selectDate(context),
                        onConfirm: () {
                          ImagePickerBottomSheet.show(
                            context: context,
                            onImagesSelected: (images) {
                              controller.addImages(images);
                              debugPrint('Selected ${images.length} images');
                            },
                          );
                        },
                        buttonHeight: responsive.hp(6),
                        buttonSpacing: responsive.wp(3),
                        confirmTextColor: isDark ? AppColors.white : AppColors.black,
                        cancelIcon: SvgPicture.asset(
                          AppIcons.calendarIc,
                          width: responsive.iconSizeMedium,
                          height: responsive.iconSizeMedium,
                          colorFilter: ColorFilter.mode(
                            isDark ? AppColors.white : AppColorsLight.black,
                            BlendMode.srcIn,
                          ),
                        ),
                        confirmIcon:SvgPicture.asset(
                          AppIcons.cameraIc,
                          width: responsive.iconSizeMedium,
                          height: responsive.iconSizeMedium,
                          colorFilter: ColorFilter.mode(
                            isDark ? AppColors.white : AppColorsLight.black,
                            BlendMode.srcIn,
                          ),
                        ),
                        cancelGradientColors: isDark
                            ? [AppColors.containerDark, AppColors.containerLight]
                            : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                        confirmGradientColors: isDark
                            ? [AppColors.containerDark, AppColors.containerLight]
                            : [AppColorsLight.splaceSecondary1, AppColorsLight.splaceSecondary2],
                        enableSweepGradient: true,
                      ),
                    )),

                    SizedBox(height: responsive.hp(2)),

                    // Selected Images Gallery (Horizontal)
                    _buildSelectedImagesGallery(responsive, isDark),

                    SizedBox(height: responsive.hp(3)),
                  ],
                ),
              ),
            ),

            // Bottom Save/Update Buttons
            SafeArea(
              child: Obx(() => Stack(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.spacing(15)),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                AppColors.containerDark,
                                AppColors.containerLight,
                                AppColors.containerLight,
                              ]
                            : [
                                AppColorsLight.background,
                                AppColorsLight.background,
                                AppColorsLight.background,
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: controller.isEditMode.value
                        ? Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'Go Back',
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : () => Get.back(),
                                  height: responsive.hp(6.5),
                                  gradientColors: isDark
                                      ? [AppColors.containerDark, AppColors.containerLight]
                                      : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                                  textColor: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                  fontSize: responsive.fontSize(18),
                                  fontWeight: FontWeight.w600,
                                  borderColor: isDark ? AppColors.driver : AppColorsLight.shadowLight,
                                  leadingWidget: SvgPicture.asset(
                                    AppIcons.arrowBackIc,
                                    width: responsive.iconSizeMedium,
                                    height: responsive.iconSizeMedium,
                                    colorFilter: ColorFilter.mode(
                                      isDark ? AppColors.white : AppColorsLight.textPrimary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: responsive.spacing(12)),
                              Expanded(
                                child: AppButton(
                                  text: controller.isSubmitting.value ? 'Updating...' : 'Update',
                                  onPressed: controller.isSubmitting.value
                                      ? null
                                      : () => _handleConfirmButton(context),
                                  height: responsive.hp(6.5),
                                  gradientColors: isDark
                                      ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                                      : [AppColorsLight.splaceSecondary1, AppColorsLight.splaceSecondary2],
                                  textColor: isDark ? AppColors.buttonTextColor : AppColorsLight.black,
                                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                  fontSize: responsive.fontSize(18),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : AppButton(
                            text: controller.isSubmitting.value ? 'Processing...' : 'Confirm',
                            onPressed: controller.isSubmitting.value
                                ? () {}
                                : () => _handleConfirmButton(context),
                            height: responsive.hp(6.5),
                            gradientColors: isDark
                                ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                                : [AppColorsLight.splaceSecondary1, AppColorsLight.splaceSecondary2],
                            textColor: isDark ? AppColors.buttonTextColor : AppColorsLight.black,
                            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            fontSize: responsive.fontSize(18),
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                  Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top))
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityMessage(AdvancedResponsiveHelper responsive, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(
          AppIcons.lockIc,
          color: isDark ? AppColors.white.withOpacity(0.7) : AppColorsLight.textSecondary,
          height: responsive.iconSizeExtraLarge,
          width: responsive.iconSizeExtraLarge,
        ),
        SizedBox(height: responsive.hp(2)),
        AppText.custom(
          'All transaction between you and customers are\nsafely private & secure.',
          style: TextStyle(
            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            fontSize: responsive.fontSize(14),
          ),
          textAlign: TextAlign.start,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTransactionTypeButtons(AdvancedResponsiveHelper responsive, bool isDark) {
    return Obx(() => Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.wp(2),
          vertical: responsive.hp(0.6),
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.black : AppColorsLight.white,
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTransactionType('IN'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: responsive.hp(1.0)),
                decoration: BoxDecoration(
                  gradient: controller.selectedType.value == 'IN'
                      ? LinearGradient(
                          colors: [
                            AppColors.green400,
                            AppColors.green800,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: controller.selectedType.value == 'IN' ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowInIc,
                      width: responsive.iconSizeMedium,
                      height: responsive.iconSizeMedium,
                    ),
                    SizedBox(width: responsive.wp(2)),
                    AppText.custom(
                      'In',
                      style: TextStyle(
                        color: controller.selectedType.value == 'IN' ? AppColors.white : Colors.white,
                        fontSize: responsive.fontSize(17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: responsive.wp(3)),
          Expanded(
            child: GestureDetector(
              onTap: () => controller.setTransactionType('OUT'),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: responsive.hp(1)),
                decoration: BoxDecoration(
                  gradient: controller.selectedType.value == 'OUT'
                      ? LinearGradient(
                          colors: [AppColors.red500, AppColors.red800],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  color: controller.selectedType.value == 'OUT' ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AppIcons.arrowOutIc,
                      width: responsive.iconSizeMedium,
                      height: responsive.iconSizeMedium,
                    ),
                    SizedBox(width: responsive.wp(2)),
                    AppText.custom(
                      'Out',
                      style: TextStyle(
                        color: controller.selectedType.value == 'OUT' ? AppColors.white : Colors.white,
                        fontSize: responsive.fontSize(17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    )
    );
  }

  Widget _buildCustomerDetails(String name, String location, AdvancedResponsiveHelper responsive, bool isDark) {
    String getInitials(String name) {
      final parts = name.trim().split(' ');
      if (parts.isEmpty) return 'A';
      if (parts.length == 1) {
        return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'A';
      }
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: Column(
      children: [
        // Avatar
        Container(
          width: responsive.wp(16),
          height: responsive.wp(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.splaceSecondary2, AppColors.splaceSecondary1],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: AppText.custom(
              getInitials(name),
              style: TextStyle(
                color: AppColors.white,
                fontSize: responsive.fontSize(24),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: responsive.hp(0.6)),
        // Name
        AppText.custom(
          name,
          style: TextStyle(
            color: isDark ? AppColors.white : AppColorsLight.textPrimary,
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.hp(0.2)),
        // Location
        AppText.custom(
          location,
          style: TextStyle(
            color: isDark ? AppColors.textDisabled : AppColorsLight.textSecondary,
            fontSize: responsive.fontSize(14),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildAmountInput(AdvancedResponsiveHelper responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center, // Align items to bottom
        children: [
        Padding(
          padding: EdgeInsets.only(top: responsive.hp(1.5)), // Fine-tune vertical position
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
        SizedBox(width: responsive.wp(0.1)),
        IntrinsicWidth(
          child: TextField(
            controller: controller.amountController,
            focusNode: controller.amountFocusNode,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            textAlign: TextAlign.left,
            cursorColor: isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary1,
            cursorWidth: 3,
            cursorHeight: responsive.fontSize(40),
            onSubmitted: (value) {
              // Close keyboard when done button pressed
              controller.amountFocusNode.unfocus();
            },
            style: TextStyle(
              color: isDark ? AppColors.white : AppColorsLight.textPrimary,
              fontSize: responsive.fontSize(60),
              fontWeight: FontWeight.w900,
              fontFamily: 'Poppins',

            ),
            decoration: InputDecoration(
              hintText: '0.00',
              hintStyle: TextStyle(
                color: isDark
                    ? AppColors.white.withOpacity(0.3)
                    : AppColorsLight.textSecondary.withOpacity(0.3),
                fontSize: responsive.fontSize(60),
                fontWeight: FontWeight.w900,
                fontFamily: 'Poppins',
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildNoteInput(AdvancedResponsiveHelper responsive, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
      child: CustomTextField(
        controller: controller.noteController,
        focusNode: controller.noteFocusNode,
        maxLines: 1,
        hintText: 'Add a note',
        fontSize: responsive.fontSize(14),
        borderRadius: responsive.borderRadiusSmall,
      ),
    );
  }

  Widget _buildSelectedImagesGallery(AdvancedResponsiveHelper responsive, bool isDark) {
    return Obx(() {
      if (controller.selectedImages.isEmpty) {
        return SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: responsive.hp(12),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  final image = controller.selectedImages[index];
                return Container(
                  margin: EdgeInsets.only(right: responsive.wp(3)),
                  child: Stack(
                    children: [
                      // Image thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                        child: Image.file(
                          File(image.path),
                          width: responsive.wp(20),
                          height: responsive.hp(8),
                          fit: BoxFit.cover,
                        ),
                      ),
                      // Remove button (Bottom Right)
                      Positioned(
                        bottom:  responsive.hp(3),
                        right: - 2,
                        child: GestureDetector(
                          onTap: () => controller.removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.red500,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close,
                              color: AppColors.white,
                              size: responsive.iconSizeMedium,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              ),
            ),
          ],
        ),
      );
    });
  }

}
