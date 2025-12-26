import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Device Categories Enum - Supports Mobile, Tablet, Desktop, and Web
enum DeviceCategory {
  // Mobile devices (< 600px)
  ultraSmallMobile,
  smallMobile,
  compactMobile,
  standardMobile,
  largeMobile,
  extraLargeMobile,

  // Tablet devices (600px - 1024px)
  smallTablet,
  standardTablet,
  largeTablet,

  // Desktop/Web (> 1024px)
  smallDesktop,
  standardDesktop,
  largeDesktop,
  extraLargeDesktop,
}

/// Device Type Helper Enum - Supports all platforms
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Button Size Enum
enum ButtonSize { small, medium, large, extraLarge }

/// Icon Button Size Enum
enum IconButtonSize { small, medium, large, extraLarge }

/// 🚀 Complete Advanced Responsive Helper Class
class AdvancedResponsiveHelper {
  final BuildContext context;

  // Cache for performance optimization
  static final Map<String, dynamic> _cache = {};

  AdvancedResponsiveHelper(this.context);

  MediaQueryData get _mediaQuery => MediaQuery.of(context);
  Size get _screenSize => _mediaQuery.size;
  double get _screenWidth => _screenSize.width;
  double get _screenHeight => _screenSize.height;
  double get _pixelRatio => _mediaQuery.devicePixelRatio;
  Orientation get _orientation => _mediaQuery.orientation;

  Orientation get orientation => _orientation;
  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;

  // Physical screen dimensions
  double get _physicalWidth => _screenWidth * _pixelRatio;
  double get _physicalHeight => _screenHeight * _pixelRatio;

  /// Calculate screen diagonal in inches
  double _calculateScreenDiagonal() {
    final widthInches = _physicalWidth / (_pixelRatio * 160);
    final heightInches = _physicalHeight / (_pixelRatio * 160);
    return math.sqrt(widthInches * widthInches + heightInches * heightInches);
  }

  /// 📱💻🖥️ Universal Device Detection (Mobile, Tablet, Desktop, Web)
  DeviceCategory get deviceCategory {
    final cacheKey = 'deviceCategory_${_screenWidth}_${_screenHeight}_${_pixelRatio}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    final width = _screenWidth;
    final diagonal = _calculateScreenDiagonal();

    DeviceCategory category;

    // 🖥️ DESKTOP/WEB Detection (> 1024px) - For Web browsers and desktop apps
    if (width >= 1920) {
      category = DeviceCategory.extraLargeDesktop; // 4K, Ultra-wide monitors
    } else if (width >= 1440) {
      category = DeviceCategory.largeDesktop; // Large desktop monitors
    } else if (width >= 1280) {
      category = DeviceCategory.standardDesktop; // Standard desktop (1280x720, 1366x768)
    } else if (width >= 1024) {
      category = DeviceCategory.smallDesktop; // Small desktop/laptop (1024x768)
    }
    // 📱 TABLET Detection (600px - 1023px)
    else if (width >= 900) {
      category = DeviceCategory.largeTablet; // iPad Pro 12.9" (1024x1366)
    } else if (width >= 768) {
      category = DeviceCategory.standardTablet; // iPad (768x1024)
    } else if (width >= 600) {
      category = DeviceCategory.smallTablet; // Small tablets
    }
    // 📱 MOBILE Detection (< 600px)
    else if (width < 320 || diagonal < 3.5) {
      category = DeviceCategory.ultraSmallMobile; // iPhone SE, small Android
    } else if (width < 375 || diagonal < 4.5) {
      category = DeviceCategory.smallMobile; // iPhone 6/7/8
    } else if (width < 390 || diagonal < 5.5) {
      category = DeviceCategory.compactMobile; // iPhone 12 mini
    } else if (width < 420 || diagonal < 6.0) {
      category = DeviceCategory.standardMobile; // iPhone 12/13/14
    } else if (width < 480 || diagonal < 6.5) {
      category = DeviceCategory.largeMobile; // iPhone 14 Pro Max
    } else {
      category = DeviceCategory.extraLargeMobile; // Large phones
    }

    _cache[cacheKey] = category;
    return category;
  }

  /// Get Device Type Helper - Detects mobile, tablet, or desktop
  DeviceType get deviceType {
    final width = _screenWidth;

    // Desktop: > 1024px
    if (width >= 1024) {
      return DeviceType.desktop;
    }
    // Tablet: 600px - 1023px
    else if (width >= 600) {
      return DeviceType.tablet;
    }
    // Mobile: < 600px
    else {
      return DeviceType.mobile;
    }
  }
}
