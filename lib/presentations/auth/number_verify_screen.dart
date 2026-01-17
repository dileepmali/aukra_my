
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_fonts.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/app_button.dart';
import '../../controllers/image_carousel_controller.dart';
import '../../core/api/global_api_function.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/services/error_service.dart';
import '../../core/untils/binding/verify_binding.dart';
import '../../core/untils/error_types.dart';
import '../../core/untils/phone_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/services/back_button_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../widgets/custom_border_widget.dart';
import 'otp_verify_screen.dart';

class NumberVerifyScreen extends StatefulWidget {
  const NumberVerifyScreen({super.key});

  @override
  State<NumberVerifyScreen> createState() => _NumberVerifyScreenState();
}

class _NumberVerifyScreenState extends State<NumberVerifyScreen> {
  ImageCarouselController? carouselController;
  final TextEditingController phoneNumber = TextEditingController();
  late ApiFetcher apiFetcher;
  bool isLoading = false;
  String selectedCountryCode = "+91";
  String? phoneValidationError;
  
  // Phone validator instance
  final PhoneValidator _phoneValidator = PhoneValidator.instance;

  @override
  void initState() {
    super.initState();
    carouselController = Get.put(ImageCarouselController(), tag: 'number_carousel');
    apiFetcher = ApiFetcher();
    
    // Initialize AppBarController to prevent "not found" error

    // Register back button handler to navigate to SelectLanguageScreen
    // Use post-frame callback to ensure proper registration after widget initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set this screen as the active screen in navigation stack
      BackButtonService.pushScreen('NumberVerifyScreen');

      BackButtonService.registerWithCleanup(
        screenName: 'NumberVerifyScreen',
        onBackPressed: BackButtonService.handleNumberVerifyBack,
        interceptorName: 'number_verify_interceptor',
        priority: 1,
      );
      print('🔙 NumberVerifyScreen: Back button handler registered and set as active screen');
    });
  }

  @override
  void dispose() {
    debugPrint('🗑️ NUMBER VERIFY SCREEN - Disposing');

    // Remove back button handler
    BackButtonService.remove(interceptorName: 'number_verify_interceptor');

    // Properly dispose carousel controller to prevent ticker errors
    if (carouselController != null) {
      try {
        carouselController!.stopAutoScroll();
        Get.delete<ImageCarouselController>(tag: 'number_carousel');
      } catch (e) {
        debugPrint('⚠️ Error disposing carousel controller: $e');
      }
    }

    phoneNumber.dispose();
    super.dispose();
  }

  /// Validate phone number without causing build conflicts
  /// ✅ showFormatError = false for TextField (only pattern errors)
  void _validatePhoneNumber(String value) {
    if (!mounted) return;

    // Schedule setState for next frame to avoid build conflicts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // ✅ Don't show format errors in TextField (showFormatError: false)
        // Only show pattern errors (all same, sequential, etc.)
        final newError = _phoneValidator.validatePhoneNumberLocalized(
          value,
          selectedCountryCode,
          context,
          showFormatError: false, // Don't show "must be 10 digits" in TextField
        );
        if (phoneValidationError != newError) {
          setState(() {
            phoneValidationError = newError;
          });
        }
      }
    });
  }

  /// Convert localization key to localized string
  String _getLocalizedText(String key, BuildContext context) {
    return AppStrings.getLocalizedString(context, (localizations) {
      switch(key) {
        case 'onboardingTitle1':
          return localizations.onboardingTitle1;
        case 'onboardingTitle2':
          return localizations.onboardingTitle2;
        case 'onboardingTitle3':
          return localizations.onboardingTitle3;
        case 'onboardingTitle4':
          return localizations.onboardingTitle4;
        case 'onboardingSubtitle1':
          return localizations.onboardingSubtitle1;
        case 'onboardingSubtitle2':
          return localizations.onboardingSubtitle2;
        case 'onboardingSubtitle3':
          return localizations.onboardingSubtitle3;
        case 'onboardingSubtitle4':
          return localizations.onboardingSubtitle4;
        default:
          return 'Loading...';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
          body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: isKeyboardVisible
                    ? MediaQuery.of(context).viewInsets.bottom * 0.2
                    : 0,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: responsive.screenPadding.left,
                    right: responsive.screenPadding.right,
                    top: responsive.screenPadding.top,
                    bottom: responsive.hp(2),
                  ),
                  child: Column(
                    children: [
                      _buildTopContainer(responsive, isKeyboardVisible),
                      SizedBox(height: responsive.spaceXL),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mobile Number Label
                          AppText.displayMedium3(
                            AppStrings.getLocalizedString(context, (localizations) => localizations.mobileNumber),
                            color: isDark ? Colors.white : AppColorsLight.textPrimary,
                            maxLines: 1,
                            minFontSize: 14,
                            textAlign: TextAlign.left,
                            fontWeight: FontWeight.w500, // Medium weight (normal look)
                          ),
                          SizedBox(height: responsive.spaceXSS),
                          TextField(
                            controller: phoneNumber,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done, // 🔥 NEW: Show Done button on keyboard
                            style: AppFonts.displayMedium3(
                              color: isDark ? Colors.white : AppColorsLight.textPrimary,
                              fontWeight: FontWeight.w500, // Medium weight (normal look)
                            ),
                            cursorColor: isDark ? AppColors.white : AppColorsLight.textPrimary,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(
                                _phoneValidator.getMaxLength(selectedCountryCode)
                              ),
                            ],
                            onChanged: (value) {
                              // ✅ Clear error if user is typing and hasn't reached 10 digits yet
                              if (phoneValidationError != null && value.length < 10) {
                                setState(() {
                                  phoneValidationError = null;
                                });
                              }

                              // ✅ Validate ONLY when user completes 10 digits
                              if (value.length == 10) {
                                _validatePhoneNumber(value);
                              }
                            },
                            // 🔥 NEW: Handle keyboard Done button press
                            onSubmitted: (value) async {
                              debugPrint('✅ TextField onSubmitted (Done button pressed): $value');

                              // Close keyboard
                              FocusScope.of(context).unfocus();

                              // Wait for keyboard to close
                              await Future.delayed(Duration(milliseconds: 300));

                              // Trigger the same logic as Send OTP button
                              if (!isLoading) {
                                _handleSendOtp();
                              }
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.getLocalizedString(context, (localizations) => localizations.enterPhoneNumber),
                              errorText: phoneValidationError,
                              errorMaxLines: 2, // 🔥 FIX: Max 2 lines for error
                              errorStyle: AppFonts.headlineMedium(
                                color: Colors.red,
                                fontWeight: AppFonts.regular,

                              ),

                              prefixText: ' ',
                              prefixStyle: AppFonts.displayMedium3(
                                color: isDark ? Colors.white : AppColorsLight.textPrimary,
                                fontWeight: AppFonts.regular,

                              ),
                              hintStyle: AppFonts.displayMedium3(
                                color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
                                fontWeight: AppFonts.regular,

                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.black.withOpacity(0.8)
                                  : AppColorsLight.inputBackground,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: responsive.spacing(16),
                                vertical: responsive.hp(2.5),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.backgroundDark : AppColorsLight.splaceSecondary2,
                                  width: 1.5,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.backgroundDark : AppColorsLight.splaceSecondary2,
                                  width: 1.5,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                borderSide: BorderSide(
                                  color: phoneValidationError != null
                                      ? Colors.red
                                      : (isDark ? AppColors.backgroundDark : AppColorsLight.splaceSecondary2),
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.red, width: 1.5),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                                borderSide: BorderSide(
                                  color: isDark ? AppColors.backgroundDark : AppColorsLight.splaceSecondary2,
                                  width: 1.5,
                                ),
                              ),
                              prefixIcon: IntrinsicWidth(
                                child: Row(
                                  children: [
                                    // Country picker commented out - only showing +91
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     CountryPickerHelper.showPicker(
                                    //       context: context,
                                    //       onSelect: (Country country) {
                                    //         setState(() {
                                    //           selectedCountryCode = '+${country.phoneCode}';
                                    //           phoneNumber.clear();
                                    //           phoneValidationError = null;
                                    //         });
                                    //       },
                                    //     );
                                    //   },
                                    //   child: Padding(
                                    //     padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                                    //     child: Text(
                                    //       selectedCountryCode,
                                    //       style: AppFonts.bodyMedium(
                                    //         color: Colors.white,
                                    //       ).copyWith(
                                    //         fontSize: responsive.fontSize(17),
                                    //         fontWeight: FontWeight.w600,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
                                    // Display fixed +91 country code
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: responsive.spacing(20)),
                                      child: Text(
                                        selectedCountryCode, // Will always be +91
                                        style: AppFonts.displayMedium3(
                                          color: isDark ? Colors.white : AppColorsLight.textPrimary,
                                          fontWeight: AppFonts.medium,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 1.5,
                                      height: responsive.hp(4.5),
                                      color: isDark
                                          ? AppColors.white.withOpacity(0.8)
                                          : AppColorsLight.black,
                                      margin: EdgeInsets.only(right: responsive.spacing(4)),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          ),
                          SizedBox(height: responsive.spaceXSS),
                          AppText.rich(
                            children: [
                              TextSpan(
                                text: AppStrings.getLocalizedString(context, (localizations) => localizations.byClicking),
                                style: AppFonts.headlineSmall(
                                  color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
                                  fontWeight: AppFonts.medium,

                                ),
                              ),
                              TextSpan(
                                text: '  ',
                                style: AppFonts.headlineSmall(
                                  color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
                                ),
                              ),
                              TextSpan(
                                text: 'Terms & Conditions', // Always English
                                style: AppFonts.headlineSmall(
                                  color: AppColors.blue, // Always blue
                                ).copyWith(
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.blue,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () async {
                                    final Uri termsUrl = Uri.parse('https://anantkaya.com/term-condition.html');
                                    if (await canLaunchUrl(termsUrl)) {
                                      await launchUrl(
                                        termsUrl,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      // If URL cannot be launched, show error
                                      AdvancedErrorService.showError(
                                        'Could not open terms and conditions',
                                        category: ErrorCategory.general,
                                        severity: ErrorSeverity.low,
                                      );
                                    }
                                  },
                              ),
                            ],
                            maxLines: 2,
                            minFontSize: 9,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                              height: isKeyboardVisible
                                  ? responsive.hp(1)
                                  : responsive.hp(4)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: isKeyboardVisible
                    ? MediaQuery.of(context).viewInsets.bottom * 0.0
                    : 0.0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: responsive.screenPadding.left,
                    right: responsive.screenPadding.right,
                    bottom: responsive.screenPadding.bottom,
                    top: responsive.hp(0.1),
                  ),
                  child: AppButton(
                        width: double.infinity,
                        height: responsive.hp(9),
                    gradientColors: [
                      AppColors.splaceSecondary1,
                      AppColors.splaceSecondary2,
                    ],
                    enableSweepGradient: true,
                        borderRadius: BorderRadius.circular(
                            responsive.borderRadiusSmall),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: responsive.wp(2),
                            offset: Offset(0, responsive.hp(0.3)),
                          ),
                        ],
                        padding: EdgeInsets.symmetric(
                            horizontal: responsive.spacing(20)),
                        onPressed: isLoading
                            ? null
                            : () async {
                          // Close keyboard first
                          FocusScope.of(context).unfocus();
                          await Future.delayed(Duration(milliseconds: 300));

                          // 🔥 Call extracted method
                          _handleSendOtp();
                        },
                        child: isLoading
                            ? Center(
                              child: SizedBox(
                                height: responsive.hp(3),
                                width: responsive.wp(6.5),
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                            : Center(
                                child: AppText.button(
                                  AppStrings.getLocalizedString(context, (localizations) => localizations.sendOtp),
                                  color: AppColors.white,
                                  maxLines: 1,
                                  minFontSize: 12,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    },
        );
  }

  Widget _buildTopContainer(AdvancedResponsiveHelper responsive, bool isKeyboardVisible) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      child: BorderColor(
        isSelected: true,
        borderRadius: responsive.borderRadiusSmall,
        topWidth: 1.5,    // Top border thin
        leftWidth: 1.5,   // Left border normal
        rightWidth: 1.5,  // Right border normal
        bottomWidth: 2.0, // Bottom border thick
        child: Container(
          width: double.infinity,
          height: _getTopContainerHeight(responsive, isKeyboardVisible),
          decoration: BoxDecoration(
            color: isDark ? AppColors.containerBack : AppColorsLight.white,
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          // ✅ Stack to position dots outside PageView
          child: carouselController?.pageController == null
              ? Center(child: CircularProgressIndicator()) // Loading state
              : Stack(
                  children: [
                    // PageView for images and text (without dots)
                    PageView.builder(
                      controller: carouselController!.pageController!,
                      onPageChanged: (index) {
                        carouselController!.onPageChanged(index);
                        carouselController!.restartAutoScroll();
                      },
                      itemCount: carouselController!.dataLength,
                      itemBuilder: (context, index) {
                        final data = carouselController!.onboardingData[index];

                        return Padding(
                          padding: responsive.screenPadding,
                          child: Column(
                            children: [
                              // Image carousel - hide when keyboard is visible
                              if (!isKeyboardVisible)
                                Expanded(
                                  flex: 8,
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(data['image']!),
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                      ),
                                    ),
                                  ),
                                ),

                              // Text content section - flexible to prevent overflow
                              Expanded(
                                flex: isKeyboardVisible ? 10 : 4, // More space when keyboard visible
                                child: Column(
                                  mainAxisSize: MainAxisSize.min, // Prevent overflow
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top spacing
                                    SizedBox(height: isKeyboardVisible ? responsive.space2XSSS : responsive.space2XSSS),

                                    // Content section
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Dynamic title
                                          Container(
                                            height: isKeyboardVisible ? responsive.hp(4) : responsive.hp(5),
                                            alignment: Alignment.centerLeft,
                                            child: AppText.displayMedium3(
                                              _getLocalizedText(data['title'] ?? '', context),
                                              color: isDark ? Colors.white : AppColorsLight.textPrimary,
                                              maxLines: 1,
                                              minFontSize: 13,
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.w500, // Medium weight (normal look)

                                            ),
                                          ),

                                          // Dynamic subtitle
                                          Container(
                                            height: isKeyboardVisible ? responsive.hp(9) : responsive.hp(9),
                                            child: AppText.headlineLarge(
                                              _getLocalizedText(data['subtitle'] ?? '', context),
                                              color: isDark ? Colors.grey[300] : AppColorsLight.textSecondary,
                                              maxLines: 4,
                                              minFontSize: 10,
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.w500, // Medium weight (normal look)

                                            ),
                                          ),

                                          SizedBox(height: isKeyboardVisible ? responsive.spaceXL : responsive.spaceMD),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // ✅ Fixed position indicators outside PageView
                    Positioned(
                      left: responsive.screenPadding.left,
                      right: responsive.screenPadding.right,
                      bottom: responsive.screenPadding.bottom,
                      child: _buildCarouselIndicators(responsive),
                    ),
                  ],
                ),
        ),
      ),
    );
  }


  double _getTopContainerHeight(
      AdvancedResponsiveHelper responsive, bool isKeyboardVisible) {
    if (isKeyboardVisible) return responsive.hp(22);
    return responsive.hp(55);
  }


  Widget _buildCarouselIndicators(AdvancedResponsiveHelper responsive) {
    if (carouselController == null) return SizedBox.shrink();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() => Padding(
          padding: EdgeInsets.symmetric(vertical: responsive.space2XS),
          child: Row(
            children: List.generate(
              carouselController!.dataLength,
              (index) => AnimatedContainer(
                duration: Duration(milliseconds: 300),
                margin: EdgeInsets.only(right: responsive.spacing(8)),
                width: responsive.spacing(10),
                height: responsive.spacing(8),
                decoration: BoxDecoration(
                  color: carouselController!.currentIndex.value == index
                      ? AppColors.splaceSecondary2
                      : (isDark ? Colors.grey[600] : AppColorsLight.border),
                  borderRadius: BorderRadius.circular(responsive.spacing(1)),
                ),
              ),
            ),
          ),
        ));
  }

  // 🔥 NEW: Extract Send OTP logic to reusable method
  Future<void> _handleSendOtp() async {
    String phoneText = phoneNumber.text.trim();

    debugPrint('🔥🔥🔥 _handleSendOtp called!');
    debugPrint('   Phone text: "$phoneText"');
    debugPrint('   Is empty: ${phoneText.isEmpty}');

    // ✅ Check if empty - Show Snackbar error
    if (phoneText.isEmpty) {
      debugPrint('🚨 Phone is empty - calling AdvancedErrorService.showError()');

      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterPhoneNumber),
        category: ErrorCategory.validation,
        severity: ErrorSeverity.medium,
      );

      debugPrint('✅ AdvancedErrorService.showError() called');
      return;
    }

    // ✅ Validate phone number - Show TextField errorText
    String? validationError = _phoneValidator.validatePhoneNumberLocalized(
      phoneText,
      selectedCountryCode,
      context,
      showFormatError: true, // Show ALL errors including "must be 10 digits"
    );

    if (validationError != null) {
      // ✅ Show error in TextField errorText (NOT Snackbar)
      setState(() {
        phoneValidationError = validationError;
      });
      return;
    }

    if (mounted) {
      setState(() => isLoading = true);
    }

    try {
      String phoneOnly = phoneText;
      String fullPhoneNumber = selectedCountryCode + phoneOnly;

      // Prepare phone number for API
      String apiPhoneNumber;
      if (selectedCountryCode == "+91") {
        // For Indian numbers, send only the number without country code
        apiPhoneNumber = phoneOnly;
      } else {
        // For other countries, send full number without + sign
        apiPhoneNumber = fullPhoneNumber.length > 1 ? fullPhoneNumber.substring(1) : fullPhoneNumber;
      }

      debugPrint('🔥 About to call API with phone: $apiPhoneNumber');
      debugPrint('🔥 Full phone number: $fullPhoneNumber');

      await apiFetcher.request(
        url: 'api/auth/send-otp',
        method: 'POST',
        body: {'mobileNumber': apiPhoneNumber},
        requireAuth: false,
      );

      debugPrint('🔥 API call completed!');
      debugPrint('🔥 Error message: ${apiFetcher.errorMessage}');
      debugPrint('🔥 Response data: ${apiFetcher.data}');
      debugPrint('🔥 Response data type: ${apiFetcher.data.runtimeType}');

      if (apiFetcher.errorMessage == null && apiFetcher.data != null) {
        // ✅ If no error and we have data, consider it success
        debugPrint('✅ OTP sent successfully! Navigating to OTP screen...');

        // Extract OTP from response (if provided)
        String? receivedOtp;

        // 🔥 FIX: Check both direct and nested 'otp' field
        if (apiFetcher.data is Map) {
          // Try direct access first
          if (apiFetcher.data.containsKey('otp')) {
            receivedOtp = apiFetcher.data['otp'].toString();
            debugPrint('🔑 OTP received from server (direct): $receivedOtp');
          }
          // Try nested access in 'data' object
          else if (apiFetcher.data.containsKey('data') &&
                   apiFetcher.data['data'] is Map &&
                   apiFetcher.data['data'].containsKey('otp')) {
            receivedOtp = apiFetcher.data['data']['otp'].toString();
            debugPrint('🔑 OTP received from server (nested): $receivedOtp');
          }
          else {
            // 🔥 DEVELOPMENT ONLY: Use dummy OTP when server doesn't send OTP
            receivedOtp = '8888';
            debugPrint('⚠️ OTP not found in response. Using DUMMY OTP for testing: $receivedOtp');
            debugPrint('📋 Available keys in response: ${apiFetcher.data.keys}');
          }
        }

        // Navigate to OTP screen
        Get.to(
          () => OtpVerifyScreen(
              phoneNumber: fullPhoneNumber,
              receivedOtp: receivedOtp),
          binding: VerifyBinding(),
        );
      } else {
        AdvancedErrorService.showError(
          apiFetcher.errorMessage ?? AppStrings.getLocalizedString(context, (localizations) => localizations.failedToSendOtp),
          category: ErrorCategory.network,
          severity: ErrorSeverity.high,
        );
      }
    } catch (e) {
      debugPrint('🚨 EXCEPTION in _handleSendOtp: $e');
      debugPrint('🚨 Stack trace: ${StackTrace.current}');

      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.networkError),
        category: ErrorCategory.network,
        severity: ErrorSeverity.high,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

}
