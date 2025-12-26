
import 'device_category.dart';

extension AdvancedResponsiveHelperPart3 on AdvancedResponsiveHelper {
  /// 🎨 Smart Font Sizing
  double fontSize(double baseSize) {
    double multiplier = _getFontMultiplier();
    return baseSize * multiplier;
  }

  double _getFontMultiplier() {
    switch (deviceCategory) {
      // Mobile devices
      case DeviceCategory.ultraSmallMobile:
        return 0.75;
      case DeviceCategory.smallMobile:
        return 0.85;
      case DeviceCategory.compactMobile:
        return 0.9;
      case DeviceCategory.standardMobile:
        return 1.0;
      case DeviceCategory.largeMobile:
        return 1.05;
      case DeviceCategory.extraLargeMobile:
        return 1.1;

      // Tablet devices - slightly smaller than desktop for better readability
      case DeviceCategory.smallTablet:
        return 0.95;
      case DeviceCategory.standardTablet:
        return 1.0;
      case DeviceCategory.largeTablet:
        return 1.05;

      // Desktop/Web - use fixed pixel sizes, not percentage-based
      case DeviceCategory.smallDesktop:
        return 0.85; // Smaller multiplier for desktop as base is larger
      case DeviceCategory.standardDesktop:
        return 0.9;
      case DeviceCategory.largeDesktop:
        return 0.95;
      case DeviceCategory.extraLargeDesktop:
        return 1.0;
    }
  }

  /// 📐 Smart Spacing
  double spacing(double baseSpacing) {
    double multiplier = _getSpacingMultiplier();
    return baseSpacing * multiplier;
  }

  double _getSpacingMultiplier() {
    switch (deviceCategory) {
      // Mobile devices
      case DeviceCategory.ultraSmallMobile:
        return 0.7;
      case DeviceCategory.smallMobile:
        return 0.8;
      case DeviceCategory.compactMobile:
        return 0.9;
      case DeviceCategory.standardMobile:
        return 1.0;
      case DeviceCategory.largeMobile:
        return 1.1;
      case DeviceCategory.extraLargeMobile:
        return 1.15;

      // Tablet devices
      case DeviceCategory.smallTablet:
        return 1.2;
      case DeviceCategory.standardTablet:
        return 1.25;
      case DeviceCategory.largeTablet:
        return 1.3;

      // Desktop/Web - larger spacing for better layout
      case DeviceCategory.smallDesktop:
        return 1.35;
      case DeviceCategory.standardDesktop:
        return 1.4;
      case DeviceCategory.largeDesktop:
        return 1.45;
      case DeviceCategory.extraLargeDesktop:
        return 1.5;
    }
  }

  /// 📏 Spacing Shortcuts
  double get space2XSSS => spacing(0.5);
  double get space2XSS => spacing(1);
  double get space2XS => spacing(2);
  double get spaceXS => spacing(4);
  double get spaceXSS => spacing(6);
  double get spaceSM => spacing(8);
  double get spaceMD => spacing(12);
  double get spaceLG => spacing(16);
  double get spaceXL => spacing(24);
  double get space2XL => spacing(32);
  double get space3XL => spacing(48);
  double get space4XL => spacing(64);
  double get space4XLL => spacing(85);
  double get space5XL => spacing(96);

  /// 🎭 Text Styles - Material 3 Typography

}
