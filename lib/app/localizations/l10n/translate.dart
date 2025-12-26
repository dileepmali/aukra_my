import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

/// Static access to [AppLocalizations].
///
/// Usage:
/// 1. Initialize in `MaterialApp.builder`: `Translate.init(context);`
/// 2. Access translations from ViewModels/Services: `Translate.current.appTitle`
/// 3. Get current locale: `Translate.locale`
/// 4. Programmatically load a different locale: `await Translate.load(Locale('hi'));`
class Translate {
  static AppLocalizations? _currentLocalizations;
  static Locale? _currentLocale;

  /// Initializes `Translate` with [AppLocalizations] from the given [context].
  /// Must be called once, typically in `MaterialApp.builder`.
  /// Also sets `intl.Intl.defaultLocale`.
  static void init(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations != null) {
      _currentLocalizations = localizations;
      _currentLocale = Locale(localizations.localeName);
      intl.Intl.defaultLocale = localizations.localeName;
    } else {
      debugPrint(
        'Translate.init(context): AppLocalizations.of(context) returned null. '
        'Verify MaterialApp setup and Translate.init call timing.',
      );
    }
  }

  /// The current [AppLocalizations] instance.
  /// Throws if `init` was not called or failed.
  static AppLocalizations get current {
    if (_currentLocalizations == null) {
      throw Exception(
        'Translate.current accessed before Translate.init(context) was successfully called. '
        'Ensure Translate.init(context) is called in your MaterialApp builder.',
      );
    }
    return _currentLocalizations!;
  }

  /// The currently active [Locale].
  /// Null if `init` was not called or failed.
  static Locale? get locale => _currentLocale;

  /// Loads and sets localizations for [newLocale]. Updates `Translate.current` and `Translate.locale`.
  static Future<void> load(Locale newLocale) async {
    try {
      // Find the best matching localization
      AppLocalizations? loadedLocalizations;

      // Try exact match first
      if (AppLocalizations.supportedLocales.contains(newLocale)) {
        loadedLocalizations = AppLocalizations.delegate.load(newLocale) as AppLocalizations?;
      } else {
        // Try language code match
        final languageMatch = AppLocalizations.supportedLocales.firstWhere(
          (locale) => locale.languageCode == newLocale.languageCode,
          orElse: () => AppLocalizations.supportedLocales.first,
        );
        loadedLocalizations = AppLocalizations.delegate.load(languageMatch) as AppLocalizations?;
      }

      if (loadedLocalizations != null) {
        _currentLocalizations = loadedLocalizations;
        _currentLocale = newLocale;
        intl.Intl.defaultLocale = newLocale.toLanguageTag();
      }
    } catch (e) {
      debugPrint(
        'Translate.load(Locale newLocale) failed for locale "${newLocale.toLanguageTag()}": $e',
      );
      rethrow;
    }
  }
}