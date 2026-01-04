import 'package:flutter/services.dart';

/// Phone number formatter - no formatting, just limit to 10 digits
/// Format: XXXXXXXXXX (10 digits without space)
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Remove all non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    // Limit to 10 digits
    if (digitsOnly.length > 10) {
      return oldValue;
    }

    return TextEditingValue(
      text: digitsOnly,
      selection: TextSelection.collapsed(offset: digitsOnly.length),
    );
  }
}

/// Formats phone number string to display format with country code
/// Format: +91 XXXXXXXXXX (no space in number)
String formatPhoneNumber(String phoneNumber) {
  // Remove all non-digit characters
  final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

  // If number starts with 91, remove it
  String number = digitsOnly;
  if (number.startsWith('91') && number.length > 10) {
    number = number.substring(2);
  }

  // Take only first 10 digits
  if (number.length > 10) {
    number = number.substring(0, 10);
  }

  // Return with +91 prefix
  if (number.length > 0) {
    return '+91 $number';
  }

  return '+91 ';
}
