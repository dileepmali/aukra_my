
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/constants/app_images.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/themes/app_text.dart';
import '../../../buttons/app_button.dart';
import '../../../controllers/image_carousel_controller.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../core/services/error_service.dart';
import '../../../core/untils/error_types.dart';
import '../../../core/untils/phone_validator.dart';
import '../../mobile/language/select_language_screen.dart';


/// Desktop layout for Number Verify Screen
/// Horizontal 2-column layout: Phone input form (left 40%), Image carousel (right 60%)
class NumberVerifyDesktopContent extends StatelessWidget {
  final ImageCarouselController? carouselController;
  final TextEditingController phoneController;
  final String selectedCountryCode;
  final String? phoneValidationError;
  final bool isLoading;
  final Function(String) onPhoneChanged;
  final Function(String) onPhoneSubmitted;
  final VoidCallback onSendOtp;

  const NumberVerifyDesktopContent({
    Key? key,
    required this.carouselController,
    required this.phoneController,
    required this.selectedCountryCode,
    this.phoneValidationError,
    required this.isLoading,
    required this.onPhoneChanged,
    required this.onPhoneSubmitted,
    required this.onSendOtp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🖥️ Desktop: 2-column layout (40% form + 60% carousel)
    return SafeArea(
      child: Row(
        children: [
          // LEFT SECTION (40%): Login Form with Gradient Background
          Expanded(
            flex: 40,
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
                  end: Alignment.topRight,
                  begin: Alignment.bottomLeft,

                ),
              ),
              child: Center(
                child: ConstrainedBox(
                             constraints: BoxConstraints(
                               minWidth: responsive.wp(26),  // Minimum width: 26%
                              maxWidth: responsive.wp(28),  // Maximum width: 28%
                               minHeight: responsive.hp(54), // Minimum height: 54%
                            maxHeight: responsive.hp(65),), // Maximum height: 62%
                  child: Container(
                    child: _buildFormSection(context, responsive, isDark),
                ),
              ),
            ),
          ),
            ),
          // RIGHT SECTION (60%): Image Carousel with Gradient Background
          Expanded(
            flex: 60,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                    AppColors.containerLight ?? Colors.black,
                    AppColors.containerDark ?? Colors.grey.shade800,
                  ]
                      : [
                    AppColorsLight.scaffoldBackground,
                    AppColorsLight.scaffoldBackground,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: _buildCarouselSection(context, responsive, isDark),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildFormSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    final phoneValidator = PhoneValidator.instance;

    return Container(
      padding: EdgeInsets.all(responsive.spaceLG),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
            AppColors.white ?? Colors.black,
            AppColors.white ?? Colors.grey.shade800,
                ]
              : [
                  AppColorsLight.white,
                  AppColorsLight.white,
                ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button Row
          GestureDetector(
            onTap: () => Get.off(() => const SelectLanguageScreen()),
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

          // Logo with Title and Subtitle
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo on the left
              Image.asset(
                AppImages.appLogoIm,
                height: responsive.iconSizeExtraLarge,
                fit: BoxFit.cover,
              ),
              SizedBox(width: responsive.spacing(4)),
              // Aukra Icon and Tagline
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Aukra SVG Icon (replacing AnantSpace text)
                    SvgPicture.asset(
                      AppIcons.aukraIc,
                      height: responsive.hp(1.8),
                    ),
                    SizedBox(height: responsive.space2XS),
                    // Tagline: Infinity Income Advance Income
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
          ),
          SizedBox(height: responsive.spaceXS),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Product by ",
                  style: AppFonts.bodyMedium(
                    color: isDark ? AppColors.black : AppColorsLight.black,
                    fontWeight: AppFonts.light,
                  ),
                ),
                TextSpan(
                  text: "AnantKaya",
                  style: AppFonts.bodyMedium(
                    color: isDark ? AppColors.black : AppColorsLight.black,
                    fontWeight: AppFonts.semiBold,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: isDark ? AppColors.black : AppColorsLight.black,
                  ),
                ),
                TextSpan(
                  text: " Solution Pvt.Ltd",
                  style: AppFonts.bodyMedium(
                    color: isDark ? AppColors.black : AppColorsLight.black,
                    fontWeight: AppFonts.light,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.spaceLG),

          // Title
          AppText.headlineSmall(
            "Enter Your\nMobile Number",
            color: isDark ? AppColors.black : AppColorsLight.black,
            maxLines: 2,
            minFontSize: 8,
            letterSpacing: 1.1,
          ),
          SizedBox(height: responsive.hp(1.5)),

          // Phone Input Field
          TextField(
            controller: phoneController,
            enabled: true,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            style: AppFonts.headlineSmall(
              color: isDark ? Colors.black : AppColorsLight.textPrimary,
              fontWeight: AppFonts.light,

            ),
            cursorColor: isDark ? AppColors.black : AppColorsLight.textPrimary,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                phoneValidator.getMaxLength(selectedCountryCode),
              ),
            ],
            onChanged: onPhoneChanged,
            onSubmitted: onPhoneSubmitted,
            decoration: InputDecoration(
              hintText: AppStrings.getLocalizedString(
                context,
                (localizations) => localizations.enterPhoneNumber,
              ),
              errorText: phoneValidationError,
              errorStyle: AppFonts.bodyLarge1(
                color: Colors.red,
                fontWeight: AppFonts.light,
              ),
              hintStyle: AppFonts.headlineSmall(
                color: isDark ? Colors.black : AppColorsLight.textSecondary,
                fontWeight: AppFonts.light,

              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.scaffoldBackground
                  : AppColorsLight.scaffoldBackground.withOpacity(0.5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: responsive.wp(0.5),
                vertical: responsive.hp(2.1),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.handleBarColor
                      : AppColors.shadowDark,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.handleBarColor
                      : AppColors.shadowDark,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                borderSide: BorderSide(
                  color: phoneValidationError != null
                      ? Colors.red
                      : (isDark
                          ? AppColors.handleBarColor
                          : AppColorsLight.splaceSecondary2),
                  width: 1.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.handleBarColor
                      : AppColorsLight.splaceSecondary2,
                  width: 1.0,
                ),
              ),
              prefixIcon: IntrinsicWidth(
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.wp(1.2),
                      ),
                      child: Text(
                        selectedCountryCode,
                        style: AppFonts.headlineSmall(
                          color: isDark ? Colors.black : AppColorsLight.textPrimary,
                          fontWeight: AppFonts.light,
                        ),
                      ),
                    ),
                    Container(
                      width: 1.5,
                      height: responsive.hp(4.5),
                      color: isDark
                          ? AppColors.black.withOpacity(0.8)
                          : AppColorsLight.black,
                      margin: EdgeInsets.only(right: responsive.wp(1)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: responsive.hp(1)),



          // Send OTP Button
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
            onPressed: isLoading ? null : onSendOtp,
            child: isLoading
                ? Center(
                  child: SizedBox(
                    height: responsive.hp(3.5),
                    width: responsive.wp(1.9),
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 1.5,
                    ),
                  ),
                )
                : Center(
                    child: AppText.headlineSmall(
                      AppStrings.getLocalizedString(
                        context,
                        (localizations) => localizations.sendOtp,
                      ),
                      color: Colors.white,
                      maxLines: 1,
                      minFontSize: 19,
                      letterSpacing: 1.1,
                      textAlign: TextAlign.center,
                      fontWeight:  FontWeight.w500
                    ),
                  ),
          ),
          SizedBox(height: responsive.hp(1)),

          // Terms and Conditions
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppStrings.getLocalizedString(
                    context,
                        (localizations) => localizations.byClicking,
                  ),
                  style: AppFonts.bodyLarge1(
                    color: isDark
                        ? AppColors.black.withOpacity(0.7)
                        : AppColorsLight.textSecondary,
                  ),
                ),
                TextSpan(
                  text: '  ',
                  style: AppFonts.bodyLarge1(
                    color: isDark
                        ? Colors.grey[400]
                        : AppColorsLight.textSecondary,
                  ),
                ),
                TextSpan(
                  text: AppStrings.getLocalizedString(
                    context,
                        (localizations) => localizations.termsConditions,
                  ),
                  style: AppFonts.bodyLarge1(
                    color: isDark ? AppColors.blue : AppColors.blue,
                  ).copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: isDark ? AppColors.blue : AppColors.blue,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri termsUrl = Uri.parse(
                          'https://anantkaya.com/term-condition.html');
                      if (await canLaunchUrl(termsUrl)) {
                        await launchUrl(
                          termsUrl,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        AdvancedErrorService.showError(
                          'Could not open terms and conditions',
                          category: ErrorCategory.general,
                          severity: ErrorSeverity.low,
                        );
                      }
                    },
                ),
              ],
            ),
          ),

          SizedBox(height: responsive.hp(3)),

          // OR Divider Row
          Row(
            children: [
              // Left Divider
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark
                      ? AppColors.black.withOpacity(0.3)
                      : AppColorsLight.border,
                ),
              ),
              // Center Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.spaceSM),
                child: AppText.headlineSmall1(
                  'or',
                  color: isDark
                      ? AppColors.black.withOpacity(0.5)
                      : AppColorsLight.textSecondary,
                ),
              ),
              // Right Divider
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark
                      ? AppColors.black.withOpacity(0.3)
                      : AppColorsLight.border,
                ),
              ),
            ],
          ),

          SizedBox(height: responsive.spaceMD),

          // Sign Up Text
          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Don't have an account? ",
                    style: AppFonts.bodyLarge1(
                      color: isDark
                          ? AppColors.black.withOpacity(0.5)
                          : AppColorsLight.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: "Sign up for one now",
                    style: AppFonts.bodyLarge1(
                      color: isDark ? AppColors.blue : AppColors.black,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: isDark ? AppColors.blue : AppColors.black,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // TODO: Handle sign up navigation
                        debugPrint('Sign up tapped');
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// RIGHT SECTION: Image Carousel with overlaid text container
  Widget _buildCarouselSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    if (carouselController?.pageController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // BACKGROUND: PageView with Images (scrollable)
        PageView.builder(
          controller: carouselController!.pageController!,
          onPageChanged: (index) {
            carouselController!.onPageChanged(index);
            carouselController!.restartAutoScroll();
          },
          itemCount: carouselController!.dataLength,
          itemBuilder: (context, index) {
            final data = carouselController!.onboardingData[index];

            return Container(
              margin: EdgeInsets.only(top: responsive.hp(1.5),bottom: responsive.hp(1.5),right: responsive.hp(1.5)),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(data['image']!),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
            );
          },
        ),

        // OVERLAY: Fixed bottom container with dynamic text (does NOT scroll)
        Positioned(
          left: responsive.spacing(16),
          right: responsive.hp(50),
          bottom: responsive.spacing(28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: responsive.wp(15),  // Minimum width: 15%
              maxWidth: responsive.wp(20),  // Maximum width: 20%
              minHeight: responsive.wp(12),  // Minimum height: 14%
              maxHeight: responsive.wp(15), // Maximum height: 16%
            ),
            child: Container(
              padding: EdgeInsets.all(responsive.spacing(10)),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withOpacity(0.3) // Transparent dark
                    : Colors.white.withOpacity(0.3), // Transparent light
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
              ),
              child: Obx(() {
                // Get current index from controller
                final currentIndex = carouselController!.currentIndex.value;
                final data = carouselController!.onboardingData[currentIndex];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title (changes with page)
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey('title_$currentIndex'),
                        child: AppText.headlineMedium(
                          _getLocalizedText(data['title'] ?? '', context),
                          color: isDark ? Colors.white : AppColorsLight.textPrimary,
                          maxLines: 2,
                          minFontSize: 9,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.spacing(6)),

                    // Subtitle (changes with page)
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey('subtitle_$currentIndex'),
                        child: AppText.bodyLarge1(
                          _getLocalizedText(data['subtitle'] ?? '', context),
                          color: isDark ? Colors.grey[300] : AppColorsLight.textSecondary,
                          maxLines: 3,
                          minFontSize: 9,
                        ),
                      ),
                    ),
                    SizedBox(height: responsive.hp(4)),

                    // Dot Indicators
                    _buildCarouselIndicators(responsive, isDark),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// Convert localization key to localized string
  String _getLocalizedText(String key, BuildContext context) {
    return AppStrings.getLocalizedString(context, (localizations) {
      switch (key) {
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

  /// Carousel dot indicators
  Widget _buildCarouselIndicators(AdvancedResponsiveHelper responsive, bool isDark) {
    if (carouselController == null) return SizedBox.shrink();

    return Obx(() => Row(
          children: List.generate(
            carouselController!.dataLength,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: responsive.spacing(8)),
              width: responsive.spacing(8),
              height: responsive.spacing(7),
              decoration: BoxDecoration(
                color: carouselController!.currentIndex.value == index
                    ? AppColors.splaceSecondary2
                    : (isDark ? Colors.grey[600] : AppColorsLight.border),
                borderRadius: BorderRadius.circular(responsive.spacing(1)),
              ),
            ),
          ),
        ));
  }

}
