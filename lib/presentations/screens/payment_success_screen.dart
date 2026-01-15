import 'package:aukra_anantkaya_space/core/responsive_layout/helper_class_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../app/constants/app_icons.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../buttons/app_button.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/padding_navigation.dart';

/// Payment Success Screen
/// Shows when payment is completed successfully
class PaymentSuccessScreen extends StatelessWidget {
  final String planName;
  final String planPrice;
  final String planDuration;
  final String transactionId;
  final VoidCallback? onDone;

  const PaymentSuccessScreen({
    super.key,
    required this.planName,
    required this.planPrice,
    this.planDuration = '',
    this.transactionId = '',
    this.onDone,
  });

  /// Show payment success screen
  static void show(
    BuildContext context, {
    required String planName,
    required String planPrice,
    required String planDuration,
    String transactionId = '',
    VoidCallback? onDone,
  }) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          planName: planName,
          planPrice: planPrice,
          planDuration: planDuration,
          transactionId: transactionId,
          onDone: onDone,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: isDark
                ? [AppColors.green400, AppColors.green800]
                : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.wp(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Left aligned content
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SVG Icon
                      SvgPicture.asset(
                        AppIcons.successIc,
                        width: responsive.iconSizeLarge1 + 5,
                        height: responsive.iconSizeLarge1 + 5,
                      ),
                      SizedBox(height: responsive.hp(0.5)),

                      // Jusni Title
                      AppText.displayMedium2(
                        'Payment Success!',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: responsive.hp(0.5)),

                      // Jusni Subtitle
                      AppText.headlineMedium(
                        'Your payment has been successfully done',
                        color: Colors.white.withValues(alpha: 0.8),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: responsive.hp(4)),

              // Payment Details Container with perforated bottom
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(responsive.wp(5)),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(responsive.borderRadiusSmall),
                        topRight: Radius.circular(responsive.borderRadiusSmall),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        AppText.searchbar1(
                          'Thank you for choosing us!',
                          color: isDark ? AppColors.black : AppColorsLight.textPrimary,
                          fontWeight: FontWeight.w600,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(height: responsive.hp(2)),
                        // Amount
                        AppText.displayMedium3(
                          '₹ $planPrice',
                          color: isDark ? AppColors.black : AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        SizedBox(height: responsive.hp(1)),

                        // Plan with RichText
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Paid for ',
                                style: TextStyle(
                                  color: isDark ? AppColors.black : AppColorsLight.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: responsive.fontSize(14),
                                ),
                              ),
                              TextSpan(
                                text: 'Anant Aukra $planName $planDuration subscriptions',
                                style: TextStyle(
                                  color: isDark ? AppColors.black : AppColorsLight.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: responsive.fontSize(14),
                                ),
                              ),

                            ],
                          ),
                        ),
                        SizedBox(height: responsive.hp(1)),

                        AppText.headlineMedium(
                          'Your subscription is valid for $planDuration. On your next renewable date, You will be notify you on your mobile number & email',
                          color: isDark ? AppColors.black : AppColorsLight.textSecondary,
                          fontWeight: FontWeight.w500,
                          maxLines: 5,
                        ),
                        SizedBox(height: responsive.hp(2)),

                        // Download Receipt Row
                        GestureDetector(
                          onTap: () {
                            // TODO: Implement PDF download
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                AppIcons.downloadIc,
                                width: responsive.iconSizeMedium,
                                height: responsive.iconSizeMedium,
                                colorFilter: ColorFilter.mode(
                                  isDark ? AppColors.black : AppColorsLight.gradientColor1,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: responsive.wp(2)),
                              AppText.headlineMedium(
                                'Download Receipt (PDF)',
                                color: isDark ? AppColors.black : AppColorsLight.gradientColor1,
                                fontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.hp(1)),

                      ],
                    ),
                  ),
                  // Perforated teeth pattern extending below
                  CustomPaint(
                    size: Size(double.infinity, 10),
                    painter: PerforatedEdgePainter(
                      color: isDark ? AppColors.white : Colors.white,
                    ),
                  ),
                ],
              ),
                SizedBox(height: responsive.hp(3)),

                // Done Button
                AppButton(
                  text: 'Go back',
                  leadingIcon: Icons.arrow_back,
                  width: double.infinity,
                  height: responsive.hp(6),
                  borderColor: isDark ? AppColors.driver : AppColorsLight.gradientColor1,
                  gradientColors: isDark
                      ? [AppColors.containerLight, AppColors.containerDark]
                      : [AppColorsLight.gradientColor1, AppColorsLight.gradientColor2],
                  textColor: Colors.white,
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                  borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                  onPressed: () {
                    if (onDone != null) {
                      onDone!();
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

/// Custom painter for perforated bottom edge (receipt style teeth extending outward)
class PerforatedEdgePainter extends CustomPainter {
  final Color color;

  PerforatedEdgePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const teethWidth = 6.0;
    const gapWidth = 4.0;
    final teethHeight = size.height;

    double x = 0;
    while (x < size.width) {
      // Draw a rectangle (tooth)
      canvas.drawRect(
        Rect.fromLTWH(x, 0, teethWidth, teethHeight),
        paint,
      );
      x += teethWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}