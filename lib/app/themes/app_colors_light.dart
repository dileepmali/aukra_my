import 'package:flutter/material.dart';

class AppColorsLight {
  // Private constructor to prevent instantiation
  AppColorsLight._();

  // 🌈 Brand Colors (Same for both themes)
  static const Color splaceSecondary2 = Color(0xFFe3bc5f);
  static const Color splaceSecondary1 = Color(0xFFca9b2b);

  // 🖼️ Backgrounds - Light Theme
  static const Color scaffoldBackground = Color(0xFFe0e0e0);
  static const Color cardBackground = Color(0xf5f5f5);
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF070707);

  // 🎨 Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF070707);
  static const Color textSecondary = Color(0xFF2C2B2B);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textPrimaryWhite = Color(0xFFFFFFFF);
  static const Color dekDrawerBack = Color(0xfff5f5f5);
  static const Color filterBack = Color(0xff0000001e);

  // 🧱 Border & Divider - Light Theme
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // 🔳 Card & Containers - Light Theme
  static const Color container = Color(0xFFF5F5F5);
  static const Color containerLight = Color(0xFFFFFFFF);

  // ✔️ Status Colors (Same for both themes)
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFD32F2F);
  static const Color blue = Color(0xFF2196F3);

  // 🌚 States - Light Theme
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color focus = Color(0xFF64B5F6);
  static const Color hover = Color(0xFFF5F5F5);
  static const Color selected = Color(0xFFE3F2FD);

  // 🔲 Shadows - Light Theme
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowMedium = Color(0x29000000);

  // 🎨 Gradient Colors - Light Theme (reusable across widgets)
  static const Color gradientColor1 = Color(0x14000000);
  static const Color gradientColor2 = Color(0x28000000);

  // ⛔ Alert/Dialog - Light Theme
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color dialogBarrier = Color(0x80000000);
  static const Color snackBarBackground = Color(0xFF323232);

  // 🎛️ Button colors - Light Theme
  static const Color buttonDisabled = Color(0xFFE0E0E0);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color buttonTextColor = Color(0xFF1f1f1f);

  // 🔆 App Bar - Light Theme
  static const Color appBarBackground = Color(0xFFFFFFFF);
  static const Color appBarText = Color(0xFF212121);

  // 🔆 Bottom Navigation - Light Theme
  static const Color bottomNavBackground = Color(0xFFFFFFFF);
  static const Color bottomNavSelected = Color(0xFFca9b2b);
  static const Color bottomNavUnselected = Color(0xFF9E9E9E);

  // 🚫 Transparent
  static const Color transparent = Colors.transparent;

  // Icon colors
  static const Color iconPrimary = Color(0xFF212121);
  static const Color iconSecondary = Color(0xFF757575);

  // Input/TextField colors
  static const Color inputBackground = Color(0xFFF5F5F5);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusedBorder = Color(0xFFca9b2b);

  // Refresh Indicator
  static const Color refreshIndicatorBackground = Color(0xFFFFFFFF);
  static const Color refreshIndicatorColor = Color(0xFFca9b2b);

  // Loading Indicator
  static const Color loadingIndicator = Color(0xFFca9b2b);

  // ============================================================================
  // 🎨 GRADIENT COLORS FOR LIGHT THEME
  // ============================================================================

  /// Brand/Golden Gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [splaceSecondary1, splaceSecondary2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success Gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}