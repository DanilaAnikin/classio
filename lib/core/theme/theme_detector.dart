import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized theme detection utilities.
///
/// Use these instead of inline theme detection to ensure consistency
/// and reduce code duplication across the codebase.

/// Extension on BuildContext for easy theme detection.
extension ThemeContextExtension on BuildContext {
  /// Returns true if the current theme is the playful theme.
  ///
  /// This checks the primary color against the known PlayfulColors.primary.
  bool get isPlayfulTheme {
    final theme = Theme.of(this);
    final primaryColor = theme.colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
  }

  /// Returns true if the current theme is the clean (professional) theme.
  bool get isCleanTheme => !isPlayfulTheme;
}

/// A mixin for StatelessWidget/StatefulWidget that provides theme detection.
///
/// Usage:
/// ```dart
/// class MyWidget extends StatelessWidget with ThemeDetectorMixin {
///   @override
///   Widget build(BuildContext context) {
///     final isPlayful = detectIsPlayful(context);
///     // ...
///   }
/// }
/// ```
mixin ThemeDetectorMixin {
  /// Detects if the current theme is playful based on primary color.
  bool detectIsPlayful(BuildContext context) {
    return context.isPlayfulTheme;
  }
}

/// Standalone function for theme detection when mixins are not suitable.
///
/// Prefer using [ThemeContextExtension] or [ThemeDetectorMixin] when possible.
bool isPlayfulTheme(BuildContext context) {
  final theme = Theme.of(context);
  final primaryColor = theme.colorScheme.primary;
  return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32();
}
