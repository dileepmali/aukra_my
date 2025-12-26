class StringUtils {
  /// Capitalize the first letter of a string
  /// Example: "hello world" -> "Hello world"
  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Capitalize the first letter of each word
  /// Example: "hello world" -> "Hello World"
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) => capitalizeFirstLetter(word)).join(' ');
  }

  /// Capitalize the first letter of each sentence
  /// Example: "my name is dileep. what is your father name?" -> "My name is dileep. What is your father name?"
  static String capitalizeSentences(String text) {
    if (text.isEmpty) return text;

    // Split by sentence endings: . ! ? and capitalize after them
    String result = text;

    // Handle start of text
    result = capitalizeFirstLetter(result.trim());

    // Patterns to detect sentence endings
    final sentenceEndings = ['. ', '! ', '? '];

    for (String ending in sentenceEndings) {
      List<String> parts = result.split(ending);
      if (parts.length > 1) {
        for (int i = 1; i < parts.length; i++) {
          if (parts[i].isNotEmpty) {
            parts[i] = capitalizeFirstLetter(parts[i].trim());
          }
        }
        result = parts.join(ending);
      }
    }

    return result;
  }

  /// Smart capitalize - handles both words and sentences based on input
  /// Example: "my name is dileep, what is your father name" -> "My Name Is Dileep, What Is Your Father Name"
  static String smartCapitalize(String text, {bool capitalizeAllWords = true}) {
    if (text.isEmpty) return text;

    if (capitalizeAllWords) {
      // Capitalize every word like "My Name Is Dileep"
      return capitalizeWords(text);
    } else {
      // Capitalize only sentences like "My name is dileep. What is your father name?"
      return capitalizeSentences(text);
    }
  }

  /// Format user input text - for TextFields, display names, etc.
  /// Example: "dileepmali" -> "Dileep Mali", "my name is dileep" -> "My Name Is Dileep"
  static String formatUserInput(String text) {
    if (text.isEmpty) return text;

    String trimmedText = text.trim();

    // If text already has spaces, just capitalize each word
    if (trimmedText.contains(' ')) {
      return smartCapitalize(trimmedText, capitalizeAllWords: true);
    }

    // For single words without spaces, add space before uppercase letters
    // that follow lowercase letters (camelCase detection)
    String result = '';
    for (int i = 0; i < trimmedText.length; i++) {
      // Add space before capital letter if it's not the first character
      // and the previous character is lowercase
      if (i > 0 &&
          trimmedText[i].toUpperCase() == trimmedText[i] &&
          trimmedText[i-1].toLowerCase() == trimmedText[i-1]) {
        result += ' ';
      }
      result += trimmedText[i];
    }

    // Then capitalize all words
    return smartCapitalize(result, capitalizeAllWords: true);
  }

  /// Format description text - for longer texts, messages, etc.
  /// Example: "hello world. how are you?" -> "Hello world. How are you?"
  static String formatDescription(String text) {
    return smartCapitalize(text.trim(), capitalizeAllWords: false);
  }

  /// Format filename while preserving extension
  /// Example: "dileep_mali_rathod.jpg" -> returns {name: "Dileep_Mali_Rathod", extension: ".jpg"}
  static Map<String, String> splitFilename(String filename) {
    final lastDotIndex = filename.lastIndexOf('.');
    if (lastDotIndex > 0) {
      return {
        'name': filename.substring(0, lastDotIndex),
        'extension': filename.substring(lastDotIndex)
      };
    } else {
      return {
        'name': filename,
        'extension': ''
      };
    }
  }

  /// Format filename input - capitalize first letter of each word separated by underscore or space
  /// Converts spaces to underscores automatically
  /// Also handles camelCase detection for words without separators
  /// Example: "dileep mali rathod" -> "Dileep_Mali_Rathod"
  /// Example: "dileepmali" -> "Dileep_Mali" (with camelCase detection)
  static String formatFilename(String filename) {
    if (filename.isEmpty) return filename;

    String trimmedText = filename.trim();

    // Check if text has underscores or spaces
    if (trimmedText.contains('_') || trimmedText.contains(' ')) {
      // Split by underscore and space, capitalize each part, then rejoin with underscore
      return trimmedText
          .split(RegExp(r'[_\s]+'))
          .where((part) => part.isNotEmpty)
          .map((part) => capitalizeFirstLetter(part))
          .join('_');
    }

    // For single words without separators, add underscore before uppercase letters
    // that follow lowercase letters (camelCase detection)
    String result = '';
    for (int i = 0; i < trimmedText.length; i++) {
      // Add underscore before capital letter if it's not the first character
      // and the previous character is lowercase
      if (i > 0 &&
          trimmedText[i].toUpperCase() == trimmedText[i] &&
          trimmedText[i] != trimmedText[i].toLowerCase() && // Make sure it's actually a letter
          trimmedText[i-1].toLowerCase() == trimmedText[i-1] &&
          trimmedText[i-1] != trimmedText[i-1].toUpperCase()) { // Make sure previous is actually a letter
        result += '_';
      }
      result += trimmedText[i];
    }

    // Then split by underscore and capitalize
    return result
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => capitalizeFirstLetter(part))
        .join('_');
  }

  /// Truncate file name to specified length while preserving file extension
  /// Example: "very_long_file_name_here.jpg" (maxLength: 24) -> "very_long_file_na.jpg"
  /// Example: "short.pdf" (maxLength: 24) -> "short.pdf"
  static String truncateFileName(String fileName, {int maxLength = 24}) {
    if (fileName.length <= maxLength) return fileName;

    // Get file name and extension separately
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) {
      // No extension, just truncate
      return fileName.substring(0, maxLength);
    }

    final extension = fileName.substring(lastDotIndex); // includes the dot
    final nameWithoutExt = fileName.substring(0, lastDotIndex);

    // Calculate available space for name (maxLength - extension length)
    final availableLength = maxLength - extension.length;

    if (availableLength <= 3) {
      // Not enough space, just return truncated full name
      return fileName.substring(0, maxLength);
    }

    // Truncate name and add extension
    return nameWithoutExt.substring(0, availableLength) + extension;
  }

  /// Format bytes to human-readable file size
  /// Converts raw bytes to KB, MB, GB format
  /// Example: 62387892 -> "59.5 MB"
  /// Example: 1024 -> "1 KB"
  /// Example: 1536 -> "1.5 KB"
  static String formatFileSize(dynamic size) {
    // Handle null or empty
    if (size == null) return 'Unknown size';

    // If already formatted (contains KB/MB/GB), return as is
    if (size is String) {
      final sizeStr = size.trim().toUpperCase();
      if (sizeStr.contains('KB') || sizeStr.contains('MB') || sizeStr.contains('GB') || sizeStr.contains('TB')) {
        return size;
      }

      // Try to parse string to number
      try {
        final bytes = double.tryParse(size);
        if (bytes == null) return size; // Return original if can't parse
        return formatFileSize(bytes); // Recursively format
      } catch (e) {
        return size;
      }
    }

    // Convert to double for calculations
    double bytes = 0;
    if (size is int) {
      bytes = size.toDouble();
    } else if (size is double) {
      bytes = size;
    } else {
      return 'Unknown size';
    }

    // Format based on size
    if (bytes < 1024) {
      // Less than 1 KB - show as bytes
      return '${bytes.toInt()} B';
    } else if (bytes < 1024 * 1024) {
      // Less than 1 MB - show as KB
      final kb = bytes / 1024;
      return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      // Less than 1 GB - show as MB
      final mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
    } else {
      // 1 GB or more - show as GB
      final gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(gb < 10 ? 1 : 0)} GB';
    }
  }
}