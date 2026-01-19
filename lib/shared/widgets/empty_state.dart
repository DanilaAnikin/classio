import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

// =============================================================================
// EMPTY STATE WIDGET
// =============================================================================
// A premium, theme-aware empty state widget for displaying when there is no
// content to show. Supports both Clean and Playful themes with proper design
// system integration.
//
// Features:
// - Theme-aware styling (Clean vs Playful)
// - Customizable icon with subtle container
// - Optional message/description
// - Optional action button
// - Optional custom illustration widget
// - Proper spacing from AppSpacing
// - Typography from AppTypography
// - Colors from AppColors
// =============================================================================

/// Enumeration of empty state visual variants.
enum EmptyStateVariant {
  /// Standard variant with icon in a circular container
  standard,

  /// Minimal variant without icon container background
  minimal,

  /// Compact variant with smaller sizing
  compact,

  /// Large variant for full-page empty states
  large,
}

/// A reusable empty state widget that displays a centered message
/// when there is no content to show.
///
/// This widget supports both Clean and Playful themes by using theme colors
/// instead of hardcoded values. Follows enterprise-grade design patterns
/// with proper spacing, typography, and subtle animations.
///
/// Example usage:
/// ```dart
/// EmptyState(
///   title: 'No Assignments',
///   message: 'Create your first assignment to get started',
///   icon: Icons.assignment_outlined,
///   actionLabel: 'Create Assignment',
///   onAction: () => _createAssignment(),
/// )
/// ```
///
/// With custom illustration:
/// ```dart
/// EmptyState(
///   title: 'No Messages',
///   message: 'Start a conversation to see messages here',
///   illustration: SvgPicture.asset('assets/illustrations/no_messages.svg'),
/// )
/// ```
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// The [title] parameter is required.
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.illustration,
    this.variant = EmptyStateVariant.standard,
    this.maxWidth,
  });

  /// Creates a compact empty state, useful for inline displays.
  const EmptyState.compact({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  })  : variant = EmptyStateVariant.compact,
        iconSize = null,
        secondaryActionLabel = null,
        onSecondaryAction = null,
        illustration = null,
        maxWidth = null;

  /// Creates a minimal empty state without icon container background.
  const EmptyState.minimal({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  })  : variant = EmptyStateVariant.minimal,
        secondaryActionLabel = null,
        onSecondaryAction = null,
        illustration = null,
        maxWidth = null;

  /// Creates a large empty state for full-page displays.
  const EmptyState.large({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.illustration,
  })  : variant = EmptyStateVariant.large,
        iconSize = null,
        maxWidth = null;

  /// The main title text to display.
  /// This is required.
  final String title;

  /// An optional message or description text.
  final String? message;

  /// The icon to display above the title.
  /// If null and no [illustration] is provided, defaults to [Icons.inbox_outlined].
  final IconData? icon;

  /// The size of the icon.
  /// Defaults based on [variant].
  final double? iconSize;

  /// Custom color for the icon.
  /// If null, uses the theme's primary color with reduced opacity.
  final Color? iconColor;

  /// The label for the primary action button.
  /// If provided along with [onAction], a button will be displayed.
  final String? actionLabel;

  /// The callback for the primary action button.
  /// If provided along with [actionLabel], a button will be displayed.
  final VoidCallback? onAction;

  /// The label for the secondary action button (text button style).
  final String? secondaryActionLabel;

  /// The callback for the secondary action button.
  final VoidCallback? onSecondaryAction;

  /// A custom illustration widget to display instead of an icon.
  /// If provided, the icon will be ignored.
  final Widget? illustration;

  /// The visual variant of the empty state.
  final EmptyStateVariant variant;

  /// Maximum width constraint for the content.
  /// Defaults to [AppSpacing.maxCardWidth].
  final double? maxWidth;

  // ===========================================================================
  // HELPER METHODS
  // ===========================================================================

  bool _isPlayfulTheme(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    // Detect playful theme by checking primary color
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        primaryColor.toARGB32() == 0xFF7C3AED;
  }

  double _getIconSize() {
    if (iconSize != null) return iconSize!;
    switch (variant) {
      case EmptyStateVariant.compact:
        return AppIconSize.xl; // 32
      case EmptyStateVariant.minimal:
        return AppIconSize.xxl; // 48
      case EmptyStateVariant.standard:
        return AppIconSize.hero; // 64
      case EmptyStateVariant.large:
        return 80.0;
    }
  }

  double _getIconContainerSize() {
    switch (variant) {
      case EmptyStateVariant.compact:
        return 64.0;
      case EmptyStateVariant.minimal:
        return 0.0; // No container
      case EmptyStateVariant.standard:
        return 120.0;
      case EmptyStateVariant.large:
        return 160.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (variant) {
      case EmptyStateVariant.compact:
        return AppSpacing.insets16;
      case EmptyStateVariant.minimal:
        return AppSpacing.insets20;
      case EmptyStateVariant.standard:
        return AppSpacing.pageInsetsLg;
      case EmptyStateVariant.large:
        return AppSpacing.insets32;
    }
  }

  double _getTitleToMessageGap() {
    switch (variant) {
      case EmptyStateVariant.compact:
        return AppSpacing.xs;
      case EmptyStateVariant.minimal:
        return AppSpacing.sm;
      case EmptyStateVariant.standard:
        return AppSpacing.sm;
      case EmptyStateVariant.large:
        return AppSpacing.md;
    }
  }

  double _getIconToTitleGap() {
    switch (variant) {
      case EmptyStateVariant.compact:
        return AppSpacing.sm;
      case EmptyStateVariant.minimal:
        return AppSpacing.md;
      case EmptyStateVariant.standard:
        return AppSpacing.xl;
      case EmptyStateVariant.large:
        return AppSpacing.xxl;
    }
  }

  double _getContentToActionGap() {
    switch (variant) {
      case EmptyStateVariant.compact:
        return AppSpacing.md;
      case EmptyStateVariant.minimal:
        return AppSpacing.lg;
      case EmptyStateVariant.standard:
        return AppSpacing.xxl;
      case EmptyStateVariant.large:
        return AppSpacing.xxxl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayfulTheme(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? AppSpacing.maxCardWidth,
        ),
        child: Padding(
          padding: _getPadding(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration or Icon
              _buildVisual(context, isPlayful, colorScheme),

              SizedBox(height: _getIconToTitleGap()),

              // Title
              _buildTitle(context, isPlayful),

              // Message (if provided)
              if (message != null) ...[
                SizedBox(height: _getTitleToMessageGap()),
                _buildMessage(context, isPlayful),
              ],

              // Action buttons (if provided)
              if (_hasActions) ...[
                SizedBox(height: _getContentToActionGap()),
                _buildActions(context, isPlayful),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasActions =>
      (actionLabel != null && onAction != null) ||
      (secondaryActionLabel != null && onSecondaryAction != null);

  Widget _buildVisual(
    BuildContext context,
    bool isPlayful,
    ColorScheme colorScheme,
  ) {
    // Use custom illustration if provided
    if (illustration != null) {
      return illustration!;
    }

    final effectiveIcon = icon ?? Icons.inbox_outlined;
    final effectiveIconSize = _getIconSize();
    final containerSize = _getIconContainerSize();

    // Determine icon color
    final baseColor = iconColor ?? colorScheme.primary;

    // For minimal variant, just show the icon without container
    if (variant == EmptyStateVariant.minimal) {
      return Icon(
        effectiveIcon,
        size: effectiveIconSize,
        color: baseColor.withValues(alpha: 0.6),
      );
    }

    // Container background and icon colors based on theme
    final containerColor = isPlayful
        ? PlayfulColors.primarySubtle
        : CleanColors.primarySubtle;

    final iconDisplayColor = iconColor ?? baseColor.withValues(alpha: 0.7);

    // Border radius for container
    final borderRadius = isPlayful
        ? BorderRadius.circular(containerSize / 2) // Circle for playful
        : BorderRadius.circular(AppRadius.xl); // Rounded square for clean

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: isPlayful
              ? PlayfulColors.primaryMuted
              : CleanColors.primaryMuted,
          width: 1,
        ),
      ),
      child: Center(
        child: Icon(
          effectiveIcon,
          size: effectiveIconSize,
          color: iconDisplayColor,
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, bool isPlayful) {
    final TextStyle titleStyle;

    switch (variant) {
      case EmptyStateVariant.compact:
        titleStyle = AppTypography.cardTitle(isPlayful: isPlayful);
      case EmptyStateVariant.minimal:
        titleStyle = AppTypography.cardTitle(isPlayful: isPlayful);
      case EmptyStateVariant.standard:
        titleStyle = AppTypography.sectionTitle(isPlayful: isPlayful);
      case EmptyStateVariant.large:
        titleStyle = AppTypography.pageTitle(isPlayful: isPlayful);
    }

    return Text(
      title,
      style: titleStyle.copyWith(
        color: isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage(BuildContext context, bool isPlayful) {
    final TextStyle messageStyle;

    switch (variant) {
      case EmptyStateVariant.compact:
        messageStyle = AppTypography.tertiaryText(isPlayful: isPlayful);
      case EmptyStateVariant.minimal:
        messageStyle = AppTypography.secondaryText(isPlayful: isPlayful);
      case EmptyStateVariant.standard:
        messageStyle = AppTypography.secondaryText(isPlayful: isPlayful);
      case EmptyStateVariant.large:
        messageStyle = AppTypography.primaryText(isPlayful: isPlayful);
    }

    return Padding(
      padding: AppSpacing.insetsH16,
      child: Text(
        message!,
        style: messageStyle.copyWith(
          color: isPlayful
              ? PlayfulColors.textSecondary
              : CleanColors.textSecondary,
          height: AppLineHeight.body,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isPlayful) {
    final hasPrimaryAction = actionLabel != null && onAction != null;
    final hasSecondaryAction =
        secondaryActionLabel != null && onSecondaryAction != null;

    if (!hasPrimaryAction && !hasSecondaryAction) {
      return const SizedBox.shrink();
    }

    // For compact variant, use smaller buttons
    if (variant == EmptyStateVariant.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPrimaryAction)
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                padding: AppSpacing.buttonInsetsSm,
                textStyle: AppTypography.buttonTextSmall(isPlayful: isPlayful),
              ),
              child: Text(actionLabel!),
            ),
          if (hasPrimaryAction && hasSecondaryAction)
            SizedBox(width: AppSpacing.sm),
          if (hasSecondaryAction)
            TextButton(
              onPressed: onSecondaryAction,
              style: TextButton.styleFrom(
                padding: AppSpacing.buttonInsetsSm,
                textStyle: AppTypography.buttonTextSmall(isPlayful: isPlayful),
              ),
              child: Text(secondaryActionLabel!),
            ),
        ],
      );
    }

    // For other variants, stack buttons vertically if both exist
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasPrimaryAction)
          FilledButton(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              padding: variant == EmptyStateVariant.large
                  ? AppSpacing.buttonInsetsLg
                  : AppSpacing.buttonInsetsMd,
              textStyle: variant == EmptyStateVariant.large
                  ? AppTypography.buttonTextLarge(isPlayful: isPlayful)
                  : AppTypography.buttonTextMedium(isPlayful: isPlayful),
            ),
            child: Text(actionLabel!),
          ),
        if (hasPrimaryAction && hasSecondaryAction)
          SizedBox(height: AppSpacing.sm),
        if (hasSecondaryAction)
          TextButton(
            onPressed: onSecondaryAction,
            style: TextButton.styleFrom(
              padding: variant == EmptyStateVariant.large
                  ? AppSpacing.buttonInsetsMd
                  : AppSpacing.buttonInsetsSm,
              textStyle: variant == EmptyStateVariant.large
                  ? AppTypography.buttonTextMedium(isPlayful: isPlayful)
                  : AppTypography.buttonTextSmall(isPlayful: isPlayful),
            ),
            child: Text(secondaryActionLabel!),
          ),
      ],
    );
  }
}

// =============================================================================
// EMPTY STATE VARIANTS FOR COMMON USE CASES
// =============================================================================

/// A pre-configured empty state for search results.
class SearchEmptyState extends StatelessWidget {
  const SearchEmptyState({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  /// The search query that returned no results.
  final String? searchQuery;

  /// Callback to clear the search.
  final VoidCallback? onClearSearch;

  @override
  Widget build(BuildContext context) {
    final hasQuery = searchQuery != null && searchQuery!.isNotEmpty;

    return EmptyState(
      icon: Icons.search_off_rounded,
      title: hasQuery ? 'No results for "$searchQuery"' : 'No Results Found',
      message: hasQuery
          ? 'Try adjusting your search terms or check the spelling'
          : 'We could not find what you are looking for',
      actionLabel: onClearSearch != null ? 'Clear Search' : null,
      onAction: onClearSearch,
    );
  }
}

/// A pre-configured empty state for error situations.
class ErrorEmptyState extends StatelessWidget {
  const ErrorEmptyState({
    super.key,
    this.title,
    this.message,
    this.onRetry,
  });

  /// Custom title. Defaults to "Something went wrong".
  final String? title;

  /// Custom error message.
  final String? message;

  /// Callback to retry the failed operation.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline_rounded,
      iconColor: Theme.of(context).colorScheme.error,
      title: title ?? 'Something Went Wrong',
      message: message ?? 'An unexpected error occurred. Please try again.',
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}

/// A pre-configured empty state for loading/fetching scenarios.
class LoadingEmptyState extends StatelessWidget {
  const LoadingEmptyState({
    super.key,
    this.message,
  });

  /// Custom loading message.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return EmptyState.minimal(
      icon: null,
      title: message ?? 'Loading...',
    );
  }
}

/// A pre-configured empty state for network connectivity issues.
class OfflineEmptyState extends StatelessWidget {
  const OfflineEmptyState({
    super.key,
    this.onRetry,
  });

  /// Callback to retry after connection is restored.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.wifi_off_rounded,
      title: 'No Internet Connection',
      message: 'Please check your network connection and try again',
      actionLabel: onRetry != null ? 'Retry' : null,
      onAction: onRetry,
    );
  }
}

/// A pre-configured empty state for permission denied scenarios.
class PermissionEmptyState extends StatelessWidget {
  const PermissionEmptyState({
    super.key,
    this.title,
    this.message,
    this.onRequestPermission,
  });

  /// Custom title.
  final String? title;

  /// Custom message explaining why permission is needed.
  final String? message;

  /// Callback to request the permission.
  final VoidCallback? onRequestPermission;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.lock_outline_rounded,
      title: title ?? 'Permission Required',
      message: message ?? 'This feature requires additional permissions',
      actionLabel: onRequestPermission != null ? 'Grant Permission' : null,
      onAction: onRequestPermission,
    );
  }
}
