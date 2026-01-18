import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<void> updateLocale(String locale);
  Future<void> updateTheme(String themeType);
}
