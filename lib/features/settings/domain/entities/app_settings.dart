import 'package:classio/core/theme/theme_type.dart';

/// Application settings entity
class AppSettings {
  final String locale;
  final ThemeType themeType;
  final bool notificationsEnabled;
  final bool soundEnabled;

  const AppSettings({
    this.locale = 'en',
    this.themeType = ThemeType.clean,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
  });

  AppSettings copyWith({
    String? locale,
    ThemeType? themeType,
    bool? notificationsEnabled,
    bool? soundEnabled,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeType: themeType ?? this.themeType,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'locale': locale,
    'theme_type': themeType.name,
    'notifications_enabled': notificationsEnabled,
    'sound_enabled': soundEnabled,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      locale: json['locale'] as String? ?? 'en',
      themeType: ThemeType.values.firstWhere(
        (t) => t.name == json['theme_type'],
        orElse: () => ThemeType.clean,
      ),
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
    );
  }
}
