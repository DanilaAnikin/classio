import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';
import '../theme/theme_type.dart';
import 'shared_preferences_provider.dart';

export '../theme/theme_type.dart';

part 'theme_provider.g.dart';

/// Notifier for managing the application theme state.
///
/// This notifier handles:
/// - Loading the saved theme preference from SharedPreferences
/// - Persisting theme changes to SharedPreferences
/// - Providing methods to change or toggle the theme
@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  late SharedPreferences _prefs;

  @override
  ThemeType build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadTheme();
  }

  /// Loads the saved theme from SharedPreferences.
  ///
  /// Returns [ThemeType.clean] as the default if no theme is saved.
  ThemeType _loadTheme() {
    final themeName = _prefs.getString(StorageKeys.themeKey);
    return ThemeType.fromString(themeName);
  }

  /// Sets the application theme to the specified [themeType].
  ///
  /// The new theme is persisted to SharedPreferences.
  Future<void> setTheme(ThemeType themeType) async {
    if (state == themeType) return;

    state = themeType;
    await _prefs.setString(StorageKeys.themeKey, themeType.name);
  }

  /// Toggles between [ThemeType.clean] and [ThemeType.playful].
  ///
  /// The new theme is persisted to SharedPreferences.
  Future<void> toggleTheme() async {
    final newTheme = state == ThemeType.clean ? ThemeType.playful : ThemeType.clean;
    await setTheme(newTheme);
  }
}

/// Convenience provider to check if the current theme is clean.
@riverpod
bool isCleanTheme(Ref ref) {
  return ref.watch(themeNotifierProvider) == ThemeType.clean;
}

/// Convenience provider to check if the current theme is playful.
@riverpod
bool isPlayfulTheme(Ref ref) {
  return ref.watch(themeNotifierProvider) == ThemeType.playful;
}
