import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import 'shared_preferences_provider.dart';

part 'language_provider.g.dart';

/// List of supported locales in the application.
///
/// This list should match the locales configured in the MaterialApp
/// and for which translations are available.
const List<Locale> supportedLocales = [
  Locale('en'), // English (default)
  Locale('cs'), // Czech
  Locale('de'), // German
  Locale('fr'), // French
  Locale('ru'), // Russian
  Locale('pl'), // Polish
  Locale('es'), // Spanish
  Locale('it'), // Italian
];

/// Default locale used when no preference is saved or the saved locale
/// is not in the supported locales list.
const Locale defaultLocale = Locale('en');

/// Notifier for managing the application locale/language state.
///
/// This notifier handles:
/// - Loading the saved locale preference from SharedPreferences
/// - Persisting locale changes to SharedPreferences
/// - Validating that the locale is in the supported locales list
@Riverpod(keepAlive: true)
class LocaleNotifier extends _$LocaleNotifier {
  late SharedPreferences _prefs;

  @override
  Locale build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadLocale();
  }

  /// Loads the saved locale from SharedPreferences.
  ///
  /// Returns [defaultLocale] if:
  /// - No locale is saved
  /// - The saved locale is not in [supportedLocales]
  Locale _loadLocale() {
    final languageCode = _prefs.getString(StorageKeys.localeKey);

    if (languageCode == null) {
      return defaultLocale;
    }

    final savedLocale = Locale(languageCode);

    // Verify the saved locale is still supported
    if (_isSupported(savedLocale)) {
      return savedLocale;
    }

    return defaultLocale;
  }

  /// Checks if a locale is in the supported locales list.
  bool _isSupported(Locale locale) {
    return supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  /// Sets the application locale to the specified [locale].
  ///
  /// The locale must be in [supportedLocales], otherwise an
  /// [ArgumentError] is thrown.
  ///
  /// The new locale is persisted to SharedPreferences.
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale)) {
      throw ArgumentError(
        'Locale ${locale.languageCode} is not supported. '
        'Supported locales: ${supportedLocales.map((l) => l.languageCode).join(", ")}',
      );
    }

    if (state.languageCode == locale.languageCode) return;

    state = locale;
    await _prefs.setString(StorageKeys.localeKey, locale.languageCode);
  }

  /// Sets the application locale by language code string.
  ///
  /// This is a convenience method that creates a [Locale] from the
  /// language code and calls [setLocale].
  Future<void> setLocaleByCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Resets the locale to the default ([defaultLocale]).
  Future<void> resetToDefault() async {
    await setLocale(defaultLocale);
  }
}

/// Provider that exposes the current language code as a String.
@riverpod
String currentLanguageCode(Ref ref) {
  return ref.watch(localeNotifierProvider).languageCode;
}

/// Provider that checks if a specific language code is the current locale.
@riverpod
bool isCurrentLocale(Ref ref, String languageCode) {
  return ref.watch(localeNotifierProvider).languageCode == languageCode;
}

/// Provider that returns the list of supported locales.
@riverpod
List<Locale> supportedLocalesList(Ref ref) {
  return supportedLocales;
}
