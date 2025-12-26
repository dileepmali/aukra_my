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
  }

  @override
  Widget build(BuildContext context) {

    final AdvancedResponsiveHelper responsive = AdvancedResponsiveHelper(context);
    final SplashController controller = Get.find<SplashController>();
    controller.skipDelay = widget.skipDelay;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: SweepGradient(
            colors: [
              AppColors.splaceSecondary1,
              AppColors.splaceSecondary2,
              AppColors.splaceSecondary1,
              AppColors.splaceSecondary2,
              AppColors.splaceSecondary1,
              AppColors.splaceSecondary2,
              AppColors.splaceSecondary1,
            ],
            startAngle: 0.0,
            endAngle: 3.14 * 2,
            transform: GradientRotation(2.7)
          ),
        ),
        child: Stack(
          children: [
            // 🌅 Rounded Lines with SVG Icons
            _buildRoundedLinesWithIcons(responsive),

            // Main Content
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
                    child: Image.asset(
                      AppImages.splashLogo,
                      height: responsive.orientation == Orientation.portrait
                          ? responsive.hp(13)
                          : responsive.hp(14),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: responsive.hp(0.05)),
                  Text(
                    'AnantSpace',
                    style: AppFonts.displayMedium(
                      color: AppColors.anantSpaceColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Your data, your space',
                    textAlign: TextAlign.center,
                    style: AppFonts.headlineMedium(
                      color: AppColors.anantSpaceColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: responsive.hp(80),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: responsive.spaceMD),
                    // SVG Pictures above text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppIcons.lionIc,
                          width: responsive.wp(6),
                          height: responsive.wp(6),
                        ),
                        SizedBox(width: responsive.wp(3)),
                        SvgPicture.asset(
                          AppIcons.indianFlagIc,
                          width: responsive.wp(6),
                          height: responsive.wp(6),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.hp(1)),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'A product of AnantKaya, proudly make in INDIA',
                            style: AppFonts.headlineLarge(
                              color: AppColors.buttonTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        ? size.width * 0.75
        : size.width * 0.45;
    final middleRadius = responsive.orientation == Orientation.portrait
        ? size.width * 0.55
        : size.width * 0.35;

    return Stack(
      children: [
        // Outer Ring Icons
        ..._buildIconsForRing(
          center: center,
          radius: outerRadius,
          icons: [AppIcons.folderIc],
          angles: [7 * pi / 2],
          responsive: responsive,
        ),

        // Middle Ring Icons
        ..._buildIconsForRing(
          center: center,
          radius: middleRadius,
          icons: [
            AppIcons.galleryIc,
            AppIcons.galleryIc,
            AppIcons.folderIc,
            AppIcons.videoIc,
          ],
          angles: [
            4.1,           // Gallery 1 - top-right
            pi / 3.3,      // Gallery 2 - right
            pi * 0.7,      // Folder - left side (more left)
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
            color: Colors.white70,
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

    // Responsive radius calculations
    final outerRadius = responsive.orientation == Orientation.portrait
        ? size.width * 0.75
        : size.width * 0.45;
    final middleRadius = responsive.orientation == Orientation.portrait
        ? size.width * 0.55
        : size.width * 0.35;
    final innerRadius = responsive.orientation == Orientation.portrait
        ? size.width * 0.30
        : size.width * 0.22;

    // Outer ring
    _drawRing(
      canvas,
      center,
      outerRadius,
      Color(0xFFFFFFFC).withOpacity(0.1),
      responsive.wp(0.5),
    );

    // Middle ring
    _drawRing(
      canvas,
      center,
      middleRadius,
      Color(0xFFFFFFFC).withOpacity(0.1),
      responsive.wp(0.5),
    );

    // Inner ring
    _drawRing(
      canvas,
      center,
      innerRadius,
      Color(0xFFFFFFFC).withOpacity(0.1),
      responsive.wp(0.5),
    );
  }

  void _drawRing(Canvas canvas, Offset center, double radius, Color color, double strokeWidth) {
    // Draw ring with glow effect
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Add glow/shadow effect to rings
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    // Draw glow first
    canvas.drawCircle(center, radius, glowPaint);
    // Draw ring on top
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}