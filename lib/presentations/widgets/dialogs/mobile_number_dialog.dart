import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/padding_navigation.dart';

class MobileNumberDialog {
  static Future<String?> show({
    required BuildContext context,
    String title = 'Enter Mobile Number',
    String subtitle = 'Enter your 10-digit mobile number',
    String? initialNumber,
    String? confirmButtonText,
    bool showWarning = false, // ✅ Show warning container
    String? warningText, // ✅ Custom warning text (different for each screen)
    Color? titleColor,
    Color? subtitleColor,
    List<Color>? confirmGradientColors,
    Color? confirmTextColor,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _MobileNumberDialogContent(
        title: title,
        subtitle: subtitle,
        initialNumber: initialNumber,
        confirmButtonText: confirmButtonText,
        showWarning: showWarning,
        warningText: warningText,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        confirmGradientColors: confirmGradientColors,
        confirmTextColor: confirmTextColor,
      ),
    );
  }
}

class _MobileNumberDialogContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? initialNumber;
  final String? confirmButtonText;
  final bool showWarning;
  final String? warningText;
  final Color? titleColor;
  final Color? subtitleColor;
  final List<Color>? confirmGradientColors;
  final Color? confirmTextColor;

  const _MobileNumberDialogContent({
    required this.title,
    required this.subtitle,
    this.initialNumber,
    this.confirmButtonText,
    this.showWarning = false,
    this.warningText,
    this.titleColor,
    this.subtitleColor,
    this.confirmGradientColors,
    this.confirmTextColor,
  });

  @override
  State<_MobileNumberDialogContent> createState() =>
      _MobileNumberDialogContentState();
}

class _MobileNumberDialogContentState
    extends State<_MobileNumberDialogContent> {
  final TextEditingController _mobileController = TextEditingController();
  final FocusNode _mobileFocusNode = FocusNode();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialNumber != null) {
      _mobileController.text = widget.initialNumber!;
    }
    // Auto focus on mobile field
    Future.delayed(Duration(milliseconds: 300), () {
      _mobileFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _mobileFocusNode.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty) {
      setState(() {
        errorMessage = 'Please enter mobile number';
      });
      return;
    }

    if (mobile.length != 10) {
      setState(() {
        errorMessage = 'Mobile number must be 10 digits';
      });
      return;
    }

    if (!RegExp(r'^[6-9][0-9]{9}$').hasMatch(mobile)) {
      setState(() {
        errorMessage = 'Please enter a valid mobile number';
      });
      return;
    }

    // Return the mobile number
    Navigator.of(context).pop(mobile);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: responsive.wp(9),
        vertical: responsive.hp(2),
      ),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                AppText.custom(
                  widget.title,
                  style: TextStyle(
                    color: widget.titleColor ??
                        (isDark ? AppColors.white : AppColorsLight.textPrimary),
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
                    color: widget.subtitleColor ??
                        (isDark
                            ? AppColors.textInverse
                            : AppColorsLight.textSecondary),
                    fontSize: responsive.fontSize(15),
                  ),
                  textAlign: TextAlign.start,
                  maxLines: 3,
                ),
                SizedBox(height: responsive.hp(3)),

                // Mobile Number Input
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.overlay, AppColors.containerLight]
                          : [
                              AppColorsLight.gradientColor1,
                              AppColorsLight.gradientColor2
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.circular(responsive.borderRadiusSmall),
                    border: Border.all(
                      color: isDark
                          ? AppColors.white.withOpacity(0.2)
                          : AppColorsLight.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: TextField(

                    controller: _mobileController,
                    focusNode: _mobileFocusNode,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    cursorColor: AppColors.white,
                    style: TextStyle(
                      fontSize: responsive.fontSize(18),
                      color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.black : AppColorsLight.white,
                      hintText: '',
                      hintStyle: TextStyle(
                        color: isDark
                            ? AppColors.textDisabled
                            : AppColorsLight.textSecondary,
                        fontSize: responsive.fontSize(18),
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.5,
                      ),
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: responsive.wp(4),
                        vertical: responsive.hp(2),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(responsive.borderRadiusSmall),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.white
                              : AppColorsLight.splaceSecondary1,
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (errorMessage != null) {
                        setState(() {
                          errorMessage = null;
                        });
                      }
                    },
                  ),
                ),

                // ✅ Warning Container (Conditional)
                if (widget.showWarning && widget.warningText != null) ...[
                  SizedBox(height: responsive.hp(2)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.hp(1.5),
                      horizontal: responsive.wp(4),
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.red800,
                          AppColors.red500,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    ),
                    child: AppText.custom(
                      widget.warningText!,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: responsive.fontSize(13),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.start,
                      maxLines: 4,
                    ),
                  ),
                ],

                // Error message
                if (errorMessage != null) ...[
                  SizedBox(height: responsive.hp(1)),
                  AppText.custom(
                    errorMessage!,
                    style: TextStyle(
                      color: AppColors.red500,
                      fontSize: responsive.fontSize(12),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],

                SizedBox(height: responsive.hp(3)),

                // Dialog Button Row with Go Back and Confirm buttons
                DialogButtonRow(
                  cancelText: 'Go Back',
                  confirmText: widget.confirmButtonText ?? 'Confirm',
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
                      : [
                          AppColorsLight.gradientColor1,
                          AppColorsLight.gradientColor2
                        ],
                  confirmGradientColors: widget.confirmGradientColors ??
                      (isDark
                          ? [
                              AppColors.splaceSecondary1,
                              AppColors.splaceSecondary2
                            ]
                          : [
                              AppColorsLight.splaceSecondary1,
                              AppColorsLight.splaceSecondary2
                            ]),
                  confirmTextColor: widget.confirmTextColor ?? AppColors.white,
                  buttonSpacing: responsive.wp(3),
                  buttonHeight: responsive.hp(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
