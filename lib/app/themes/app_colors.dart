import 'package:flutter/material.dart';

class AppColors {
  // 🌈 Brand Colors


  static const Color splaceSecondary2 = Color(0xFF22d3ee);
  static const Color splaceSecondary1 = Color(0xFF1d4ed8);
  static const Color freeCardWhite1 = Color(0xFFbdbdbd);
  static const Color freeCardWhite2 = Color(0xFFffffff);
  static const Color primeryamount = Color(0xFF22C55E); // rgba(34, 197, 94, 1)
  static const Color red500 = Color(0xFFEF4444); // Red gradient start
  static const Color red800 = Color(0xFF991B1B); // Red gradient end
  static const Color green400 = Color(0xFF4ADE80); // Green gradient start
  static const Color green800 = Color(0xFF166534); // Green gradient end
  static const Color blue700 = Color(0xFF1e3a8a); // rgba(30, 58, 138, 1)
  static const Color blue900 = Color(0xFF1d4ed8); // rgba(29, 78, 216, 1)
  static const Color splashArcColor = Color(0x1938B721); // Splash arc color with transparency
  static const Color splashArcColor2 = Color(0xFF1A3AB7); // Splash arc color 2
  static const Color splashArcColor3 = Color(0x33FFFFFF); // White with 20% opacity


  static const Color containerColor = Color(0x0FFFFFFF);
  static const Color borderColor = Color(0x19FFFFFF);
  static const Color headerGradientStart = Color(0xFF2d2d2d);
  static const Color headerGradientEnd = Color(0xFF1e1e1e);
  static const Color deletedDialog1 = Color(0xff991543);
  static const Color deletedDialog2 = Color(0xfff21a1e);
  static const Color girdBack = Color(0x0FFFFFFF);
  static const Color driver = Color(0x19FFFFFF);
  static const Color checkbox = Color(0x28ffffff);
  // 🖼️ Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF303030);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF0F0F0);
  static const Color goldenSliver = Color(0xFFC6BEA1);
  static const Color buttonTextColor = Color(0xFF1f1f1f);
  static const Color bottomSheet = Color(0xFF1f1f1f);
  static const Color deskSnackBack = Color(0xFF15803d);

  // 🎨 Text Colors
  static const Color textPrimary1 = Color(0xFF554D4D);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color anantSpaceColor = Color(0xff6f4d00);

  // ✔️ Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color yellow = Color(0xFFE1B93F);
  static const Color error = Color(0xFFD32F2F);
  static const Color blue = Color(0xFF2196F3);

  // 🧱 Border & Divider
  static const Color border = Color(0xFFBDBDBD);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border1 = Color(0xFF4cffffff);

  // 🌚 States
  static const Color disabled = Color(0xFF9E9E9E);
  static const Color focus = Color(0xFF64B5F6);
  static const Color hover = Color(0xFFE3F2FD);
  static const Color selected = Color(0xFFD1E3F8);

  // 🔳 Card & Containers
  static const Color card = Color(0xFFFFFFFF);
  static const Color sheet = Color(0xFFF8F8F8);

  // 🔲 Shadows
  static const Color shadowLight = Color(0x29000000); // black26
  static const Color shadowDark = Color(0x66000000); // black40
  static const Color containerBack = Color(0xFF262626); // black40
  static const Color dialogBariary = Color(0xFF302525); // black40

  // 🌫️ Overlay
  static const Color overlay = Color(0xFF171515); // 50% Black
  static const Color black = Color(0xFF000000); // 50% Black

  // ⛔ Alert/Dialog
  static const Color dialogBackground = Color(0xFFFFFFFF);
  static const Color snackBarBackground = Color(0xFF323232);

  // 🎛️ Button colors
  static const Color buttonDisabled = Color(0xFFBDBDBD);
  static const Color buttonText = Colors.white;

  // ============================================================================
  // 🎨 EXISTING GRADIENT COLORS (Used throughout the app - DO NOT ADD NEW ONES)
  // ============================================================================

  /// Primary App Gradients (existing)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF64B5F6), Color(0xFF2196F3)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  /// Success Gradient (currently used in main_screen.dart for upload success)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Brand/Golden Gradient (currently used in floating_button.dart)
  static const LinearGradient brandGradient = LinearGradient(
    colors: [splaceSecondary1, splaceSecondary2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🚫 Transparent
  static const Color transparent = Colors.transparent;
  static const Color transparentWhite70 = Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)



  // ============================================================================
  // 🚨 ERROR HANDLING COLORS (Centralized for all error displays)
  // ============================================================================

  /// Success colors (Green family)
  static const Color successPrimary = Color(0xFF4CAF50);      // Main success green
  static const Color successLight = Color(0xFF81C784);        // Light success
  static const Color successDark = Color(0xFF388E3C);         // Dark success
  static const Color successBackground = successPrimary;      // Error system background
  static const Color successText = Colors.white;              // Error system text
  static const Color successIcon = Colors.white;              // Error system icon

  /// Info colors (Blue family)
  static const Color infoPrimary = Color(0xFF2196F3);         // Main info blue
  static const Color infoLight = Color(0xFF64B5F6);           // Light info
  static const Color infoDark = Color(0xFF1976D2);            // Dark info
  static const Color infoBackground = infoPrimary;            // Error system background
  static const Color infoText = Colors.white;                 // Error system text
  static const Color infoIcon = Colors.white;                 // Error system icon

  /// Warning colors (Orange family)
  static const Color warningPrimary = Color(0xFFFF9800);      // Main warning orange
  static const Color warningLight = Color(0xFFFFB74D);        // Light warning
  static const Color warningDark = Color(0xFFF57C00);         // Dark warning
  static const Color warningBackground = warningPrimary;      // Error system background
  static const Color warningText = Colors.white;              // Error system text
  static const Color warningIcon = Colors.white;              // Error system icon

  /// Error colors (Red family)
  static const Color errorPrimary = Color(0xFFFF5722);        // Main error red
  static const Color errorLight = Color(0xFFFF8A65);          // Light error
  static const Color errorDark = Color(0xFFE64A19);           // Dark error
  static const Color errorBackground = errorPrimary;          // Error system background
  static const Color errorText = Colors.white;                // Error system text
  static const Color errorIcon = Colors.white;                // Error system icon

  /// Critical colors (Dark Red family)
  static const Color criticalPrimary = Color(0xFFD32F2F);     // Main critical red
  static const Color criticalLight = Color(0xFFEF5350);       // Light critical
  static const Color criticalDark = Color(0xFFB71C1C);        // Dark critical
  static const Color criticalBackground = criticalPrimary;    // Error system background
  static const Color criticalText = Colors.white;             // Error system text
  static const Color criticalIcon = Colors.white;             // Error system icon

  /// Network colors (Grey family)
  static const Color networkPrimary = Color(0xFF607D8B);      // Main network grey
  static const Color networkLight = Color(0xFF90A4AE);        // Light network
  static const Color networkDark = Color(0xFF455A64);         // Dark network
  static const Color networkBackground = networkPrimary;      // Error system background
  static const Color networkText = Colors.white;              // Error system text
  static const Color networkIcon = Colors.white;              // Error system icon

  /// Auth colors (Purple family)
  static const Color authPrimary = Color(0xFF9C27B0);         // Main auth purple
  static const Color authLight = Color(0xFFBA68C8);           // Light auth
  static const Color authDark = Color(0xFF7B1FA2);            // Dark auth
  static const Color authBackground = authPrimary;            // Error system background
  static const Color authText = Colors.white;                 // Error system text
  static const Color authIcon = Colors.white;                 // Error system icon

  /// Validation colors (Yellow family)
  static const Color validationPrimary = Color(0xFFFFC107);   // Main validation yellow
  static const Color validationLight = Color(0xFFFFD54F);     // Light validation
  static const Color validationDark = Color(0xFFFFA000);      // Dark validation
  static const Color validationBackground = validationPrimary; // Error system background
  static const Color validationText = Colors.black;           // Error system text (black for yellow bg)
  static const Color validationIcon = Colors.black;           // Error system icon (black for yellow bg)

  // ============================================================================
  // 🎨 UI COMPONENT COLORS (Centralized for all UI elements)
  // ============================================================================

  /// Dialog & Modal colors
  static const Color dialogBackgroundDark = Color(0xFF1F1F1F);  // Dark dialog background
  static const Color dialogBackgroundLight = Colors.white;       // Light dialog background
  static const Color dialogText = Colors.white70;                // Dialog text
  static const Color dialogTextSecondary = Colors.white54;       // Dialog secondary text
  static const Color bottomSheetBackground = Color(0xFF262626);   // Bottom sheet background
  static const Color handleBarColor = Color(0xFF595757);         // Bottom sheet handle bar
  static const Color dropdownBackground = Color(0xFF2a2a2a);     // Dropdown background
  static const Color dropdownSelected = Color(0xFF4A90E2);       // Dropdown selected item

  /// Border & Outline colors
  static const Color borderLight = Color(0xFFEEEEEE);           // Light border
  static const Color borderDark = Color(0xFF424242);            // Dark border
  static const Color borderDark1 = Color(0xFF4cffffff);            // Dark border
  static const Color borderAccent = Color(0xFF2d2d2d );          // Accent border (with transparency)
  static const Color outlineGrey = Colors.grey;                 // Standard grey outline

  /// Container & Card colors
  static const Color containerDark = Color(0xFF2d2d2d);         // Dark container
  static const Color containerLight = Color(0xFF1e1e1e);        // Light dark container
  static const Color cardDark = Color(0xFF1A1A1A);              // Dark card background
  static const Color cardOverlay = Color(0xFF1A1A1A);           // Card overlay color
  static const Color descontainerLight = Color(0xFF424242);           // Card overlay color
  static const Color descontainerDark = Color(0xFF212121);           // Card overlay color

  /// Text colors (Additional)
  static const Color textWhite = Colors.white;                  // Pure white text
  static const Color textWhite70 = Colors.white70;              // 70% white text
  static const Color textWhite54 = Colors.white54;              // 54% white text
  static const Color textBlack = Colors.black;                  // Pure black text
  static const Color textBlack87 = Colors.black87;              // 87% black text
  static const Color textGrey = Colors.grey;                    // Standard grey text

  /// Special UI colors
  static const Color redAccent = Colors.redAccent;              // Red accent for PDFs, etc.
  static const Color transparentWhite30 = Color(0x4DFFFFFF);    // 30% transparent white
  static const Color transparentBlack20 = Color(0x33000000);    // 20% transparent black
  static const Color transparentBlack = Colors.transparent;     // Fully transparent

  /// Button interaction colors
  static const Color splashTransparent = Colors.transparent;    // Splash color
  static const Color highlightTransparent = Colors.transparent; // Highlight color
  static const Color hoverTransparent = Colors.transparent;     // Hover color


  // ============================================================================
  // 🛠️ UTILITY METHODS FOR COLOR MANAGEMENT
  // ============================================================================

  /// Get error color by severity type
  static Color getErrorColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'success':
        return successBackground;
      case 'info':
        return infoBackground;
      case 'warning':
        return warningBackground;
      case 'error':
        return errorBackground;
      case 'critical':
        return criticalBackground;
      case 'network':
        return networkBackground;
      case 'auth':
        return authBackground;
      case 'validation':
        return validationBackground;
      default:
        return errorBackground;
    }
  }

  /// Get text color by severity type
  static Color getErrorTextColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'success':
        return successText;
      case 'info':
        return infoText;
      case 'warning':
        return warningText;
      case 'error':
        return errorText;
      case 'critical':
        return criticalText;
      case 'network':
        return networkText;
      case 'auth':
        return authText;
      case 'validation':
        return validationText; // Black for yellow background
      default:
        return errorText;
    }
  }

  /// Get shadow color by severity type
  static Color getErrorShadowColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'success':
        return successBackground.withOpacity(0.3);
      case 'info':
        return infoBackground.withOpacity(0.3);
      case 'warning':
        return warningBackground.withOpacity(0.3);
      case 'error':
        return errorBackground.withOpacity(0.3);
      case 'critical':
        return criticalBackground.withOpacity(0.3);
      case 'network':
        return networkBackground.withOpacity(0.3);
      case 'auth':
        return authBackground.withOpacity(0.3);
      case 'validation':
        return validationBackground.withOpacity(0.3);
      default:
        return errorBackground.withOpacity(0.3);
    }
  }
}
