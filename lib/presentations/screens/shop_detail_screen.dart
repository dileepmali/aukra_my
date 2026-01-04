import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../app/localizations/l10n/app_strings.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_fonts.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/app_button.dart';
import '../../controllers/shop_detail_controller.dart';
import '../../core/api/auth_storage.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';
import '../../core/services/back_button_service.dart';
import '../../core/services/error_service.dart';
import '../../core/untils/error_types.dart';
import '../../core/untils/phone_number_formatter.dart';
import '../../models/merchant_model.dart';
import '../widgets/custom_border_widget.dart';
import '../widgets/text_filed/search_bar.dart';
import '../widgets/text_filed/custom_text_field.dart';
import 'main_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  const ShopDetailScreen({Key? key}) : super(key: key);

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  late ShopDetailController controller;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController ownerPhoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final FocusNode nameFocusNode = FocusNode();
  final FocusNode shopNameFocusNode = FocusNode();
  final FocusNode locationFocusNode = FocusNode();
  final FocusNode ownerPhoneFocusNode = FocusNode();
  final FocusNode otpFocusNode = FocusNode();

  final GlobalKey nameFieldKey = GlobalKey();
  final GlobalKey shopNameFieldKey = GlobalKey();
  final GlobalKey locationFieldKey = GlobalKey();
  final GlobalKey ownerPhoneFieldKey = GlobalKey();
  final GlobalKey otpFieldKey = GlobalKey();

  Worker? _phoneWorker; // Track the worker to dispose it later

  @override
  void initState() {
    super.initState();

    // Initialize controller
    if (!Get.isRegistered<ShopDetailController>()) {
      Get.put(ShopDetailController());
    }
    controller = Get.find<ShopDetailController>();

    debugPrint('🔍 ShopDetailScreen: Controller initialized');
    debugPrint('📱 ShopDetailScreen: Current registered phone: ${controller.registeredPhone.value}');

    // Auto-fill owner phone number with registered number
    // Use ever() to reactively fill when phone loads
    _phoneWorker = ever(controller.registeredPhone, (phone) {
      debugPrint('🔔 ShopDetailScreen: registeredPhone changed to: $phone');
      if (mounted && phone.isNotEmpty) {
        // Remove any formatting and set the raw number
        String rawNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
        debugPrint('🔍 ShopDetailScreen: Raw number extracted: $rawNumber (length: ${rawNumber.length})');

        // If number starts with 91 and is 12 digits (91 + 10 digits), remove 91 prefix
        if (rawNumber.length == 12 && rawNumber.startsWith('91')) {
          rawNumber = rawNumber.substring(2); // Remove first 2 digits (91)
          debugPrint('🔧 ShopDetailScreen: Removed 91 prefix, new number: $rawNumber');
        }

        if (rawNumber.length == 10) {
          debugPrint('✅ ShopDetailScreen: Auto-filling owner phone with: $rawNumber');
          ownerPhoneController.text = rawNumber;
        } else {
          debugPrint('⚠️ ShopDetailScreen: Number length is not 10 (${rawNumber.length}), skipping auto-fill');
        }
      } else {
        debugPrint('⚠️ ShopDetailScreen: Phone is empty or widget not mounted');
      }
    });

    // Also try immediate fill if phone is already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('🔍 ShopDetailScreen: PostFrameCallback - checking for immediate fill');
      // Wait a bit for controller to load phone
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted && controller.registeredPhone.value.isNotEmpty) {
        String rawNumber = controller.registeredPhone.value.replaceAll(RegExp(r'[^0-9]'), '');
        debugPrint('🔍 ShopDetailScreen: Found registered phone immediately: $rawNumber (length: ${rawNumber.length})');

        // If number starts with 91 and is 12 digits (91 + 10 digits), remove 91 prefix
        if (rawNumber.length == 12 && rawNumber.startsWith('91')) {
          rawNumber = rawNumber.substring(2); // Remove first 2 digits (91)
          debugPrint('🔧 ShopDetailScreen: Removed 91 prefix immediately, new number: $rawNumber');
        }

        if (rawNumber.length == 10) {
          debugPrint('✅ ShopDetailScreen: Auto-filling owner phone immediately: $rawNumber');
          setState(() {
            ownerPhoneController.text = rawNumber;
          });
        } else {
          debugPrint('⚠️ ShopDetailScreen: Number length is not 10 (${rawNumber.length}) in immediate check');
        }
      } else {
        debugPrint('⚠️ ShopDetailScreen: No phone found in immediate check');
      }
    });

    // Register back button interceptor
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BackButtonService.pushScreen('ShopDetailScreen');
        BackButtonService.registerWithCleanup(
          screenName: 'ShopDetailScreen',
          onBackPressed: () {
            Get.back();
            return ;
          },
          interceptorName: 'shop_detail_interceptor',
        );
      }
    });
  }

  @override
  void dispose() {
    BackButtonService.remove(interceptorName: 'shop_detail_interceptor');
    _phoneWorker?.dispose(); // Dispose the worker
    nameController.dispose();
    shopNameController.dispose();
    locationController.dispose();
    ownerPhoneController.dispose();
    otpController.dispose();
    nameFocusNode.dispose();
    shopNameFocusNode.dispose();
    locationFocusNode.dispose();
    ownerPhoneFocusNode.dispose();
    otpFocusNode.dispose();
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
                  bottom: 0,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: responsive.screenPadding.left,
                      right: responsive.screenPadding.right,
                      top: responsive.screenPadding.top,
                      bottom: responsive.hp(20), // Increased space for fixed button and extra bottom padding
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: responsive.spaceMD),

                        // Header
                        AppText.displayMedium1(
                          AppStrings.getLocalizedString(context, (localizations) => localizations.addBusinessShopDetails),
                          color: isDark ? Colors.white : AppColorsLight.textPrimary,
                          maxLines: 2,
                          minFontSize: 14,
                          textAlign: TextAlign.left,
                        ),

                        SizedBox(height: responsive.spaceXL),

                        // Name Field
                        _buildInputField(
                          responsive,
                          isDark,
                          context,
                          label: AppStrings.getLocalizedString(context, (localizations) => localizations.name),
                          controller: nameController,
                          focusNode: nameFocusNode,
                          nextFocusNode: shopNameFocusNode,
                          minLines: 1,
                          maxLines: 1,
                          fieldKey: nameFieldKey,
                        ),

                        SizedBox(height: responsive.spaceMD),

                        // Business/Shop Name Field
                        _buildInputField(
                          responsive,
                          isDark,
                          context,
                          label: AppStrings.getLocalizedString(context, (localizations) => localizations.businessShopName),
                          controller: shopNameController,
                          focusNode: shopNameFocusNode,
                          nextFocusNode: locationFocusNode,
                          minLines: 1,
                          maxLines: 1,
                          fieldKey: shopNameFieldKey,
                        ),

                        SizedBox(height: responsive.spaceMD),

                        // Location/Address Field
                        _buildInputField(
                          responsive,
                          isDark,
                          context,
                          label: AppStrings.getLocalizedString(context, (localizations) => localizations.locationAddress),
                          controller: locationController,
                          focusNode: locationFocusNode,
                          nextFocusNode: ownerPhoneFocusNode,
                          minLines: 2,
                          maxLines: null,
                          fieldKey: locationFieldKey,
                        ),

                        SizedBox(height: responsive.spaceMD),

                        // Registered Mobile Number (Read-only)
                        _buildReadOnlyField(
                          responsive,
                          isDark,
                          context,
                          label: AppStrings.getLocalizedString(context, (localizations) => localizations.registeredMobileNumber),
                          value: controller.registeredPhone.value,
                        ),

                        SizedBox(height: responsive.spaceMD),

                        // Owner (Master mobile number) with Send OTP button
                        _buildOwnerPhoneField(responsive, isDark, context),

                        SizedBox(height: responsive.spaceMD),

                        // OTP Input Section
                        Obx(() {
                          debugPrint('🔄 OTP Section Obx rebuilding - isOtpSent: ${controller.isOtpSent.value}');
                          return controller.isOtpSent.value
                              ? _buildOtpSection(responsive, isDark, context)
                              : SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                ),

                // Fixed bottom button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: responsive.screenPadding.left,
                      right: responsive.screenPadding.right,
                      bottom: responsive.screenPadding.bottom,
                      top: responsive.hp(1),
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.overlay : AppColorsLight.scaffoldBackground,
                    ),
                    child: _buildSubmitButton(responsive),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _scrollToField(GlobalKey fieldKey) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (fieldKey.currentContext != null) {
        Scrollable.ensureVisible(
          fieldKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: 0.2, // Position field at 20% from top
        );
      }
    });
  }

  Widget _buildInputField(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    int? maxLines = 1,
    int? minLines,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    TextInputAction? textInputAction,
    GlobalKey? fieldKey,
  }) {
    return Column(
      key: fieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.searchbar2(
          label,
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 12,
        ),
        SizedBox(height: responsive.spaceXSS),
        CustomTextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: 2,
          minLines: minLines,
          hintText: '',
          showBorder: true,
          filled: true,
          textInputAction: textInputAction ?? (nextFocusNode != null ? TextInputAction.next : TextInputAction.done),
          onTap: () {
            if (fieldKey != null) {
              _scrollToField(fieldKey);
            }
          },
          onSubmitted: (value) {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            }
          },
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(
    AdvancedResponsiveHelper responsive,
    bool isDark,
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.searchbar2(
          label,
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 12,
        ),
        SizedBox(height: responsive.spaceXSS),
        Obx(() => CustomTextField(
          controller: TextEditingController(
            text: formatPhoneNumber(controller.registeredPhone.value),
          ),
          readOnly: true,
          enabled: false,
          fillColor: isDark ? AppColors.black : AppColorsLight.white,
          textColor: isDark ? Colors.grey[500] : AppColorsLight.textSecondary,
          showBorder: true,
          filled: true,
          fontSize: responsive.fontSize(20),
        )),
      ],
    );
  }

  Widget _buildOwnerPhoneField(AdvancedResponsiveHelper responsive, bool isDark, BuildContext context) {
    return Column(
      key: ownerPhoneFieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.searchbar2(
          AppStrings.getLocalizedString(context, (localizations) => localizations.ownerMasterMobileNumber),
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 12,
        ),
        SizedBox(height: responsive.spaceXSS),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                height: responsive.hp(6.5),
                child: CustomTextField(
                  controller: ownerPhoneController,
                  focusNode: ownerPhoneFocusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  hintText: '+91 XXXXXXXXXX',
                  showBorder: true,
                  filled: true,
                  fontSize: responsive.fontSize(20),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    PhoneNumberFormatter(),
                  ],
                  onChanged: (value) {
                    // ✅ Force rebuild to update Send OTP button state
                    setState(() {
                      // TextField value changed, rebuild to update isDifferent check
                    });
                  },
                  onTap: () {
                    _scrollToField(ownerPhoneFieldKey);
                  },
                  onSubmitted: (value) {
                    final rawOwner = value.replaceAll(RegExp(r'[^0-9]'), '');
                    final rawRegistered = controller.registeredPhone.value.replaceAll(RegExp(r'[^0-9]'), '');

                    if (rawOwner.length == 10 && rawOwner != rawRegistered) {
                      _handleSendOtp();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: responsive.spaceMD),
            Expanded(
              flex: 4,
              child: Obx(() {
                // Check if owner number is different from registered number
                final rawOwner = ownerPhoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                String rawRegistered = controller.registeredPhone.value.replaceAll(RegExp(r'[^0-9]'), '');

                // Handle +91 prefix in registered number
                if (rawRegistered.length == 12 && rawRegistered.startsWith('91')) {
                  rawRegistered = rawRegistered.substring(2);
                }

                // Button enabled only if numbers are different AND valid 10 digits
                final isDifferent = rawOwner.isNotEmpty && rawOwner != rawRegistered && rawOwner.length == 10;

                return SizedBox(
                  height: responsive.hp(6.5),
                  width: double.infinity,
                  child: AppButton(
                    textAlign: TextAlign.center,
                    gradientColors: [
                      // Always use normal gradient colors (same for both enabled/disabled)
                      isDark ? AppColors.containerLight : AppColorsLight.textSecondary,
                      isDark ? AppColors.containerDark : AppColorsLight.textSecondary,
                    ],
                    enableSweepGradient: false,
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    // Disable button if: sending OTP OR numbers are same
                    onPressed: (controller.isSendingOtp.value || !isDifferent) ? null : _handleSendOtp,
                    child: controller.isSendingOtp.value
                        ? Center(
                          child: SizedBox(
                            height: responsive.wp(5),
                            width: responsive.wp(5),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                        : Center(
                            child: AppText.headlineLarge(
                              AppStrings.getLocalizedString(context, (localizations) => localizations.sendOtp),
                              // Text color: White when enabled, Grey when disabled
                              color: isDifferent
                                  ? Colors.white
                                  : (isDark ? Colors.grey[600] : Colors.grey[400]),
                              maxLines: 1,
                              minFontSize: 11,
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOtpSection(AdvancedResponsiveHelper responsive, bool isDark, BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: responsive.wp(18),
      height: responsive.hp(8.5),
      textStyle: AppFonts.displaySmall(
        color: isDark ? Colors.white : AppColorsLight.textPrimary,
        fontWeight: AppFonts.regular,
      ),
      decoration: BoxDecoration(
        // ✅ Apply gradient colors for PIN box
        gradient: isDark
          ? LinearGradient(
              colors: [
                AppColors.black,
                AppColors.black,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                AppColorsLight.gradientColor1,
                AppColorsLight.gradientColor2,
              ],
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

    // Add focus listener to scroll to OTP field
    otpFocusNode.addListener(() {
      if (otpFocusNode.hasFocus) {
        _scrollToField(otpFieldKey);
      }
    });

    // Auto-fill OTP ONLY if API returned an OTP (development mode)
    // If receivedOtp is empty, user will type manually
    if (controller.receivedOtp.value.isNotEmpty &&
        controller.receivedOtp.value.length == 4 &&
        otpController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          otpController.text = controller.receivedOtp.value;
          debugPrint('🔑 Auto-filled OTP from API: ${controller.receivedOtp.value}');
        }
      });
    } else if (controller.receivedOtp.value.isEmpty) {
      debugPrint('📝 No OTP from API - User will type manually');
    }

    return Column(
      key: otpFieldKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.searchbar2(
          AppStrings.getLocalizedString(context, (localizations) => localizations.enterOtp),
          color: isDark ? Colors.grey[400] : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 12,
        ),
        SizedBox(height: responsive.spaceXSS),
        Obx(() => Opacity(
          opacity: controller.isOtpExpired.value ? 0.5 : 1.0, // ✅ Dim when expired
          child: AbsorbPointer(
            absorbing: controller.isOtpExpired.value, // ✅ Disable input when expired
            child: Pinput(
              controller: otpController,
              focusNode: otpFocusNode,
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
              showCursor: !controller.isOtpExpired.value, // ✅ Hide cursor when expired
              keyboardType: TextInputType.number,
              onCompleted: (code) {
                controller.verifyOwnerOtp(code);
              },
            ),
          ),
        )),
        SizedBox(height: responsive.spaceXSS),
        // ✅ Show expiry message
        Obx(() => controller.isOtpExpired.value
            ? Padding(
                padding: EdgeInsets.only(bottom: responsive.spaceXSS),
                child: AppText.searchbar2(
                  'OTP expired. Please request a new OTP.',
                  color: Colors.red,
                  maxLines: 2,
                  minFontSize: 10,
                ),
              )
            : SizedBox.shrink()),
        SizedBox(height: responsive.spaceXSS),
        Obx(() => Row(
          children: [
            controller.isResendAvailable.value
                ? GestureDetector(
                    onTap: () async {
                      debugPrint('🔄 Resend OTP clicked');
                      // Clear old OTP
                      otpController.clear();
                      // Call same API as Send OTP
                      await controller.sendOwnerOtp(ownerPhoneController.text.trim());
                    },
                    child: AppText.searchbar2(
                      AppStrings.getLocalizedString(context, (localizations) => localizations.resendOtp),
                      color: isDark ? Colors.white : AppColorsLight.textPrimary,
                      maxLines: 1,
                      minFontSize: 11,
                    ),
                  )
                : AppText.searchbar2(
                    AppStrings.getLocalizedString(context, (localizations) => localizations.resendOtp),
                    color: isDark ? Colors.grey[600] : AppColorsLight.textSecondary,
                    maxLines: 1,
                    minFontSize: 11,
                  ),
            if (!controller.isResendAvailable.value) ...[
              AppText.searchbar(
                ' in ${controller.resendTimer.value} seconds',
                color: isDark ? Colors.grey[600] : AppColorsLight.textSecondary,
                maxLines: 1,
                minFontSize: 11,
              ),
            ],
          ],
        )),
      ],
    );
  }

  Widget _buildSubmitButton(AdvancedResponsiveHelper responsive) {
    return Obx(() {
      return AppButton(
        width: double.infinity,
        height: responsive.hp(9),
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
        onPressed: controller.isLoading.value ? null : _handleSubmit,
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
                  AppStrings.getLocalizedString(context, (localizations) => localizations.confirmFinish),
                  color: Colors.black,
                  maxLines: 1,
                  minFontSize: 12,
                  textAlign: TextAlign.center,
                ),
              ),
      );
    });
  }

  Future<void> _handleSendOtp() async {
    debugPrint('🔵 _handleSendOtp() called');
    final phone = ownerPhoneController.text.trim();
    debugPrint('📱 Owner phone text: "$phone"');

    // Extract only digits for validation
    final rawPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    debugPrint('📱 Raw phone (digits only): "$rawPhone"');

    // Handle +91 prefix
    String cleanedPhone = rawPhone;
    if (rawPhone.startsWith('91') && rawPhone.length == 12) {
      cleanedPhone = rawPhone.substring(2);
      debugPrint('📱 Removed +91 prefix, cleaned phone: "$cleanedPhone"');
    }

    if (cleanedPhone.isEmpty || cleanedPhone.length != 10) {
      debugPrint('❌ Validation failed: Phone length is ${cleanedPhone.length}, expected 10');
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterValidMobileNumber),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    debugPrint('✅ Validation passed, calling controller.sendOwnerOtp()');
    debugPrint('📊 Before API call - isOtpSent: ${controller.isOtpSent.value}');

    await controller.sendOwnerOtp(phone);

    debugPrint('📊 After API call - isOtpSent: ${controller.isOtpSent.value}');
    debugPrint('📊 After API call - receivedOtp: ${controller.receivedOtp.value}');

    // ✅ Scroll to OTP field after OTP section appears
    if (controller.isOtpSent.value) {
      debugPrint('✅ OTP sent successfully - Scrolling to OTP field');
      await Future.delayed(Duration(milliseconds: 300)); // Wait for UI to update
      _scrollToField(otpFieldKey);

      // Auto-focus OTP field
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(otpFocusNode);
          debugPrint('✅ OTP field focused');
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();

    final merchantName = nameController.text.trim();
    final businessName = shopNameController.text.trim();
    final location = locationController.text.trim();
    final ownerPhone = ownerPhoneController.text.trim();

    // Validation
    if (merchantName.isEmpty) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.name),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    if (businessName.isEmpty) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterBusinessShopName),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    if (location.isEmpty) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterLocationAddress),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    // ✅ IMPROVED: Normalize and validate phone numbers
    String rawRegistered = controller.registeredPhone.value.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawRegistered.length == 12 && rawRegistered.startsWith('91')) {
      rawRegistered = rawRegistered.substring(2);
    }

    String rawOwner = ownerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawOwner.length == 12 && rawOwner.startsWith('91')) {
      rawOwner = rawOwner.substring(2);
    }

    // ✅ Validate owner phone number format (must be 10 digits)
    if (rawOwner.isEmpty || rawOwner.length != 10) {
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.pleaseEnterValidMobileNumber),
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    bool isOwnerDifferent = rawOwner != rawRegistered;

    debugPrint('');
    debugPrint('🔍 ========== PHONE NUMBER VALIDATION ==========');
    debugPrint('📱 Registered Number: $rawRegistered');
    debugPrint('📱 Owner Number: $rawOwner');
    debugPrint('🔄 Is Different: $isOwnerDifferent');
    debugPrint('✅ OTP Verified: ${controller.isOwnerOtpVerified.value}');
    debugPrint('=============================================');
    debugPrint('');

    // ✅ CRITICAL VALIDATION: If owner number is DIFFERENT, OTP verification is MANDATORY
    if (isOwnerDifferent && !controller.isOwnerOtpVerified.value) {
      debugPrint('❌ Validation Failed: Different owner number requires OTP verification');
      AdvancedErrorService.showError(
        'Please verify master mobile number with OTP',
        severity: ErrorSeverity.medium,
        category: ErrorCategory.validation,
      );
      return;
    }

    // ✅ SUCCESS: Validation passed
    if (isOwnerDifferent) {
      debugPrint('✅ Different owner number - OTP verified');
    } else {
      debugPrint('✅ Same owner number - No OTP verification needed');
    }

    try {
      controller.isLoading.value = true;

      // Validate address - should have minimum 5 characters and not be random
      if (location.trim().length < 5) {
        AdvancedErrorService.showError(
          'Please enter a valid address (minimum 5 characters)',
          severity: ErrorSeverity.medium,
          category: ErrorCategory.validation,
        );
        controller.isLoading.value = false;
        return;
      }

      // ✅ IMPROVED: Prepare merchant data with proper handling for same/different numbers
      final merchant = MerchantModel(
        merchantName: merchantName,
        businessName: businessName,
        mobileNumber: rawRegistered,
        address: location.trim(),
        city: '', // Empty for now
        area: '', // Empty for now
        state: '', // Empty for now
        country: 'INDIA',
        pinCode: '', // Empty for now
        location: null, // GPS coordinates not required for now
        // ✅ FIX: Always send owner number (same or different)
        masterMobileNumber: rawOwner,
        // ✅ FIX: Only send OTP when numbers are DIFFERENT (and OTP is verified)
        otp: isOwnerDifferent ? otpController.text.trim() : null,
      );

      debugPrint('📋 Submitting merchant:');
      debugPrint('   Merchant Name: $merchantName');
      debugPrint('   Business Name: $businessName');
      debugPrint('   Registered Phone: $rawRegistered');
      debugPrint('   Master Phone: $rawOwner');
      debugPrint('   Is Owner Different: $isOwnerDifferent');
      debugPrint('   OTP Included: ${merchant.otp != null}');

      final result = await controller.submitMerchantDetails(merchant);

      if (result) {
        // ✅ Mark shop details as complete
        await AuthStorage.markShopDetailsComplete();
        debugPrint('✅ Shop details marked as complete in storage');

        AdvancedErrorService.showSuccess(
          AppStrings.getLocalizedString(context, (localizations) => localizations.detailsSavedSuccessfully),
          type: SuccessType.snackbar,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        // Navigate to main screen
        Get.offAll(() => const MainScreen());
      } else {
        throw Exception('Failed to save merchant details');
      }
    } catch (e) {
      debugPrint('❌ Error submitting merchant details: $e');
      AdvancedErrorService.showError(
        AppStrings.getLocalizedString(context, (localizations) => localizations.failedToSaveDetails),
        severity: ErrorSeverity.high,
        category: ErrorCategory.general,
      );
    } finally {
      controller.isLoading.value = false;
    }
  }
}
