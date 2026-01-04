import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/padding_navigation.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/localizations/l10n/app_strings.dart';
import '../../../app/constants/app_icons.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller; // ✅ FIX: Made nullable for safety
  final FocusNode? focusNode; // 🔥 NEW: External FocusNode for auto-focus
  final double? height;
  final double? width;
  final String? hintText;
  final Function(String)? onChanged;
  final VoidCallback? onSubmitted;
  final VoidCallback? onTap; // Custom tap handler
  final bool enableInput; // Enable actual input vs navigation
  final bool forceEnable; // 🔧 NEW: Force enable for specific screens (contact_screen)

  const CustomSearchBar({
    super.key,
    this.controller, // ✅ FIX: Now optional instead of required
    this.focusNode, // 🔥 NEW: External FocusNode parameter
    this.height,
    this.width,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.onTap, // Custom tap handler
    this.enableInput = false, // Default to navigation mode
    this.forceEnable = false, // 🔧 NEW: Default to false (disabled for all screens except contact)
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late final FocusNode _focusNode; // 🔥 UPDATED: Use external FocusNode if provided

  @override
  void initState() {
    super.initState();
    // Use external FocusNode if provided, otherwise create internal one
    _focusNode = widget.focusNode ?? FocusNode();

    // Add listener to update UI when text changes
    if (widget.enableInput && mounted) {
      final controller = widget.controller;
      if (controller != null) {
        controller.addListener(_onTextChanged);
      }
    }
  }

  // Separate listener method with safety checks
  void _onTextChanged() {
    if (mounted) {
      setState(() {}); // Update UI for clear button visibility
    }
  }

  @override
  void dispose() {
    final controller = widget.controller;
    if (controller != null && widget.enableInput) {
      controller.removeListener(_onTextChanged);
    }
    // Only dispose internal FocusNode, not external one
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height ?? _getSearchBarHeight(responsive),
      width: widget.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
      ),
      alignment: Alignment.center,
      child: TextField(
        // ✅ FIX: Add FocusNode to manage keyboard focus
        focusNode: _focusNode,

        // ✅ FIX: Unfocus when user taps outside (closes keyboard automatically)
        onTapOutside: (event) {
          _focusNode.unfocus();
        },

        // 🔧 CRITICAL FIX: Prevent focus when input is disabled (STOPS KEYBOARD!)
        canRequestFocus: widget.enableInput, // ✅ Can only focus when input is enabled

        // 🔧 FIX: Always keep enabled to allow tap detection
        // But use readOnly to control keyboard behavior
        enabled: true, // ✅ Always enabled for tap detection
        readOnly: !widget.enableInput, // ✅ ReadOnly when input is not needed (prevents keyboard)

        // 🔧 FIX: Enable tap handlers when forceEnable=true OR onTap callback is provided
        // 🔍 IMPORTANT: Call onTap callback even when input is enabled (for search mode)
        onTap: (widget.forceEnable || widget.onTap != null)
            ? () {
                // 🔧 CRITICAL FIX: Prevent keyboard from opening when input is disabled
                if (!widget.enableInput) {
                  _focusNode.unfocus(); // Immediately unfocus to prevent keyboard
                  // Small delay to ensure unfocus happens before navigation
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (!mounted) return;
                    _focusNode.unfocus(); // Double unfocus for safety
                  });
                }

                // 🔍 Call the custom onTap handler if provided (for navigation to SearchScreen)
                if (widget.onTap != null) {
                  widget.onTap!();
                }
                // Don't navigate if enableInput is true (let the field accept input)
                else if (!widget.enableInput && widget.forceEnable) {
                  Get.toNamed('/search-Screen');
                }
              }
            : null, // Completely disabled when no tap handler and forceEnable is false

        onChanged: widget.forceEnable && widget.enableInput ? widget.onChanged : null,
        onSubmitted: widget.forceEnable && widget.enableInput && widget.onSubmitted != null ? (_) => widget.onSubmitted!() : null,
        controller: widget.controller,
        // ✅ Using smaller font size for better South Indian language support
        style: TextStyle(
          color: isDark ? Colors.white : AppColorsLight.textPrimary,
          fontSize: responsive.fontSize(16),
          fontWeight: FontWeight.w400,
        ),
        cursorColor: isDark ? Colors.white : AppColorsLight.splaceSecondary1,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AppColors.black : AppColorsLight.scaffoldBackground,
          hintText: widget.hintText ?? AppStrings.getLocalizedString(context, (localizations) => localizations.searchForAnything),
          // ✅ Using smaller font size for hint text to accommodate longer translations
          hintStyle: TextStyle(
            color: isDark ? Colors.white.withOpacity(0.6) : AppColorsLight.textSecondary,
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              AppIcons.searchIIc,
              color: isDark ? Colors.white : AppColorsLight.iconPrimary,
              width: _getPrefixIconSize(responsive),
              height: _getPrefixIconSize(responsive),
            ),
          ),
          suffixIcon: widget.enableInput && (widget.controller?.text.isNotEmpty ?? false)
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? Colors.white.withOpacity(0.6) : AppColorsLight.black,
                    size: _getPrefixIconSize(responsive) * 2.5,
                  ),
                  onPressed: () {
                    widget.controller?.clear();
                    if (widget.onChanged != null) widget.onChanged!('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.borderAccent : AppColorsLight.splaceSecondary1, width: 1.5),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.borderAccent : AppColorsLight.splaceSecondary1, width: 1.5),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: isDark ? AppColors.borderAccent : AppColorsLight.splaceSecondary1, width: 1.5),
            borderRadius: BorderRadius.circular(responsive.borderRadiusSmall),
          ),
          isDense: true,
          contentPadding: _getContentPadding(responsive),
        ),
      ),
    );
  }

  // Responsive height for different devices
  double _getSearchBarHeight(AdvancedResponsiveHelper responsive) {
    return responsive.hp(6.5);
  }
  // Responsive prefix icon size
  double _getPrefixIconSize(AdvancedResponsiveHelper responsive) {
    return responsive.iconSizeSmall;
  }

  // Responsive content padding for proper hint alignment
  EdgeInsets _getContentPadding(AdvancedResponsiveHelper responsive) {
    return EdgeInsets.symmetric(
        horizontal: responsive.spacing(12),
        vertical: responsive.spacing(18),
    );
  }
}
