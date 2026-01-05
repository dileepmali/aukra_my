
import 'package:flutter/material.dart';

import 'device_category.dart';
import 'font_size_hepler_class.dart';
import 'helper_class_2.dart';

extension AdvancedResponsiveHelperPart4 on AdvancedResponsiveHelper {
  /// 🔘 Button Responsive Sizing
  double get buttonHeightSmall => 36.0;
  double get buttonHeightMedium => 44.0;
  double get buttonHeightLarge => 52.0;
  double get buttonHeightExtraLarge => 60.0;

  double get buttonWidthSmall => wp(25);
  double get buttonWidthMedium => wp(40);
  double get buttonWidthLarge => wp(60);
  double get buttonWidthFull => wp(100);



  EdgeInsets get buttonPaddingSmall =>
      EdgeInsets.symmetric(horizontal: spacing(12), vertical: spacing(8));
  EdgeInsets get buttonPaddingMedium =>
      EdgeInsets.symmetric(horizontal: spacing(16), vertical: spacing(12));
  EdgeInsets get buttonPaddingLarge =>
      EdgeInsets.symmetric(horizontal: spacing(24), vertical: spacing(16));
  EdgeInsets get buttonPaddingExtraLarge =>
      EdgeInsets.symmetric(horizontal: spacing(32), vertical: spacing(20));

  /// 🖼️ Icon Responsive Sizing
  /// Desktop: Scale based on screen width for responsiveness across all desktop sizes
  /// Mobile/Tablet: Keep fixed sizes (already working perfectly)
  double get iconSizeSmall {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 0.9% of width, clamped between 12-16px
      return (screenWidth * 0.009).clamp(10.0, 16.0);
    }
    return 10.0; // Mobile/Tablet: Fixed size
  }

  double get iconSizeSmall1 {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 1.0% of width, clamped between 14-18px
      return (screenWidth * 0.010).clamp(14.0, 18.0);
    }
    return 1.0;
  }

  double get iconSizeMedium {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 1.3% of width, clamped between 18-24px
      return (screenWidth * 0.013).clamp(18.0, 24.0);
    }
    return 20.0;
  }

  double get iconSizeLarge {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 1.6% of width, clamped between 22-30px
      return (screenWidth * 0.016).clamp(22.0, 30.0);
    }
    return 25.0;
  }

  double get iconSizeLarge1 {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 2.2% of width, clamped between 28-40px
      return (screenWidth * 0.022).clamp(28.0, 40.0);
    }
    return 35.0;
  }

  double get iconSizeLarge2 {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 1.9% of width, clamped between 26-36px
      return (screenWidth * 0.019).clamp(26.0, 36.0);
    }
    return 30.0;
  }

  double get iconSizeExtraLarge {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 2.5% of width, clamped between 32-48px
      return (screenWidth * 0.025).clamp(32.0, 48.0);
    }
    return 40.0;
  }

  double get iconSizeExtraLarge1 {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 3.0% of width, clamped between 40-60px
      return (screenWidth * 0.030).clamp(40.0, 60.0);
    }
    return 50.0;
  }

  double get iconSizeHuge {
    if (deviceType == DeviceType.desktop) {
      // Desktop: 3.5% of width, clamped between 48-72px
      return (screenWidth * 0.035).clamp(48.0, 72.0);
    }
    return 60.0;
  }

  /// 🔲 Border Radius Responsive
  /// Desktop: Scale based on screen width for smooth edges on all sizes
  /// Mobile/Tablet: Keep fixed values (already perfect)
  double get borderRadiusSmall => 1.0;
  double get borderRadiusMedium => 8.0;
  double get borderRadiusLarge => 12.0;
  double get borderRadiusExtraLarge => 16.0;
  double get borderRadiusExtraLarge1 => 20.0;
  double get borderRadiusCircular => 100.0;


  /// 🎬 Play Button Specific Border Radius
  /// Desktop: Scale based on screen width for play button containers
  /// Mobile/Tablet: Keep fixed values
  double get playButtonBorderRadius {
    if (deviceType == DeviceType.desktop) {
      // Desktop: Scale from 18px to 30px based on screen size
      return (screenWidth * 0.025).clamp(25.0, 30.0);
    }
    return 25.0; // Mobile/Tablet: Fixed size
  }

  /// 📦 Container Heights & Widths
  double get containerHeightSmall => hp(8);
  double get containerHeightMedium => hp(12);
  double get containerHeightLarge => hp(20);
  double get containerHeightExtraLarge => hp(30);
  double get containerHeightHuge => hp(40);

  double get containerWidthSmall => wp(30);
  double get containerWidthMedium => wp(50);
  double get containerWidthLarge => wp(70);
  double get containerWidthExtraLarge => wp(85);
  double get containerWidthFull => wp(100);

  /// 🖼️ Image Sizing
  double get imageHeightSmall => 80.0;
  double get imageHeightMedium => 120.0;
  double get imageHeightLarge => 200.0;
  double get imageHeightExtraLarge => 300.0;

  double get imageWidthSmall => wp(25);
  double get imageWidthMedium => wp(40);
  double get imageWidthLarge => wp(60);
  double get imageWidthExtraLarge => wp(80);
  double get imageWidthFull => wp(100);

  /// 📏 Avatar Sizing
  double get avatarSizeSmall => 32.0;
  double get avatarSizeMedium => 48.0;
  double get avatarSizeLarge => 64.0;
  double get avatarSizeExtraLarge => 96.0;

  /// 🃏 Card Sizing
  double get cardHeightSmall => hp(15);
  double get cardHeightMedium => hp(25);
  double get cardHeightLarge => hp(35);
  double get cardHeightExtraLarge => hp(45);

  double get cardWidthSmall => wp(80);
  double get cardWidthMedium => wp(90);
  double get cardWidthLarge => wp(95);
}

extension AdvancedResponsiveHelperPart5 on AdvancedResponsiveHelper {
  /// 🧭 Navigation & Layout Dimensions
  double get appBarHeight => 56.0;

  double get bottomNavigationBarHeight => 56.0;

  double get drawerWidth => wp(80);

  /// Grid Columns Count for Responsive Layouts (Mobile, Tablet, Desktop)
  int get gridColumnsCount {
    // Desktop devices - 4-8 columns based on screen size
    if (isExtraLargeDesktop) return 8;
    if (isLargeDesktop) return 6;
    if (isStandardDesktop) return 5;
    if (isSmallDesktop) return 4;

    // Tablet devices - 3-4 columns
    if (isLargeTablet) return 4;
    if (isStandardTablet) return 3;
    if (isSmallTablet) return 3;

    // Mobile devices - 2 columns
    if (isUltraSmallMobile) return 2;
    if (isSmallMobile) return 2;
    if (isCompactMobile) return 2;
    if (isStandardMobile) return 2;
    if (isLargeMobile) return 2;
    if (isExtraLargeMobile) return 2;

    return 2; // Default fallback
  }

  /// Responsive Padding Sets
  EdgeInsets get screenPadding => EdgeInsets.symmetric(
      horizontal: spacing(15), vertical: spacing(15));

  EdgeInsets get widthPadding => EdgeInsets.symmetric(
      horizontal: spacing(22),);

  EdgeInsets get contentPadding => EdgeInsets.symmetric(
      horizontal: spacing(12), vertical: spacing(8));

  EdgeInsets get cardPadding => EdgeInsets.all(spacing(12));

  /// Responsive AppBar Widget Helper

}