import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/constants/app_icons.dart';
import '../../app/constants/app_images.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_fonts.dart';
import '../../app/themes/app_text.dart';
import '../../controllers/splash_controller.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';
import '../../core/responsive_layout/padding_navigation.dart';

class SplashScreen extends StatefulWidget {
  final bool skipDelay;

  const SplashScreen({super.key, this.skipDelay = false});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    // ⚡ OPTIMIZED: Removed biometric authentication from splash screen
    // This was blocking the UI thread and causing 2-3 second delay
    // Biometric authentication now happens AFTER navigation in MainScreen/AppEntryWrapper
    // This makes deep links and cold starts feel much faster!

    // 🖼️ Make splash screen truly full screen (edge-to-edge)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  @override
  Widget build(BuildContext context) {

    final AdvancedResponsiveHelper responsive = AdvancedResponsiveHelper(context);
    final SplashController controller = Get.find<SplashController>();
    controller.skipDelay = widget.skipDelay;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full screen SVG image
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: SvgPicture.asset(
              AppImages.AukraSplashIm,
              fit: BoxFit.cover,
            ),
          ),
          // Bottom text - Product of Anantkaya & Proudly made in Bharat
          Positioned(
            left: 0,
            right: 0,
            bottom: responsive.hp(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Product of ',
                        style: AppFonts.headlineLarge(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Anantkaya',
                        style: AppFonts.headlineLarge(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' Solucation Pvt.Ltd.',
                        style: AppFonts.headlineLarge(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: responsive.hp(2)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText.headlineSmall(
                      'Proudly made in Bharat',
                      color: AppColors.white,
                      minFontSize: 10,
                    ),
                    SizedBox(width: responsive.wp(2)),
                    SvgPicture.asset(
                      AppIcons.indianFlagIc,
                      width: responsive.wp(5),
                      height: responsive.wp(5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      /* COMMENTED OUT - Previous splash screen design
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                AppColors.splashBlurShape,
                AppColors.splashBlurShape,
                AppColors.splashBlurShape5,
                AppColors.splashBlurShape4,
              ],
            begin: Alignment.bottomCenter,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          children: [
            // 🌅 Rounded Lines with SVG Icons
            _buildRoundedLinesWithIcons(responsive),

            // Horizontal Line
            Center(
              child: Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  color:AppColors.splashArcColor3,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),

            // Center Images
            Center(
              child: Padding(
                padding:  EdgeInsets.only(top: responsive.hp(8)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Image.asset(
                      AppImages.splashMainIm,
                      width: responsive.wp(50),
                      height: responsive.wp(45),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: responsive.hp(0)),
                    Image.asset(
                      AppImages.AukraIm,
                      width: responsive.wp(35),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: responsive.hp(2)),
                    AppText.headlineMedium(
                      'Infinity Income Advance Income',
                      color: AppColors.white,
                      letterSpacing: 1.5,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              top: responsive.hp(80),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: responsive.spaceMD),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Product of ',
                            style: AppFonts.headlineLarge(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Anantkaya',
                            style: AppFonts.headlineLarge(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ).copyWith(
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.white,
                            ),
                          ),
                          TextSpan(
                            text: ' Solucation Pvt.Ltd.',
                            style: AppFonts.headlineLarge(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: responsive.hp(2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText.headlineSmall(
                          'Proudly made in Bharat',
                          color: AppColors.white,
                          minFontSize: 10,
                        ),
                        SizedBox(width: responsive.wp(2)),
                        SvgPicture.asset(
                          AppIcons.indianFlagIc,
                          width: responsive.wp(5),
                          height: responsive.wp(5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      */
    );
  }

  // 🌅 Rounded Lines with SVG Icons
  Widget _buildRoundedLinesWithIcons(AdvancedResponsiveHelper responsive) {
    return CustomPaint(
      size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
      painter: ResponsiveRoundedLinesPainter(
        responsive: responsive,
        screenSize: MediaQuery.of(context).size,
      ),
      child: _buildFloatingIcons(responsive),
    );
  }

  // 🎨 Floating SVG Icons on Rings
  Widget _buildFloatingIcons(AdvancedResponsiveHelper responsive) {
    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);

    // Responsive radius calculations
    final outerRadius = responsive.orientation == Orientation.portrait
        ? size.width * 0.89
        : size.width * 0.45;
    final middleRadius = responsive.orientation == Orientation.portrait
        ? size.width * 0.61
        : size.width * 0.35;

    return Stack(
      children: [
        // Outer Ring Icons
        ..._buildIconsForRing(
          center: center,
          radius: outerRadius,
          icons: [AppIcons.bookIc],
          angles: [7 * pi / 2],
          responsive: responsive,
        ),

        // Middle Ring Icons
        ..._buildIconsForRing(
          center: center,
          radius: middleRadius,
          icons: [
            AppIcons.calendarIc,
            AppIcons.shopIc,
            AppIcons.shoppingCartIc,
            AppIcons.briefcaseIc,
          ],
          angles: [
            4.2,           // Gallery 1 - top-right
            pi / 3.3,      // Gallery 2 - right
            pi * 0.62,      // Folder - left side (more left)
            2.5 * pi / 1.5 // Video - bottom
          ],
          responsive: responsive,
        ),
      ],
    );
  }

  // Helper method to build icons for a ring
  List<Widget> _buildIconsForRing({
    required Offset center,
    required double radius,
    required List<String> icons,
    required List<double> angles,
    required AdvancedResponsiveHelper responsive,
  }) {
    List<Widget> iconWidgets = [];

    for (int i = 0; i < icons.length && i < angles.length; i++) {
      final angle = angles[i];
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      final iconSize = responsive.orientation == Orientation.portrait
          ? responsive.wp(6)
          : responsive.wp(4);

      iconWidgets.add(
        Positioned(
          left: x - iconSize / 2,
          top: y - iconSize / 1.3,
          child: SvgPicture.asset(
            icons[i],
            color: Colors.white,
            width: iconSize * 1.3,
            height: iconSize * 1.3,
          ),
        ),
      );
    }

    return iconWidgets;
  }
}

// 🎨 Responsive Rounded Lines Painter
class ResponsiveRoundedLinesPainter extends CustomPainter {
  final AdvancedResponsiveHelper responsive;
  final Size screenSize;

  ResponsiveRoundedLinesPainter({
    required this.responsive,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Outer oval - balanced size
    final outerWidth = responsive.orientation == Orientation.portrait
        ? size.width * 1.5
        : size.width * 0.60;
    final outerHeight = responsive.orientation == Orientation.portrait
        ? size.height * 0.80
        : size.height * 0.50;

    // Middle oval - balanced size
    final middleWidth = responsive.orientation == Orientation.portrait
        ? size.width * 1.2
        : size.width * 0.45;
    final middleHeight = responsive.orientation == Orientation.portrait
        ? size.height * 0.55
        : size.height * 0.38;

    // Outer ring (oval)
    _drawOvalRing(
      canvas,
      center,
      outerWidth,
      outerHeight,
     AppColors.splashArcColor3,
      responsive.wp(0.5),
    );

    // Middle ring (oval)
    _drawOvalRing(
      canvas,
      center,
      middleWidth,
      middleHeight,
      AppColors.splashArcColor3,
      responsive.wp(0.5),
    );

    // NEW: 180 degree arcs (semi-circles) - width = height for perfect circle
    final arc1Size = responsive.orientation == Orientation.portrait
        ? size.width * 0.85
        : size.width * 0.45;

    final arc2Size = responsive.orientation == Orientation.portrait
        ? size.width * 0.60
        : size.width * 0.35;

    // Outer 180 degree semi-circle - RED
    _drawHalfArc(
      canvas,
      center,
      arc1Size,
      arc1Size,
      AppColors.splashArcColor2.withOpacity(0.3),
    );

    // Inner 180 degree semi-circle - BLACK
    _drawHalfArc(
      canvas,
      center,
      arc2Size,
      arc2Size,
      AppColors.splashArcColor2.withOpacity(0.4),
    );
  }

  // Full 360 degree oval ring
  void _drawOvalRing(Canvas canvas, Offset center, double width, double height, Color color, double strokeWidth) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    // Draw full oval (360 degree)
    canvas.drawOval(rect, glowPaint);
    canvas.drawOval(rect, paint);
  }

  // 180 degree half arc with single color fill
  void _drawHalfArc(Canvas canvas, Offset center, double width, double height, Color color) {
    final rect = Rect.fromCenter(center: center, width: width, height: height);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw FULL filled arc
    canvas.drawArc(rect, pi, pi, true, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}