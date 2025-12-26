import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppThemes {
  // Private constructor to prevent instantiation
  AppThemes._();

  // Light Theme Configuration
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: AppFonts.primary,
    primaryColor: AppColors.splaceSecondary1,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppFonts.headlineMedium().copyWith(
        color: AppColors.textPrimary,
      ),
      // Status bar styling for light theme
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.dark, // Dark icons (for light background)
        statusBarBrightness: Brightness.light, // Light status bar (for iOS)
        systemNavigationBarColor: AppColors.white, // Bottom navigation bar color
        systemNavigationBarIconBrightness: Brightness.dark, // Dark icons for bottom nav
      ),
    ),

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.splaceSecondary1,
      secondary: AppColors.splaceSecondary2,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.white,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.splaceSecondary1,
        foregroundColor: AppColors.buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppFonts.labelLarge(),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.splaceSecondary1,
        textStyle: AppFonts.labelLarge(),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.splaceSecondary1,
        side: BorderSide(color: AppColors.splaceSecondary1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppFonts.labelLarge(),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.splaceSecondary1, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textDisabled),
      labelStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textSecondary),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),

    // Text Theme
    textTheme: TextTheme(
      // Display styles
      displayLarge: AppFonts.displayLarge().copyWith(color: AppColors.textPrimary),
      displayMedium: AppFonts.displayMedium().copyWith(color: AppColors.textPrimary),
      displaySmall: AppFonts.displaySmall().copyWith(color: AppColors.textPrimary),

      // Headline styles
      headlineLarge: AppFonts.headlineLarge().copyWith(color: AppColors.textPrimary),
      headlineMedium: AppFonts.headlineMedium().copyWith(color: AppColors.textPrimary),
      headlineSmall: AppFonts.headlineSmall().copyWith(color: AppColors.textPrimary),

      // Body styles
      bodyLarge: AppFonts.bodyLarge().copyWith(color: AppColors.textPrimary),
      bodyMedium: AppFonts.bodyMedium().copyWith(color: AppColors.textPrimary),
      bodySmall: AppFonts.bodySmall().copyWith(color: AppColors.textSecondary),

      // Label styles
      labelLarge: AppFonts.labelLarge().copyWith(color: AppColors.textPrimary),
      labelMedium: AppFonts.labelMedium().copyWith(color: AppColors.textPrimary),
      labelSmall: AppFonts.labelSmall().copyWith(color: AppColors.textSecondary),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.splaceSecondary1,
      unselectedItemColor: AppColors.textDisabled,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.background,
      selectedColor: AppColors.splaceSecondary1.withOpacity(0.2),
      disabledColor: AppColors.disabled.withOpacity(0.2),
      labelStyle: AppFonts.labelMedium(),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: AppFonts.headlineSmall().copyWith(color: AppColors.textPrimary),
      contentTextStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textPrimary),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.snackBarBackground,
      contentTextStyle: AppFonts.bodyMedium().copyWith(color: AppColors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Dark Theme Configuration
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppFonts.primary,
    primaryColor: AppColors.splaceSecondary1,
    scaffoldBackgroundColor: AppColors.overlay,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.containerDark,
      foregroundColor: AppColors.textInverse,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textInverse),
      titleTextStyle: AppFonts.headlineMedium().copyWith(
        color: AppColors.textInverse,
      ),
      // Status bar styling for dark theme
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent status bar
        statusBarIconBrightness: Brightness.light, // Light icons (for dark background)
        statusBarBrightness: Brightness.dark, // Dark status bar (for iOS)
        systemNavigationBarColor: AppColors.containerDark, // Bottom navigation bar color
        systemNavigationBarIconBrightness: Brightness.light, // Light icons for bottom nav
      ),
    ),

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.splaceSecondary1,
      secondary: AppColors.splaceSecondary2,
      surface: AppColors.containerDark,
      background: AppColors.overlay,
      error: AppColors.error,
      onPrimary: AppColors.buttonTextColor,
      onSecondary: AppColors.buttonTextColor,
      onSurface: AppColors.textInverse,
      onBackground: AppColors.textInverse,
      onError: AppColors.white,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.containerDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.splaceSecondary1,
        foregroundColor: AppColors.buttonTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppFonts.labelLarge(),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.splaceSecondary2,
        textStyle: AppFonts.labelLarge(),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.splaceSecondary2,
        side: BorderSide(color: AppColors.splaceSecondary2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: AppFonts.labelLarge(),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.containerDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDark1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.borderDark1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.splaceSecondary1, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textWhite54),
      labelStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textWhite70),
    ),

    // Icon Theme
    iconTheme: IconThemeData(
      color: AppColors.textInverse,
      size: 24,
    ),

    // Text Theme
    textTheme: TextTheme(
      // Display styles
      displayLarge: AppFonts.displayLarge().copyWith(color: AppColors.textInverse),
      displayMedium: AppFonts.displayMedium().copyWith(color: AppColors.textInverse),
      displaySmall: AppFonts.displaySmall().copyWith(color: AppColors.textInverse),

      // Headline styles
      headlineLarge: AppFonts.headlineLarge().copyWith(color: AppColors.textInverse),
      headlineMedium: AppFonts.headlineMedium().copyWith(color: AppColors.textInverse),
      headlineSmall: AppFonts.headlineSmall().copyWith(color: AppColors.textInverse),

      // Body styles
      bodyLarge: AppFonts.bodyLarge().copyWith(color: AppColors.textInverse),
      bodyMedium: AppFonts.bodyMedium().copyWith(color: AppColors.textWhite70),
      bodySmall: AppFonts.bodySmall().copyWith(color: AppColors.textWhite54),

      // Label styles
      labelLarge: AppFonts.labelLarge().copyWith(color: AppColors.textInverse),
      labelMedium: AppFonts.labelMedium().copyWith(color: AppColors.textWhite70),
      labelSmall: AppFonts.labelSmall().copyWith(color: AppColors.textWhite54),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.containerDark,
      selectedItemColor: AppColors.splaceSecondary1,
      unselectedItemColor: AppColors.textWhite54,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.borderDark1,
      thickness: 1,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.containerDark,
      selectedColor: AppColors.splaceSecondary1.withOpacity(0.3),
      disabledColor: AppColors.disabled.withOpacity(0.2),
      labelStyle: AppFonts.labelMedium().copyWith(color: AppColors.textInverse),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dialogBackgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titleTextStyle: AppFonts.headlineSmall().copyWith(color: AppColors.textInverse),
      contentTextStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textWhite70),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.bottomSheetBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.containerDark,
      contentTextStyle: AppFonts.bodyMedium().copyWith(color: AppColors.textInverse),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // Get theme based on mode
  static ThemeData getTheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return lightTheme;
      case ThemeMode.dark:
        return darkTheme;
      case ThemeMode.system:
      default:
        // Will be handled by MaterialApp to use system preference
        return lightTheme;
    }
  }
}