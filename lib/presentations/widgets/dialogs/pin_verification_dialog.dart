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
import 'mobile_number_dialog.dart';

class PinVerificationDialog {
  static Future<Map<String, String>?> show({
    required BuildContext context,
    String title = 'Enter Security Pin',
    String subtitle = 'Enter your 4-digit pin to proceed',
    String? maskedPhoneNumber,
    bool requireOtp = false,
    String? confirmButtonText,
    bool showWarning = false, // ✅ Show warning container
    String? warningText, // ✅ Custom warning text
    Color? titleColor,
    Color? subtitleColor,
    List<Color>? confirmGradientColors,
    Color? confirmTextColor,
    Future<bool> Function()? onResendOtp, // ✅ Callback for resending OTP
  }) async {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _PinVerificationDialogContent(
        title: title,
        subtitle: subtitle,
        maskedPhoneNumber: maskedPhoneNumber,
        requireOtp: requireOtp,
        confirmButtonText: confirmButtonText,
        showWarning: showWarning,
        warningText: warningText,
        titleColor: titleColor,
        subtitleColor: subtitleColor,
        confirmGradientColors: confirmGradientColors,
        confirmTextColor: confirmTextColor,
        onResendOtp: onResendOtp,
      ),
    );
  }
}

class _PinVerificationDialogContent extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? maskedPhoneNumber;
  final bool requireOtp;
  final String? confirmButtonText;
  final bool showWarning;
  final String? warningText;
  final Color? titleColor;
  final Color? subtitleColor;
  final List<Color>? confirmGradientColors;
  final Color? confirmTextColor;
  final Future<bool> Function()? onResendOtp; // ✅ Callback for resending OTP

  const _PinVerificationDialogContent({
    required this.title,
    required this.subtitle,
    this.maskedPhoneNumber,
    this.requireOtp = false,
    this.confirmButtonText,
    this.showWarning = false,
    this.warningText,
    this.titleColor,
    this.subtitleColor,
    this.confirmGradientColors,
    this.confirmTextColor,
    this.onResendOtp,
  });

  @override
  State<_PinVerificationDialogContent> createState() =>
      _PinVerificationDialogContentState();
}

class _PinVerificationDialogContentState
    extends State<_PinVerificationDialogContent> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  final FocusNode _otpFocusNode = FocusNode();
  String? errorMessage;

  // Two-step state management
  bool _isOtpStep = false;
  String? _enteredPin;

  // OTP timer
  int _resendTimer = 30;
  bool _canResend = false;
  bool _isResending = false; // ✅ Loading state for resend

  @override
  void initState() {
    super.initState();
    // Auto focus on PIN field immediately to keep keyboard open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pinFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _otpController.dispose();
    _pinFocusNode.dispose();
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

  Future<void> _resendOtp() async {
    if (_canResend && !_isResending) {
      debugPrint('🔄 Resending OTP...');

      // ✅ Call API to resend OTP if callback is provided
      if (widget.onResendOtp != null) {
        setState(() {
          _isResending = true;
        });

        try {
          final success = await widget.onResendOtp!();
          if (success) {
            debugPrint('✅ OTP resent successfully');
            _startResendTimer();
          } else {
            debugPrint('❌ Failed to resend OTP');
            setState(() {
              errorMessage = 'Failed to resend OTP. Please try again.';
            });
          }
        } catch (e) {
          debugPrint('❌ Error resending OTP: $e');
          setState(() {
            errorMessage = 'Failed to resend OTP. Please try again.';
          });
        } finally {
          if (mounted) {
            setState(() {
              _isResending = false;
            });
          }
        }
      } else {
        // Fallback: Just restart timer if no callback provided
        _startResendTimer();
      }
    }
  }

  Future<void> _validateAndSubmit() async {
    if (!_isOtpStep) {
      // Step 1: Validate PIN
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

      // If requireOtp is true, move to OTP step
      if (widget.requireOtp) {
        setState(() {
          _enteredPin = pin;
          _isOtpStep = true;
          errorMessage = null;
          _pinController.clear();
        });
        _startResendTimer();
        // Focus OTP field immediately to keep keyboard open
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _otpFocusNode.requestFocus();
        });
      } else {
        // No OTP required, return PIN only
        Navigator.of(context).pop({'pin': pin});
      }
    } else {
      // Step 2: Validate OTP
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

      // OTP validated - now show mobile number dialog
      final mobileNumber = await MobileNumberDialog.show(
        context: context,
        title: 'New master mobile number',
        subtitle: 'Enter your new 10-digit mobile number',
        confirmButtonText: 'Next',
        showWarning: true, // ✅ Always show warning in mobile number dialog
        warningText: widget.warningText, // ✅ Pass warning text
      );

      // If mobile number is entered, return all data
      if (mobileNumber != null) {
        Navigator.of(context).pop({
          'pin': _enteredPin!,
          'otp': otp,
          'mobile': mobileNumber,
        });
      }
    }
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
              AppText.searchbar2(
                _isOtpStep ? 'Enter OTP' : widget.title,
                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              SizedBox(height: responsive.hp(1)),

              // Subtitle
              AppText.headlineLarge(
                _isOtpStep
                    ? 'Enter OTP received on your phone\n${widget.maskedPhoneNumber ?? ""}'
                    : '${widget.subtitle}${widget.maskedPhoneNumber != null ? '\n${widget.maskedPhoneNumber}' : ''}',
                color: isDark ? AppColors.textInverse : AppColorsLight.textSecondary,
                textAlign: TextAlign.start,
                maxLines: 3,
              ),
              SizedBox(height: responsive.hp(3)),

              // PIN/OTP Input
              Pinput(
                controller: _isOtpStep ? _otpController : _pinController,
                focusNode: _isOtpStep ? _otpFocusNode : _pinFocusNode,
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
                          ? [AppColors.black, AppColors.black]
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

              // Resend OTP section (only show in OTP step)
              if (_isOtpStep) ...[
                SizedBox(height: responsive.hp(2)),
                GestureDetector(
                  onTap: (_canResend && !_isResending) ? _resendOtp : null,
                  child: _isResending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: responsive.iconSizeSmall,
                              height: responsive.iconSizeSmall,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isDark
                                    ? AppColors.splaceSecondary2
                                    : AppColorsLight.splaceSecondary1,
                              ),
                            ),
                            SizedBox(width: responsive.wp(2)),
                            AppText.headlineLarge1(
                              'Sending...',
                              color: isDark
                                  ? AppColors.textDisabled
                                  : AppColorsLight.textSecondary,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        )
                      : AppText.headlineLarge1(
                          _canResend
                              ? 'Resend OTP'
                              : 'Resend OTP in $_resendTimer seconds',
                          color: _canResend
                              ? (isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary1)
                              : (isDark ? AppColors.textDisabled : AppColorsLight.textSecondary),
                          fontWeight: FontWeight.w600,
                          decoration: _canResend ? TextDecoration.underline : null,
                          textAlign: TextAlign.start,
                        ),
                ),
              ],

              // ✅ Warning Container (Show when showWarning is true)
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
                  child: AppText.headlineMedium(
                    widget.warningText!,
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.start,
                    maxLines: 10,
                  ),
                ),
              ],

              // Error message
              if (errorMessage != null) ...[
                SizedBox(height: responsive.hp(1)),
                AppText.bodyLarge(
                  errorMessage!,
                  color: AppColors.red500,
                  textAlign: TextAlign.center,
                ),
              ],

              SizedBox(height: responsive.hp(3)),

              // Dialog Button Row with Go Back and Confirm buttons
              DialogButtonRow(
              cancelText: 'Go Back',
              confirmText: _isOtpStep
                  ? 'Confirm'
                  : (widget.confirmButtonText ?? 'Confirm'),
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
