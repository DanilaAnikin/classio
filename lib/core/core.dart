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

/// All theme-related exports (colors, typography, shadows, radius, spacing, themes)
/// Note: ThemeType enum is exported from providers/theme_provider.dart
/// to avoid duplicate definition conflicts.
export 'theme/theme.dart';

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

// ============================================================================
// Exceptions
// ============================================================================

/// Application exception classes
export 'exceptions/exceptions.dart';
