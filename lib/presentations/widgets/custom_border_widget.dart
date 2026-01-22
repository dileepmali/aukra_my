import 'package:flutter/material.dart';


// Color Presets Class
class GradientBorderColors {
  // Dark theme selected colors
  static const List<Color> defaultSelectedColors = [
    Color.fromARGB(255, 39, 38, 38),
    Color.fromARGB(235, 189, 186, 186),
    Color.fromARGB(255, 39, 38, 38),
  ];

  // Light theme selected colors (Golden gradient)
  static const List<Color> lightSelectedColors = [
    Color.fromARGB(224, 255, 224, 224),
    Color.fromARGB(255, 216, 169, 15),
    Color.fromARGB(224, 255, 224, 224),
  ];

  static const List<Color> defaultUnselectedColors = [
    Colors.transparent,
    Colors.transparent,
    Colors.transparent,
  ];
}

// Main Custom Border Widget with individual side control
class CustomBorderWidget extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final double borderRadius;
  final double? topWidth;
  final double? leftWidth;
  final double? rightWidth;
  final double? bottomWidth;
  final double? allSides;
  final List<Color>? selectedColors;
  final List<Color>? unselectedColors;
  final Color? backgroundColor;

  const CustomBorderWidget({
    Key? key,
    required this.child,
    this.isSelected = false,
    this.borderRadius = 8.0,
    this.topWidth,
    this.leftWidth,
    this.rightWidth,
    this.bottomWidth,
    this.allSides,
    this.selectedColors,
    this.unselectedColors,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate individual border widths
    final double top = topWidth ?? allSides ?? 1.5;
    final double left = leftWidth ?? allSides ?? 1.5;
    final double right = rightWidth ?? allSides ?? 1.5;
    final double bottom = bottomWidth ?? allSides ?? 1.5;

    // Get border colors based on theme
    final List<Color> borderColors = isSelected
        ? (selectedColors ?? (isDark
            ? GradientBorderColors.defaultSelectedColors
            : GradientBorderColors.lightSelectedColors))
        : (unselectedColors ?? GradientBorderColors.defaultUnselectedColors);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: borderColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(
          top: top,
          left: left,
          right: right,
          bottom: bottom,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            borderRadius > 2 ? borderRadius - 2 : 0,
          ),
          color: backgroundColor ?? Colors.transparent,
        ),
        child: child,
      ),
    );
  }
}

// Simplified BorderColor widget for backward compatibility
class BorderColor extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final double borderRadius;
  final double? topWidth;
  final double? leftWidth;
  final double? rightWidth;
  final double? bottomWidth;
  final double? allSides;
  final bool useCustomColors;
  final List<Color>? selectedColors;
  final List<Color>? unselectedColors;

  const BorderColor({
    Key? key,
    required this.child,
    required this.isSelected,
    this.borderRadius = 1.0,
    this.topWidth,
    this.leftWidth,
    this.rightWidth,
    this.bottomWidth,
    this.allSides,
    this.useCustomColors = false,
    this.selectedColors,
    this.unselectedColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomBorderWidget(
      child: child,
      isSelected: isSelected,
      borderRadius: borderRadius,
      topWidth: topWidth,
      leftWidth: leftWidth,
      rightWidth: rightWidth,
      bottomWidth: bottomWidth,
      allSides: allSides,
      selectedColors: useCustomColors ? selectedColors : null,
      unselectedColors: useCustomColors ? unselectedColors : null,
    );
  }
}

// Language Card Border for specific use case
class LanguageCardBorder extends StatelessWidget {
  final Widget child;
  final bool isSelected;
  final double borderRadius;
  final double? topWidth;
  final double? leftWidth;
  final double? rightWidth;
  final double? bottomWidth;

  const LanguageCardBorder({
    Key? key,
    required this.child,
    required this.isSelected,
    this.borderRadius = 1.0,
    this.topWidth,
    this.leftWidth,
    this.rightWidth,
    this.bottomWidth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomBorderWidget(
      child: child,
      isSelected: isSelected,
      borderRadius: borderRadius,
      topWidth: topWidth,
      leftWidth: leftWidth,
      rightWidth: rightWidth,
      bottomWidth: bottomWidth,
      allSides: 1.5, // default value
    );
  }
}


