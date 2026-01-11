/// Enum representing the available theme types in the application.
///
/// - [clean]: A minimalist, Apple-inspired professional theme
/// - [playful]: A colorful, engaging theme for younger students
enum ThemeType {
  /// Minimalist, professional theme with clean lines and subtle shadows.
  /// Uses Inter font and deep blue primary colors.
  clean,

  /// Fun, engaging theme with vibrant colors and rounded corners.
  /// Uses Nunito font and purple/coral color scheme.
  playful;

  /// Returns a human-readable name for the theme.
  String get displayName {
    switch (this) {
      case ThemeType.clean:
        return 'Clean';
      case ThemeType.playful:
        return 'Playful';
    }
  }

  /// Returns a description of the theme.
  String get description {
    switch (this) {
      case ThemeType.clean:
        return 'A minimalist, professional theme with clean lines';
      case ThemeType.playful:
        return 'A fun, colorful theme perfect for younger students';
    }
  }

  /// Creates a [ThemeType] from its string name.
  ///
  /// Returns [ThemeType.clean] if the name is not recognized.
  static ThemeType fromString(String? name) {
    return ThemeType.values.firstWhere(
      (type) => type.name == name,
      orElse: () => ThemeType.clean,
    );
  }
}
