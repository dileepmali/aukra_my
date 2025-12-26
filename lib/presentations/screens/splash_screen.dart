import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.splaceSecondary2,
              AppColors.splaceSecondary1,
              AppColors.splaceSecondary2,
            ],
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
                    'Infinite income, Advanced accounts',
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

  // 🎨 Floating SVG Icons on Ring Boundaries
  Widget _buildFloatingIcons(AdvancedResponsiveHelper responsive) {
    final size = MediaQuery.of(context).size;

    // 🎯 Center point - EXACT screen center to match logo position
    final center = Offset(size.width / 2, size.height * 0.5);

    // 🎨 Ring radius (using outer ring for icon placement)
    final iconRingRadius = responsive.orientation == Orientation.portrait
        ? size.height * 0.42
        : size.width * 0.55;

    return Stack(
      children: [
        // 🎨 Icons placed around the ring boundary - equally spaced
        ..._buildIconsForRing(
          center: center,
          radius: iconRingRadius,
          icons: [
            AppIcons.folderIc,     // Top-left (calculator in design)
            AppIcons.galleryIc,    // Top-right (notebook in design)
            AppIcons.videoIc,      // Right (briefcase in design)
            AppIcons.folderIc,     // Bottom-right (gift box in design)
            AppIcons.galleryIc,    // Bottom-left (shopping cart in design)
          ],
          angles: [
            pi * 0.25,   // Top-left (~45°)
            pi * 0.05,   // Top-right (~10°)
            pi * 0.5,    // Right side (90°)
            pi * 1.75,   // Bottom-right (~315°)
            pi * 1.25,   // Bottom-left (~225°)
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
    // 🎯 Center point - EXACT screen center to match logo position
    final center = Offset(size.width / 2, size.height * 0.5);

    // 🎨 VERY LARGE CONCENTRIC RINGS with MORE SPACING between them
    final outerRadius = responsive.orientation == Orientation.portrait
        ? size.height * 0.42  // Very large - almost full screen height
        : size.width * 0.55;
    final middleRadius = responsive.orientation == Orientation.portrait
        ? size.height * 0.32  // Increased spacing from outer ring
        : size.width * 0.42;
    final innerRadius = responsive.orientation == Orientation.portrait
        ? size.height * 0.22  // Increased spacing from middle ring
        : size.width * 0.30;

    // Draw FULL CIRCULAR RINGS (not partial arcs)
    _drawFullRing(
      canvas,
      center,
      outerRadius,
      Color(0xFFFFFFFF).withOpacity(0.12),
      responsive.wp(0.5),
    );

    _drawFullRing(
      canvas,
      center,
      middleRadius,
      Color(0xFFFFFFFF).withOpacity(0.10),
      responsive.wp(0.5),
    );

    _drawFullRing(
      canvas,
      center,
      innerRadius,
      Color(0xFFFFFFFF).withOpacity(0.08),
      responsive.wp(0.5),
    );

    // 🎨 HORIZONTAL LINE passing through logo center
    _drawHorizontalLine(canvas, center, size.width, responsive.wp(0.5));
  }

  void _drawFullRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
    double strokeWidth,
  ) {
    // Draw FULL circular ring with subtle glow
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Add subtle glow effect
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    // Draw glow first
    canvas.drawCircle(center, radius, glowPaint);
    // Draw ring on top
    canvas.drawCircle(center, radius, paint);
  }

  void _drawHorizontalLine(
    Canvas canvas,
    Offset center,
    double screenWidth,
    double strokeWidth,
  ) {
    // Draw horizontal line passing through logo center (left to right)
    final paint = Paint()
      ..color = Color(0xFFFFFFFF).withOpacity(0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Add subtle glow effect
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    // Start point (left edge) and end point (right edge) at logo center height
    final startPoint = Offset(0, center.dy);
    final endPoint = Offset(screenWidth, center.dy);

    // Draw glow first
    canvas.drawLine(startPoint, endPoint, glowPaint);
    // Draw line on top
    canvas.drawLine(startPoint, endPoint, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}