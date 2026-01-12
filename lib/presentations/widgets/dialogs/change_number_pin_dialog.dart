import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../controllers/change_number_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../buttons/dialog_botton.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/utils/dialog_transition_helper.dart';
import 'mobile_number_dialog.dart';

/// PIN Verification Dialog specifically for Change Number feature
/// Handles PIN -> OTP (current) -> Mobile Number entry flow with API integration
class ChangeNumberPinDialog {
  static Future<Map<String, String>?> show({
    required BuildContext context,
    required ChangeNumberController controller,
    String? maskedPhoneNumber,
  }) async {
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ChangeNumberPinDialogContent(
        controller: controller,
        maskedPhoneNumber: maskedPhoneNumber,
      ),
    );
  }
}

class _ChangeNumberPinDialogContent extends StatefulWidget {
  final ChangeNumberController controller;
  final String? maskedPhoneNumber;

  const _ChangeNumberPinDialogContent({
    required this.controller,
    this.maskedPhoneNumber,
  });

  @override
  State<_ChangeNumberPinDialogContent> createState() =>
      _ChangeNumberPinDialogContentState();
}

class _ChangeNumberPinDialogContentState
    extends State<_ChangeNumberPinDialogContent> {
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

  @override
  void initState() {
    super.initState();
    debugPrint('🔍 Dialog received masked number: ${widget.maskedPhoneNumber}');
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

  void _resendOtp() {
    if (_canResend && _enteredPin != null) {
      debugPrint('🔄 Resending OTP...');
      _sendOtpToCurrentNumber(_enteredPin!);
      _startResendTimer();
    }
  }

  /// Step 1: Send OTP to current number (API 1)
  Future<void> _sendOtpToCurrentNumber(String pin) async {
    final success = await widget.controller.sendOtpToCurrentNumber(pin);
    if (success) {
      // Move to OTP step
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
      setState(() {
        errorMessage = widget.controller.errorMessage.value;
      });
    }
  }

  /// Step 2: Verify current OTP (API 2)
  Future<void> _verifyCurrentOtp(String otp) async {
    final success = await widget.controller.verifyCurrentNumberOtp(otp);
    if (success) {
      // Wait for keyboard to close before showing next dialog
      await DialogTransitionHelper.waitForDialogTransition();

      if (!mounted) return;

      // OTP verified, now show mobile number dialog
      final mobileNumber = await MobileNumberDialog.show(
        context: context,
        title: 'Enter New Mobile Number',
        subtitle: 'Enter your new 10-digit mobile number',
        confirmButtonText: 'Confirm',
      );

      if (mobileNumber != null) {
        // Return PIN, OTP, and new mobile number
        Navigator.of(context).pop({
          'pin': _enteredPin!,
          'otp': otp,
          'mobile': mobileNumber,
        });
      }
    } else {
      setState(() {
        errorMessage = widget.controller.errorMessage.value;
      });
    }
  }

  Future<void> _validateAndSubmit() async {
    if (!_isOtpStep) {
      // Step 1: Validate and send PIN
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

      // Call API 1: Send OTP to current number
      await _sendOtpToCurrentNumber(pin);
    } else {
      // Step 2: Validate and verify OTP
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

      // Call API 2: Verify current OTP
      await _verifyCurrentOtp(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = AdvancedResponsiveHelper(context);

    return Obx(() {
      final isLoading = widget.controller.isLoading.value;

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
                    _isOtpStep ? 'Enter OTP' : 'Enter Security Pin',
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
                    _isOtpStep
                        ? 'Enter OTP received on your phone\n${widget.maskedPhoneNumber ?? ""}'
                        : 'Enter your 4-digit pin to get otp on\n${widget.maskedPhoneNumber ?? ""}',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textInverse
                          : AppColorsLight.textSecondary,
                      fontSize: responsive.fontSize(15),
                    ),
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
                    enabled: !isLoading,
                    defaultPinTheme: PinTheme(
                      width: responsive.wp(18),
                      height: responsive.hp(7),
                      textStyle: TextStyle(
                        fontSize: responsive.fontSize(24),
                        color:
                            isDark ? AppColors.white : AppColorsLight.textPrimary,
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
                        color:
                            isDark ? AppColors.white : AppColorsLight.textPrimary,
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

                  // Resend OTP section (only show in OTP step)
                  if (_isOtpStep) ...[
                    SizedBox(height: responsive.hp(2)),
                    GestureDetector(
                      onTap: _canResend && !isLoading ? _resendOtp : null,
                      child: AppText.custom(
                        _canResend
                            ? 'Resend OTP'
                            : 'Resend OTP in $_resendTimer seconds',
                        style: TextStyle(
                          color: _canResend && !isLoading
                              ? (isDark
                                  ? AppColors.splaceSecondary2
                                  : AppColorsLight.splaceSecondary1)
                              : (isDark
                                  ? AppColors.textDisabled
                                  : AppColorsLight.textSecondary),
                          fontSize: responsive.fontSize(14),
                          fontWeight: FontWeight.w600,
                          decoration:
                              _canResend && !isLoading ? TextDecoration.underline : null,
                        ),
                        textAlign: TextAlign.start,
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

                  // Dialog Button Row
                  DialogButtonRow(
                    cancelText: 'Go Back',
                    confirmText: _isOtpStep ? 'Confirm' : 'Send OTP',
                    isLoading: isLoading,
                    onCancel: isLoading ? null : () => Navigator.of(context).pop(),
                    onConfirm: isLoading ? null : _validateAndSubmit,
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
                    confirmGradientColors: isDark
                        ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                        : [
                            AppColorsLight.splaceSecondary1,
                            AppColorsLight.splaceSecondary2
                          ],
                    confirmTextColor: AppColors.white,
                    buttonSpacing: responsive.wp(3),
                    buttonHeight: responsive.hp(6),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
