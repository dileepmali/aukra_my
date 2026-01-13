import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'app_fonts.dart';

// ============================================================================
// 📱 APP TEXT - AUTO SIZE TEXT WRAPPER
// ============================================================================
/// Wrapper class jo AppFonts aur AutoSizeText ko combine karta hai
/// Ye class automatically text ko fit karega aur overflow prevent karega
///
/// Perfect for:
/// - Localization (South Indian languages with longer text)
/// - Responsive layouts
/// - Preventing text overflow
/// - Maintaining consistent styling
// ============================================================================

class AppText {

  // ============================================================================
  // 📏 DISPLAY & HEADLINES - AUTO SIZE
  // ============================================================================

  /// Display Large - Auto sizing ke saath
  /// Best for: Hero text, major headings
  static Widget displayLarge(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 16,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.displayLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Display Medium - Auto sizing ke saath
  /// Best for: Section headings
  static Widget displayMedium(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 14,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.displayMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Display Medium 1 - Auto sizing ke saath
  static Widget displayMedium1(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 14,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.displayMedium1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Display Medium 2 - Auto sizing ke saath
  static Widget displayMedium2(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 13,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.displayMedium2(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium2(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Display Medium 3 - Auto sizing ke saath
  static Widget displayMedium3(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 13,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.displayMedium3(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium3(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Display Small - Auto sizing ke saath
  /// Best for: Sub-section headings
  static Widget displaySmall(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.displaySmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displaySmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Searchbar - Auto sizing ke saath
  /// Best for: Search fields
  static Widget searchbar(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.searchbar(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.searchbar(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Searchbar 1 - Auto sizing ke saath
  static Widget searchbar1(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 11,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.searchbar1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.searchbar1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Searchbar 2 - Auto sizing ke saath (Extra Light)
  static Widget searchbar2(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.searchbar2(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.searchbar2(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  // ============================================================================
  // 📰 HEADLINES - AUTO SIZE
  // ============================================================================

  /// Headline Large - Auto sizing ke saath
  /// Best for: Page titles
  static Widget headlineLarge(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 11,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.headlineLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Headline Large 1 - Auto sizing ke saath
  static Widget headlineLarge1(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 10,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.headlineLarge1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineLarge1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Headline Medium - Auto sizing ke saath
  /// Best for: Card titles
  static Widget headlineMedium(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 10,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.headlineMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Headline Small - Auto sizing ke saath
  /// Best for: Small headings
  static Widget headlineSmall(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 9,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.headlineSmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineSmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Headline Small 1 - Auto sizing ke saath
  static Widget headlineSmall1(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 9,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.headlineSmall1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineSmall1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  // ============================================================================
  // 📝 BODY TEXT - AUTO SIZE
  // ============================================================================

  /// Body Large - Auto sizing ke saath
  /// Best for: Important body text
  static Widget bodyLarge(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 9,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.bodyLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodyLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Body Large 1 - Auto sizing ke saath
  static Widget bodyLarge1(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.bodyLarge1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodyLarge1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Body Medium - Auto sizing ke saath
  /// Best for: Regular body text
  static Widget bodyMedium(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.bodyMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodyMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Body Small - Auto sizing ke saath
  /// Best for: Supporting text
  static Widget bodySmall(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.bodySmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodySmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  // ============================================================================
  // 🏷️ LABELS & CAPTIONS - AUTO SIZE
  // ============================================================================

  /// Label Large - Auto sizing ke saath
  /// Best for: Form labels, button text
  static Widget labelLarge(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.labelLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.labelLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Label Medium - Auto sizing ke saath
  /// Best for: Smaller labels
  static Widget labelMedium(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.labelMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.labelMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Label Small - Auto sizing ke saath
  /// Best for: Tiny labels and hints
  static Widget labelSmall(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 6,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.labelSmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.labelSmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Caption - Auto sizing ke saath
  /// Best for: Metadata, timestamps
  static Widget caption(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.caption(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.caption(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Overline - Auto sizing ke saath
  /// Best for: Categories, tags
  static Widget overline(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 6,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.overline(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.overline(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  // ============================================================================
  // 🎨 SPECIALIZED - AUTO SIZE
  // ============================================================================

  /// Button Text - Auto sizing ke saath
  /// Best for: Button labels (especially localized)
  static Widget button(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 10,
    double? fontSize,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.button(color: color, fontWeight: fontWeight, fontSize: fontSize).copyWith(letterSpacing: letterSpacing)
          : AppFonts.button(color: color, fontWeight: fontWeight, fontSize: fontSize),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign ?? TextAlign.center,
      group: group,
    );
  }

  /// Dialog Button Text - Auto sizing ke saath
  /// Best for: Dialog buttons
  static Widget dialogButton(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 10,
    double? fontSize,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.dialogButton(color: color, fontWeight: fontWeight, fontSize: fontSize).copyWith(letterSpacing: letterSpacing)
          : AppFonts.dialogButton(color: color, fontWeight: fontWeight, fontSize: fontSize),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign ?? TextAlign.center,
      group: group,
    );
  }

  /// App Bar Title Large - Auto sizing ke saath
  /// Best for: Large app bar titles
  static Widget appBarTitleLarge(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 13,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.appBarTitleLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.appBarTitleLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// App Bar Title - Auto sizing ke saath
  /// Best for: Standard app bar titles
  static Widget appBarTitle(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.appBarTitle(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.appBarTitle(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// App Bar Title Medium - Auto sizing ke saath
  static Widget appBarTitleMedium(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.appBarTitleMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.appBarTitleMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Tab Bar - Auto sizing ke saath
  /// Best for: Tab labels
  static Widget tabBar(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.tabBar(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.tabBar(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Navigation - Auto sizing ke saath
  /// Best for: Bottom nav, drawer items
  static Widget navigation(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.navigation(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.navigation(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Code/Monospace - Auto sizing ke saath
  /// Best for: Code snippets, data display
  static Widget code(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 5,
    double minFontSize = 8,
    double? fontSize,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.code(color: color, fontWeight: fontWeight, fontSize: fontSize).copyWith(letterSpacing: letterSpacing)
          : AppFonts.code(color: color, fontWeight: fontWeight, fontSize: fontSize),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  // ============================================================================
  // 🔧 CUSTOM - Apna custom style ke saath
  // ============================================================================

  /// Custom text with any TextStyle from AppFonts
  /// Full flexibility for special cases
  static Widget custom(
    String text, {
    required TextStyle style,
    int maxLines = 2,
    double minFontSize = 8,
    double? maxFontSize,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    List<double>? presetFontSizes,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? style.copyWith(letterSpacing: letterSpacing)
          : style,
      maxLines: maxLines,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize ?? double.infinity,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
      presetFontSizes: presetFontSizes,
    );
  }

  // ============================================================================
  // 🎯 DEVICE-SPECIFIC - AUTO SIZE
  // ============================================================================

  /// Extra Large Display - Auto sizing ke saath
  /// Best for: Tablets and large screens
  static Widget extraLargeDisplay(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 18,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.extraLargeDisplay(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.extraLargeDisplay(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  /// Tiny Text - Auto sizing ke saath
  /// Best for: Dense information display
  static Widget tinyText(
    String text, {
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 5,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText(
      text,
      style: letterSpacing != null
          ? AppFonts.tinyText(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.tinyText(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }

  // ============================================================================
  // 💡 HELPER METHOD - Rich Text Support
  // ============================================================================

  /// Rich text builder with auto sizing
  /// Use when you need different styles in same text
  static Widget rich({
    required List<InlineSpan> children,
    int maxLines = 2,
    double minFontSize = 8,
    double? maxFontSize,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    TextStyle? style,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    return AutoSizeText.rich(
      TextSpan(children: children),
      style: letterSpacing != null && style != null
          ? style.copyWith(letterSpacing: letterSpacing)
          : style,
      maxLines: maxLines,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize ?? double.infinity,
      overflow: overflow,
      textAlign: textAlign,
      group: group,
    );
  }
}
