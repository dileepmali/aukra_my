import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_svg/svg.dart';

import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_images.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/themes/app_text.dart';
import '../../../buttons/app_button.dart';
import '../../../controllers/shop_detail_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/untils/phone_number_formatter.dart';

/// Desktop layout for Shop Detail Screen
/// Two dialogs: First for merchant details, Second for phone verification
class ShopDetailDesktopContent extends StatefulWidget {
  final ShopDetailController controller;
  final TextEditingController nameController;
  final TextEditingController shopNameController;
  final TextEditingController locationController;
  final TextEditingController ownerPhoneController;
  final TextEditingController otpController;
  final FocusNode nameFocusNode;
  final FocusNode shopNameFocusNode;
  final FocusNode locationFocusNode;
  final FocusNode ownerPhoneFocusNode;
  final FocusNode otpFocusNode;
  final VoidCallback onSendOtp;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final Function(String) onOwnerPhoneChanged;

  const ShopDetailDesktopContent({
    Key? key,
    required this.controller,
    required this.nameController,
    required this.shopNameController,
    required this.locationController,
    required this.ownerPhoneController,
    required this.otpController,
    required this.nameFocusNode,
    required this.shopNameFocusNode,
    required this.locationFocusNode,
    required this.ownerPhoneFocusNode,
    required this.otpFocusNode,
    required this.onSendOtp,
    required this.onSubmit,
    required this.onBack,
    required this.onOwnerPhoneChanged,
  }) : super(key: key);

  @override
  State<ShopDetailDesktopContent> createState() => _ShopDetailDesktopContentState();
}

class _ShopDetailDesktopContentState extends State<ShopDetailDesktopContent> {
  // Track which dialog to show: 0 = first dialog, 1 = second dialog
  int _currentDialog = 0;

  void _goToSecondDialog() {
    // Validate first dialog fields before proceeding
    if (widget.nameController.text.trim().isEmpty) {
      _showValidationError('Please enter merchant name');
      return;
    }
    if (widget.shopNameController.text.trim().isEmpty) {
      _showValidationError('Please enter business/shop name');
      return;
    }
    if (widget.locationController.text.trim().isEmpty) {
      _showValidationError('Please enter address');
      return;
    }

    setState(() {
      _currentDialog = 1;
    });
  }

  void _goBackToFirstDialog() {
    setState(() {
      _currentDialog = 0;
    });
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.containerLight ?? Colors.black,
                    AppColors.containerLight ?? Colors.black,
                    AppColors.containerDark ?? Colors.grey.shade800,
                    AppColors.containerDark ?? Colors.grey.shade800,
                  ]
                : [
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                  ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(_currentDialog == 0 ? -0.1 : 0.1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _currentDialog == 0
                ? _buildFirstDialog(responsive, isDark)
                : _buildSecondDialog(responsive, isDark),
          ),
        ),
      ),
    );
  }

  /// First Dialog: Merchant Name, Business Name, Address
  Widget _buildFirstDialog(AdvancedResponsiveHelper responsive, bool isDark) {
    return ConstrainedBox(
      key: ValueKey('first_dialog'),
      constraints: BoxConstraints(
        minWidth: responsive.wp(28),
        maxWidth: responsive.wp(32),
        minHeight: responsive.hp(55),
        maxHeight: responsive.hp(65),
      ),
      child: Container(
        padding: EdgeInsets.all(responsive.wp(1.5)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColorsLight.white, AppColorsLight.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button Row
            GestureDetector(
              onTap: widget.onBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.arrowBackIc,
                    height: responsive.iconSizeMedium,
                    width: responsive.iconSizeMedium,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.black : AppColorsLight.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: responsive.spaceXS),
                  AppText.bodyLarge(
                    'Go back',
                    color: isDark ? AppColors.black : AppColorsLight.textPrimary,
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.spaceLG),

            // Logo section
            _buildLogoSection(responsive),

            SizedBox(height: responsive.spaceMD),

            // Title
            AppText.headlineSmall(
              AppStrings.getLocalizedString(context, (localizations) => localizations.addBusinessShopDetails),
              color: isDark ? AppColors.black : AppColorsLight.black,
              maxLines: 2,
              minFontSize: 8,
              letterSpacing: 1.1,
            ),

            SizedBox(height: responsive.spaceMD),

            // Form Fields
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Merchant Name Field
                      _buildInputField(
                        responsive,
                        isDark,
                        context,
                        label: AppStrings.getLocalizedString(context, (localizations) => localizations.name),
                        controller: widget.nameController,
                        focusNode: widget.nameFocusNode,
                        nextFocusNode: widget.shopNameFocusNode,
                      ),

                      SizedBox(height: responsive.spaceSM),

                      // Business/Shop Name Field
                      _buildInputField(
                        responsive,
                        isDark,
                        context,
                        label: AppStrings.getLocalizedString(context, (localizations) => localizations.businessShopName),
                        controller: widget.shopNameController,
                        focusNode: widget.shopNameFocusNode,
                        nextFocusNode: widget.locationFocusNode,
                      ),

                      SizedBox(height: responsive.spaceSM),

                      // Location/Address Field
                      _buildInputField(
                        responsive,
                        isDark,
                        context,
                        label: AppStrings.getLocalizedString(context, (localizations) => localizations.locationAddress),
                        controller: widget.locationController,
                        focusNode: widget.locationFocusNode,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: responsive.spaceMD),

            // Continue Button
            AppButton(
              width: double.infinity,
              height: responsive.hp(7),
              gradientColors: [
                AppColors.splaceSecondary1,
                AppColors.splaceSecondary2,
              ],
              enableSweepGradient: true,
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: responsive.wp(1),
                  offset: Offset(0, responsive.hp(0.3)),
                ),
              ],
              onPressed: _goToSecondDialog,
              child: Center(
                child: AppText.headlineSmall(
                  AppStrings.getLocalizedString(context, (localizations) => localizations.continueText ?? 'Continue'),
                  color: Colors.white,
                  maxLines: 1,
                  minFontSize: 12,
                  letterSpacing: 1.1,
                  textAlign: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Second Dialog: Registered Number, Owner Number, OTP
  Widget _buildSecondDialog(AdvancedResponsiveHelper responsive, bool isDark) {
    return ConstrainedBox(
      key: ValueKey('second_dialog'),
      constraints: BoxConstraints(
        minWidth: responsive.wp(28),
        maxWidth: responsive.wp(32),
        minHeight: responsive.hp(55),
        maxHeight: responsive.hp(70),
      ),
      child: Container(
        padding: EdgeInsets.all(responsive.wp(1.5)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColorsLight.white, AppColorsLight.white],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back Button Row (to first dialog)
            GestureDetector(
              onTap: _goBackToFirstDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.arrowBackIc,
                    height: responsive.iconSizeMedium,
                    width: responsive.iconSizeMedium,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.black : AppColorsLight.textPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: responsive.spaceXS),
                  AppText.bodyLarge(
                    'Go back',
                    color: isDark ? AppColors.black : AppColorsLight.textPrimary,
                  ),
                ],
              ),
            ),
            SizedBox(height: responsive.spaceLG),

            // Logo section
            _buildLogoSection(responsive),

            SizedBox(height: responsive.spaceMD),

            // Title
            AppText.headlineSmall(
              'Verify Mobile Numbers',
              color: isDark ? AppColors.black : AppColorsLight.black,
              maxLines: 2,
              minFontSize: 8,
              letterSpacing: 1.1,
            ),

            SizedBox(height: responsive.spaceMD),

            // Form Fields
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Registered Mobile Number (Read-only)
                      _buildReadOnlyField(
                        responsive,
                        isDark,
                        context,
                        label: AppStrings.getLocalizedString(context, (localizations) => localizations.registeredMobileNumber),
                      ),

                      SizedBox(height: responsive.spaceSM),

                      // Owner Phone with Send OTP button
                      _buildOwnerPhoneField(responsive, isDark, context),

                      SizedBox(height: responsive.spaceSM),

                      // OTP Section
                      Obx(() {
                        return widget.controller.isOtpSent.value
                            ? _buildOtpSection(responsive, isDark, context)
                            : SizedBox.shrink();
                      }),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: responsive.spaceMD),

            // Submit Button
            _buildSubmitButton(responsive, isDark, context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(AdvancedResponsiveHelper responsive) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          AppImages.appLogoIm,
          height: responsive.iconSizeExtraLarge,
          fit: BoxFit.cover,
        ),
        SizedBox(width: responsive.spacing(4)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppIcons.aukraIc,
                height: responsive.hp(1.8),
              ),
              SizedBox(height: responsive.space2XS),
              AppText.bodyMedium(
                'Infinity Income Advance Income',
                color: AppColors.splaceSecondary1,
                maxLines: 1,
                minFontSize: 7,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyLarge1(
          label,
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 10,
        ),
        SizedBox(height: responsive.space2XS),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          style: AppFonts.bodyLarge(
            color: isDark ? AppColors.black : AppColorsLight.textPrimary,
            fontWeight: AppFonts.regular,
          ),
          textInputAction: nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
          onSubmitted: (value) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? AppColors.scaffoldBackground
                : AppColorsLight.scaffoldBackground.withOpacity(0.7),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.wp(1),
              vertical: responsive.hp(1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              borderSide: BorderSide(
                color: isDark ? AppColors.handleBarColor : AppColorsLight.border,
                width: 1.0,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              borderSide: BorderSide(
                color: isDark ? AppColors.handleBarColor : AppColorsLight.border,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              borderSide: BorderSide(
                color: isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary2,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context, {
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyLarge1(
          label,
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 10,
        ),
        SizedBox(height: responsive.space2XS),
        Obx(() => TextField(
          controller: TextEditingController(
            text: _formatPhoneNumber(widget.controller.registeredPhone.value),
          ),
          readOnly: true,
          enabled: false,
          style: AppFonts.bodyLarge(
            color: isDark ? Colors.grey[500] : AppColorsLight.textSecondary,
            fontWeight: AppFonts.regular,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.black : AppColorsLight.scaffoldBackground.withOpacity(0.7),
            contentPadding: EdgeInsets.symmetric(
              horizontal: responsive.wp(1),
              vertical: responsive.hp(1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              borderSide: BorderSide(
                color: isDark ? AppColors.handleBarColor : AppColorsLight.border,
                width: 1.0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              borderSide: BorderSide(
                color: isDark ? AppColors.handleBarColor : AppColorsLight.border,
                width: 1.0,
              ),
            ),
          ),
        )),
      ],
    );
  }

  String _formatPhoneNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return '+91 ${digits.substring(2, 7)} ${digits.substring(7)}';
    } else if (digits.length == 10) {
      return '+91 ${digits.substring(0, 5)} ${digits.substring(5)}';
    }
    return phone;
  }

  Widget _buildOwnerPhoneField(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyLarge1(
          AppStrings.getLocalizedString(context, (localizations) => localizations.ownerMasterMobileNumber),
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 10,
        ),
        SizedBox(height: responsive.space2XS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                height: responsive.hp(6.5),
                child: TextField(
                  controller: widget.ownerPhoneController,
                  focusNode: widget.ownerPhoneFocusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: AppFonts.bodyLarge(
                    color: isDark ? AppColors.black : AppColorsLight.textPrimary,
                    fontWeight: AppFonts.regular,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneNumberFormatter(),
                  ],
                  onChanged: widget.onOwnerPhoneChanged,
                  decoration: InputDecoration(
                    hintText: '+91 XXXXXXXXXX',
                    hintStyle: AppFonts.bodyLarge(
                      color: isDark ? Colors.grey[500] : AppColorsLight.textSecondary,
                      fontWeight: AppFonts.light,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.scaffoldBackground
                        : AppColorsLight.scaffoldBackground.withOpacity(0.7),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: responsive.wp(1),
                      vertical: responsive.hp(1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.handleBarColor : AppColorsLight.border,
                        width: 1.0,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.handleBarColor : AppColorsLight.border,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary2,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: responsive.spaceSM),
            Expanded(
              flex: 4,
              child: SizedBox(
                height: responsive.hp(6.5),
                child: Obx(() {
                  final rawOwner = widget.ownerPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  String rawRegistered = widget.controller.registeredPhone.value.replaceAll(RegExp(r'[^0-9]'), '');
                  if (rawRegistered.length == 12 && rawRegistered.startsWith('91')) {
                    rawRegistered = rawRegistered.substring(2);
                  }
                  final isDifferent = rawOwner.isNotEmpty && rawOwner != rawRegistered && rawOwner.length == 10;

                  return AppButton(
                    height: responsive.hp(6.5),
                    gradientColors: [
                      isDark ? AppColors.containerLight : AppColorsLight.gradientColor1,
                      isDark ? AppColors.containerDark : AppColorsLight.gradientColor2,
                    ],
                    enableSweepGradient: false,
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    onPressed: (widget.controller.isSendingOtp.value || !isDifferent) ? null : widget.onSendOtp,
                    child: widget.controller.isSendingOtp.value
                        ? Center(
                            child: SizedBox(
                              height: responsive.wp(2),
                              width: responsive.wp(2),
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : Center(
                            child: AppText.bodyLarge(
                              AppStrings.getLocalizedString(context, (localizations) => localizations.sendOtp),
                              color: isDifferent
                                  ? Colors.white
                                  : (isDark ? Colors.grey[600] : AppColorsLight.textSecondary),
                              maxLines: 1,
                              minFontSize: 10,
                            ),
                          ),
                  );
                }),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpSection(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context,
  ) {
    final defaultPinTheme = PinTheme(
      width: responsive.wp(4.5),
      height: responsive.hp(6.5),
      textStyle: AppFonts.headlineMedium(
        color: isDark ? Colors.white : AppColorsLight.textPrimary,
        fontWeight: AppFonts.regular,
      ),
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                colors: [AppColors.black, AppColors.black],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        border: Border.all(
          color: isDark ? AppColors.borderAccent : AppColorsLight.splaceSecondary1,
          width: 1.5,
        ),
      ),
    );

    // Auto-fill OTP if available
    if (widget.controller.receivedOtp.value.isNotEmpty &&
        widget.controller.receivedOtp.value.length == 4 &&
        widget.otpController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.otpController.text = widget.controller.receivedOtp.value;
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bodyLarge(
          AppStrings.getLocalizedString(context, (localizations) => localizations.enterOtp),
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 10,
        ),
        SizedBox(height: responsive.space2XS),
        Obx(() => Opacity(
          opacity: widget.controller.isOtpExpired.value ? 0.5 : 1.0,
          child: AbsorbPointer(
            absorbing: widget.controller.isOtpExpired.value,
            child: Pinput(
              controller: widget.otpController,
              focusNode: widget.otpFocusNode,
              length: 4,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration!.copyWith(
                  border: Border.all(
                    color: AppColors.white,
                    width: 0.5,
                  ),
                ),
              ),
              submittedPinTheme: defaultPinTheme,
              showCursor: !widget.controller.isOtpExpired.value,
              keyboardType: TextInputType.number,
              onCompleted: (code) {
                widget.controller.verifyOwnerOtp(code);
              },
            ),
          ),
        )),
        SizedBox(height: responsive.space2XS),
        Obx(() => widget.controller.isOtpExpired.value
            ? Padding(
                padding: EdgeInsets.only(bottom: responsive.space2XS),
                child: AppText.bodyMedium(
                  'OTP expired. Please request a new OTP.',
                  color: Colors.red,
                  maxLines: 2,
                  minFontSize: 9,
                ),
              )
            : SizedBox.shrink()),
        Obx(() => Row(
          children: [
            widget.controller.isResendAvailable.value
                ? GestureDetector(
                    onTap: () async {
                      widget.otpController.clear();
                      await widget.controller.sendOwnerOtp(widget.ownerPhoneController.text.trim());
                    },
                    child: AppText.bodyMedium(
                      AppStrings.getLocalizedString(context, (localizations) => localizations.resendOtp),
                      color: isDark ? AppColors.black : AppColorsLight.textPrimary,
                      maxLines: 1,
                      minFontSize: 10,
                    ),
                  )
                : AppText.bodyMedium(
                    AppStrings.getLocalizedString(context, (localizations) => localizations.resendOtp),
                    color: isDark ? Colors.grey[600] : AppColorsLight.textSecondary,
                    maxLines: 1,
                    minFontSize: 10,
                  ),
            if (!widget.controller.isResendAvailable.value) ...[
              AppText.bodyMedium(
                ' in ${widget.controller.resendTimer.value} seconds',
                color: isDark ? Colors.grey[600] : AppColorsLight.textSecondary,
                maxLines: 1,
                minFontSize: 10,
              ),
            ],
          ],
        )),
      ],
    );
  }

  Widget _buildSubmitButton(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context,
  ) {
    return Obx(() => AppButton(
      width: double.infinity,
      height: responsive.hp(7),
      gradientColors: [
        AppColors.splaceSecondary1,
        AppColors.splaceSecondary2,
      ],
      enableSweepGradient: true,
      borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: responsive.wp(1),
          offset: Offset(0, responsive.hp(0.3)),
        ),
      ],
      onPressed: widget.controller.isLoading.value ? null : widget.onSubmit,
      child: widget.controller.isLoading.value
          ? Center(
              child: SizedBox(
                height: responsive.hp(3),
                width: responsive.wp(3),
                child: CircularProgressIndicator(
                  color: AppColors.buttonTextColor,
                  strokeWidth: 2,
                ),
              ),
            )
          : Center(
              child: AppText.headlineSmall(
                AppStrings.getLocalizedString(context, (localizations) => localizations.confirmFinish),
                color: Colors.white,
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w500,
              ),
            ),
    ));
  }
}