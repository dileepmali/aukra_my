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
/// - Amount display with Indian/Western formatting
// ============================================================================

class AppText {
  // ============================================================================
  // 💰 AMOUNT FORMATTING HELPERS
  // ============================================================================

  /// Format amount with Indian numbering system (1,23,456)
  static String formatIndianAmount(double value, {int decimalPlaces = 0, bool showDecimals = false}) {
    final isNegative = value < 0;
    final absValue = value.abs();

    String intPart;
    String decPart = '';

    if (showDecimals) {
      final parts = absValue.toStringAsFixed(decimalPlaces).split('.');
      intPart = parts[0];
      if (parts.length > 1) {
        decPart = '.${parts[1]}';
      }
    } else {
      intPart = absValue.toStringAsFixed(0);
    }

    // Apply Indian format (1,23,456)
    if (intPart.length > 3) {
      String result = '';
      int count = 0;

      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = ',$result';
          count = 0;
        } else if (count > 3 && (count - 3) % 2 == 0) {
          result = ',$result';
        }
        result = intPart[i] + result;
        count++;
      }
      intPart = result;
    }

    return '${isNegative ? '-' : ''}$intPart$decPart';
  }

  /// Format amount with Western numbering system (1,234,567)
  static String formatWesternAmount(double value, {int decimalPlaces = 0, bool showDecimals = false}) {
    final isNegative = value < 0;
    final absValue = value.abs();

    String intPart;
    String decPart = '';

    if (showDecimals) {
      final parts = absValue.toStringAsFixed(decimalPlaces).split('.');
      intPart = parts[0];
      if (parts.length > 1) {
        decPart = '.${parts[1]}';
      }
    } else {
      intPart = absValue.toStringAsFixed(0);
    }

    // Apply Western format (1,234,567)
    if (intPart.length > 3) {
      String result = '';
      int count = 0;

      for (int i = intPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          result = ',$result';
        }
        result = intPart[i] + result;
        count++;
      }
      intPart = result;
    }

    return '${isNegative ? '-' : ''}$intPart$decPart';
  }

  /// Build display text from amount or text
  static String _buildDisplayText({
    String? text,
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
  }) {
    if (amount != null) {
      String formattedAmount;

      if (useCompactCrore) {
        formattedAmount = formatCompactCrore(amount, decimalPlaces: decimalPlaces);
      } else if (useIndianFormat) {
        formattedAmount = formatIndianAmount(amount, decimalPlaces: decimalPlaces, showDecimals: showDecimals);
      } else {
        formattedAmount = formatWesternAmount(amount, decimalPlaces: decimalPlaces, showDecimals: showDecimals);
      }

      return '$prefix$formattedAmount$suffix';
    }
    return text ?? '';
  }

  // ============================================================================
  // 💰 COMPACT CRORE FORMAT (Only Cr - Full Precision)
  // ============================================================================

  /// Format large amounts to Crore (Cr) only - with full decimal precision
  /// Only converts to Cr when amount >= 1 Crore (1,00,00,000)
  /// Below 1 Crore, uses normal Indian format
  ///
  /// Examples:
  /// - 50000 → "50,000" (less than 1Cr, normal format)
  /// - 1500000 → "15,00,000" (less than 1Cr, normal format)
  /// - 10000000 → "1 Cr" (exactly 1 Cr)
  /// - 676534567 → "67.6534567 Cr" (full precision)
  /// - 6665885588585584640000000 → "666588558858558.464 Cr"
  static String formatCompactCrore(double amount, {int decimalPlaces = 7}) {
    final absAmount = amount.abs();
    final isNegative = amount < 0;
    final prefix = isNegative ? '-' : '';

    // 1 Crore = 1,00,00,000 = 10^7
    const oneCrore = 1e7;

    if (absAmount >= oneCrore) {
      // Convert to Crore
      final croreValue = absAmount / oneCrore;

      // Format with specified decimal places (always show decimals)
      String formatted = croreValue.toStringAsFixed(decimalPlaces);

      return '$prefix$formatted Cr';
    } else {
      // Below 1 Crore - use normal Indian format with decimals
      return formatIndianAmount(amount, decimalPlaces: decimalPlaces, showDecimals: true);
    }
  }

  /// Format amount string to Crore format
  static String formatCompactCroreFromString(String amountStr, {int decimalPlaces = 7}) {
    final cleanAmount = amountStr.replaceAll(',', '').replaceAll('₹', '').trim();
    final parsedAmount = double.tryParse(cleanAmount);
    if (parsedAmount == null) return '0';
    return formatCompactCrore(parsedAmount, decimalPlaces: decimalPlaces);
  }

  // ============================================================================
  // 📏 DISPLAY & HEADLINES - AUTO SIZE
  // ============================================================================

  /// Display Large - Auto sizing ke saath
  /// Best for: Hero text, major headings, large amounts
  ///
  /// Usage with text: AppText.displayLarge('Hello')
  /// Usage with amount: AppText.displayLarge(amount: 123456, prefix: '₹ ')
  /// Usage with Crore: AppText.displayLarge(amount: 676534567, prefix: '₹ ', useCompactCrore: true)
  static Widget displayLarge(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 16,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.displayLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Display Medium - Auto sizing ke saath
  /// Best for: Section headings, amounts
  static Widget displayMedium(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 14,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.displayMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Display Medium 1 - Auto sizing ke saath
  static Widget displayMedium1(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 14,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.displayMedium1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Display Medium 2 - Auto sizing ke saath
  static Widget displayMedium2(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 13,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.displayMedium2(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium2(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Display Medium 3 - Auto sizing ke saath
  static Widget displayMedium3(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 13,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.displayMedium3(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.displayMedium3(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Display Small - Auto sizing ke saath
  /// Best for: Sub-section headings, amounts
  static Widget displaySmall(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    final baseStyle = AppFonts.displaySmall(color: color, fontWeight: fontWeight);
    final finalStyle = baseStyle.copyWith(
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: finalStyle,
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Searchbar - Auto sizing ke saath
  /// Best for: Search fields, amounts
  static Widget searchbar(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.searchbar(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.searchbar(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Searchbar 1 - Auto sizing ke saath
  static Widget searchbar1(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 11,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    final baseStyle = AppFonts.searchbar1(color: color, fontWeight: fontWeight);
    final finalStyle = baseStyle.copyWith(
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: finalStyle,
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  static Widget searchbar4(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 11.5,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    final baseStyle = AppFonts.searchbar1(color: color, fontWeight: fontWeight);
    final finalStyle = baseStyle.copyWith(
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: finalStyle,
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Searchbar 2 - Auto sizing ke saath (Extra Light)
  static Widget searchbar2(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
        bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    final baseStyle = AppFonts.searchbar2(color: color, fontWeight: fontWeight);
    final finalStyle = baseStyle.copyWith(
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: finalStyle,
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  // ============================================================================
  // 📰 HEADLINES - AUTO SIZE
  // ============================================================================

  /// Headline Large - Auto sizing ke saath
  /// Best for: Page titles, amounts
  static Widget headlineLarge(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 11,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.headlineLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Headline Large 1 - Auto sizing ke saath
  static Widget headlineLarge1(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 10,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    final baseStyle = AppFonts.headlineLarge1(color: color, fontWeight: fontWeight);
    final finalStyle = baseStyle.copyWith(
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: finalStyle,
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Headline Medium - Auto sizing ke saath
  /// Best for: Card titles, amounts
  static Widget headlineMedium(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 10,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.headlineMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Headline Small - Auto sizing ke saath
  /// Best for: Small headings, amounts
  static Widget headlineSmall(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 9,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.headlineSmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineSmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Headline Small 1 - Auto sizing ke saath
  static Widget headlineSmall1(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 9,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.headlineSmall1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.headlineSmall1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  // ============================================================================
  // 📝 BODY TEXT - AUTO SIZE
  // ============================================================================

  /// Body Large - Auto sizing ke saath
  /// Best for: Important body text, amounts
  static Widget bodyLarge(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 9,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.bodyLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodyLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Body Large 1 - Auto sizing ke saath
  static Widget bodyLarge1(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.bodyLarge1(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodyLarge1(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Body Medium - Auto sizing ke saath
  /// Best for: Regular body text, amounts
  static Widget bodyMedium(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.bodyMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodyMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Body Small - Auto sizing ke saath
  /// Best for: Supporting text, amounts
  static Widget bodySmall(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 3,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.bodySmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.bodySmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  // ============================================================================
  // 🏷️ LABELS & CAPTIONS - AUTO SIZE
  // ============================================================================

  /// Label Large - Auto sizing ke saath
  /// Best for: Form labels, button text, amounts
  static Widget labelLarge(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.labelLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.labelLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Label Medium - Auto sizing ke saath
  /// Best for: Smaller labels, amounts
  static Widget labelMedium(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.labelMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.labelMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Label Small - Auto sizing ke saath
  /// Best for: Tiny labels and hints, amounts
  static Widget labelSmall(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 6,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.labelSmall(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.labelSmall(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Caption - Auto sizing ke saath
  /// Best for: Metadata, timestamps, amounts
  static Widget caption(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.caption(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.caption(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Overline - Auto sizing ke saath
  /// Best for: Categories, tags, amounts
  static Widget overline(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 6,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.overline(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.overline(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  // ============================================================================
  // 🎨 SPECIALIZED - AUTO SIZE
  // ============================================================================

  /// Button Text - Auto sizing ke saath
  /// Best for: Button labels (especially localized), amounts
  static Widget button(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
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
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // For buttons, default to center, but right for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : TextAlign.center);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.button(color: color, fontWeight: fontWeight, fontSize: fontSize).copyWith(letterSpacing: letterSpacing)
          : AppFonts.button(color: color, fontWeight: fontWeight, fontSize: fontSize),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Dialog Button Text - Auto sizing ke saath
  /// Best for: Dialog buttons, amounts
  static Widget dialogButton(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
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
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // For dialog buttons, default to center, but right for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : TextAlign.center);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.dialogButton(color: color, fontWeight: fontWeight, fontSize: fontSize).copyWith(letterSpacing: letterSpacing)
          : AppFonts.dialogButton(color: color, fontWeight: fontWeight, fontSize: fontSize),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// App Bar Title Large - Auto sizing ke saath
  /// Best for: Large app bar titles, amounts
  static Widget appBarTitleLarge(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 13,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.appBarTitleLarge(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.appBarTitleLarge(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// App Bar Title - Auto sizing ke saath
  /// Best for: Standard app bar titles, amounts
  static Widget appBarTitle(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.appBarTitle(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.appBarTitle(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// App Bar Title Medium - Auto sizing ke saath
  static Widget appBarTitleMedium(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 12,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.appBarTitleMedium(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.appBarTitleMedium(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Tab Bar - Auto sizing ke saath
  /// Best for: Tab labels, amounts
  static Widget tabBar(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 8,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.tabBar(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.tabBar(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Navigation - Auto sizing ke saath
  /// Best for: Bottom nav, drawer items, amounts
  static Widget navigation(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 1,
    double minFontSize = 7,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.navigation(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.navigation(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Code/Monospace - Auto sizing ke saath
  /// Best for: Code snippets, data display, amounts
  static Widget code(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
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
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.code(color: color, fontWeight: fontWeight, fontSize: fontSize).copyWith(letterSpacing: letterSpacing)
          : AppFonts.code(color: color, fontWeight: fontWeight, fontSize: fontSize),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  // ============================================================================
  // 🎯 DEVICE-SPECIFIC - AUTO SIZE
  // ============================================================================

  /// Extra Large Display - Auto sizing ke saath
  /// Best for: Tablets and large screens, large amounts
  static Widget extraLargeDisplay(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 18,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.extraLargeDisplay(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.extraLargeDisplay(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  /// Tiny Text - Auto sizing ke saath
  /// Best for: Dense information display, small amounts
  static Widget tinyText(
    String? text, {
    double? amount,
    String prefix = '',
    String suffix = '',
    bool useIndianFormat = true,
    int decimalPlaces = 0,
    bool showDecimals = false,
    bool useCompactCrore = true,
    Color? color,
    FontWeight? fontWeight,
    int maxLines = 2,
    double minFontSize = 5,
    TextAlign? textAlign,
    TextOverflow overflow = TextOverflow.ellipsis,
    AutoSizeGroup? group,
    double? letterSpacing,
  }) {
    final displayText = _buildDisplayText(
      text: text,
      amount: amount,
      prefix: prefix,
      suffix: suffix,
      useIndianFormat: useIndianFormat,
      decimalPlaces: decimalPlaces,
      showDecimals: showDecimals,
      useCompactCrore: useCompactCrore,
    );
    // Default to right alignment for amounts
    final effectiveAlign = textAlign ?? (amount != null ? TextAlign.right : null);
    return AutoSizeText(
      displayText,
      style: letterSpacing != null
          ? AppFonts.tinyText(color: color, fontWeight: fontWeight).copyWith(letterSpacing: letterSpacing)
          : AppFonts.tinyText(color: color, fontWeight: fontWeight),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: overflow,
      textAlign: effectiveAlign,
      group: group,
    );
  }

  // ============================================================================
  // 💡 HELPER METHOD - Rich Text Support
  // ============================================================================

  // ============================================================================
  // 💰 AMOUNT ROW - Small ₹ symbol (bottom-aligned) + Amount text
  // ============================================================================

  /// Displays amount with a smaller ₹ symbol aligned to bottom
  /// The ₹ symbol uses a smaller text style than the amount number
  ///
  /// Usage:
  /// ```dart
  /// AppText.amountRow(
  ///   amount: 214351009.65,
  ///   color: AppColors.red500,
  /// )
  /// ```
  ///
  /// With custom styles:
  /// ```dart
  /// AppText.amountRow(
  ///   amount: 50000,
  ///   color: AppColors.primeryamount,
  ///   symbolSize: AmountSymbolSize.headlineLarge1,
  ///   amountSize: AmountTextSize.searchbar2,
  /// )
  /// ```
  static Widget amountRow({
    required double amount,
    required Color color,
    FontWeight symbolFontWeight = FontWeight.w500,
    FontWeight amountFontWeight = FontWeight.w600,
    int decimalPlaces = 2,
    double minFontSize = 9,
    double symbolBottomPadding = 0.1,
    double spacing = 2.0,
    AmountSymbolSize symbolSize = AmountSymbolSize.headlineLarge1,
    AmountTextSize amountSize = AmountTextSize.searchbar2,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: symbolBottomPadding),
          child: _buildAmountSymbol(symbolSize, color, symbolFontWeight),
        ),
        SizedBox(width: spacing),
        _buildAmountValue(amountSize, amount, decimalPlaces, color, amountFontWeight, minFontSize),
      ],
    );
  }

  /// Build ₹ symbol widget based on size
  static Widget _buildAmountSymbol(AmountSymbolSize size, Color color, FontWeight fontWeight) {
    switch (size) {
      case AmountSymbolSize.headlineLarge:
        return headlineLarge('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.headlineLarge1:
        return headlineLarge1('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.searchbar1:
        return searchbar1('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.searchbar2:
        return searchbar2('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.headlineSmall:
        return headlineSmall('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.bodyLarge:
        return bodyLarge('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.headlineMedium:
        return headlineMedium('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.bodyMedium:
        return bodyMedium('₹', color: color, fontWeight: fontWeight);
      case AmountSymbolSize.displayMedium:
        return displayMedium('₹', color: color, fontWeight: fontWeight);
    }
  }

  /// Build amount value widget based on size
  static Widget _buildAmountValue(AmountTextSize size, double amount, int decimalPlaces, Color color, FontWeight fontWeight, double minFontSize) {
    switch (size) {
      case AmountTextSize.searchbar1:
        return searchbar1(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.searchbar2:
        return searchbar2(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.headlineLarge:
        return headlineLarge(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.headlineLarge1:
        return headlineLarge1(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.headlineSmall:
        return headlineSmall(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.headlineMedium:
        return headlineMedium(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.bodyLarge:
        return bodyLarge(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.bodyMedium:
        return bodyMedium(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.displaySmall:
        return displaySmall(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
      case AmountTextSize.displayMedium:
        return displayMedium(null, amount: amount, decimalPlaces: decimalPlaces, color: color, fontWeight: fontWeight, minFontSize: minFontSize);
    }
  }

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

/// ₹ symbol size options for AppText.amountRow
enum AmountSymbolSize {
  headlineLarge,
  headlineLarge1,
  headlineMedium,
  headlineSmall,
  searchbar1,
  searchbar2,
  bodyLarge,
  bodyMedium,
  displayMedium,
}

/// Amount number size options for AppText.amountRow
enum AmountTextSize {
  searchbar1,
  searchbar2,
  headlineLarge,
  headlineLarge1,
  headlineMedium,
  headlineSmall,
  bodyLarge,
  bodyMedium,
  displaySmall,
  displayMedium,
}
