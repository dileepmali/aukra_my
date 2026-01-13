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

class EditBusinessNameDialog {
  static Future<String?> show({
    required BuildContext context,
    required String currentName,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EditBusinessNameDialogContent(
        currentName: currentName,
      ),
    );
  }
}

class _EditBusinessNameDialogContent extends StatefulWidget {
  final String currentName;

  const _EditBusinessNameDialogContent({
    required this.currentName,
  });

  @override
  State<_EditBusinessNameDialogContent> createState() =>
      _EditBusinessNameDialogContentState();
}

class _EditBusinessNameDialogContentState
    extends State<_EditBusinessNameDialogContent> {
  late final TextEditingController _nameController;
  final FocusNode _nameFocusNode = FocusNode();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    // Auto focus on name field
    Future.delayed(Duration(milliseconds: 300), () {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final name = _nameController.text.trim();

    // Validation
    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Business name cannot be empty';
      });
      return;
    }

    if (name.length < 2) {
      setState(() {
        errorMessage = 'Business name must be at least 2 characters';
      });
      return;
    }

    if (name.length > 100) {
      setState(() {
        errorMessage = 'Business name must be less than 100 characters';
      });
      return;
    }

    // Return the new name
    Navigator.of(context).pop(name);
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
              child: AppText.searchbar2(
                'Business Name',
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            ),
            SizedBox(height: responsive.hp(0.5)),

            // Subtitle
            Padding(
              padding: EdgeInsets.only(left: responsive.wp(4)),
              child: AppText.headlineLarge1(
                'Edit your business name',
                color: isDark
                    ? AppColors.textDisabled
                    : AppColorsLight.textSecondary,
                fontWeight: FontWeight.w400,
                textAlign: TextAlign.start,
              ),
            ),

            // Name Input Field
            Padding(
              padding: EdgeInsets.all(responsive.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    hintText: 'Enter business name',
                    fontSize: responsive.fontSize(16),
                    borderRadius: responsive.borderRadiusSmall,
                    maxLines: 1,
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
                    AppText.bodyLarge(
                      errorMessage!,
                      color: AppColors.red500,
                      fontWeight: FontWeight.w400,
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
                        isDark ? AppColors.white : AppColorsLight.white,
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
