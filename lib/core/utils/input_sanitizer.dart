/// Input sanitization utility to prevent XSS, SQL injection, and invalid data
///
/// Provides methods to clean and validate user inputs before processing or display
class InputSanitizer {
  /// Sanitize HTML/Script tags to prevent XSS attacks
  ///
  /// Converts dangerous characters to HTML entities
  ///
  /// Example:
  /// ```dart
  /// final safe = InputSanitizer.sanitizeHtml('<script>alert("xss")</script>');
  /// // Result: '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;'
  /// ```
  static String sanitizeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Remove all HTML tags from input
  ///
  /// Useful when you want to display user content as plain text
  static String stripHtml(String input) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return input.replaceAll(regex, '');
  }

  /// Sanitize SQL injection attempts
  ///
  /// Removes common SQL injection patterns
  /// Note: Use parameterized queries as primary defense
  static String sanitizeSql(String input) {
    return input
        .replaceAll("'", "''") // Escape single quotes
        .replaceAll(';', '') // Remove statement terminators
        .replaceAll('--', '') // Remove SQL comments
        .replaceAll('/*', '') // Remove multi-line comments
        .replaceAll('*/', '')
        .replaceAll('xp_', '') // Remove extended procedures
        .replaceAll('sp_', '') // Remove stored procedures
        .replaceAll('exec ', '') // Remove exec commands
        .replaceAll('execute ', '')
        .replaceAll('drop ', '') // Remove dangerous keywords
        .replaceAll('delete ', '')
        .replaceAll('truncate ', '');
  }

  /// Sanitize user input for safe display
  ///
  /// Removes control characters, excessive whitespace, and limits length
  static String sanitizeForDisplay(String input, {int maxLength = 500}) {
    // Remove control characters (ASCII 0-31 and 127)
    var cleaned = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Trim whitespace
    cleaned = cleaned.trim();

    // Limit length
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }

    return cleaned;
  }

  /// Validate and sanitize amount input
  ///
  /// Keeps only digits and decimal point, enforces 2 decimal places
  static String sanitizeAmount(String input) {
    // Keep only digits and decimal point
    var cleaned = input.replaceAll(RegExp(r'[^\d.]'), '');

    // Ensure only one decimal point
    final parts = cleaned.split('.');
    if (parts.length > 2) {
      cleaned = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit decimal places to 2
    if (parts.length == 2) {
      final decimalPart = parts[1];
      if (decimalPart.length > 2) {
        cleaned = '${parts[0]}.${decimalPart.substring(0, 2)}';
      }
    }

    // Remove leading zeros except before decimal
    if (cleaned.startsWith('0') && !cleaned.startsWith('0.') && cleaned.length > 1) {
      cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');
      if (cleaned.isEmpty) {
        cleaned = '0';
      }
    }

    return cleaned;
  }

  /// Sanitize phone number input
  ///
  /// Keeps only digits, enforces 10-digit format for Indian numbers
  static String sanitizePhoneNumber(String input, {int expectedLength = 10}) {
    // Keep only digits
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to expected length
    if (cleaned.length > expectedLength) {
      return cleaned.substring(0, expectedLength);
    }

    return cleaned;
  }

  /// Sanitize PIN code input (Indian 6-digit PIN)
  ///
  /// Keeps only digits, enforces 6-digit format
  static String sanitizePinCode(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 6 digits
    if (cleaned.length > 6) {
      return cleaned.substring(0, 6);
    }

    return cleaned;
  }

  /// Sanitize name input
  ///
  /// Removes special characters, keeps only letters, spaces, and common punctuation
  static String sanitizeName(String input, {int maxLength = 100}) {
    // Allow letters (including Unicode for Indian names), spaces, hyphens, apostrophes, and dots
    var cleaned = input.replaceAll(RegExp(r"[^a-zA-Z\u0900-\u097F\s\-'.]+"), '');

    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Trim
    cleaned = cleaned.trim();

    // Limit length
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }

    return cleaned;
  }

  /// Sanitize address input
  ///
  /// Removes dangerous characters but keeps most printable characters
  static String sanitizeAddress(String input, {int maxLength = 500}) {
    // Remove control characters and HTML tags
    var cleaned = stripHtml(input);
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Remove excessive whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Trim
    cleaned = cleaned.trim();

    // Limit length
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }

    return cleaned;
  }

  /// Sanitize email input
  ///
  /// Converts to lowercase and removes invalid characters
  static String sanitizeEmail(String input) {
    // Convert to lowercase
    var cleaned = input.toLowerCase();

    // Remove whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s'), '');

    // Keep only valid email characters
    cleaned = cleaned.replaceAll(RegExp(r'[^a-z0-9@.\-_+]'), '');

    return cleaned;
  }

  /// Validate email format
  ///
  /// Returns true if email format is valid
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Sanitize numeric input (integers only)
  ///
  /// Keeps only digits
  static String sanitizeNumeric(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Sanitize URL input
  ///
  /// Validates and cleans URL format
  static String sanitizeUrl(String input) {
    var cleaned = input.trim();

    // Remove dangerous protocols
    cleaned = cleaned.replaceAll(RegExp(r'^(javascript|data|vbscript):', caseSensitive: false), '');

    // Ensure http/https protocol
    if (!cleaned.startsWith('http://') && !cleaned.startsWith('https://')) {
      cleaned = 'https://$cleaned';
    }

    return cleaned;
  }

  /// Check if string contains potentially dangerous content
  ///
  /// Returns true if input contains XSS or SQL injection patterns
  static bool isDangerous(String input) {
    final dangerousPatterns = [
      RegExp(r'<script', caseSensitive: false),
      RegExp(r'javascript:', caseSensitive: false),
      RegExp(r'onerror=', caseSensitive: false),
      RegExp(r'onclick=', caseSensitive: false),
      RegExp(r'onload=', caseSensitive: false),
      RegExp(r'(\bor\b|\band\b)\s+\d+\s*=\s*\d+', caseSensitive: false), // SQL: 1=1
      RegExp(r'union\s+select', caseSensitive: false),
      RegExp(r'drop\s+table', caseSensitive: false),
      RegExp(r'<iframe', caseSensitive: false),
      RegExp(r'<embed', caseSensitive: false),
      RegExp(r'<object', caseSensitive: false),
    ];

    for (final pattern in dangerousPatterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }

    return false;
  }

  /// Sanitize comments/notes input
  ///
  /// Allows most characters but prevents injection attacks
  static String sanitizeComments(String input, {int maxLength = 1000}) {
    // Remove HTML tags
    var cleaned = stripHtml(input);

    // Remove control characters
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Trim
    cleaned = cleaned.trim();

    // Limit length
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }

    return cleaned;
  }

  /// Batch sanitize a map of inputs
  ///
  /// Useful for sanitizing form data
  static Map<String, String> sanitizeMap(Map<String, String> inputs) {
    final sanitized = <String, String>{};

    inputs.forEach((key, value) {
      sanitized[key] = sanitizeForDisplay(value);
    });

    return sanitized;
  }
}
