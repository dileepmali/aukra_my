import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppFonts {
  // ============================================================================
  // 🔤 FONT FAMILY DEFINITIONS
  // ============================================================================
  
  /// Primary font family (BricolageGrotesque - currently available)
  static const String primary = 'BricolageGrotesque';
  
  /// Secondary font family (Future font - to be added)
  static const String secondary = 'Roboto'; // Fallback to system font
  
  /// Accent font family (Future font - to be added)
  static const String accent = 'Poppins'; // Fallback to system font
  
  /// Monospace font family (For code/data display)
  static const String monospace = 'Courier New';
  
  /// Default system font fallback
  static const String systemDefault = 'System';

  // ============================================================================
  // 🎯 FONT WEIGHT DEFINITIONS
  // ============================================================================
  
  /// Extra Light (200)
  static const FontWeight extraLight = FontWeight.w200;
  
  /// Light (300)
  static const FontWeight light = FontWeight.w300;
  
  /// Regular (400) - Default
  static const FontWeight regular = FontWeight.w400;
  
  /// Medium (500)
  static const FontWeight medium = FontWeight.w500;
  
  /// Semi Bold (600)
  static const FontWeight semiBold = FontWeight.w600;
  
  /// Bold (700)
  static const FontWeight bold = FontWeight.w700;
  
  /// Extra Bold (800)
  static const FontWeight extraBold = FontWeight.w800;

  // ============================================================================
  // 📏 TEXT STYLE PRESETS - DISPLAY & HEADLINES
  // ============================================================================

  /// Display Large - For major headings and hero text
  static TextStyle displayLarge({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 24.sp,  // 32px on standard devices, responsive with sp
      fontWeight: fontWeight ?? bold,
      height: 1.2,
      color: color,
      letterSpacing: -0.5,
    );
  }
  
  /// Display Medium - For section headings
  static TextStyle displayMedium({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 21.sp,  // 28px on standard devices, responsive with sp
      fontWeight: fontWeight ?? bold,
      height: 1.3,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle displayMedium1({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 20.sp,  // 28px on standard devices, responsive with sp
      fontWeight: fontWeight ?? bold,
      height: 1.3,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle displayMedium2({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 19.sp,  // 28px on standard devices, responsive with sp
      fontWeight: fontWeight ?? bold,
      height: 1.3,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle displayMedium3({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 18.5.sp,  // 28px on standard devices, responsive with sp
      fontWeight: fontWeight ?? bold,
      height: 1.3,
      color: color,
      letterSpacing: -0.3,
    );
  }
  
  /// Display Small - For sub-section headings
  static TextStyle displaySmall({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 18.sp,  // 24px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.3,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle searchbar({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 17.sp,  // 24px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.3,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle searchbar2({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 17.sp,  // 24px on standard devices, responsive with sp
      fontWeight: fontWeight ?? extraLight,
      height: 1.3,
      color: color,
      letterSpacing: -0.2,
    );
  }

  static TextStyle searchbar1({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 15.5.sp,  // 24px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.2,
      color: color,
      letterSpacing: -0.2,
    );
  }

  // ============================================================================
  // 📰 TEXT STYLE PRESETS - HEADLINES
  // ============================================================================
  
  /// Headline Large - For page titles
  static TextStyle headlineLarge({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 15.sp,  // 20px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.4,
      color: color,
      letterSpacing: 0.0,
    );
  }

  static TextStyle headlineLarge1({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 14.sp,  // 20px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.4,
      color: color,
      letterSpacing: 0.0,
    );
  }
  
  /// Headline Medium - For card titles
  static TextStyle headlineMedium({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 13.5.sp,  // 18px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.4,
      color: color,
      letterSpacing: 0.0,
    );
  }
  static TextStyle headlineSmall1({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 12.5.sp,  // 16px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.4,
      color: color,
      letterSpacing: 0.1,
    );
  }
  /// Headline Small - For small headings
  static TextStyle headlineSmall({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 12.sp,  // 16px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.4,
      color: color,
      letterSpacing: 0.1,
    );
  }

  // ============================================================================
  // 📝 TEXT STYLE PRESETS - BODY TEXT
  // ============================================================================
  
  /// Body Large - For important body text
  static TextStyle bodyLarge({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 12.sp,  // 16px on standard devices, responsive with sp
      fontWeight: fontWeight ?? regular,
      height: 1.5,
      color: color,
      letterSpacing: 0.1,
    );
  }

  static TextStyle bodyLarge1({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 11.sp,  // 16px on standard devices, responsive with sp
      fontWeight: fontWeight ?? regular,
      height: 1.5,
      color: color,
      letterSpacing: 0.1,
    );
  }
  
  /// Body Medium - For regular body text
  static TextStyle bodyMedium({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 10.5.sp,  // 14px on standard devices, responsive with sp
      fontWeight: fontWeight ?? regular,
      height: 1.5,
      color: color,
      letterSpacing: 0.1,
    );
  }
  
  /// Body Small - For supporting text
  static TextStyle bodySmall({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 9.sp,  // 12px on standard devices, responsive with sp
      fontWeight: fontWeight ?? regular,
      height: 1.4,
      color: color,
      letterSpacing: 0.2,
    );
  }

  // ============================================================================
  // 🏷️ TEXT STYLE PRESETS - LABELS & CAPTIONS
  // ============================================================================
  
  /// Label Large - For form labels and button text
  static TextStyle labelLarge({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 10.5.sp,  // 14px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.3,
      color: color,
      letterSpacing: 0.1,
    );
  }
  
  /// Label Medium - For smaller labels
  static TextStyle labelMedium({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 9.sp,  // 12px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.3,
      color: color,
      letterSpacing: 0.2,
    );
  }
  
  /// Label Small - For tiny labels and hints
  static TextStyle labelSmall({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 7.5.sp,  // 10px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.2,
      color: color,
      letterSpacing: 0.3,
    );
  }
  
  /// Caption - For metadata and timestamps
  static TextStyle caption({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 9.sp,  // 12px on standard devices, responsive with sp
      fontWeight: fontWeight ?? regular,
      height: 1.3,
      color: color,
      letterSpacing: 0.3,
    );
  }
  
  /// Overline - For overline text (categories, tags)
  static TextStyle overline({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 7.5.sp,  // 10px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.2,
      color: color,
      letterSpacing: 1.0,
    );
  }

  // ============================================================================
  // 🎨 SPECIALIZED TEXT STYLES
  // ============================================================================
  
  /// Button text style
  static TextStyle button({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: fontSize ?? 18.5.sp,  // 14px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.2,
      color: color,
      letterSpacing: 0.5,
    );
  }

  static TextStyle dialogButton({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: fontSize ?? 16.5.sp,  // 14px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.2,
      color: color,
      letterSpacing: 0.5,
    );
  }

  static TextStyle appBarTitleLarge({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 18.sp,  // 20px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.2,
      color: color,
      letterSpacing: 0.0,
    );
  }
  /// App Bar title style
  static TextStyle appBarTitle({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 15.sp,  // 20px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.2,
      color: color,
      letterSpacing: 0.0,
    );
  }

  static TextStyle appBarTitleMedium({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 16.sp,  // 20px on standard devices, responsive with sp
      fontWeight: fontWeight ?? semiBold,
      height: 1.2,
      color: color,
      letterSpacing: 0.0,
    );
  }
  
  /// Tab bar text style
  static TextStyle tabBar({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 10.5.sp,  // 14px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.2,
      color: color,
      letterSpacing: 0.2,
    );
  }
  
  /// Navigation text style
  static TextStyle navigation({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 9.sp,  // 12px on standard devices, responsive with sp
      fontWeight: fontWeight ?? medium,
      height: 1.2,
      color: color,
      letterSpacing: 0.3,
    );
  }
  
  /// Code/Monospace text style
  static TextStyle code({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
    double? fontSize,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? monospace,
      fontSize: fontSize ?? 10.5.sp,  // 14px on standard devices, responsive with sp
      fontWeight: fontWeight ?? regular,
      height: 1.4,
      color: color,
      letterSpacing: 0.0,
    );
  }

  // ============================================================================
  // 🔧 UTILITY METHODS
  // ============================================================================
  
  /// Get available font families
  static List<String> getAvailableFonts() {
    return [
      primary,
      secondary,
      accent,
      monospace,
      systemDefault,
    ];
  }
  
  /// Check if a font family is available
  static bool isFontAvailable(String fontFamily) {
    return getAvailableFonts().contains(fontFamily);
  }
  
  /// Get fallback font if the requested font is not available
  static String getFallbackFont(String requestedFont) {
    if (isFontAvailable(requestedFont)) {
      return requestedFont;
    }
    return primary; // Fallback to primary font
  }
  
  /// Create custom text style with font fallback
  static TextStyle createCustomStyle({
    required double fontSize,
    String? fontFamily,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    bool useResponsive = true,  // Flag to use responsive sizing
  }) {
    return TextStyle(
      fontFamily: getFallbackFont(fontFamily ?? primary),
      fontSize: useResponsive ? fontSize.sp : fontSize,
      fontWeight: fontWeight ?? regular,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ============================================================================
  // 📱 RESPONSIVE TEXT STYLES WITH SIZER
  // ============================================================================

  /// Get adaptive font size based on device type
  /// This method provides more granular control over font sizes
  static double getAdaptiveFontSize(double baseSize) {
    // Using screen width to detect device type
    // Phones typically have width < 600, tablets >= 600
    bool isTablet = 100.w >= 600;

    if (!isTablet) {
      // For mobile devices
      if (100.w < 360) {
        // Extra small phones (width < 360px)
        return (baseSize * 0.85).sp;
      } else if (100.w < 400) {
        // Small to medium phones
        return (baseSize * 0.9).sp;
      } else {
        // Large phones
        return baseSize.sp;
      }
    } else {
      // For tablets
      return (baseSize * 1.1).sp;
    }
  }

  /// Get responsive font size with custom scaling
  static double getResponsiveFontSize({
    required double baseSize,
    double? minSize,
    double? maxSize,
  }) {
    double responsiveSize = baseSize.sp;

    // Apply min/max constraints if provided
    if (minSize != null && responsiveSize < minSize) {
      return minSize;
    }
    if (maxSize != null && responsiveSize > maxSize) {
      return maxSize;
    }

    return responsiveSize;
  }

  /// Dynamic text style based on screen orientation
  static TextStyle getOrientationBasedStyle({
    required TextStyle portraitStyle,
    required TextStyle landscapeStyle,
    required BuildContext context,
  }) {
    return MediaQuery.of(context).orientation == Orientation.portrait
        ? portraitStyle
        : landscapeStyle;
  }

  /// Get text scale factor for accessibility
  static double getTextScaleFactor() {
    // This helps maintain readability for users who have adjusted text size in settings
    // Note: In Sizer 3.x, we can use a default value of 1.0
    double deviceTextScaleFactor = 1.0;

    // Cap the scale factor to prevent text from becoming too large or too small
    if (deviceTextScaleFactor > 1.3) {
      return 1.3;
    } else if (deviceTextScaleFactor < 0.8) {
      return 0.8;
    }

    return deviceTextScaleFactor;
  }

  // ============================================================================
  // 🎯 DEVICE-SPECIFIC TEXT PRESETS
  // ============================================================================

  /// Extra large text for tablets and large screens
  static TextStyle extraLargeDisplay({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    // Using screen width to detect tablets (width >= 600)
    bool isTablet = 100.w >= 600;
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: isTablet ? 30.sp : 26.sp,
      fontWeight: fontWeight ?? extraBold,
      height: 1.1,
      color: color,
      letterSpacing: -0.8,
    );
  }

  /// Tiny text for dense information display
  static TextStyle tinyText({
    Color? color,
    String? fontFamily,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: fontFamily ?? primary,
      fontSize: 6.5.sp,  // 8-9px on standard devices
      fontWeight: fontWeight ?? regular,
      height: 1.2,
      color: color,
      letterSpacing: 0.3,
    );
  }
}