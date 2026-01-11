/// Storage keys for SharedPreferences persistence.
///
/// This class contains all the keys used to store data in SharedPreferences.
/// Using constants ensures consistency and prevents typos when accessing stored values.
abstract final class StorageKeys {
  /// Key for storing the user's selected theme preference.
  /// Stored value: String representation of [ThemeType] enum (e.g., 'clean', 'playful').
  static const String themeKey = 'app_theme';

  /// Key for storing the user's selected locale/language preference.
  /// Stored value: String language code (e.g., 'en', 'cs', 'de').
  static const String localeKey = 'app_locale';
}
