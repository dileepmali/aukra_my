import 'package:aukra_anantkaya_space/core/responsive_layout/helper_class_2.dart';
import 'package:aukra_anantkaya_space/presentations/widgets/custom_border_widget.dart';
import 'package:flutter/material.dart';

import '../app/themes/app_colors.dart';
import '../app/themes/app_text.dart';
import '../core/haptic_service.dart';
import '../core/responsive_layout/device_category.dart';
import '../core/responsive_layout/font_size_hepler_class.dart';
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

  /// Get button text based on screen type
  String _getButtonText() {
    switch (widget.screenType.toLowerCase()) {
      case 'customers':
        return 'Add Customer';
      case 'suppliers':
        return 'Add Supplier';
      case 'employers':
        return 'Add Employer';
      case 'businesses':
        return 'Add Business';
      default:
        return 'Add Customer';
    }
  }

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
    final buttonSize = 52.0;

    final iconSize = responsive.iconSizeMedium;

    return RepaintBoundary(
      // ✅ FIX: RepaintBoundary prevents unnecessary repaints during navigation
      child: BorderColor(
        isSelected: true,
        child: Container(
          width: responsive.wp(35),
          height: buttonSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
            gradient: LinearGradient(
                colors: [
                  AppColors.splaceSecondary1,
                  AppColors.splaceSecondary2,
                ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            )
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: iconSize,
                    color: AppColors.white,
                  ),
                  SizedBox(width: responsive.spacing(4)),
                  AppText.headlineLarge(
                    _getButtonText(),
                    color:  AppColors.white,
                    maxLines: 1,
                    minFontSize: 10,
                    fontWeight: FontWeight.w600,

                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
