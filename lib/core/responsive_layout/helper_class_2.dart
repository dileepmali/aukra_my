import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'device_category.dart';

extension AdvancedResponsiveHelperPart2 on AdvancedResponsiveHelper {
  // Mobile Device Category Checks
  bool get isUltraSmallMobile => deviceCategory == DeviceCategory.ultraSmallMobile;
  bool get isSmallMobile => deviceCategory == DeviceCategory.smallMobile;
  bool get isCompactMobile => deviceCategory == DeviceCategory.compactMobile;
  bool get isStandardMobile => deviceCategory == DeviceCategory.standardMobile;
  bool get isLargeMobile => deviceCategory == DeviceCategory.largeMobile;
  bool get isExtraLargeMobile => deviceCategory == DeviceCategory.extraLargeMobile;

  // Tablet Device Category Checks
  bool get isSmallTablet => deviceCategory == DeviceCategory.smallTablet;
  bool get isStandardTablet => deviceCategory == DeviceCategory.standardTablet;
  bool get isLargeTablet => deviceCategory == DeviceCategory.largeTablet;

  // Desktop Device Category Checks
  bool get isSmallDesktop => deviceCategory == DeviceCategory.smallDesktop;
  bool get isStandardDesktop => deviceCategory == DeviceCategory.standardDesktop;
  bool get isLargeDesktop => deviceCategory == DeviceCategory.largeDesktop;
  bool get isExtraLargeDesktop => deviceCategory == DeviceCategory.extraLargeDesktop;

  // Device Type Checks
  bool get isAnyMobile => deviceType == DeviceType.mobile;
  bool get isAnyTablet => deviceType == DeviceType.tablet;
  bool get isAnyDesktop => deviceType == DeviceType.desktop;

  bool get isLandscape => orientation == Orientation.landscape;
  bool get isPortrait => orientation == Orientation.portrait;

  // Platform checks
  bool get isAndroid => !kIsWeb && Theme.of(context).platform == TargetPlatform.android;
  bool get isIOS => !kIsWeb && Theme.of(context).platform == TargetPlatform.iOS;
  bool get isWeb => kIsWeb;
  bool get isDesktopPlatform => !kIsWeb &&
      (Theme.of(context).platform == TargetPlatform.windows ||
          Theme.of(context).platform == TargetPlatform.macOS ||
          Theme.of(context).platform == TargetPlatform.linux);

  /// Width और Height percentage calculations
  double wp(double percent) => screenWidth * (percent / 100);
  double hp(double percent) => screenHeight * (percent / 100);

  /// Smart font size with clamping to prevent extreme sizes (Mobile only)
  double smartFontSize(double percentage, {
    double? minSize,
    double? maxSize,
  }) {
    double baseSize = hp(percentage);
    double deviceMinSize = minSize ?? 10.0;
    double deviceMaxSize = maxSize ?? 24.0;
    return baseSize.clamp(deviceMinSize, deviceMaxSize);
  }

  /// Smart grid columns based on device type and available width
  int smartGridColumns({
    int? minColumns,
    int? maxColumns,
    double? itemMinWidth,
  }) {
    final availableWidth = screenWidth;
    final minItemWidth = itemMinWidth ?? 150.0;

    int calculatedColumns = (availableWidth / minItemWidth).floor();

    // Apply device-specific constraints
    if (isAnyDesktop) {
      // Desktop: 4-8 columns based on screen size
      final minCols = minColumns ?? 4;
      final maxCols = maxColumns ?? 8;
      return calculatedColumns.clamp(minCols, maxCols);
    } else if (isAnyTablet) {
      // Tablet: 3-6 columns based on screen size
      final minCols = minColumns ?? 3;
      final maxCols = maxColumns ?? 6;
      return calculatedColumns.clamp(minCols, maxCols);
    } else {
      // Mobile: 2-3 columns
      final minCols = minColumns ?? 2;
      final maxCols = maxColumns ?? 3;
      return calculatedColumns.clamp(minCols, maxCols);
    }
  }

  /// Enhanced spacing that adapts to device type (Mobile only)
  double smartSpacing(SpacingLevel level) {
    double baseSpacing;

    switch (level) {
      case SpacingLevel.xs:
        baseSpacing = wp(0.5);
        break;
      case SpacingLevel.sm:
        baseSpacing = wp(1.5);
        break;
      case SpacingLevel.md:
        baseSpacing = wp(2);
        break;
      case SpacingLevel.lg:
        baseSpacing = wp(3);
        break;
      case SpacingLevel.xl:
        baseSpacing = wp(4);
        break;
      case SpacingLevel.xxl:
        baseSpacing = wp(5);
        break;
    }

    return baseSpacing.clamp(4.0, 40.0);
  }
}

/// Spacing levels enum
enum SpacingLevel { xs, sm, md, lg, xl, xxl }