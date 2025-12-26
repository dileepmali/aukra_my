class TolgeeConfig {
  // Tolgee configuration constants
  static const String apiUrl = 'https://app.tolgee.io';
  static const String apiKey = 'tgpak_gizdsmbtl4ywyodfgnsxg2rxg5xhanlsm5zg6n3cnu3gyzbunr2a'; // Replace with your actual API key

  static const List<String> supportedLanguages = [
    'en', // English
    'hi', // Hindi
    'es', // Spanish
    'fr', // French
    'de', // German
    'zh', // Chinese
    'ja', // Japanese
    'ar', // Arabic
    'pt', // Portuguese
    'ru', // Russian
    'ko', // Korean
    'it', // Italian
    'nl', // Dutch
    'tr', // Turkish
    'pl', // Polish
    'sv', // Swedish
    'no', // Norwegian
    'da', // Danish
    'fi', // Finnish
    'he', // Hebrew
    'th', // Thai
    'id', // Indonesian
    'ms', // Malay
    'vi', // Vietnamese
    'bn', // Bengali
    'ta', // Tamil
    'te', // Telugu
    'mr', // Marathi
    'gu', // Gujarati
    'ur', // Urdu
    'pa', // Punjabi
  ];

  static const String defaultLanguage = 'en';

  static Map<String, String> getLanguageDisplayNames() {
    return {
      'en': 'English',
      'hi': 'हिन्दी',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'zh': '中文',
      'ja': '日本語',
      'ar': 'العربية',
      'pt': 'Português',
      'ru': 'Русский',
      'ko': '한국어',
      'it': 'Italiano',
      'nl': 'Nederlands',
      'tr': 'Türkçe',
      'pl': 'Polski',
      'sv': 'Svenska',
      'no': 'Norsk',
      'da': 'Dansk',
      'fi': 'Suomi',
      'he': 'עברית',
      'th': 'ไทย',
      'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
      'vi': 'Tiếng Việt',
      'bn': 'বাংলা',
      'ta': 'তমিল',
      'te': 'తెలుగు',
      'mr': 'मराठी',
      'gu': 'ગુજરાતી',
      'ur': 'اردو',
      'pa': 'ਪੰਜਾਬੀ',
    };
  }
}