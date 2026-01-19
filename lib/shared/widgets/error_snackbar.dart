import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/spacing.dart';

// =============================================================================
// CLASSIO TOAST SYSTEM v2.0
// =============================================================================
// Premium enterprise-grade toast/snackbar system with:
// - Four semantic variants: error, success, warning, info
// - Proper entry/exit animations
// - Consistent design tokens from the design system
// - Optional action buttons and close functionality
// - Auto-dismiss support
// =============================================================================

/// Toast variant types with their semantic meanings
enum ToastVariant {
  /// Error toast - for failures, validation errors, critical issues
  error,

  /// Success toast - for confirmations, completed actions
  success,

  /// Warning toast - for cautions, potential issues
  warning,

  /// Info toast - for informational messages, tips
  info,
}

/// Configuration for a toast variant's appearance
class _ToastVariantConfig {
  const _ToastVariantConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color secondaryTextColor;
  final IconData icon;

  /// Get configuration for Clean theme
  static _ToastVariantConfig forCleanTheme(ToastVariant variant) {
    switch (variant) {
      case ToastVariant.error:
        return _ToastVariantConfig(
          backgroundColor: CleanColors.errorMuted,
          borderColor: CleanColors.errorBorder,
          iconColor: CleanColors.error,
          textColor: CleanColors.error,
          secondaryTextColor: CleanColors.textSecondary,
          icon: Icons.error_outline_rounded,
        );
      case ToastVariant.success:
        return _ToastVariantConfig(
          backgroundColor: CleanColors.successMuted,
          borderColor: CleanColors.successBorder,
          iconColor: CleanColors.success,
          textColor: CleanColors.success,
          secondaryTextColor: CleanColors.textSecondary,
          icon: Icons.check_circle_outline_rounded,
        );
      case ToastVariant.warning:
        return _ToastVariantConfig(
          backgroundColor: CleanColors.warningMuted,
          borderColor: CleanColors.warningBorder,
          iconColor: CleanColors.warning,
          textColor: CleanColors.warningPressed,
          secondaryTextColor: CleanColors.textSecondary,
          icon: Icons.warning_amber_rounded,
        );
      case ToastVariant.info:
        return _ToastVariantConfig(
          backgroundColor: CleanColors.infoMuted,
          borderColor: CleanColors.infoBorder,
          iconColor: CleanColors.info,
          textColor: CleanColors.info,
          secondaryTextColor: CleanColors.textSecondary,
          icon: Icons.info_outline_rounded,
        );
    }
  }

  /// Get configuration for Playful theme
  static _ToastVariantConfig forPlayfulTheme(ToastVariant variant) {
    switch (variant) {
      case ToastVariant.error:
        return _ToastVariantConfig(
          backgroundColor: PlayfulColors.errorMuted,
          borderColor: PlayfulColors.errorBorder,
          iconColor: PlayfulColors.error,
          textColor: PlayfulColors.errorPressed,
          secondaryTextColor: PlayfulColors.textSecondary,
          icon: Icons.error_outline_rounded,
        );
      case ToastVariant.success:
        return _ToastVariantConfig(
          backgroundColor: PlayfulColors.successMuted,
          borderColor: PlayfulColors.successBorder,
          iconColor: PlayfulColors.success,
          textColor: PlayfulColors.successPressed,
          secondaryTextColor: PlayfulColors.textSecondary,
          icon: Icons.check_circle_outline_rounded,
        );
      case ToastVariant.warning:
        return _ToastVariantConfig(
          backgroundColor: PlayfulColors.warningMuted,
          borderColor: PlayfulColors.warningBorder,
          iconColor: PlayfulColors.warning,
          textColor: PlayfulColors.warningPressed,
          secondaryTextColor: PlayfulColors.textSecondary,
          icon: Icons.warning_amber_rounded,
        );
      case ToastVariant.info:
        return _ToastVariantConfig(
          backgroundColor: PlayfulColors.infoMuted,
          borderColor: PlayfulColors.infoBorder,
          iconColor: PlayfulColors.info,
          textColor: PlayfulColors.infoPressed,
          secondaryTextColor: PlayfulColors.textSecondary,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

/// Premium toast/snackbar widget with modern styling and animations.
///
/// Features:
/// - Four semantic variants (error, success, warning, info)
/// - Icon, title, and optional description
/// - Optional action button
/// - Optional close button
/// - Auto-dismiss with configurable duration
/// - Smooth entry/exit animations
///
/// Usage:
/// ```dart
/// // Using static show methods (recommended)
/// AppToast.showError(context, 'Something went wrong');
/// AppToast.showSuccess(context, 'Changes saved successfully');
/// AppToast.showWarning(context, 'Connection unstable');
/// AppToast.showInfo(context, 'New features available');
///
/// // With description
/// AppToast.showError(
///   context,
///   'Upload failed',
///   description: 'Please check your internet connection and try again.',
/// );
///
/// // With action button
/// AppToast.showSuccess(
///   context,
///   'Item deleted',
///   actionLabel: 'Undo',
///   onAction: () => undoDelete(),
/// );
/// ```
class AppToast extends StatelessWidget {
  const AppToast({
    super.key,
    required this.message,
    required this.variant,
    this.description,
    this.actionLabel,
    this.onAction,
    this.showCloseButton = true,
    this.onClose,
    this.isPlayful = false,
  });

  /// The main message/title to display
  final String message;

  /// The toast variant (error, success, warning, info)
  final ToastVariant variant;

  /// Optional description text below the title
  final String? description;

  /// Label for the optional action button
  final String? actionLabel;

  /// Callback when the action button is pressed
  final VoidCallback? onAction;

  /// Whether to show the close button
  final bool showCloseButton;

  /// Callback when the close button is pressed
  final VoidCallback? onClose;

  /// Whether to use playful theme styling
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final config = isPlayful
        ? _ToastVariantConfig.forPlayfulTheme(variant)
        : _ToastVariantConfig.forCleanTheme(variant);

    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: AppRadius.snackbar(isPlayful: isPlayful),
        border: Border.all(
          color: config.borderColor,
          width: 1,
        ),
        boxShadow: AppShadows.toast(isPlayful: isPlayful),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
        child: Row(
          crossAxisAlignment: description != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            // Icon
            _buildIcon(config),
            AppSpacing.gapH12,

            // Content (title + description)
            Expanded(
              child: _buildContent(config),
            ),

            // Action button (if provided)
            if (actionLabel != null && onAction != null) ...[
              AppSpacing.gapH8,
              _buildActionButton(config),
            ],

            // Close button (if enabled)
            if (showCloseButton) ...[
              AppSpacing.gapH4,
              _buildCloseButton(config),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_ToastVariantConfig config) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: config.iconColor.withValues(alpha: 0.1),
        borderRadius: AppRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        config.icon,
        color: config.iconColor,
        size: AppIconSize.md,
      ),
    );
  }

  Widget _buildContent(_ToastVariantConfig config) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          message,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            color: config.textColor,
            fontSize: AppFontSize.bodyMedium,
            height: AppLineHeight.body,
          ),
        ),

        // Description (if provided)
        if (description != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            description!,
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              color: config.secondaryTextColor,
              fontSize: AppFontSize.bodySmall,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(_ToastVariantConfig config) {
    return TextButton(
      onPressed: onAction,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: config.iconColor,
        textStyle: AppTypography.buttonTextSmall(isPlayful: isPlayful).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Text(actionLabel!),
    );
  }

  Widget _buildCloseButton(_ToastVariantConfig config) {
    return IconButton(
      onPressed: onClose,
      icon: Icon(
        Icons.close_rounded,
        color: config.secondaryTextColor,
        size: AppIconSize.sm,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
      splashRadius: 16,
      tooltip: 'Dismiss',
    );
  }

  // ===========================================================================
  // STATIC SHOW METHODS
  // ===========================================================================

  /// Show an error toast.
  ///
  /// Example:
  /// ```dart
  /// AppToast.showError(context, 'Failed to save changes');
  /// ```
  static void showError(
    BuildContext context,
    String message, {
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Duration duration = const Duration(seconds: 6),
    bool autoDismiss = true,
  }) {
    _showToast(
      context,
      message: message,
      variant: ToastVariant.error,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      showCloseButton: showCloseButton,
      duration: duration,
      autoDismiss: autoDismiss,
    );
  }

  /// Show a success toast.
  ///
  /// Example:
  /// ```dart
  /// AppToast.showSuccess(context, 'Profile updated successfully');
  /// ```
  static void showSuccess(
    BuildContext context,
    String message, {
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Duration duration = const Duration(seconds: 4),
    bool autoDismiss = true,
  }) {
    _showToast(
      context,
      message: message,
      variant: ToastVariant.success,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      showCloseButton: showCloseButton,
      duration: duration,
      autoDismiss: autoDismiss,
    );
  }

  /// Show a warning toast.
  ///
  /// Example:
  /// ```dart
  /// AppToast.showWarning(context, 'Your session will expire soon');
  /// ```
  static void showWarning(
    BuildContext context,
    String message, {
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Duration duration = const Duration(seconds: 5),
    bool autoDismiss = true,
  }) {
    _showToast(
      context,
      message: message,
      variant: ToastVariant.warning,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      showCloseButton: showCloseButton,
      duration: duration,
      autoDismiss: autoDismiss,
    );
  }

  /// Show an info toast.
  ///
  /// Example:
  /// ```dart
  /// AppToast.showInfo(context, 'New features are available');
  /// ```
  static void showInfo(
    BuildContext context,
    String message, {
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Duration duration = const Duration(seconds: 4),
    bool autoDismiss = true,
  }) {
    _showToast(
      context,
      message: message,
      variant: ToastVariant.info,
      description: description,
      actionLabel: actionLabel,
      onAction: onAction,
      showCloseButton: showCloseButton,
      duration: duration,
      autoDismiss: autoDismiss,
    );
  }

  /// Internal method to show a toast using ScaffoldMessenger.
  static void _showToast(
    BuildContext context, {
    required String message,
    required ToastVariant variant,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    bool showCloseButton = true,
    Duration duration = const Duration(seconds: 4),
    bool autoDismiss = true,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Determine if using playful theme
    // Check brightness as a proxy for theme type
    final brightness = Theme.of(context).brightness;
    final isPlayful = Theme.of(context).primaryColor ==
        const Color(0xFF7C3AED); // PlayfulColors.primary

    // Clear existing snackbars
    scaffoldMessenger.clearSnackBars();

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: AppToast(
          message: message,
          variant: variant,
          description: description,
          actionLabel: actionLabel,
          onAction: () {
            onAction?.call();
            scaffoldMessenger.hideCurrentSnackBar();
          },
          showCloseButton: showCloseButton,
          onClose: () => scaffoldMessenger.hideCurrentSnackBar(),
          isPlayful: isPlayful,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: autoDismiss ? duration : const Duration(days: 365),
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  /// Clear all currently displayed toasts.
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  /// Hide the current toast.
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
}

// =============================================================================
// LEGACY COMPATIBILITY FUNCTIONS
// =============================================================================
// These functions maintain backward compatibility with the old API.
// New code should use AppToast.showError() and AppToast.showSuccess() instead.

/// Shows an error snackbar with a working dismiss button.
///
/// @deprecated Use [AppToast.showError] instead for the premium toast styling.
///
/// This utility function captures the ScaffoldMessenger before building
/// the SnackBar to prevent stale context issues with the dismiss button.
void showErrorSnackBar(BuildContext context, String message) {
  AppToast.showError(context, message);
}

/// Shows a success snackbar.
///
/// @deprecated Use [AppToast.showSuccess] instead for the premium toast styling.
///
/// Uses the same pattern as [showErrorSnackBar] to ensure consistent behavior.
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  bool isPlayful = false,
}) {
  AppToast.showSuccess(context, message);
}
