import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
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

/// Dialog for verifying OTP sent to NEW mobile number
class NewNumberOtpDialog {
  static Future<String?> show({
    required BuildContext context,
    required String newPhoneNumber,
    String title = 'Verify New Number',
    String? subtitle,
    String? confirmButtonText,
    String? warningText, // ✅ Custom warning text
    Color? titleColor,
    Color? subtitleColor,
    List<Color>? confirmGradientColors,
    Color? confirmTextColor,
  }) async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _NewNumberOtpDialogContent(
        newPhoneNumber: newPhoneNumber,
        title: title,
        subtitle: subtitle,
        confirmButtonText: confirmButtonText,
        warningText: warningText,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        confirmGradientColors: confirmGradientColors,
        confirmTextColor: confirmTextColor,
      ),
    );
  }
}

class _NewNumberOtpDialogContent extends StatefulWidget {
  final String newPhoneNumber;
  final String title;
  final String? subtitle;
  final String? confirmButtonText;
  final String? warningText;
  final Color? titleColor;
  final Color? subtitleColor;
  final List<Color>? confirmGradientColors;
  final Color? confirmTextColor;

  const _NewNumberOtpDialogContent({
    required this.newPhoneNumber,
    required this.title,
    this.subtitle,
    this.confirmButtonText,
    this.warningText,
    this.titleColor,
    this.subtitleColor,
    this.confirmGradientColors,
    this.confirmTextColor,
  });

  @override
  State<_NewNumberOtpDialogContent> createState() =>
      _NewNumberOtpDialogContentState();
}

class _NewNumberOtpDialogContentState
    extends State<_NewNumberOtpDialogContent> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? errorMessage;

  // OTP timer
  int _resendTimer = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    // Auto focus on OTP field immediately to keep keyboard open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
    // Start resend timer
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 30;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _resendTimer--;
        if (_resendTimer <= 0) {
          _canResend = true;
        }
      });

      return _resendTimer > 0;
    });
  }

  void _resendOtp() {
    if (_canResend) {
      debugPrint('🔄 Resending OTP to new number...');
      _startResendTimer();
      // TODO: Call API to resend OTP
    }
  }

  void _validateAndSubmit() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      setState(() {
        errorMessage = 'Please enter OTP';
      });
      return;
    }
    if (otp.length != 4) {
      setState(() {
        errorMessage = 'OTP must be 4 digits';
      });
      return;
    }

    // Return OTP to caller
    Navigator.of(context).pop(otp);
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
                  widget.subtitle ??
                      'Enter OTP sent to\n${widget.newPhoneNumber}',
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

                // OTP Input
                Pinput(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
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
                            ? AppColors.white
                            : AppColorsLight.splaceSecondary1,
                        width: 2,
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

                // Resend OTP section
                SizedBox(height: responsive.hp(2)),
                GestureDetector(
                  onTap: _canResend ? _resendOtp : null,
                  child: AppText.custom(
                    _canResend
                        ? 'Resend OTP'
                        : 'Resend OTP in $_resendTimer seconds',
                    style: TextStyle(
                      color: _canResend
                          ? (isDark
                              ? AppColors.splaceSecondary2
                              : AppColorsLight.splaceSecondary1)
                          : (isDark
                              ? AppColors.textDisabled
                              : AppColorsLight.textSecondary),
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight.w600,
                      decoration: _canResend ? TextDecoration.underline : null,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),

                // ✅ Warning Container (Only show if warningText is provided)
                if (widget.warningText != null) ...[
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
                    textAlign: TextAlign.center,
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
