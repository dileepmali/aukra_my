import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_colors_light.dart';
import '../../app/themes/app_text.dart';
import '../../core/responsive_layout/device_category.dart';
import '../../core/responsive_layout/font_size_hepler_class.dart';
import '../../core/responsive_layout/helper_class_2.dart';

/// Reusable Animated Pie Chart Widget
/// Can be used throughout the app for different data visualizations
class AnimatedPieChart extends StatefulWidget {
  final double usedValue;
  final double remainingValue;
  final Color? usedColor;
  final Color? remainingColor;
  final String centerText;
  final String centerSubText;
  final Widget? centerWidget;
  final double? chartSize;
  final double? centerSpaceRadius;
  final double? usedRadius;
  final double? remainingRadius;
  final bool isDark;

  const AnimatedPieChart({
    Key? key,
    required this.usedValue,
    required this.remainingValue,
    required this.centerText,
    this.centerSubText = '',
    this.centerWidget,
    this.usedColor,
    this.remainingColor,
    this.chartSize,
    this.centerSpaceRadius,
    this.usedRadius,
    this.remainingRadius,
    this.isDark = false,
  }) : super(key: key);

  @override
  State<AnimatedPieChart> createState() => _AnimatedPieChartState();
}

class _AnimatedPieChartState extends State<AnimatedPieChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double animatedUsed = widget.usedValue * _animation.value;
        double animatedRemaining = widget.remainingValue * _animation.value;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Main Pie Chart
            Transform.scale(
              scale: _animation.value,
              child: SizedBox(
                width: widget.chartSize ?? responsive.wp(25),
                height: widget.chartSize ?? responsive.wp(25),
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 1,
                    centerSpaceRadius: widget.centerSpaceRadius ?? 32,
                    startDegreeOffset: -90,
                    sections: [
                      // Used section
                      PieChartSectionData(
                        value: animatedUsed,
                        color: widget.usedColor ??
                            (widget.isDark
                                ? const Color(0xff80000000)
                                : AppColorsLight.textPrimaryWhite.withValues(alpha: 0.8)),
                        title: '',
                        radius: widget.usedRadius ?? 14,
                      ),
                      // Remaining section
                      PieChartSectionData(
                        value: animatedRemaining,
                        color: widget.remainingColor ??
                            (widget.isDark
                                ? const Color(0xff33000000)
                                : AppColorsLight.textSecondary.withValues(alpha: 0.3)),
                        title: '',
                        radius: widget.remainingRadius ?? 11,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center Text
            Opacity(
              opacity: _animation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtitle Text (shown first - above the amount)
                  if (widget.centerSubText.isNotEmpty) ...[
                    AppText.bodyLarge(
                      widget.centerSubText,
                      fontWeight: FontWeight.w500,
                      color: widget.isDark
                          ? AppColors.white
                          : AppColorsLight.textSecondary,
                    ),
                    SizedBox(height: responsive.hp(0.1)),
                  ],

                  // Main Text (Percentage or Value - shown below subtitle)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      // If centerWidget is provided, use it directly
                      if (widget.centerWidget != null) {
                        return widget.centerWidget!;
                      }
                      // If centerText contains %, show animated percentage
                      if (widget.centerText.contains('%')) {
                        int animatedPercentage = (widget.usedValue * _animation.value).toInt();
                        return AppText.searchbar1(
                          '$animatedPercentage%',
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppColors.white
                              : AppColorsLight.textPrimary,
                        );
                      } else {
                        // Otherwise show static text
                        return AppText.searchbar1(
                          widget.centerText,
                          fontWeight: FontWeight.w600,
                          color: widget.isDark
                              ? AppColors.white
                              : AppColorsLight.textPrimary,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
