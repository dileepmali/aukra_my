
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../app/themes/app_colors.dart';
import '../app/themes/app_text.dart';
import '../core/haptic_service.dart';

/// A comprehensive button component that follows React Native's prop-based approach
/// with full localization support and extensive customization options
class AppButton extends StatefulWidget {
  // Text and Localization
  final String? text;
  final String? translationKey; // Key for localization
  final Map<String, String>? translations; // Custom translations
  final TextStyle? textStyle;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? textColor;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? textOverflow;

  // Button Properties
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final bool? enabled;
  final bool? isLoading;
  final String? loadingText;
  final Widget? loadingWidget;
  final double? progressPercentage; // Progress percentage (0.0 to 1.0)

  // Styling
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final List<Color>? gradientColors;
  final Gradient? gradient;
  final bool? enableSweepGradient; // Enable/disable sweep gradient
  final Color? borderColor;
  final double? borderWidth;
  final Border? customBorder; // Custom border for specific sides
  final BorderRadius? borderRadius;
  final double? cornerRadius;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  // Size and Layout
  final double? width;
  final double? height;
  final double? minWidth;
  final double? minHeight;
  final double? maxWidth;
  final double? maxHeight;
  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;

  // Icons and Widgets
  final IconData? icon;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final double? iconSize;
  final Color? iconColor;
  final double? iconSpacing;

  // Animation and Effects
  final bool? enableScaleAnimation;
  final bool? enableRippleEffect;
  final Duration? animationDuration;
  final Curve? animationCurve;
  final double? scaleFactor;
  final Color? rippleColor;

  // Special Effects
  final bool? enableShimmer;
  final bool? enableGlow;
  final Color? glowColor;
  final double? glowRadius;

  // Accessibility
  final String? tooltip;
  final String? semanticsLabel;

  // Custom Widget
  final Widget? child;

  const AppButton({
    super.key,
    // Text and Localization
    this.text,
    this.translationKey,
    this.translations,
    this.textStyle,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.textAlign,
    this.maxLines,
    this.textOverflow,

    // Button Properties
    this.onPressed,
    this.onLongPress,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.enabled = true,
    this.isLoading = false,
    this.loadingText,
    this.loadingWidget,
    this.progressPercentage,

    // Styling
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.gradientColors,
    this.gradient,
    this.enableSweepGradient = false,
    this.borderColor,
    this.borderWidth,
    this.customBorder,
    this.borderRadius,
    this.cornerRadius,
    this.boxShadow,
    this.padding,
    this.margin,

    // Size and Layout
    this.width,
    this.height,
    this.minWidth,
    this.minHeight,
    this.maxWidth,
    this.maxHeight,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,

    // Icons and Widgets
    this.icon,
    this.leadingIcon,
    this.trailingIcon,
    this.leadingWidget,
    this.trailingWidget,
    this.iconSize,
    this.iconColor,
    this.iconSpacing,

    // Animation and Effects
    this.enableScaleAnimation = true,
    this.enableRippleEffect = true,
    this.animationDuration,
    this.animationCurve,
    this.scaleFactor,
    this.rippleColor,

    // Special Effects
    this.enableShimmer = false,
    this.enableGlow = false,
    this.glowColor,
    this.glowRadius,

    // Accessi, required Border customBorderbility
    this.tooltip,
    this.semanticsLabel,

    // Custom Widget
    this.child,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;
  DateTime? _lastClickTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor ?? 0.96,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: widget.animationCurve ?? Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enableScaleAnimation == true && widget.enabled == true) {
      _animationController.forward();
    }
    widget.onTapDown?.call();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enableScaleAnimation == true && widget.enabled == true) {
      _animationController.reverse();
    }
    widget.onTapUp?.call();
  }

  void _onTapCancel() {
    if (widget.enableScaleAnimation == true && widget.enabled == true) {
      _animationController.reverse();
    }
    widget.onTapCancel?.call();
  }

  // Debounce mechanism to prevent multiple rapid clicks
  bool _canProcessClick() {
    final now = DateTime.now();

    // Only check if we're currently processing an async operation
    if (_isProcessing) {
      return false;
    }

    // Reduce debounce time to 200ms for better responsiveness
    if (_lastClickTime != null) {
      final difference = now.difference(_lastClickTime!);
      if (difference.inMilliseconds < 200) {
        return false;
      }
    }

    _lastClickTime = now;
    return true;
  }

  void _handleTap() {
    if (!_canProcessClick()) {
      return;
    }

    // ✅ Set processing flag BEFORE haptic and callback to prevent multiple calls
    _isProcessing = true;

    // ✅ Haptic feedback on button press (medium impact for all buttons)
    HapticService.mediumImpact();

    // Only set processing if the callback might be async
    // For normal sync callbacks, don't block
    if (widget.onPressed != null) {
      widget.onPressed!();
    }

    // Reset processing flag after a shorter delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _isProcessing = false;
      }
    });
  }

  String _getLocalizedText() {
    // Priority: custom translations > translation key > direct text
    if (widget.translations != null && widget.translationKey != null) {
      return widget.translations![widget.translationKey!] ?? widget.text ?? '';
    }

    if (widget.translationKey != null) {
      return widget.translationKey!.tr;
    }

    return widget.text ?? '';
  }

  Color _getBackgroundColor() {
    if (widget.enabled == false) {
      return widget.disabledBackgroundColor ?? Colors.grey[400]!;
    }

    if (widget.gradient != null || widget.gradientColors != null) {
      return Colors.transparent;
    }

    return widget.backgroundColor ?? Theme
        .of(context)
        .primaryColor;
  }

  Gradient? _getGradient() {
    if (widget.gradient != null) return widget.gradient;

    if (widget.gradientColors != null) {
      // Always use normal LinearGradient (SweepGradient removed)
      return LinearGradient(
        colors: widget.gradientColors!,
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );
    }

    return null;
  }

  BorderRadius _getBorderRadius() {
    if (widget.borderRadius != null) return widget.borderRadius!;

    if (widget.cornerRadius != null) {
      return BorderRadius.circular(widget.cornerRadius!);
    }

    return BorderRadius.circular(12.0);
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.boxShadow != null) return widget.boxShadow!;

    List<BoxShadow> shadows = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ];

    if (widget.enableGlow == true && widget.glowColor != null) {
      shadows.add(BoxShadow(
        color: widget.glowColor!.withValues(alpha: 0.3),
        blurRadius: widget.glowRadius ?? 20,
        spreadRadius: 2,
      ));
    }

    return shadows;
  }

  Widget _buildContent() {
    if (widget.child != null) return widget.child!;

    if (widget.isLoading == true) {
      return _buildLoadingContent();
    }

    return _buildNormalContent();
  }

  Widget _buildLoadingContent() {
    // If progressPercentage is provided, show circular progress with percentage text
    if (widget.progressPercentage != null) {
      final percentage = (widget.progressPercentage! * 100).toInt();
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Percentage text on LEFT side
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: widget.textColor ?? Colors.white,
              ),
            ),
            SizedBox(width: 8), // Spacing between percentage and circular
            // Circular progress indicator in CENTER
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                value: widget.progressPercentage,
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.textColor ?? Colors.white,
                ),
                backgroundColor: (widget.textColor ?? Colors.white).withOpacity(0.2),
              ),
            ),
          ],
        ),
      );
    }

    // If loadingText is provided, show loader + text
    if (widget.loadingText != null) {
      return Row(
        mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
        mainAxisSize: widget.mainAxisSize ?? MainAxisSize.min,
        crossAxisAlignment: widget.crossAxisAlignment ?? CrossAxisAlignment.center,
        children: [
          widget.loadingWidget ??
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.textColor ?? AppColors.black,
                  ),
                ),
              ),
          SizedBox(width: widget.iconSpacing ?? 12),
          Flexible(
            child: AppText.custom(
              widget.loadingText!,
              style: _getTextStyle(),
              textAlign: widget.textAlign ?? TextAlign.center,
              maxLines: widget.maxLines ?? 2, // ✅ Changed default to 2 lines for loading text
              minFontSize: 12, // ✅ Increased minFontSize for better readability
              overflow: widget.textOverflow ?? TextOverflow.ellipsis,
              letterSpacing: 1.1
            ),
          ),
        ],
      );
    }

    // Otherwise, show only centered CircularProgressIndicator (hide text completely)
    return Center(
      child: widget.loadingWidget ??
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.textColor ?? Colors.black,
              ),
            ),
          ),
    );
  }

  Widget _buildNormalContent() {
    List<Widget> children = [];

    // Leading widget or icon
    if (widget.leadingWidget != null) {
      children.add(widget.leadingWidget!);
    } else if (widget.leadingIcon != null) {
      children.add(Icon(
        widget.leadingIcon,
        size: widget.iconSize ?? 20,
        color: widget.iconColor ?? widget.textColor ?? Colors.white,
      ));
    } else if (widget.icon != null) {
      children.add(Icon(
        widget.icon,
        size: widget.iconSize ?? 20,
        color: widget.iconColor ?? widget.textColor ?? Colors.white,
      ));
    }

    // Add spacing if there's a leading element
    if (children.isNotEmpty &&
        (widget.text != null || widget.translationKey != null)) {
      children.add(SizedBox(width: widget.iconSpacing ?? 8));
    }

    // Text - Using AppText for auto-sizing support
    if (widget.text != null || widget.translationKey != null) {
      children.add(Flexible(
        child: AppText.custom(
          _getLocalizedText(),
          style: _getTextStyle(),
          textAlign: widget.textAlign ?? TextAlign.center,
          maxLines: widget.maxLines ?? 2, // ✅ Changed default to 2 lines for better text wrapping
          minFontSize: 8, // ✅ Further reduced to 8 to prevent overflow with long South Indian text
          overflow: TextOverflow.visible, // ✅ Allow text to wrap instead of ellipsis
        ),
      ));
    }

    // Add spacing if there's a trailing element
    if ((widget.text != null || widget.translationKey != null) &&
        (widget.trailingWidget != null || widget.trailingIcon != null)) {
      children.add(SizedBox(width: widget.iconSpacing ?? 8));
    }

    // Trailing widget or icon
    if (widget.trailingWidget != null) {
      children.add(widget.trailingWidget!);
    } else if (widget.trailingIcon != null) {
      children.add(Icon(
        widget.trailingIcon,
        size: widget.iconSize ?? 20,
        color: widget.iconColor ?? widget.textColor ?? Colors.white,
      ));
    }

    return Row(
      mainAxisAlignment: widget.mainAxisAlignment ?? MainAxisAlignment.center,
      mainAxisSize: widget.mainAxisSize ?? MainAxisSize.min,
      crossAxisAlignment: widget.crossAxisAlignment ??
          CrossAxisAlignment.center,
      children: children,
    );
  }

  TextStyle _getTextStyle() {
    return widget.textStyle ??
        TextStyle(
          fontSize: widget.fontSize ?? 16,
          fontWeight: widget.fontWeight ?? FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.2,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      constraints: BoxConstraints(
        minWidth: widget.minWidth ?? 0,
        minHeight: widget.minHeight ?? 0,
        maxWidth: widget.maxWidth ?? double.infinity,
        maxHeight: widget.maxHeight ?? double.infinity,
      ),
      margin: widget.margin,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled == true && widget.isLoading != true
              ? _handleTap
              : null,
          onLongPress: widget.enabled == true && widget.isLoading != true
              ? widget.onLongPress
              : null,
          onTapDown: (details) {
            if (widget.enabled == true && widget.isLoading != true) {
              _onTapDown(details);
            }
          },
          onTapUp: (details) {
            if (widget.enabled == true && widget.isLoading != true) {
              _onTapUp(details);
            }
          },
          onTapCancel: () {
            if (widget.enabled == true && widget.isLoading != true) {
              _onTapCancel();
            }
          },
          borderRadius: _getBorderRadius(),
          splashColor: widget.enableRippleEffect == true
              ? (widget.rippleColor ?? Colors.white.withValues(alpha: 0.2))
              : Colors.transparent,
          highlightColor: widget.enableRippleEffect == true
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.transparent,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.enableScaleAnimation == true
                    ? _scaleAnimation.value
                    : 1.0,
                child: Container(
                  padding: widget.padding ?? EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    // यहाँ gradient के होने पर color को null कर दिया गया है ताकि gradient दिखे
                    color: _getGradient() == null
                        ? _getBackgroundColor()
                        : null,
                    gradient: _getGradient(),
                    borderRadius: _getBorderRadius(),
                    border: widget.customBorder ??
                        (widget.borderColor != null
                            ? Border.all(
                          color: widget.borderColor!,
                          width: widget.borderWidth ?? 1.0,
                        )
                            : null),
                    boxShadow: _getBoxShadow(),
                  ),
                  child: _buildContent(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}


// Predefined button variants for common use cases
class AppButtonVariants {
  static AppButton primary({
    Key? key,
    String? text,
    String? translationKey,
    VoidCallback? onPressed,
    bool? isLoading,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return AppButton(
      key: key,
      text: text,
      translationKey: translationKey,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }

  static AppButton secondary({
    Key? key,
    String? text,
    String? translationKey,
    VoidCallback? onPressed,
    bool? isLoading,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return AppButton(
      key: key,
      text: text,
      translationKey: translationKey,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
      backgroundColor: Colors.transparent,
      textColor: Colors.blue,
      borderColor: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    );
  }

  static AppButton danger({
    Key? key,
    String? text,
    String? translationKey,
    VoidCallback? onPressed,
    bool? isLoading,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return AppButton(
      key: key,
      text: text,
      translationKey: translationKey,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }

  static AppButton success({
    Key? key,
    String? text,
    String? translationKey,
    VoidCallback? onPressed,
    bool? isLoading,
    double? width,
    double? height,
    IconData? icon,
  }) {
    return AppButton(
      key: key,
      text: text,
      translationKey: translationKey,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      borderRadius: BorderRadius.circular(8),
    );
  }

  static AppButton outline({
    Key? key,
    String? text,
    String? translationKey,
    VoidCallback? onPressed,
    bool? isLoading,
    double? width,
    double? height,
    IconData? icon,
    Color? borderColor,
    Color? textColor,
  }) {
    return AppButton(
      key: key,
      text: text,
      translationKey: translationKey,
      onPressed: onPressed,
      isLoading: isLoading,
      width: width,
      height: height,
      icon: icon,
      backgroundColor: Colors.transparent,
      textColor: textColor ?? Colors.black,
      borderColor: borderColor ?? Colors.grey,
      borderRadius: BorderRadius.circular(8),
    );
  }
} 