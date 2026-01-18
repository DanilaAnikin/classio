/// Core module exports for the Classio application.
///
/// This barrel file provides convenient access to all core functionality.
/// Import this single file to access themes, providers, router, localization,
/// and constants.
///
/// Usage:
/// ```dart
/// import 'package:classio/core/core.dart';
/// ```
library;

// ============================================================================
// Constants
// ============================================================================

/// Storage keys for SharedPreferences persistence
export 'constants/storage_keys.dart';

// ============================================================================
// Theme
// ============================================================================

// Note: ThemeType enum is exported from providers/theme_provider.dart
// to avoid duplicate definition conflicts. Do not export theme_type.dart here.

/// Color definitions for both themes
export 'theme/app_colors.dart';

/// Text styles for both themes
export 'theme/app_text_styles.dart';

/// Clean theme - minimalist, professional design
export 'theme/clean_theme.dart';

/// Playful theme - colorful, engaging design
export 'theme/playful_theme.dart';

// ============================================================================
// Providers
// ============================================================================

/// All Riverpod providers (SharedPreferences, Theme, Language)
export 'providers/providers.dart';

// ============================================================================
// Router
// ============================================================================

/// GoRouter configuration and route definitions
export 'router/router.dart';

// ============================================================================
// Localization
// ============================================================================

/// Localization configuration and generated translations
export 'localization/app_localizations.dart';

// ============================================================================
// Utils
// ============================================================================

/// Subject color utilities
export 'utils/subject_colors.dart';
