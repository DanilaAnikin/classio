import 'package:flutter/material.dart';

// Import the generated localizations for use in this file
import 'generated/app_localizations.dart';

// Export the generated localizations for other files to use
export 'generated/app_localizations.dart';

/// Configuration and helper utilities for the Classio localization system.
///
/// This class provides all localization-related configurations including:
/// - List of supported locales
/// - Helper methods for locale management
/// - Language metadata (names, flags)
///
/// For accessing translated strings, use the generated [AppLocalizations] class:
/// ```dart
/// final l10n = AppLocalizations.of(context);
/// Text(l10n.welcomeMessage);
/// ```
class LocalizationConfig {
  LocalizationConfig._();

  /// Default locale for the application.
  static const Locale defaultLocale = Locale('en');

  /// List of all supported locales in the application.
  ///
  /// Languages supported:
  /// - English (EN) - Default
  /// - Czech (CS)
  /// - German (DE)
  /// - French (FR)
  /// - Russian (RU)
  /// - Polish (PL)
  /// - Spanish (ES)
  /// - Italian (IT)
  static const List<Locale> supportedLocales = [
    Locale('en'), // English (Default)
    Locale('cs'), // Czech
    Locale('de'), // German
    Locale('fr'), // French
    Locale('ru'), // Russian
    Locale('pl'), // Polish
    Locale('es'), // Spanish
    Locale('it'), // Italian
  ];

  /// Returns a human-readable name for a given locale.
  ///
  /// Example:
  /// ```dart
  /// final name = LocalizationConfig.getLanguageName(Locale('cs'));
  /// // Returns 'Cestina'
  /// ```
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'cs':
        return 'Cestina';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Francais';
      case 'ru':
        return 'Russkiy';
      case 'pl':
        return 'Polski';
      case 'es':
        return 'Espanol';
      case 'it':
        return 'Italiano';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Returns the native name for a given locale.
  ///
  /// This is useful for displaying language options in their native script.
  static String getNativeLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'cs':
        return 'Cestina';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Francais';
      case 'ru':
        return 'Russkiy';
      case 'pl':
        return 'Polski';
      case 'es':
        return 'Espanol';
      case 'it':
        return 'Italiano';
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  /// Returns the flag emoji for a given locale.
  ///
  /// Note: Flag emojis may not display correctly on all platforms.
  static String getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '\u{1F1EC}\u{1F1E7}'; // GB flag
      case 'cs':
        return '\u{1F1E8}\u{1F1FF}'; // CZ flag
      case 'de':
        return '\u{1F1E9}\u{1F1EA}'; // DE flag
      case 'fr':
        return '\u{1F1EB}\u{1F1F7}'; // FR flag
      case 'ru':
        return '\u{1F1F7}\u{1F1FA}'; // RU flag
      case 'pl':
        return '\u{1F1F5}\u{1F1F1}'; // PL flag
      case 'es':
        return '\u{1F1EA}\u{1F1F8}'; // ES flag
      case 'it':
        return '\u{1F1EE}\u{1F1F9}'; // IT flag
      default:
        return '\u{1F3F3}'; // White flag
    }
  }

  /// Checks if a locale is supported by the application.
  static bool isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// Returns the best matching supported locale for a given locale.
  ///
  /// If the exact locale is not supported, returns the default locale.
  static Locale resolveLocale(Locale? locale) {
    if (locale == null) return defaultLocale;

    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return defaultLocale;
  }

  /// Locale resolution callback for MaterialApp.
  ///
  /// This callback is used to determine which locale to use when the app starts.
  /// It matches the device locale against supported locales and falls back to
  /// the default locale if no match is found.
  static Locale? localeResolutionCallback(
    Locale? deviceLocale,
    Iterable<Locale> supportedLocales,
  ) {
    if (deviceLocale == null) return defaultLocale;

    for (final locale in supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }

    return defaultLocale;
  }
}

/// Extension on BuildContext for easy access to localization.
extension LocalizationExtension on BuildContext {
  /// Returns the AppLocalizations instance for easy access to translated strings.
  ///
  /// Usage:
  /// ```dart
  /// final l10n = context.l10n;
  /// Text(l10n.welcomeMessage);
  /// ```
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Returns the current locale of the app.
  Locale get currentLocale => Localizations.localeOf(this);

  /// Returns true if the current locale is the default locale.
  bool get isDefaultLocale =>
      currentLocale.languageCode ==
      LocalizationConfig.defaultLocale.languageCode;
}

/// Enum representing all supported languages with their metadata.
enum SupportedLanguage {
  english(
    locale: Locale('en'),
    name: 'English',
    nativeName: 'English',
  ),
  czech(
    locale: Locale('cs'),
    name: 'Czech',
    nativeName: 'Cestina',
  ),
  german(
    locale: Locale('de'),
    name: 'German',
    nativeName: 'Deutsch',
  ),
  french(
    locale: Locale('fr'),
    name: 'French',
    nativeName: 'Francais',
  ),
  russian(
    locale: Locale('ru'),
    name: 'Russian',
    nativeName: 'Russkiy',
  ),
  polish(
    locale: Locale('pl'),
    name: 'Polish',
    nativeName: 'Polski',
  ),
  spanish(
    locale: Locale('es'),
    name: 'Spanish',
    nativeName: 'Espanol',
  ),
  italian(
    locale: Locale('it'),
    name: 'Italian',
    nativeName: 'Italiano',
  );

  const SupportedLanguage({
    required this.locale,
    required this.name,
    required this.nativeName,
  });

  final Locale locale;
  final String name;
  final String nativeName;

  /// Returns the language code (e.g., 'en', 'cs', 'de').
  String get languageCode => locale.languageCode;

  /// Creates a SupportedLanguage from a locale.
  ///
  /// Returns [SupportedLanguage.english] if the locale is not supported.
  static SupportedLanguage fromLocale(Locale locale) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.languageCode == locale.languageCode,
      orElse: () => SupportedLanguage.english,
    );
  }

  /// Creates a SupportedLanguage from a language code string.
  ///
  /// Returns [SupportedLanguage.english] if the code is not recognized.
  static SupportedLanguage fromCode(String code) {
    return SupportedLanguage.values.firstWhere(
      (lang) => lang.languageCode == code.toLowerCase(),
      orElse: () => SupportedLanguage.english,
    );
  }
}
