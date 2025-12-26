import 'package:flutter/material.dart';

import '../app/themes/app_colors.dart';
import '../core/haptic_service.dart';
import '../core/responsive_layout/device_category.dart';
import '../core/responsive_layout/padding_navigation.dart';


class CustomFloatingActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String screenType;

  const CustomFloatingActionButton({
    Key? key,
    required this.onPressed,
    required this.screenType,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  State<CustomFloatingActionButton> createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton> {
  bool _isProcessing = false;
  DateTime? _lastTapTime;

  /// ✅ Handle tap with debounce and haptic feedback
  void _handleTap() {
    final now = DateTime.now();

    // ✅ Prevent rapid double-taps (debounce)
    if (_lastTapTime != null && now.difference(_lastTapTime!) < Duration(milliseconds: 300)) {
      print('⚠️ FAB: Tap ignored (too fast - debounce)');
      return;
    }

    // ✅ Prevent processing while already processing
    if (_isProcessing) {
      print('⚠️ FAB: Tap ignored (already processing)');
      return;
    }

    _lastTapTime = now;
    _isProcessing = true;

    print('🔊 FAB: Tap registered, triggering haptic feedback');

    // ✅ Haptic feedback
    HapticService.mediumImpact();

    // Execute callback
    widget.onPressed();

    // Reset processing flag
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _isProcessing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);

    // ✅ FIX: Pre-calculate size to avoid layout shifts
    final buttonSize = 68.0;

    final iconSize = responsive.iconSizeLarge + 8;

    return RepaintBoundary(
      // ✅ FIX: RepaintBoundary prevents unnecessary repaints during navigation
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          gradient: SweepGradient(
            center: Alignment.center,
            colors: const [
              Color(0xFFca9b2b),
              Color(0xFFe3bc5f),
              Color(0xFFca9b2b),
              Color(0xFFe3bc5f),
              Color(0xFFca9b2b),
              Color(0xFFe3bc5f),
              Color(0xFFca9b2b),

            ],
            startAngle: 0.8,
            endAngle: 3.14 * 2,
          ),
        ),
        child: Material(
          // ✅ FIX: Use Material widget for better rendering
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: InkWell(
            // ✅ FIX: InkWell for instant touch feedback
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            onTap: _handleTap,
            child: Center(
              // ✅ FIX: Center ensures icon is always centered
              child: Icon(
                widget.icon,
                size: iconSize,
                color: AppColors.buttonTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
