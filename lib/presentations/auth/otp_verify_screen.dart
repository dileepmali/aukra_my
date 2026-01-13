import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Orientation;
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/themes/app_text.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../../../controllers/verify_otp_controller.dart';
import '../../../controllers/image_carousel_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/services/error_service.dart';
import '../../buttons/app_button.dart';
import '../../core/api/global_api_function.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/untils/error_types.dart';

import '../../../core/api/auth_storage.dart';
import '../../../core/services/back_button_service.dart';
import '../widgets/custom_border_widget.dart';
import '../routes/app_routes.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? receivedOtp;

  const OtpVerifyScreen({Key? key, this.phoneNumber, this.receivedOtp}) : super(key: key);

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  late OtpVerifyController controller;
  late ApiFetcher apiFetcher;
  ImageCarouselController? carouselController;
  bool isOtpVerified = false;

  // ✅ Create pinController once to prevent rebuilds from resetting it
  final TextEditingController _pinController = TextEditingController();

  // 🔥 FIX: Add FocusNode to maintain focus and prevent keyboard from closing
  final FocusNode _pinFocusNode = FocusNode();

  // 🔥 FIX: Prevent multiple simultaneous OTP fill operations
  bool _isFillingOtp = false;
  Timer? _autoSubmitTimer;

  @override
  void initState() {
    super.initState();
    debugPrint('🔥 OTP VERIFY SCREEN - InitState started');

    apiFetcher = ApiFetcher();


    // Initialize controller
    if (!Get.isRegistered<OtpVerifyController>()) {
      Get.put(OtpVerifyController());
      debugPrint('📝 OTP Controller registered');
    }
    controller = Get.find<OtpVerifyController>();

    // Set phone number
    controller.setPhoneNumber(widget.phoneNumber ?? '');
    debugPrint('📞 Phone number set: ${widget.phoneNumber}');

    // Initialize OTP screen (controller handles clipboard monitoring)
    controller.initializeOtpScreen();
    debugPrint('⚡ OTP screen initialized');

    // Set auto-submit callback
    controller.setAutoSubmitCallback(() {
      debugPrint('🎯 Auto-submit triggered from controller');
      _handleVerifyOtp();
    });

    // ✅ RE-ENABLED: Listen to controller's OTP changes for clipboard auto-fill
    // 🔥 SMART DETECTION: Only sync when OTP comes from clipboard (not manual typing)
    ever(controller.otp, (callback) {
      final otpString = controller.getOtpString();
      final currentPinputValue = _pinController.text;

      debugPrint('📋 Controller OTP changed: "$otpString" (current Pinput: "$currentPinputValue")');
      debugPrint('📋 Is Clipboard OTP: ${controller.isClipboardOtp.value}');

      // 🔥 FIX: ONLY auto-fill if this OTP came from clipboard, not manual typing
      if (!controller.isClipboardOtp.value) {
        debugPrint('⏭️ Skipping auto-fill - This is manual OTP entry, not clipboard');
        return;
      }

      // 🔥 FIX: Wait until OTP is COMPLETE (4 digits) before processing
      if (otpString.length < 4) {
        debugPrint('⏸️ Waiting for complete OTP... Current length: ${otpString.length}');
        return;
      }

      // 🔥 FIX: Prevent multiple fills if already filling
      if (_isFillingOtp) {
        debugPrint('⏸️ Already filling OTP, skipping duplicate fill...');
        return;
      }

      // 🔥 FIX: Auto-fill clipboard OTP even if wrong OTP is already filled
      // Only requirement: OTP is complete (4 digits) and different from current value
      if (currentPinputValue != otpString) {

        debugPrint('✅ Clipboard OTP detected! Clearing old OTP and auto-filling: $otpString');

        // 🔥 Set flag to prevent re-entry
        _isFillingOtp = true;

        // 🔥 Cancel any pending auto-submit timer
        _autoSubmitTimer?.cancel();

        // 🔥 STEP 1: Clear old OTP immediately and visibly
        debugPrint('🧹 Step 1: Clearing old OTP...');
        _pinController.clear();

        // 🔥 STEP 2: Wait for 400ms to let user see the clearing animation
        Future.delayed(Duration(milliseconds: 400), () {
          if (mounted) {
            debugPrint('🔄 Step 2: Now filling new OTP: $otpString');

            // Fill new OTP from clipboard
            _pinController.text = otpString;

            debugPrint('✅ New OTP filled in Pinput: ${_pinController.text}');

            // 🔥 STEP 3: Wait another 800ms before auto-submitting
            _autoSubmitTimer = Timer(Duration(milliseconds: 800), () {
              if (mounted && !isOtpVerified) {
                debugPrint('🚀 Step 3: Auto-submitting new OTP...');
                _handleVerifyOtp();
              }
              // Reset flags after submission
              _isFillingOtp = false;
              controller.isClipboardOtp.value = false; // Reset clipboard flag
              debugPrint('🔓 Flags reset, ready for next OTP');
            });
          } else {
            _isFillingOtp = false;
            controller.isClipboardOtp.value = false;
            debugPrint('⚠️ Widget not mounted, resetting flags');
          }
        });
      } else {
        debugPrint('⏭️ OTP already filled: "$otpString"');
      }
    });

    // Initialize carousel
    carouselController = Get.put(ImageCarouselController(), tag: 'otp_carousel');

    // 🔙 Register back button interceptor for OtpVerifyScreen after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // First remove any potential conflicting interceptors
        debugPrint('🔧 OTP VERIFY SCREEN - Removing potential conflicting interceptors');
        BackButtonService.remove(interceptorName: 'number_verify_interceptor');
        BackButtonService.remove(interceptorName: 'select_language_interceptor');
        
        // Register OTP screen interceptor
        debugPrint('📝 OTP VERIFY SCREEN - Registering back button interceptor');
        BackButtonService.registerWithCleanup(
          screenName: 'OtpVerifyScreen',
          onBackPressed: BackButtonService.handleOtpVerifyBack,
          interceptorName: 'otp_verify_interceptor',
        );
      }
    });

    debugPrint('✅ OTP VERIFY SCREEN - InitState completed successfully');
  }

  @override
  void dispose() {
    debugPrint('🗑️ OTP VERIFY SCREEN - Disposing and cleaning up interceptors');

    // 🔙 Remove back button interceptor with additional safety
    try {
      BackButtonService.remove(interceptorName: 'otp_verify_interceptor');
      debugPrint('✅ OTP VERIFY SCREEN - Successfully removed back button interceptor');
    } catch (e) {
      debugPrint('⚠️ OTP VERIFY SCREEN - Error removing interceptor: $e');
    }

    // 🔥 Cancel auto-submit timer
    _autoSubmitTimer?.cancel();

    // Dispose pin controller and focus node
    _pinController.dispose();
    _pinFocusNode.dispose();

    // Controller handles cleanup
    super.dispose();
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
                // Main content
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom * 0.2 : 0,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: responsive.screenPadding.left,
                      right: responsive.screenPadding.right,
                      top: responsive.screenPadding.top,
                      bottom: responsive.hp(2),
                    ),
                    child: Column(
                      children: [
                        // Top gradient container
                        _buildTopContainer(responsive, isKeyboardVisible),

                        // Space between top container and form
                        SizedBox(height: isKeyboardVisible ? responsive.spaceMD : responsive.spaceMD),

                        // OTP Form Section
                        _buildOtpFormSection(responsive, isKeyboardVisible),

                        // Extra space for scrolling
                        SizedBox(height: isKeyboardVisible ? responsive.hp(1) : responsive.hp(12)),
                      ],
                    ),
                  ),
                ),

                // Fixed bottom button
                Positioned(
                  bottom: isKeyboardVisible ? MediaQuery.of(context).viewInsets.bottom * 0.0 : 0.0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: responsive.screenPadding.left,
                      right: responsive.screenPadding.right,
                      bottom: responsive.screenPadding.bottom,
                      top: isKeyboardVisible ? responsive.hp(0.1) : responsive.hp(0.1),
                    ),
                    child: _buildFixedBottomButton(responsive),
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
        topWidth: 1.5,
        leftWidth: 1.5,
        rightWidth: 1.5,
        bottomWidth: 2.0,
        child: Container(
          width: double.infinity,
          height: _getTopContainerHeight(responsive, isKeyboardVisible),
          // padding: responsive.screenPadding,
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
                                    SizedBox(height: isKeyboardVisible ? responsive.spaceXS : responsive.spaceXS),

                                    // Content section
                                    Flexible(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Dynamic title
                                          Container(
                                            height: isKeyboardVisible ? responsive.hp(4) : responsive.hp(4),
                                            alignment: Alignment.centerLeft,
                                            child: AppText.displayMedium3(
                                              carouselController!.getCurrentTitle(context),
                                              color: isDark ? Colors.white : AppColorsLight.textPrimary,
                                              maxLines: 1,
                                              minFontSize: 13,
                                              textAlign: TextAlign.left,
                                              fontWeight: FontWeight.w500, // Medium weight (normal look)

                                            ),
                                          ),

                                          SizedBox(height: isKeyboardVisible ? responsive.hp(0) : responsive.hp(0.2)),

                                          // Dynamic subtitle
                                          Container(
                                            height: isKeyboardVisible ? responsive.hp(9) : responsive.hp(9),
                                            child: AppText.headlineLarge(
                                              carouselController!.getCurrentSubtitle(context),
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

  double _getTopContainerHeight(AdvancedResponsiveHelper responsive, bool isKeyboardVisible) {
    if (isKeyboardVisible) {
      return responsive.hp(22);
    }
    return responsive.hp(55);
  }


  Widget _buildCarouselIndicators(AdvancedResponsiveHelper responsive) {
    if (carouselController == null) {
      return SizedBox.shrink();
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() => Padding(
      padding: EdgeInsets.symmetric(vertical: responsive.space2XS),
      child: Row(
        children: List.generate(
          carouselController!.dataLength,
          (index) => AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.only(right: responsive.spacing(8)),
            width: carouselController!.currentIndex.value == index
                ? responsive.spacing(10)
                : responsive.spacing(10),
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

  Widget _buildOtpFormSection(AdvancedResponsiveHelper responsive, bool isKeyboardVisible) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.displaySmall(
          '${AppStrings.getLocalizedString(context, (localizations) => localizations.enterOtpSentTo)}\n${widget.phoneNumber}',
          color: isDark ? Colors.white : AppColorsLight.textPrimary,
          maxLines: 2,
          minFontSize: 12,
          textAlign: TextAlign.left,
          fontWeight: FontWeight.w500, // Medium weight (normal look)

        ),
        SizedBox(height: isKeyboardVisible ? responsive.space2XS : responsive.space2XSS),

        // OTP Input Field
        _buildOtpInputField(responsive, isKeyboardVisible),

        SizedBox(height: isKeyboardVisible ? responsive.spaceMD : responsive.spaceLG),

        // Resend OTP Section
        _buildResendOtpSection(responsive, isKeyboardVisible),

        SizedBox(height: isKeyboardVisible ? responsive.spaceXS : responsive.space2XL),
      ],
    );
  }


  Widget _buildOtpInputField(AdvancedResponsiveHelper responsive, bool isKeyboardVisible) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultPinTheme = PinTheme(
      width: responsive.wp(18),
      height: responsive.hp(9),
      textStyle: AppFonts.displayMedium(
        color: isDark ? Colors.white : AppColorsLight.textPrimary,
        fontWeight: AppFonts.regular,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColorsLight.background,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        border: Border.all(
          color: isDark ? AppColors.borderDark1 : AppColorsLight.splaceSecondary2,
          width: 1.5,
        ),
      ),
    );

    return Obx(() => Opacity(
      opacity: controller.isOtpExpired.value ? 0.5 : 1.0, // ✅ Dim when expired
      child: AbsorbPointer(
        absorbing: controller.isOtpExpired.value, // ✅ Disable input when expired
        child: Pinput(
          controller: _pinController,
          focusNode: _pinFocusNode, // 🔥 FIX: Add explicit FocusNode
          length: 4,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: defaultPinTheme.copyWith(
            decoration: defaultPinTheme.decoration!.copyWith(
              borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              border: Border.all(
                color: isDark ? AppColors.splaceSecondary2 : AppColorsLight.splaceSecondary2,
                width: 2,
              ),
            ),
          ),
          submittedPinTheme: defaultPinTheme,
          showCursor: !controller.isOtpExpired.value, // ✅ Hide cursor when expired
          // autofocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done, // 🔥 NEW: Show Done button on keyboard
          onChanged: (code) {
            debugPrint('🔄 Pinput onChanged: $code (length: ${code.length})');

            // 🔥 NEW APPROACH: Do NOTHING in onChanged to prevent keyboard close
            // Only store the value locally in _pinController
            // Controller update will happen ONLY in onCompleted
          },
          onCompleted: (code) {
            debugPrint('🚀 Pinput onCompleted: $code');

            // 🔥 FIX: Mark this as manual entry, NOT clipboard
            controller.isClipboardOtp.value = false;

            for (int i = 0; i < 4; i++) {
              controller.otp[i] = code[i];
            }
            controller.otp.refresh();

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              FocusScope.of(context).unfocus();
              await Future.delayed(Duration(milliseconds: 500));
              _handleVerifyOtp();
            });
          },
          // 🔥 NEW: Handle keyboard Done/Submit button
          onSubmitted: (code) {
            debugPrint('✅ Pinput onSubmitted (Done button pressed): $code');

            // Update controller if OTP is complete
            if (code.length == 4) {
              // 🔥 FIX: Mark this as manual entry, NOT clipboard
              controller.isClipboardOtp.value = false;

              for (int i = 0; i < 4; i++) {
                controller.otp[i] = code[i];
              }
              controller.otp.refresh();

              // Close keyboard and verify OTP
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                FocusScope.of(context).unfocus();
                await Future.delayed(Duration(milliseconds: 300));
                _handleVerifyOtp();
              });
            } else {
              // If incomplete OTP, show error
              debugPrint('⚠️ Incomplete OTP on Submit: $code (length: ${code.length})');
              AdvancedErrorService.showError(
                AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterComplete4DigitOtp),
                severity: ErrorSeverity.medium,
                category: ErrorCategory.validation,
              );
            }
          },
        ),
      ),
    ));
  }


  Widget _buildResendOtpSection(AdvancedResponsiveHelper responsive, bool isKeyboardVisible) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        AppText.headlineLarge(
          AppStrings.getLocalizedString(context, (localizations) => localizations.didntReceiveOtp),
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 10,
        ),
        SizedBox(width: responsive.spaceSM,),
        Flexible(
          child: Obx(() => controller.isResendAvailable.value
              ? GestureDetector(
                  onTap: () => _handleResendOtp(),
                  child: AppText.custom(
                    'Resend OTP', // Always English
                    style: AppFonts.searchbar1(
                      color: isDark ? AppColors.textWhite : AppColorsLight.textPrimary,
                      fontWeight: AppFonts.medium,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                    ),
                    maxLines: 1,
                    minFontSize: 10,
                  ),
                )
              : AppText.headlineLarge(
                  "Resend in ${controller.resendTimer.value} sec", // Always English
                  color: isDark ? Colors.grey[600] : AppColorsLight.textSecondary,
                  maxLines: 1,
                  minFontSize: 10,
                ),
          ),
        ),
      ],
    );
  }


  Future<void> _handleResendOtp() async {
    try {
      await controller.resendOtp();
      AdvancedErrorService.showSuccess(
        '${AppStrings.getLocalizedString(context, (localizations) => localizations.otpSentSuccessfully)} ${controller.phoneNumber}',
        type: SuccessType.snackbar,
      );
    } catch (e) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.failedToSendOtp),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.general,
      );
    }
  }

  Widget _buildFixedBottomButton(AdvancedResponsiveHelper responsive) {
    return Obx(() {
      return AppButton(
        width: double.infinity,
        height: _getButtonHeight(responsive),
        gradientColors: [
          AppColors.splaceSecondary1,
          AppColors.splaceSecondary2,
        ],
        enableSweepGradient: true,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: responsive.wp(2),
            offset: Offset(0, responsive.hp(0.3)),
          ),
        ],
        padding: EdgeInsets.symmetric(horizontal: responsive.spacing(24)),
        onPressed: controller.isLoading.value ? null : _handleVerifyOtp,
        child: controller.isLoading.value
            ? Center(
              child: SizedBox(
                height: responsive.hp(3),
                width: responsive.wp(6.2),
                child: CircularProgressIndicator(
                  color: AppColors.buttonTextColor,
                  strokeWidth: 2,
                ),
              ),
            )
            : Center(
                child: AppText.button(
                  AppStrings.getLocalizedString(context, (localizations) => localizations.submitOtp),
                  color: Colors.black,
                  maxLines: 1,
                  minFontSize: 12,
                  textAlign: TextAlign.center,
                ),
              ),
      );
    });
  }

  double _getButtonHeight(AdvancedResponsiveHelper responsive) {
    return  responsive.hp(9);
  }

Future<void> _handleVerifyOtp() async {
  // 🔥 FIX: Get OTP directly from Pinput controller instead of GetX controller
  final otpString = _pinController.text;

  try {
    debugPrint('🚀 _handleVerifyOtp() called - Starting OTP verification');
    FocusScope.of(context).unfocus();

    // If OTP is already verified or currently loading, prevent duplicate verification
    if (isOtpVerified || controller.isLoading.value) {
      debugPrint('⚠️ Verification already in progress or completed, skipping...');
      return;
    }

    controller.isLoading.value = true;

    String phone = controller.phoneNumber.trim();
    if (phone.startsWith("+91")) {
      phone = phone.substring(3);
    }

    if (phone.isEmpty) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.phoneNumberRequired),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    if (otpString.length != 4) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterComplete4DigitOtp),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    // ✅ Check if OTP has expired
    if (controller.isOtpExpired.value) {
      debugPrint('⏰ OTP verification failed - OTP has expired');

      // ✅ Clear PIN boxes
      _pinController.clear();
      controller.clearOtp();

      AdvancedErrorService.showError(
        'OTP has expired. Please request a new OTP.',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      controller.isLoading.value = false;
      return;
    }

    // 🔥 DEVELOPMENT: Log if dummy OTP is being used
    final isDummyOtp = (otpString == '8888');
    if (isDummyOtp) {
      debugPrint('🔥 Dummy OTP detected (8888) - Will still call API for real token');
    }

    // 🔥 ALWAYS CALL API - Whether OTP is dummy or real
    final payload = {
      'mobileNumber': phone,  // ✅ Fixed: Changed from 'phone' to 'mobileNumber'
      'otp': otpString,
    };

    debugPrint('📡 Making verify-otp API call with payload: $payload');
    debugPrint('📍 URL: api/auth/verify-otp');

    await apiFetcher.request(
      url: 'api/auth/verify-otp',  // ✅ Fixed: Added 'api/' prefix
      method: 'POST',
      body: payload,
      requireAuth: false,
    );

    debugPrint('📥 API Response: ${apiFetcher.data}');
    debugPrint('❌ API Error: ${apiFetcher.errorMessage}');

    // ✅ Success case - Check for token in response
    if (apiFetcher.errorMessage == null && apiFetcher.data != null) {
      debugPrint('✅ OTP verification successful: ${apiFetcher.data}');

      // ✅ CRITICAL FIX: Extract and save token FIRST before anything else
      final token = apiFetcher.data is Map ? apiFetcher.data['token'] : null;
      final userId = apiFetcher.data['userId'];
      final isNewUser = apiFetcher.data['isNewUser'] ?? false;
      final merchantId = apiFetcher.data['merchantId'];

      debugPrint('🔑 Token: ${token != null ? "${token.toString().substring(0, 20)}..." : "null"}');
      debugPrint('👤 User ID: $userId');
      debugPrint('🆕 Is New User: $isNewUser');
      debugPrint('🏢 Merchant ID: $merchantId');

      // ✅ CRITICAL: Save token to secure storage IMMEDIATELY
      if (token != null) {
        await AuthStorage.saveToken(token);
        debugPrint('✅ Token manually saved to storage');

        // Verify token was saved
        final savedToken = await AuthStorage.getToken();
        if (savedToken != null) {
          debugPrint('✅ Token verified in storage: ${savedToken.substring(0, 20)}...');
        } else {
          debugPrint('❌ WARNING: Token save failed!');
        }
      } else {
        debugPrint('⚠️ No token in OTP response - check API response format');
      }

      // Mark OTP as verified
      isOtpVerified = true;

      // Save phone number to secure storage
      await AuthStorage.savePhoneNumber(controller.phoneNumber);
      debugPrint('📱 Phone number saved: ${controller.phoneNumber}');

      // Save userId to secure storage (needed for creating merchant)
      if (userId != null) {
        await AuthStorage.saveUserId(userId.toString());
        debugPrint('👤 User ID saved: $userId');
      } else {
        debugPrint('⚠️ No user ID in OTP response');
      }

      // Clear old merchant ID if user is new (to prevent conflicts with old data)
      if (isNewUser) {
        await AuthStorage.clearMerchantId();
        debugPrint('🧹 Cleared old merchant ID for new user');
      }

      // Save merchant ID to secure storage if available
      if (merchantId != null) {
        await AuthStorage.saveMerchantId(merchantId);
        debugPrint('🏢 Merchant ID saved: $merchantId');
      } else {
        debugPrint('⚠️ No merchant ID in OTP response - will be set after shop details');
      }

      // Show success message
      AdvancedErrorService.showSuccess(
        AppStrings.getLocalizedString(context, (localizations) => localizations.otpVerifiedSuccessfully),
        type: SuccessType.snackbar,
      );

      // Wait for keyboard to close before navigation
      await Future.delayed(const Duration(milliseconds: 300));

      // ✅ SMART NAVIGATION: Check if merchant already exists
      debugPrint('');
      debugPrint('🔍 ========== NAVIGATION DECISION ==========');

      Future.delayed(const Duration(seconds: 1), () async {
        if (mounted && isOtpVerified) {
          // ✅ IMPROVED: Retry mechanism with exponential backoff
          // Sometimes backend needs time to sync merchant data with new session token
          int maxRetries = 3;
          int retryCount = 0;
          bool merchantFound = false;

          while (retryCount < maxRetries && !merchantFound) {
            // Add delay for retries (0ms for first attempt, then increasing delays)
            if (retryCount > 0) {
              final delayMs = retryCount * 1000; // 1s, 2s delays
              debugPrint('⏳ Retry attempt $retryCount/${maxRetries - 1} - Waiting ${delayMs}ms before checking again...');
              await Future.delayed(Duration(milliseconds: delayMs));
            }

            debugPrint('📡 Fetching all merchant data from /api/merchant/all (Attempt ${retryCount + 1}/$maxRetries)...');

            try {
              await apiFetcher.request(
                url: 'api/merchant/all',
                method: 'GET',
                requireAuth: true,
              );

              if (apiFetcher.errorMessage == null && apiFetcher.data != null) {
                debugPrint('✅ Merchant API response received (Attempt ${retryCount + 1})');
                debugPrint('📊 Response type: ${apiFetcher.data.runtimeType}');

                // ✅ STEP 2: Parse merchant data and match with logged-in phone
                if (apiFetcher.data is List && (apiFetcher.data as List).isNotEmpty) {
                  final loggedInPhone = await AuthStorage.getPhoneNumber();

                  // Normalize logged-in phone
                  String normalizedLoggedInPhone = loggedInPhone?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                  if (normalizedLoggedInPhone.startsWith('91') && normalizedLoggedInPhone.length == 12) {
                    normalizedLoggedInPhone = normalizedLoggedInPhone.substring(2);
                  }

                  // Find matching merchant
                  final merchantList = apiFetcher.data as List;
                  dynamic matchedMerchant;

                  for (var merchant in merchantList) {
                    if (merchant is Map) {
                      // ✅ FIX: Check BOTH phone/mobileNumber AND adminMobileNumber for number change support
                      String? merchantPhone = merchant['phone']?.toString() ?? merchant['mobileNumber']?.toString();
                      String? adminPhone = merchant['adminMobileNumber']?.toString();

                      // Check primary phone
                      bool primaryMatch = false;
                      if (merchantPhone != null) {
                        String normalizedMerchantPhone = merchantPhone.replaceAll(RegExp(r'[^0-9]'), '');
                        if (normalizedMerchantPhone.startsWith('91') && normalizedMerchantPhone.length == 12) {
                          normalizedMerchantPhone = normalizedMerchantPhone.substring(2);
                        }
                        primaryMatch = normalizedMerchantPhone == normalizedLoggedInPhone;
                      }

                      // Check admin phone (for changed numbers)
                      bool adminMatch = false;
                      if (adminPhone != null) {
                        String normalizedAdminPhone = adminPhone.replaceAll(RegExp(r'[^0-9]'), '');
                        if (normalizedAdminPhone.startsWith('91') && normalizedAdminPhone.length == 12) {
                          normalizedAdminPhone = normalizedAdminPhone.substring(2);
                        }
                        adminMatch = normalizedAdminPhone == normalizedLoggedInPhone;
                      }

                      if (primaryMatch || adminMatch) {
                        matchedMerchant = merchant;
                        debugPrint('✅ Found matching merchant: ${merchant['merchantId']} on attempt ${retryCount + 1}');
                        debugPrint('   Match type: ${primaryMatch ? "Primary phone" : "Admin phone (changed number)"}');
                        break;
                      }
                    }
                  }

                  // ✅ STEP 3: Save merchant data if found
                  if (matchedMerchant != null) {
                    final merchantId = int.tryParse(matchedMerchant['merchantId']?.toString() ?? '');
                    if (merchantId != null) {
                      await AuthStorage.saveMerchantId(merchantId);
                      await AuthStorage.markShopDetailsComplete();

                      // Save other merchant data if available
                      if (matchedMerchant['businessName'] != null) {
                        await AuthStorage.saveBusinessName(matchedMerchant['businessName'].toString());
                      }

                      debugPrint('✅ Merchant data saved to storage');
                      debugPrint('✅ DECISION: Merchant exists (ID: $merchantId)');
                      debugPrint('   → Navigate to Main Screen');
                      debugPrint('==========================================');
                      merchantFound = true;
                      Get.offAllNamed(AppRoutes.main);
                      return;
                    }
                  }
                } else {
                  debugPrint('⚠️ API returned empty merchant list on attempt ${retryCount + 1}');
                }
              } else {
                debugPrint('⚠️ API error on attempt ${retryCount + 1}: ${apiFetcher.errorMessage}');
              }
            } catch (e) {
              debugPrint('⚠️ Error fetching merchant on attempt ${retryCount + 1}: $e');
            }

            retryCount++;
          }

          // ✅ STEP 4: If no merchant found after all retries, navigate to Shop Detail Screen
          if (!merchantFound) {
            debugPrint('⚠️ DECISION: Merchant does not exist (checked $maxRetries times)');
            debugPrint('   → Navigate to Shop Detail Screen');
            debugPrint('   → User will fill merchant details');
            debugPrint('==========================================');
            debugPrint('');
            Get.offAllNamed(AppRoutes.shopDetail);
          }
        }
      });
    } else {
      // ❌ Fake/Invalid OTP case - Only show error if OTP is not already verified
      debugPrint('❌ OTP verification failed. Response: ${apiFetcher.data}');

      // ✅ Clear PIN boxes on wrong OTP
      _pinController.clear();
      controller.clearOtp();

      if (mounted && !isOtpVerified) {
        // 🔥 Always show same localized message as countdown expired case
        AdvancedErrorService.showError(
          AppStrings.getLocalizedString(context, (localizations) => localizations.invalidOrExpiredOtp),
          severity: ErrorSeverity.medium,
          category: ErrorCategory.validation,
          customDuration: Duration(milliseconds: 3000),
        );
      }
    }
  } catch (e) {
    debugPrint('💥 Exception in _handleVerifyOtp: $e');

    // ✅ Clear PIN boxes on exception
    _pinController.clear();
    controller.clearOtp();

    if (mounted && !isOtpVerified) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.verificationFailed),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.general,
      );
    }
  } finally {
    if (mounted) {
      controller.isLoading.value = false;
    }
  }
}

}
