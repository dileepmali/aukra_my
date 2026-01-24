import 'package:flutter/material.dart';

import '../app/themes/app_colors.dart';
import '../core/haptic_service.dart';
import '../core/responsive_layout/device_category.dart';
import '../core/responsive_layout/helper_class_2.dart';
import '../core/responsive_layout/padding_navigation.dart';

/// Desktop version of CustomFloatingActionButton with responsive sizes
class CustomFloatingActionButtonDesktop extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String screenType;

  const CustomFloatingActionButtonDesktop({
    Key? key,
    required this.onPressed,
    required this.screenType,
    this.icon = Icons.add,
  }) : super(key: key);

  @override
  State<CustomFloatingActionButtonDesktop> createState() =>
      _CustomFloatingActionButtonDesktopState();
}

class _CustomFloatingActionButtonDesktopState
    extends State<CustomFloatingActionButtonDesktop> {
  bool _isProcessing = false;
  DateTime? _lastTapTime;

  /// Get button text based on screen type
  String _getButtonText() {
    switch (widget.screenType.toLowerCase()) {
      case 'customers':
        return 'Add Customer';
      case 'suppliers':
        return 'Add Supplier';
      case 'employees':
        return 'Add Employee';
      case 'businesses':
        return 'Add Business';
      default:
        return 'Add Customer';
    }
  }

  /// Handle tap with debounce and haptic feedback
  void _handleTap() {
    final now = DateTime.now();

    // Prevent rapid double-taps (debounce)
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < Duration(milliseconds: 300)) {
      debugPrint('⚠️ FAB Desktop: Tap ignored (too fast - debounce)');
      return;
    }

    // Prevent processing while already processing
    if (_isProcessing) {
      debugPrint('⚠️ FAB Desktop: Tap ignored (already processing)');
      return;
    }

    _lastTapTime = now;
    _isProcessing = true;

    debugPrint('🔊 FAB Desktop: Tap registered, triggering haptic feedback');

    // Haptic feedback
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

    return RepaintBoundary(
      child: Container(
        height: responsive.hp(5.5),
        padding: EdgeInsets.symmetric(horizontal: responsive.wp(1)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          gradient: LinearGradient(
            colors: [
              AppColors.splaceSecondary1,
              AppColors.splaceSecondary2,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            onTap: _handleTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: responsive.iconSizeSmall,
                  color: AppColors.white,
                ),
                SizedBox(width: responsive.wp(0.3)),
                Text(
                  _getButtonText(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}