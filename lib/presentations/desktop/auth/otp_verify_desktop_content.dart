import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
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
import '../../mobile/auth/number_verify_screen.dart';

/// Desktop layout for OTP Verify Screen
/// Horizontal 2-column layout: OTP form (left 40%), Image carousel (right 60%)
class OtpVerifyDesktopContent extends StatefulWidget {
  final ImageCarouselController? carouselController;
  final TextEditingController pinController;
  final FocusNode pinFocusNode;
  final String phoneNumber;
  final bool isLoading;
  final bool isResendAvailable;
  final int resendTimer;
  final Function(String) onOtpChanged;
  final Function(String) onOtpCompleted;
  final Function(String) onOtpSubmitted;
  final VoidCallback onVerifyOtp;
  final VoidCallback onResendOtp;

  const OtpVerifyDesktopContent({
    Key? key,
    required this.carouselController,
    required this.pinController,
    required this.pinFocusNode,
    required this.phoneNumber,
    required this.isLoading,
    required this.isResendAvailable,
    required this.resendTimer,
    required this.onOtpChanged,
    required this.onOtpCompleted,
    required this.onOtpSubmitted,
    required this.onVerifyOtp,
    required this.onResendOtp,
  }) : super(key: key);

  @override
  State<OtpVerifyDesktopContent> createState() => _OtpVerifyDesktopContentState();
}

class _OtpVerifyDesktopContentState extends State<OtpVerifyDesktopContent> {
  @override
  void initState() {
    super.initState();
    // 🔥 Auto-focus OTP input field when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.pinFocusNode.requestFocus();
    });
  }

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
              child: Center(
                child: ConstrainedBox(
                             constraints: BoxConstraints(
                                 minWidth: responsive.wp(26),  // Minimum width: 20%
                                 maxWidth: responsive.wp(28),  // Maximum width: 35%
                                 minHeight: responsive.hp(50), // Minimum height: 40%
                                 maxHeight: responsive.hp(52),), /// Maximum height: 70%
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


  /// RIGHT SECTION: Image Carousel with overlaid text container
  Widget _buildCarouselSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    if (widget.carouselController?.pageController == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // BACKGROUND: PageView with Images (scrollable)
        PageView.builder(
          controller: widget.carouselController!.pageController!,
          onPageChanged: (index) {
            widget.carouselController!.onPageChanged(index);
            widget.carouselController!.restartAutoScroll();
          },
          itemCount: widget.carouselController!.dataLength,
          itemBuilder: (context, index) {
            final data = widget.carouselController!.onboardingData[index];

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
                final currentIndex = widget.carouselController!.currentIndex.value;
                final data = widget.carouselController!.onboardingData[currentIndex];

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
                    SizedBox(height: responsive.spacing(8)),

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
                    SizedBox(height: responsive.hp(8)),

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
    if (widget.carouselController == null) return SizedBox.shrink();

    return Obx(() => Row(
          children: List.generate(
            widget.carouselController!.dataLength,
            (index) => AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.only(right: responsive.spacing(8)),
              width: responsive.spacing(8),
              height: responsive.spacing(7),
              decoration: BoxDecoration(
                color: widget.carouselController!.currentIndex.value == index
                    ? AppColors.splaceSecondary2
                    : (isDark ? Colors.grey[600] : AppColorsLight.border),
                borderRadius: BorderRadius.circular(responsive.spacing(1)),
              ),
            ),
          ),
        ));
  }

  Widget _buildFormSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
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
            onTap: () => Get.off(() => const NumberVerifyScreen()),
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
            "Enter OTP received on your\nmobile number ${widget.phoneNumber}",
            color: isDark ? AppColors.black : AppColorsLight.black,
            maxLines: 2,
            minFontSize: 8,
            letterSpacing: 1.1,
          ),
          SizedBox(height: responsive.hp(1.5)),

          // OTP Input Field
          _buildOtpInputField(responsive, isDark),

          SizedBox(height: responsive.hp(1)),

          // Resend OTP Section
          _buildResendOtpSection(context, responsive, isDark),

          SizedBox(height: responsive.hp(2)),

          // Verify OTP Button
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
            onPressed: widget.isLoading ? null : widget.onVerifyOtp,
            child: widget.isLoading
                ? Center(
                  child: SizedBox(
                    height: responsive.hp(3.5),
                    width: responsive.wp(1.9),
                    child: CircularProgressIndicator(
                      color: AppColors.buttonTextColor,
                      strokeCap: StrokeCap.round,
                      strokeWidth: 1.5,
                    ),
                  ),
                )
                : Center(
                    child: AppText.headlineSmall(
                      AppStrings.getLocalizedString(
                        context,
                        (localizations) => localizations.submitOtp,
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


        ],
      ),
    );
  }

  Widget _buildOtpInputField(AdvancedResponsiveHelper responsive, bool isDark) {
    final defaultPinTheme = PinTheme(
      width: responsive.wp(3.5),
      height: responsive.hp(7),
      textStyle: AppFonts.headlineMedium(
        color: isDark ? Colors.black : AppColorsLight.textPrimary,
        fontWeight: AppFonts.light,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.scaffoldBackground
            : AppColorsLight.inputBackground,
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
        border: Border.all(
          color: isDark
              ? AppColors.splaceSecondary2
              : AppColorsLight.splaceSecondary2,
          width: 1.5,
        ),
      ),
    );

    return Pinput(
      controller: widget.pinController,
      focusNode: widget.pinFocusNode,
      length: 4,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: defaultPinTheme.decoration!.copyWith(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          border: Border.all(
            color: isDark
                ? AppColors.splaceSecondary2
                : AppColorsLight.splaceSecondary2,
            width: 1.0,
          ),
        ),
      ),
      submittedPinTheme: defaultPinTheme,
      showCursor: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      onChanged: widget.onOtpChanged,
      onCompleted: widget.onOtpCompleted,
      onSubmitted: widget.onOtpSubmitted,
    );
  }

  Widget _buildResendOtpSection(
    BuildContext context,
    AdvancedResponsiveHelper responsive,
    bool isDark,
  ) {
    return Row(
      children: [
        AppText.bodyLarge1(
          AppStrings.getLocalizedString(
              context, (localizations) => localizations.didntReceiveOtp),
          color: isDark
              ? AppColors.black.withOpacity(0.5)
              : AppColorsLight.textSecondary,
          maxLines: 1,
          minFontSize: 9,
        ),
        SizedBox(width: responsive.spaceSM),
        Flexible(
          child: widget.isResendAvailable
              ? GestureDetector(
                  onTap: widget.onResendOtp,
                  child: AppText.bodyLarge1(
                    AppStrings.getLocalizedString(
                        context, (localizations) => localizations.resendOtp),
                    color: isDark ? AppColors.blue : AppColors.blue,
                    maxLines: 1,
                    minFontSize: 9,
                  ),
                )
              : AppText.bodyLarge1(
                  "${AppStrings.getLocalizedString(context, (localizations) => localizations.resendIn)} ${widget.resendTimer} ${AppStrings.getLocalizedString(context, (localizations) => localizations.sec)}",
                  color: isDark
                      ? Colors.grey[600]
                      : AppColorsLight.textSecondary,
                  maxLines: 1,
                  minFontSize: 8,
                ),
        ),
      ],
    );
  }

}

