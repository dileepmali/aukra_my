import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../text_filed/custom_text_field.dart';

class EditAddressDialog {
  static Future<String?> show({
    required BuildContext context,
    required String currentAddress,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EditAddressDialogContent(
        currentAddress: currentAddress,
      ),
    );
  }
}

class _EditAddressDialogContent extends StatefulWidget {
  final String currentAddress;

  const _EditAddressDialogContent({
    required this.currentAddress,
  });

  @override
  State<_EditAddressDialogContent> createState() =>
      _EditAddressDialogContentState();
}

class _EditAddressDialogContentState extends State<_EditAddressDialogContent> {
  late final TextEditingController _addressController;
  final FocusNode _addressFocusNode = FocusNode();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.currentAddress);
    // Auto focus on address field
    Future.delayed(Duration(milliseconds: 300), () {
      _addressFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _addressFocusNode.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final address = _addressController.text.trim();

    // Validation
    if (address.isEmpty) {
      setState(() {
        errorMessage = 'Address cannot be empty';
      });
      return;
    }

    if (address.length < 5) {
      setState(() {
        errorMessage = 'Address must be at least 5 characters';
      });
      return;
    }

    if (address.length > 200) {
      setState(() {
        errorMessage = 'Address must be less than 200 characters';
      });
      return;
    }

    // Return the new address
    Navigator.of(context).pop(address);
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: responsive.wp(8)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.containerDark, AppColors.containerLight]
                : [AppColorsLight.background, AppColorsLight.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          border: Border.all(
            color: isDark ? AppColors.driver : AppColorsLight.shadowLight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(
                  left: responsive.wp(4), top: responsive.hp(1)),
              child: AppText.custom(
                'Business Address',
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: responsive.hp(0.5)),

            // Subtitle
            Padding(
              padding: EdgeInsets.only(left: responsive.wp(4)),
              child: AppText.custom(
                'Edit your business address',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textDisabled
                      : AppColorsLight.textSecondary,
                  fontSize: responsive.fontSize(14),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.start,
              ),
            ),

            // Address Input Field
            Padding(
              padding: EdgeInsets.all(responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _addressController,
                    focusNode: _addressFocusNode,
                    hintText: 'Enter business address',
                    fontSize: responsive.fontSize(16),
                    borderRadius: responsive.borderRadiusSmall,
                    maxLines: 3,
                    minLines: 3,
                    onChanged: (value) {
                      // Clear error when user types
                      if (errorMessage != null) {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                  if (errorMessage != null) ...[
                    SizedBox(height: responsive.hp(1)),
                    AppText.custom(
                      errorMessage!,
                      style: TextStyle(
                        color: AppColors.red500,
                        fontSize: responsive.fontSize(12),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Action Buttons
            Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(responsive.wp(4)),
                  child: DialogButtonRow(
                    cancelText: 'Cancel',
                    confirmText: 'Submit',
                    onCancel: () => Navigator.of(context).pop(),
                    onConfirm: _handleConfirm,
                    buttonHeight: responsive.hp(6),
                    buttonSpacing: responsive.wp(3),
                    cancelGradientColors: isDark
                        ? [AppColors.containerDark, AppColors.containerLight]
                        : [
                            AppColorsLight.gradientColor1,
                            AppColorsLight.gradientColor2
                          ],
                    confirmGradientColors: isDark
                        ? [
                            AppColors.splaceSecondary1,
                            AppColors.splaceSecondary2
                          ]
                        : [
                            AppColorsLight.splaceSecondary1,
                            AppColorsLight.splaceSecondary2
                          ],
                    confirmTextColor:
                        isDark ? AppColors.buttonTextColor : AppColorsLight.black,
                    cancelTextColor:
                        isDark ? AppColors.white : AppColorsLight.black,
                    enableSweepGradient: true,
                  ),
                ),
                Positioned.fill(
                  child: CustomSingleBorderWidget(
                    position: BorderPosition.top,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
