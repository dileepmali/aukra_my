import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../app/constants/app_icons.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_text.dart';
import '../../../buttons/app_button.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/padding_navigation.dart';

/// Payment Error Screen
/// Shows when payment fails
class PaymentErrorScreen extends StatelessWidget {
  final String planName;
  final String planPrice;
  final String errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const PaymentErrorScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    this.errorMessage = 'Something went wrong. Please try again.',
    this.onRetry,
    this.onCancel,
  });

  /// Show payment error screen
  static void show(BuildContext context, {
    required String planName,
    required String planPrice,
    String errorMessage = 'Something went wrong. Please try again.',
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            PaymentErrorScreen(
              planName: planName,
              planPrice: planPrice,
              errorMessage: errorMessage,
              onRetry: onRetry,
              onCancel: onCancel,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [AppColors.red500, AppColors.red800]
                : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.wp(10)),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Left aligned content
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SVG Icon
                    SvgPicture.asset(
                      AppIcons.failedIc,
                      width: responsive.iconSizeLarge1 + 5,
                      height: responsive.iconSizeLarge1 + 5,
                    ),
                    SizedBox(height: responsive.hp(0.5)),

                    // Jusni Title
                    AppText.displayMedium2(
                      'Payment failed!',
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.start,
                    ),
                    SizedBox(height: responsive.hp(0.5)),

                    // Jusni Subtitle
                    AppText.headlineMedium(
                        'We tried to charge from your qr code but, something went wrong. Please  update your payment method below to continue',
                        color: Colors.white.withValues(alpha: 0.8),
                        textAlign: TextAlign.start,
                        maxLines: 5
                    ),
                  ],
                ),
              ),
              SizedBox(height: responsive.hp(4)),

              // Cancel Button
              AppButton(
                text: 'Try again',
                width: double.infinity,
                leadingIcon: Icons.arrow_back,

                height: responsive.hp(6),
                borderColor: isDark ? AppColors.driver : AppColorsLight.gradientColor1,
                gradientColors: isDark
                    ? [AppColors.containerLight, AppColors.containerDark]
                    : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                textColor: isDark ? AppColors.white : AppColorsLight.textPrimary,
                fontSize: responsive.fontSize(16),
                fontWeight: FontWeight.w500,
                borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                onPressed: () {
                  if (onCancel != null) {
                    onCancel!();
                  } else {
                    // Pop to root or home screen
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
        ),
      ),
    );
  }

}

