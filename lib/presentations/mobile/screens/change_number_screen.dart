import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/api/auth_storage.dart';
import '../../../core/api/merchant_list_api.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../widgets/custom_app_bar/custom_app_bar.dart';
import '../../widgets/custom_app_bar/model/app_bar_config.dart';
import '../../../buttons/app_button.dart';
import '../../widgets/dialogs/change_number_pin_dialog.dart';
import '../../widgets/dialogs/new_number_otp_dialog.dart';
import '../../widgets/dialogs/mobile_number_dialog.dart';
import '../../../core/utils/formatters.dart';
import '../../../controllers/change_number_controller.dart';
import '../../../controllers/privacy_setting_controller.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../../core/utils/dialog_transition_helper.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_border_widget.dart';
import '../../widgets/custom_single_border_color.dart';

class ChangeNumberScreen extends StatefulWidget {
  const ChangeNumberScreen({super.key});

  @override
  State<ChangeNumberScreen> createState() => _ChangeNumberScreenState();
}

class _ChangeNumberScreenState extends State<ChangeNumberScreen> {
  String _currentNumber = '';
  String? _newNumber;
  bool _isLoading = true;
  late ChangeNumberController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(ChangeNumberController());
    _loadCurrentNumber();
  }

  @override
  void dispose() {
    Get.delete<ChangeNumberController>();
    super.dispose();
  }

  Future<void> _loadCurrentNumber() async {
    try {
      // ✅ Fetch from merchant API to get the correct registered phone number
      // NOT adminMobileNumber which is different
      final merchantApi = MerchantListApi();
      final merchants = await merchantApi.getAllMerchants();

      String? phone;
      if (merchants.isNotEmpty) {
        // Find main account or use first merchant
        final merchant = merchants.firstWhere(
          (m) => m.isMainAccount,
          orElse: () => merchants.first,
        );
        // Use 'phone' field (registered number), NOT adminMobileNumber
        phone = merchant.phone;
        debugPrint('✅ Loaded phone from merchant API: $phone');
      }

      // Fallback to AuthStorage if API fails
      phone ??= await AuthStorage.getPhoneNumber();

      setState(() {
        _currentNumber = phone ?? '';
        _isLoading = false;
      });
      // Set current number in controller
      _controller.setCurrentNumber(_currentNumber);
    } catch (e) {
      debugPrint('❌ Error loading phone number: $e');
      // Fallback to AuthStorage on error
      final phone = await AuthStorage.getPhoneNumber();
      setState(() {
        _currentNumber = phone ?? '';
        _isLoading = false;
      });
      _controller.setCurrentNumber(_currentNumber);
    }
  }

  /// Handle first button click: Show PIN Dialog or Skip if PIN is disabled
  Future<void> _handleFirstButtonClick() async {
    debugPrint('📱 First button clicked: Verify OTP');

    // Format masked phone number
    final maskedNumber = Formatters.formatMaskedPhone(_currentNumber);
    debugPrint('🔍 Current number: $_currentNumber');
    debugPrint('🔍 Masked number: $maskedNumber');

    // Prepare for dialog sequence - hide any existing keyboard
    await DialogTransitionHelper.prepareForDialogSequence(context);

    // Check if PIN is enabled globally
    bool isPinEnabled = false;
    try {
      final privacyController = Get.find<PrivacySettingController>();
      isPinEnabled = privacyController.isPinEnabled;
      debugPrint('🔐 PIN enabled: $isPinEnabled');
    } catch (e) {
      debugPrint('⚠️ PrivacySettingController not found, assuming PIN is enabled');
      isPinEnabled = true;
    }

    if (isPinEnabled) {
      // PIN is enabled - Show full PIN dialog flow
      final result = await ChangeNumberPinDialog.show(
        context: context,
        controller: _controller,
        maskedPhoneNumber: maskedNumber,
      );

      if (result != null) {
        final mobile = result['mobile'];
        debugPrint('✅ First flow completed. New number: $mobile');

        // Update UI to show numbers
        setState(() {
          _newNumber = '+91$mobile';
        });

        // Store new number in controller
        _controller.setNewNumber(mobile!);
      } else {
        debugPrint('❌ First flow cancelled');
      }
    } else {
      // PIN is disabled - Skip PIN and go directly to OTP flow
      debugPrint('🔓 PIN is disabled, skipping PIN dialog...');

      // Step 1: Send OTP to current number (with empty PIN)
      final otpSent = await _controller.sendOtpToCurrentNumber('');
      if (!otpSent) {
        debugPrint('❌ Failed to send OTP to current number');
        return;
      }

      if (!mounted) return;
      await DialogTransitionHelper.waitForDialogTransition();

      // Step 2: Show OTP dialog for current number
      final currentOtp = await NewNumberOtpDialog.show(
        context: context,
        newPhoneNumber: maskedNumber,
        title: 'Enter OTP',
        subtitle: 'Enter OTP sent to\n$maskedNumber',
        confirmButtonText: 'Verify',
      );

      if (currentOtp == null) {
        debugPrint('❌ Current OTP entry cancelled');
        return;
      }

      await DialogTransitionHelper.waitForDialogTransition();

      // Step 3: Verify current number OTP
      final verified = await _controller.verifyCurrentNumberOtp(currentOtp);
      if (!verified) {
        debugPrint('❌ Failed to verify current OTP');
        return;
      }

      if (!mounted) return;
      await DialogTransitionHelper.waitForDialogTransition();

      // Step 4: Show mobile number entry dialog
      final newMobile = await MobileNumberDialog.show(
        context: context,
        title: 'Enter New Mobile',
        subtitle: 'Enter your new 10-digit mobile number',
        confirmButtonText: 'Continue',
      );

      if (newMobile == null || newMobile.isEmpty) {
        debugPrint('❌ New mobile entry cancelled');
        return;
      }

      debugPrint('✅ Flow completed. New number: $newMobile');

      // Update UI to show numbers
      setState(() {
        _newNumber = '+91$newMobile';
      });

      // Store new number in controller
      _controller.setNewNumber(newMobile);
    }
  }

  /// Handle second button click: Send OTP to new number & verify
  Future<void> _handleSecondButtonClick() async {
    debugPrint('📱 Second button clicked: Send OTP & Change');

    if (_newNumber == null) {
      AdvancedErrorService.showError(
        'Please complete the first step',
        category: ErrorCategory.validation,
        severity: ErrorSeverity.medium,
      );
      return;
    }

    // Extract just the number (remove +91)
    final newNumberOnly = _newNumber!.replaceAll('+91', '');

    // Step 3: Send OTP to new number (API 3)
    final otpSent = await _controller.sendOtpToNewNumber(newNumberOnly);

    if (!otpSent) {
      debugPrint('❌ Failed to send OTP to new number');
      return;
    }

    debugPrint('✅ OTP sent to new number');

    if (!mounted) return;

    // Wait for smooth transition before showing dialog
    await DialogTransitionHelper.waitForDialogTransition();

    // Show OTP dialog for new number
    final maskedNewNumber = Formatters.formatMaskedPhone(_newNumber!);
    final newOtp = await NewNumberOtpDialog.show(
      context: context,
      newPhoneNumber: maskedNewNumber,
      title: 'Enter secure OTP received on your new number',
      subtitle: 'Enter OTP sent to\n$maskedNewNumber',
      warningText: 'You will be signed out from current device & all other devices.',
    );

    if (newOtp == null) {
      debugPrint('❌ New number OTP entry cancelled');
      return;
    }

    debugPrint('📱 User entered new OTP');

    // Wait for keyboard to close before API call
    await DialogTransitionHelper.waitForDialogTransition();

    // Step 4: Verify new number OTP (API 4)
    final success = await _controller.verifyNewNumberOtp(newOtp);

    if (success) {
      debugPrint('✅ Number change completed successfully!');

      // Show success message
      AdvancedErrorService.showSuccess(
        'Your mobile number is changed successfully please continue with new number again',
        type: SuccessType.snackbar,
      );

      // Wait for 5 seconds before logout
      await Future.delayed(Duration(seconds: 5));

      // ✅ FIX: Logout without clearing permanent controllers (ThemeController, LocalizationService)
      await AuthStorage.logout(clearControllers: false);

      // Navigate to select language screen
      if (mounted) {
        Get.offAllNamed(AppRoutes.selectLanguage);
      }
    } else {
      debugPrint('❌ Failed to verify new number OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
      appBar: CustomResponsiveAppBar(
        config: AppBarConfig(
          type: AppBarType.titleOnly,
          titleColor: isDark ? Colors.white : AppColorsLight.textPrimary,
          showBorder: true,
          customHeight: responsive.hp(12),
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
              AppText.searchbar2(
                'Change Number',
                  color: isDark ? Colors.white : AppColorsLight.textPrimary,
                  fontWeight: FontWeight.w500,
                maxLines: 1,
                minFontSize: 12,
                letterSpacing: 1.1,
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.white : AppColorsLight.splaceSecondary1,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(responsive.wp(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  SizedBox(height: responsive.hp(3)),
                    // Container with 2 SVG icons in a row
                    Container(
                      height: responsive.hp(40),
                      padding: EdgeInsets.symmetric(vertical: responsive.wp(4)),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.containerLight : AppColorsLight.white,
                        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              // Row with 2 SVG icons and text below each
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Old number column (icon + text)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SvgPicture.asset(
                                          AppIcons.changeNumberIc,
                                          width: responsive.iconSizeHuge * 1.4,
                                          height: responsive.iconSizeHuge * 1.4,
                                        ),
                                        SizedBox(height: responsive.hp(1)),
                                        AppText.searchbar1(
                                          'Old Number',
                                            color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          letterSpacing: 1.1,
                                        ),
                                        if (_newNumber != null) ...[
                                          SizedBox(height: responsive.hp(0.5)),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: AppText.searchbar1(
                                              Formatters.formatPhoneWithCountryCode(_currentNumber),
                                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Arrow icon
                                  Padding(
                                    padding: EdgeInsets.only(bottom: responsive.hp(3)),
                                    child: Icon(
                                      Icons.arrow_forward,
                                      size: responsive.iconSizeLarge1,
                                      color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                                    ),
                                  ),
                                  // New number column (icon + text)
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SvgPicture.asset(
                                          AppIcons.changeNumberIc,
                                          width: responsive.iconSizeHuge * 1.4,
                                          height: responsive.iconSizeHuge * 1.4,
                                        ),
                                        SizedBox(height: responsive.hp(1)),
                                        AppText.searchbar1(
                                          'New Number',
                                            color: isDark ? AppColors.white : AppColorsLight.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          letterSpacing: 1.1,
                                        ),
                                        if (_newNumber != null) ...[
                                          SizedBox(height: responsive.hp(0.5)),
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: AppText.searchbar1(
                                              Formatters.formatPhoneWithCountryCode(_newNumber!),
                                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                                fontWeight: FontWeight.w500,
                                              letterSpacing: 1.1,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: responsive.hp(2)),
                              // Divider line
                              Divider(
                                indent: responsive.wp(8),
                                endIndent: responsive.wp(8),
                                color: isDark ? AppColors.border1 : AppColorsLight.textDisabled,
                                thickness: 1,
                              ),
                              SizedBox(height: responsive.hp(2)),
                              // Text below divider
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
                                child: AppText.headlineLarge(
                                  _newNumber != null
                                      ? 'You are about to change your number. AN OTP will be send to new number for user verification.'
                                      : 'Chaining number will migrate all your data to teh new number. Make sure you are able to receive SMS on new number.',
                                  color: isDark ? AppColors.textDisabled : AppColorsLight.textPrimary,
                                  textAlign: TextAlign.center,
                                  fontWeight: FontWeight.w400,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                          // OTP message container at bottom
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: responsive.wp(3)),
                            padding: EdgeInsets.symmetric(
                              vertical: responsive.hp(1.2),
                              horizontal: responsive.wp(5),
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _newNumber != null
                                    ? [
                                  AppColors.red800,
                                  AppColors.red500,
                                      ]
                                    : isDark
                                        ? [
                                            AppColors.blue700,
                                            AppColors.blue900,
                                          ]
                                        : [
                                            AppColorsLight.containerLight,
                                            AppColorsLight.containerLight,
                                          ],
                                end: Alignment.topCenter,
                                begin: Alignment.bottomCenter,
                              ),
                              color: isDark ? AppColors.primeryamount : AppColorsLight.containerLight,
                              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                            ),
                            child: AppText.headlineLarge1(
                              _newNumber != null
                                  ? 'You will be signed out from current device & all other devices.'
                                  : 'An OTP will be send to verify the user / number.',
                                color: isDark ? AppColors.white : AppColorsLight.textPrimary,
                                fontWeight: FontWeight.w400,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(4)),

                  ],
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Stack(
          children:[
            Positioned.fill(child: CustomSingleBorderWidget(position: BorderPosition.top)),
            Container(
            padding: EdgeInsets.all(responsive.wp(4)),
            child: AppButton(
              text: _newNumber != null ? 'Send OTP & Change' : 'Verify OTP',
              width: double.infinity,
              height: responsive.hp(7),
              gradientColors: isDark
                  ? [AppColors.splaceSecondary1, AppColors.splaceSecondary2]
                  : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
              textColor: AppColors.white,
              fontSize: responsive.fontSize(18),
              fontWeight: FontWeight.w600,
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              onPressed: () async {
                // Determine which flow to execute based on whether numbers are displayed
                if (_newNumber == null) {
                  // First click: Show PIN dialog flow
                  await _handleFirstButtonClick();
                } else {
                  // Second click: Send OTP to new number and verify
                  await _handleSecondButtonClick();
                }
              },
            ),
          ),]
        ),
      ),
    );
  }
}
