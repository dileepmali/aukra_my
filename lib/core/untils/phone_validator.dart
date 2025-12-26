import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../../app/localizations/l10n/app_strings.dart';

class PhoneValidator {
  static PhoneValidator? _instance;
  
  PhoneValidator._internal();
  
  static PhoneValidator get instance {
    _instance ??= PhoneValidator._internal();
    return _instance!;
  }

  /// Validates phone number for India only with localization
  /// Returns error message if invalid, null if valid
  ///
  /// Parameters:
  /// - [showFormatError]: If false, won't return format errors (only pattern errors)
  ///   Use false for TextField errorText (only show pattern errors)
  ///   Use true for button click validation (show all errors)
  String? validatePhoneNumberLocalized(
    String phoneNumber,
    String countryCode,
    BuildContext context, {
    bool showFormatError = true,
  }) {
    if (phoneNumber.isEmpty) {
      return null; // Don't show error for empty field
    }

    // Only validate Indian numbers
    if (countryCode != '+91') {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationOnlyIndian);
    }

    // Step 1: Check for fake/invalid patterns (ALWAYS show these)
    String? fakePatternError = _checkFakePatternsLocalized(phoneNumber, context);
    if (fakePatternError != null) {
      return fakePatternError;
    }

    // Step 2: Indian number validation
    // Indian mobile must start with 6,7,8,9 and be 10 digits
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber)) {
      // ✅ Only return format error if showFormatError is true
      if (showFormatError) {
        return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationIndianFormat);
      }
      return null; // Don't show format error in TextField
    }

    // Check for invalid Indian patterns
    List<String> invalidPrefixes = [
      '0000', '1111', '2222', '3333', '4444', '5555',
      '1234', '4321', '0123', '9876', '1010', '0101'
    ];

    String firstFour = phoneNumber.substring(0, 4);
    if (invalidPrefixes.contains(firstFour)) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidPattern);
    }

    // Check if it's a known invalid series
    if (phoneNumber.startsWith('11111') ||
        phoneNumber.startsWith('22222') ||
        phoneNumber.startsWith('33333') ||
        phoneNumber.startsWith('44444') ||
        phoneNumber.startsWith('55555')) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    return null; // Valid number
  }

  /// Validates phone number for India only (non-localized version for backward compatibility)
  /// Returns error message if invalid, null if valid
  String? validatePhoneNumber(String phoneNumber, String countryCode) {
    if (phoneNumber.isEmpty) {
      return null; // Don't show error for empty field
    }
    
    // Only validate Indian numbers
    if (countryCode != '+91') {
      return 'Only Indian numbers are supported';
    }
    
    // Step 1: Check for fake/invalid patterns
    String? fakePatternError = _checkFakePatterns(phoneNumber);
    if (fakePatternError != null) {
      return fakePatternError;
    }
    
    // Step 2: Indian number validation
    // Indian mobile must start with 6,7,8,9 and be 10 digits
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(phoneNumber)) {
      return 'Indian mobile numbers start with 6, 7, 8, or 9 and be 10 digits';
    }
    
    // Check for invalid Indian patterns
    List<String> invalidPrefixes = [
      '0000', '1111', '2222', '3333', '4444', '5555',
      '1234', '4321', '0123', '9876', '1010', '0101'
    ];
    
    String firstFour = phoneNumber.substring(0, 4);
    if (invalidPrefixes.contains(firstFour)) {
      return 'Invalid Indian mobile number pattern';
    }
    
    // Check if it's a known invalid series
    if (phoneNumber.startsWith('11111') || 
        phoneNumber.startsWith('22222') ||
        phoneNumber.startsWith('33333') ||
        phoneNumber.startsWith('44444') ||
        phoneNumber.startsWith('55555')) {
      return 'Invalid Indian mobile number';
    }
    
    return null; // Valid number
  }

  /// Get example phone number for India
  String getExampleNumber(String countryCode) {
    if (countryCode == '+91') {
      return 'Number';
    }
    return 'Number';
  }

  /// Get maximum allowed length for input field
  int getMaxLength(String countryCode) {
    if (countryCode == '+91') {
      return 10; // Indian numbers are 10 digits
    }
    return 15; // Default fallback
  }

  /// Check if country is supported (only India)
  bool isCountrySupported(String countryCode) {
    return countryCode == '+91';
  }

  /// Format phone number for display
  String formatPhoneNumber(String phoneNumber, String countryCode) {
    if (countryCode == '+91' && phoneNumber.length == 10) {
      // Format as +91 98765 43210
      return '$countryCode ${phoneNumber.substring(0, 5)} ${phoneNumber.substring(5)}';
    }
    return '$countryCode $phoneNumber';
  }

  /// Check for obviously fake patterns (localized version)
  /// ✅ UPDATED: Show generic "Invalid number" for all pattern errors
  String? _checkFakePatternsLocalized(String phoneNumber, BuildContext context) {
    // Check 1: All digits same (1111111111)
    if (_hasAllSameDigits(phoneNumber)) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    // Check 2: Sequential patterns (1234567890, 0123456789)
    if (_isSequential(phoneNumber)) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    // Check 3: Repeating patterns (1212121212, 123123123)
    if (_hasRepeatingPattern(phoneNumber)) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    // Check 4: 5 or more consecutive same digits (9016666666, 8888812345)
    if (_hasConsecutiveSameDigits(phoneNumber, 5)) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    // Check 5: Minimum unique digits (real numbers have at least 4 different digits)
    // Examples: 11122223 (only 3 unique digits: 1,2,3)
    Set<String> uniqueDigits = phoneNumber.split('').toSet();
    if (uniqueDigits.length < 4) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    // Check 5: Known test/fake numbers
    List<String> testNumbers = [
      '1234567890', '0123456789', '9876543210', '0987654321',
      '1111111111', '2222222222', '3333333333', '4444444444',
      '5555555555', '6666666666', '7777777777', '8888888888',
      '9999999999', '0000000000', '1234512345', '1122334455',
      '1010101010', '0101010101', '1212121212', '2121212121',
      '1231231231', '3213213213', '1001001001', '9009009009'
    ];

    if (testNumbers.contains(phoneNumber)) {
      return AppStrings.getLocalizedString(context, (localizations) => localizations.phoneValidationInvalidNumber);
    }

    return null;
  }

  /// Check for obviously fake patterns (non-localized version)
  String? _checkFakePatterns(String phoneNumber) {
    // Check 1: All digits same (1111111111)
    if (_hasAllSameDigits(phoneNumber)) {
      return 'Invalid number - all digits cannot be same';
    }
    
    // Check 2: Sequential patterns (1234567890, 0123456789)
    if (_isSequential(phoneNumber)) {
      return 'Invalid number - sequential pattern detected';
    }
    
    // Check 3: Repeating patterns (1212121212, 123123123)
    if (_hasRepeatingPattern(phoneNumber)) {
      return 'Invalid number - repeating pattern detected';
    }
    
    // Check 4: Minimum unique digits (real numbers have at least 4 different digits)
    Set<String> uniqueDigits = phoneNumber.split('').toSet();
    if (uniqueDigits.length < 4) {
      return 'Invalid number - too few unique digits';
    }
    
    // Check 5: Known test/fake numbers
    List<String> testNumbers = [
      '1234567890', '0123456789', '9876543210', '0987654321',
      '1111111111', '2222222222', '3333333333', '4444444444',
      '5555555555', '6666666666', '7777777777', '8888888888',
      '9999999999', '0000000000', '1234512345', '1122334455',
      '1010101010', '0101010101', '1212121212', '2121212121',
      '1231231231', '3213213213', '1001001001', '9009009009'
    ];
    
    if (testNumbers.contains(phoneNumber)) {
      return 'This is a test number - not allowed';
    }
    
    return null;
  }
  
  /// Check if all digits are same
  bool _hasAllSameDigits(String number) {
    if (number.isEmpty) return false;
    String firstDigit = number[0];
    return number.split('').every((digit) => digit == firstDigit);
  }
  
  /// Check if digits are sequential
  bool _isSequential(String number) {
    if (number.length < 4) return false;
    
    bool isAscending = true;
    bool isDescending = true;
    
    for (int i = 1; i < number.length; i++) {
      int current = int.parse(number[i]);
      int previous = int.parse(number[i - 1]);
      
      // Check ascending (with wrap around: 9->0)
      if (!((current == previous + 1) || (previous == 9 && current == 0))) {
        isAscending = false;
      }
      
      // Check descending (with wrap around: 0->9)
      if (!((current == previous - 1) || (previous == 0 && current == 9))) {
        isDescending = false;
      }
      
      if (!isAscending && !isDescending) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Check for repeating patterns
  bool _hasRepeatingPattern(String number) {
    if (number.length < 4) return false;
    
    // Check 2-digit pattern (12121212)
    if (number.length >= 6 && number.length % 2 == 0) {
      String pattern = number.substring(0, 2);
      bool isRepeating = true;
      for (int i = 2; i < number.length; i += 2) {
        if (number.substring(i, i + 2) != pattern) {
          isRepeating = false;
          break;
        }
      }
      if (isRepeating) return true;
    }
    
    // Check 3-digit pattern (123123123)
    if (number.length >= 9 && number.length % 3 == 0) {
      String pattern = number.substring(0, 3);
      bool isRepeating = true;
      for (int i = 3; i < number.length; i += 3) {
        if (number.substring(i, i + 3) != pattern) {
          isRepeating = false;
          break;
        }
      }
      if (isRepeating) return true;
    }
    
    // Check 4-digit pattern (12341234)
    if (number.length >= 8 && number.length % 4 == 0) {
      String pattern = number.substring(0, 4);
      bool isRepeating = true;
      for (int i = 4; i < number.length; i += 4) {
        if (number.substring(i, Math.min(i + 4, number.length)) != pattern) {
          isRepeating = false;
          break;
        }
      }
      if (isRepeating) return true;
    }
    
    return false;
  }

  /// Check if number has N or more consecutive same digits
  /// Example: _hasConsecutiveSameDigits("9016666666", 5) returns true
  bool _hasConsecutiveSameDigits(String number, int count) {
    if (number.length < count) return false;

    for (int i = 0; i <= number.length - count; i++) {
      String digit = number[i];
      bool allSame = true;

      for (int j = i; j < i + count; j++) {
        if (number[j] != digit) {
          allSame = false;
          break;
        }
      }

      if (allSame) return true;
    }

    return false;
  }
}