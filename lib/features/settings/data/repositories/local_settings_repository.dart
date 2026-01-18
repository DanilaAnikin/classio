import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  final SharedPreferences _prefs;
  static const _settingsKey = 'app_settings';

  LocalSettingsRepository(this._prefs);

  @override
  Future<AppSettings> getSettings() async {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null) {
      return const AppSettings();
    }
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AppSettings.fromJson(json);
    } catch (e) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final jsonString = jsonEncode(settings.toJson());
    await _prefs.setString(_settingsKey, jsonString);
  }

  @override
  Future<void> updateLocale(String locale) async {
    final settings = await getSettings();
    await saveSettings(settings.copyWith(locale: locale));
  }

  @override
  Future<void> updateTheme(String themeType) async {
    // Theme is already handled by theme_provider, this is for persistence
  }
}
