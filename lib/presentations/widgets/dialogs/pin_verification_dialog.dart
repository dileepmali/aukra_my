import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
import 'package:aukra_anantkaya_space/presentations/widgets/custom_single_border_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/padding_navigation.dart';

class PinVerificationDialog {
  static Future<String?> show({
    required BuildContext context,
    String title = 'Enter Security Pin',
    String subtitle = 'Enter your 4-digit pin to proceed',
    Color? titleColor,
    Color? subtitleColor,
    List<Color>? confirmGradientColors,
    Color? confirmTextColor,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PinVerificationDialogContent(
        title: title,
        subtitle: subtitle,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        confirmGradientColors: confirmGradientColors,
        confirmTextColor: confirmTextColor,
      ),
    );
  }
}

class _PinVerificationDialogContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final List<Color>? confirmGradientColors;
  final Color? confirmTextColor;

  const _PinVerificationDialogContent({
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.confirmGradientColors,
    this.confirmTextColor,
  });

  @override
  State<_PinVerificationDialogContent> createState() =>
      _PinVerificationDialogContentState();
}

class _PinVerificationDialogContentState
    extends State<_PinVerificationDialogContent> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // Auto focus on PIN field
    Future.delayed(Duration(milliseconds: 300), () {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() {
        errorMessage = 'Please enter PIN';
      });
      return;
    }
    if (pin.length != 4) {
      setState(() {
        errorMessage = 'PIN must be 4 digits';
      });
      return;
    }
    // Return PIN to caller
    Navigator.of(context).pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: BorderColor(
        isSelected: true,
        child: Container(
          padding: EdgeInsets.all(responsive.spacing(20)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.containerDark, AppColors.containerLight]
                  : [AppColorsLight.background, AppColorsLight.container],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              AppText.custom(
                widget.title,
                style: TextStyle(
                  color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                  fontSize: responsive.fontSize(20),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.start,
              ),
              SizedBox(height: responsive.hp(1)),

              // Subtitle
              AppText.custom(
                widget.subtitle,
                style: TextStyle(
                  color: isDark ? AppColors.textInverse : AppColorsLight.textSecondary,
                  fontSize: responsive.fontSize(15),
                ),
                textAlign: TextAlign.start,
                maxLines: 2,
              ),
              SizedBox(height: responsive.hp(3)),

              // PIN Input
              Pinput(
                controller: _pinController,
                focusNode: _pinFocusNode,
                length: 4,
                obscureText: true,
                obscuringCharacter: '●',
                defaultPinTheme: PinTheme(
                  width: responsive.wp(18),
                  height: responsive.hp(7),
                  textStyle: TextStyle(
                    fontSize: responsive.fontSize(24),
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.overlay, AppColors.containerLight]
                          : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    border: Border.all(
                      color: isDark
                          ? AppColors.white.withOpacity(0.2)
                          : AppColorsLight.textSecondary.withOpacity(0.2),
                    ),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: responsive.wp(18),
                  height: responsive.hp(7),
                  textStyle: TextStyle(
                    fontSize: responsive.fontSize(24),
                    color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.containerDark, AppColors.containerLight]
                          : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    border: Border.all(
                      color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
                      width: 2,
                    ),
                  ),
                ),
              ),

              // Error message
              if (errorMessage != null) ...[
                SizedBox(height: responsive.hp(1)),
                AppText.custom(
                  errorMessage!,
                  style: TextStyle(
                    color: AppColors.red500,
                    fontSize: responsive.fontSize(12),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: responsive.hp(3)),

              // Dialog Button Row with Go Back and Confirm buttons
              DialogButtonRow(
              cancelText: 'Go Back',
              confirmText: 'Confirm',
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: _validateAndSubmit,
              cancelIcon: SvgPicture.asset(
                AppIcons.arrowBackIc,
                width: responsive.iconSizeMedium,
                height: responsive.iconSizeMedium,
                colorFilter: ColorFilter.mode(
                  isDark ? AppColors.white : AppColorsLight.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
              cancelGradientColors: isDark
                  ? [AppColors.containerDark, AppColors.containerLight]
                  : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
              confirmGradientColors: widget.confirmGradientColors ?? (isDark
                  ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                  : [AppColorsLight.splaceSecondary1, AppColorsLight.splaceSecondary2]),
              confirmTextColor: widget.confirmTextColor,
              buttonSpacing: responsive.wp(3),
              buttonHeight: responsive.hp(6),

                              ),
            ],
          ),
        ),
      ),
    );
  }
}
