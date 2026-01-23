import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_colors_light.dart';
import '../../../app/themes/app_fonts.dart';
import '../../../app/themes/app_text.dart';
import '../../../core/responsive_layout/device_category.dart';
import '../../../core/responsive_layout/font_size_hepler_class.dart';
import '../../../core/responsive_layout/helper_class_2.dart';
import '../../../core/responsive_layout/padding_navigation.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final IconData? prefixIconData;
  final IconData? suffixIconData;
  final Color? prefixIconColor;
  final Color? suffixIconColor;
  final double? prefixIconSize;
  final double? suffixIconSize;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final EdgeInsets? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? textColor;
  final Color? hintColor;
  final double? borderRadius;
  final double? borderWidth;
  final double? height;
  final double? width;
  final bool showBorder;
  final bool filled;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool autofocus;
  final bool enableSuggestions;
  final bool autocorrect;
  final bool expands;
  final FontWeight? fontWeight;
  final double? fontSize;
  final String? prefixText;
  final String? suffixText;
  final String? prefixBoxText; // For left side box with icon/text

  // ✅ Auto-scroll parameters
  final bool autoScrollOnFocus;    // Enable auto-scroll when focused (default: false)
  final double scrollAlignment;     // 0.0 = top, 0.5 = center, 1.0 = bottom (default: 0.3)
  final int scrollDelayMs;          // Delay in milliseconds before scrolling (default: 400)

  const CustomTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixIconData,
    this.suffixIconData,
    this.prefixIconColor,
    this.suffixIconColor,
    this.prefixIconSize,
    this.suffixIconSize,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.validator,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.hintColor,
    this.borderRadius,
    this.borderWidth,
    this.height,
    this.width,
    this.showBorder = true,
    this.filled = true,
    this.textStyle,
    this.hintStyle,
    this.autofocus = false,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.expands = false,
    this.fontWeight,
    this.fontSize,
    this.prefixText,
    this.suffixText,
    this.prefixBoxText,
    // Auto-scroll parameters
    this.autoScrollOnFocus = false,
    this.scrollAlignment = 0.3,
    this.scrollDelayMs = 400,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  final GlobalKey _fieldKey = GlobalKey(); // ✅ Key for auto-scroll

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });

    // ✅ Auto-scroll when focused
    if (widget.autoScrollOnFocus && _internalFocusNode.hasFocus) {
      _scrollToVisible();
    }
  }

  /// ✅ Scroll this text field into view when focused
  void _scrollToVisible() {
    Future.delayed(Duration(milliseconds: widget.scrollDelayMs), () {
      if (_fieldKey.currentContext != null && mounted) {
        Scrollable.ensureVisible(
          _fieldKey.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: widget.scrollAlignment,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AdvancedResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default colors based on theme
    final defaultTextColor = widget.textColor ?? (isDark ? Colors.white : AppColorsLight.textPrimary);
    final defaultHintColor = widget.hintColor ?? (isDark ? Colors.grey[600] : AppColorsLight.textSecondary);
    final defaultFillColor = widget.fillColor ?? (isDark ? AppColors.black : AppColorsLight.white);
    final defaultBorderColor = widget.borderColor ?? (isDark ? AppColors.descontainerLight : AppColorsLight.splaceSecondary1);
    final defaultFocusedBorderColor = widget.focusedBorderColor ?? (isDark ? AppColors.white : AppColorsLight.black);

    // Responsive sizes
    final defaultBorderRadius = widget.borderRadius ?? responsive.borderRadiusSmall;
    final defaultBorderWidth = widget.borderWidth ?? 1.0;
    final defaultContentPadding = widget.contentPadding ?? EdgeInsets.symmetric(
      horizontal: responsive.wp(4),
      vertical: responsive.hp(2),
    );
    final defaultFontSize = widget.fontSize ?? responsive.fontSize(19);
    final defaultIconSize = widget.prefixIconSize ?? responsive.iconSizeSmall;

    // Build prefix icon
    Widget? buildPrefixIcon;
    if (widget.prefixIcon != null) {
      buildPrefixIcon = widget.prefixIcon;
    } else if (widget.prefixIconData != null) {
      buildPrefixIcon = Icon(
        widget.prefixIconData,
        color: widget.prefixIconColor ?? (isDark ? Colors.grey[400] : AppColorsLight.textSecondary),
        size: defaultIconSize,
      );
    }

    // Build suffix icon
    Widget? buildSuffixIcon;
    if (widget.suffixIcon != null) {
      buildSuffixIcon = widget.suffixIcon;
    } else if (widget.suffixIconData != null) {
      buildSuffixIcon = Icon(
        widget.suffixIconData,
        color: widget.suffixIconColor ?? (isDark ? Colors.grey[400] : AppColorsLight.textSecondary),
        size: widget.suffixIconSize ?? defaultIconSize,
      );
    }

    // Build prefix box if needed
    Widget? prefixBoxWidget;
    final containerHeight = (widget.minLines != null || widget.maxLines == null) ? null : widget.height;

    if (widget.prefixBoxText != null) {
      prefixBoxWidget = Container(
        width: responsive.wp(16),
        height: responsive.hp(6.6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.overlay : AppColorsLight.white,
          border: Border(
            right: BorderSide(
              color: _isFocused ? defaultFocusedBorderColor : defaultBorderColor,
              width: defaultBorderWidth,
            ),
          ),
        ),
        child: Center(
          child: Text(
            widget.prefixBoxText!,
            style: TextStyle(
              color: defaultTextColor,
              fontSize: defaultFontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    return Container(
      key: _fieldKey, // ✅ Key for auto-scroll functionality
      height: containerHeight,
      width: widget.width,
      decoration: BoxDecoration(
        color: widget.filled ? defaultFillColor : Colors.transparent,
        borderRadius: BorderRadius.circular(defaultBorderRadius),
        border: widget.showBorder
            ? Border.all(
                color: _isFocused ? defaultFocusedBorderColor : defaultBorderColor,
                width: defaultBorderWidth,
              )
            : null,
      ),
      child: Row(
        children: [
          if (prefixBoxWidget != null) prefixBoxWidget,
          Expanded(
            child: TextField(
        controller: widget.controller,
        focusNode: _internalFocusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        textCapitalization: widget.textCapitalization,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        onEditingComplete: widget.onEditingComplete,
        inputFormatters: widget.inputFormatters,
        textAlign: widget.textAlign,
        autofocus: widget.autofocus,
        enableSuggestions: widget.enableSuggestions,
        autocorrect: widget.autocorrect,
        expands: widget.expands,
        style: widget.textStyle ?? AppFonts.searchbar1(
          color: defaultTextColor,
          fontWeight: widget.fontWeight ?? AppFonts.medium,
        ).copyWith(fontSize: defaultFontSize),
        cursorColor: isDark ? AppColors.white : AppColorsLight.black,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AppColors.black : AppColorsLight.white,
          hintText: widget.hintText,
          labelText: widget.labelText,
          hintStyle: widget.hintStyle ?? TextStyle(
            color: defaultHintColor,
            fontSize: defaultFontSize,
            fontWeight: FontWeight.w300,
          ),
          prefixIcon: buildPrefixIcon,
          suffixIcon: buildSuffixIcon,
          prefixText: widget.prefixText,
          suffixText: widget.suffixText,
          prefixStyle: TextStyle(
            color: defaultTextColor,
            fontSize: defaultFontSize,
            fontWeight: FontWeight.w400,
          ),
          suffixStyle: TextStyle(
            color: defaultTextColor,
            fontSize: defaultFontSize,
            fontWeight: FontWeight.w400,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding: defaultContentPadding,
          counterText: '', // Hide character counter
        ),
      ),
          ),
        ],
      ),
    );
  }
}
