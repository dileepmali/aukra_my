import 'package:intl/intl.dart';

/// Utility class for formatting phone numbers, amounts, dates, and times
class Formatters {
  /// Extracts last 10 digits from phone number (removes country code)
  ///
  /// Examples:
  /// - "+91-9876543210" → "9876543210"
  /// - "919876543210" → "9876543210"
  /// - "9876543210" → "9876543210"
  /// - "123456789" → "123456789" (less than 10 digits, returns as is)
  static String extractPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // If more than 10 digits, take last 10 (remove country code)
    if (digitsOnly.length > 10) {
      return digitsOnly.substring(digitsOnly.length - 10);
    }

    // Otherwise return as is
    return digitsOnly;
  }

  /// Formats amount to decimal format with 2 decimal places
  ///
  /// Examples:
  /// - "1000" → "1000.00"
  /// - "1000.5" → "1000.50"
  /// - "1000.123" → "1000.12" (rounds to 2 decimals)
  /// - "abc" → "0.00" (invalid input)
  /// - "" → "0.00" (empty input)
  static String formatAmountToDecimal(String amount) {
    // Remove commas and extra spaces
    final cleanAmount = amount.replaceAll(',', '').trim();

    // Try to parse the amount
    final parsedAmount = double.tryParse(cleanAmount);

    // If parsing fails, return 0.00
    if (parsedAmount == null) {
      return '0.00';
    }

    // Format to 2 decimal places
    return parsedAmount.toStringAsFixed(2);
  }

  /// Formats amount with commas for better readability
  ///
  /// Examples:
  /// - "1000" → "1,000.00"
  /// - "100000" → "1,00,000.00" (Indian format)
  /// - "1000000" → "10,00,000.00"
  static String formatAmountWithCommas(String amount) {
    final decimalAmount = formatAmountToDecimal(amount);
    final parts = decimalAmount.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';

    // Indian number format (lakhs, crores)
    String formattedInteger = '';
    int count = 0;

    // Reverse the string for easier processing
    for (int i = integerPart.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        formattedInteger = ',$formattedInteger';
      }
      formattedInteger = integerPart[i] + formattedInteger;
      count++;
    }

    return '$formattedInteger.$decimalPart';
  }

  /// Converts amount from decimal format back to plain number
  ///
  /// Examples:
  /// - "1,000.00" → "1000"
  /// - "10,00,000.50" → "1000000.50"
  static String removeFormatting(String formattedAmount) {
    return formattedAmount.replaceAll(',', '');
  }

  /// Masks phone number showing only last 4 digits
  ///
  /// Examples:
  /// - "+919876543210" → "+91 ******3210"
  /// - "+1234567890" → "+1 ******7890"
  /// - "9876543210" → "******3210"
  static String formatMaskedPhone(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    // Remove any existing spaces
    String cleanNumber = phoneNumber.replaceAll(' ', '');

    // Check if it starts with + (country code)
    if (cleanNumber.startsWith('+')) {
      // Remove the + sign temporarily
      String withoutPlus = cleanNumber.substring(1);

      // Detect country code length
      int countryCodeLength = 2; // Default to 2 (for +91, +44, etc.)

      if (withoutPlus.startsWith('1') && withoutPlus.length == 11) {
        countryCodeLength = 1;
      } else if (withoutPlus.startsWith('91') && withoutPlus.length == 12) {
        countryCodeLength = 2;
      } else if (withoutPlus.startsWith('44') && withoutPlus.length >= 12) {
        countryCodeLength = 2;
      }

      // Extract parts
      if (withoutPlus.length > countryCodeLength + 4) {
        String countryCode = '+' + withoutPlus.substring(0, countryCodeLength);
        String number = withoutPlus.substring(countryCodeLength);

        // Mask all except last 4 digits
        String last4 = number.substring(number.length - 4);
        String masked = '*' * (number.length - 4);

        return '$countryCode $masked$last4';
      }
    } else {
      // No country code - mask all except last 4 digits
      if (cleanNumber.length > 4) {
        String last4 = cleanNumber.substring(cleanNumber.length - 4);
        String masked = '*' * (cleanNumber.length - 4);
        return '$masked$last4';
      }
    }

    return cleanNumber;
  }

  /// Formats phone number with country code and space separator (for UI display)
  ///
  /// Examples:
  /// - "9876543210" → "+91 9876543210" (adds +91 prefix for 10 digit numbers)
  /// - "+919876543210" → "+91 9876543210"
  /// - "919876543210" → "+91 9876543210"
  static String formatPhoneWithCountryCode(String phoneNumber) {
    if (phoneNumber.isEmpty) return phoneNumber;

    // Remove any existing spaces, +, and -
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\+\-]'), '');

    // If it's exactly 10 digits, add +91 prefix (India)
    if (cleanNumber.length == 10) {
      return '+91 $cleanNumber';
    }

    // If it starts with 91 and has 12 digits (91 + 10 digit number)
    if (cleanNumber.startsWith('91') && cleanNumber.length == 12) {
      String number = cleanNumber.substring(2);
      return '+91 $number';
    }

    // For other cases with more than 10 digits, extract last 10 as number
    if (cleanNumber.length > 10) {
      String countryCode = cleanNumber.substring(0, cleanNumber.length - 10);
      String number = cleanNumber.substring(cleanNumber.length - 10);
      return '+$countryCode $number';
    }

    return cleanNumber;
  }

  /// Validates if phone number is valid (10 digits)
  static bool isValidPhoneNumber(String phoneNumber) {
    final digitsOnly = extractPhoneNumber(phoneNumber);
    return digitsOnly.length == 10;
  }

  /// Validates if amount is valid
  static bool isValidAmount(String amount) {
    final cleanAmount = amount.replaceAll(',', '').trim();
    final parsedAmount = double.tryParse(cleanAmount);
    return parsedAmount != null && parsedAmount >= 0;
  }

  // ==================== DATE & TIME FORMATTING ====================

  /// Formats DateTime to time string (HH:mm) - 24-hour format
  ///
  /// Examples:
  /// - DateTime(2026, 1, 4, 14, 30) → "14:30"
  /// - DateTime(2026, 1, 4, 9, 15) → "09:15"
  /// - DateTime(2026, 1, 4, 13, 0) → "13:00"
  static String formatTime(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final timeFormat = DateFormat('HH:mm');
    return timeFormat.format(localTime);
  }

  /// Formats DateTime to date string (d MMM yyyy)
  ///
  /// Examples:
  /// - DateTime(2026, 1, 4) → "4 Jan 2026"
  /// - DateTime(2025, 12, 25) → "25 Dec 2025"
  static String formatDate(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final dateFormat = DateFormat('d MMM yyyy');
    return dateFormat.format(localTime);
  }

  /// Formats DateTime to combined date and time string (d MMM yyyy, HH:mm)
  ///
  /// Examples:
  /// - DateTime(2026, 1, 4, 14, 30) → "4 Jan 2026, 14:30"
  /// - DateTime(2025, 12, 25, 9, 15) → "25 Dec 2025, 09:15"
  /// - null → "No date available"
  static String formatTimeAndDate(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date available';
    }

    final localTime = dateTime.toLocal();
    final formattedDate = formatDate(localTime);
    final formattedTime = formatTime(localTime);
    return '$formattedDate, $formattedTime';
  }

  /// Formats DateTime to date and time string (d MMM yyyy, HH:mm)
  ///
  /// Examples:
  /// - DateTime(2026, 1, 4, 14, 30) → "4 Jan 2026, 14:30"
  /// - DateTime(2025, 12, 25, 9, 15) → "25 Dec 2025, 09:15"
  /// - null → "No date available"
  static String formatDateAndTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date available';
    }

    final localTime = dateTime.toLocal();
    final formattedDate = formatDate(localTime);
    final formattedTime = formatTime(localTime);
    return '$formattedDate, $formattedTime';
  }

  /// Formats string to DateTime and then to date and time
  ///
  /// Examples:
  /// - "2026-01-04T14:30:00.000Z" → "4 Jan 2026, 14:30"
  /// - "invalid" → "No date available"
  /// - null → "No date available"
  static String formatStringToTimeAndDate(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'No date available';
    }

    final dateTime = DateTime.tryParse(dateTimeString);
    return formatTimeAndDate(dateTime);
  }

  /// Formats string to DateTime and then to date and time
  ///
  /// Examples:
  /// - "2026-01-04T14:30:00.000Z" → "4 Jan 2026, 14:30"
  /// - "invalid" → "No date available"
  /// - null → "No date available"
  static String formatStringToDateAndTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return 'No date available';
    }

    final dateTime = DateTime.tryParse(dateTimeString);
    return formatDateAndTime(dateTime);
  }

  /// Formats DateTime to short date format (d MMM)
  ///
  /// Examples:
  /// - DateTime(2026, 1, 4) → "4 Jan"
  /// - DateTime(2025, 12, 25) → "25 Dec"
  static String formatShortDate(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    final dateFormat = DateFormat('d MMM');
    return dateFormat.format(localTime);
  }

  /// Formats DateTime to full format (d MMM yyyy 'at' HH:mm)
  ///
  /// Examples:
  /// - DateTime(2026, 1, 4, 14, 30) → "4 Jan 2026 at 14:30"
  /// - DateTime(2025, 12, 25, 9, 15) → "25 Dec 2025 at 09:15"
  static String formatFullDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'No date available';
    }

    final localTime = dateTime.toLocal();
    final dateFormat = DateFormat('d MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    return '${dateFormat.format(localTime)} at ${timeFormat.format(localTime)}';
  }
}
