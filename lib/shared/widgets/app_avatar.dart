import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

// =============================================================================
// APP AVATAR COMPONENT
// =============================================================================
// A premium, reusable avatar component that supports multiple variants,
// sizes, and theme-aware styling. Designed for consistency across the app.
//
// ## Features:
// - Multiple variants: image, initials, icon, group
// - Six size options from xs (24px) to xxl (80px)
// - Theme-aware styling (Clean vs Playful)
// - Badge support with configurable positioning
// - Smooth loading states and error fallbacks
// - Group avatars with overlap and "+N more" indicator
// - Optional shadow and border customization
// - Tap callback support
//
// ## Usage Examples:
//
// ### Basic Image Avatar
// ```dart
// AppAvatar(
//   imageUrl: 'https://example.com/photo.jpg',
//   size: AvatarSize.md,
// )
// ```
//
// ### Initials Avatar
// ```dart
// AppAvatar.initials(
//   name: 'John Doe',
//   size: AvatarSize.lg,
//   backgroundColor: Colors.blue,
// )
// ```
//
// ### Icon Avatar
// ```dart
// AppAvatar.icon(
//   icon: Icons.person,
//   size: AvatarSize.md,
// )
// ```
//
// ### Avatar with Badge (Online Indicator)
// ```dart
// AppAvatar(
//   imageUrl: 'https://example.com/photo.jpg',
//   badge: Container(
//     width: 12,
//     height: 12,
//     decoration: BoxDecoration(
//       color: Colors.green,
//       shape: BoxShape.circle,
//       border: Border.all(color: Colors.white, width: 2),
//     ),
//   ),
//   badgePosition: BadgePosition.bottomRight,
// )
// ```
//
// ### Group Avatar (Overlapping Avatars)
// ```dart
// AppAvatar.group(
//   avatars: [
//     AvatarData(imageUrl: 'https://example.com/1.jpg'),
//     AvatarData(name: 'Jane Doe'),
//     AvatarData(imageUrl: 'https://example.com/3.jpg'),
//   ],
//   maxDisplayed: 3,
//   size: AvatarSize.sm,
// )
// ```
//
// ### Image Avatar with Fallback to Initials
// ```dart
// AppAvatar(
//   imageUrl: 'https://example.com/photo.jpg',
//   fallbackName: 'John Doe', // Shows "JD" if image fails
//   size: AvatarSize.md,
// )
// ```
// =============================================================================

/// Avatar size options following a consistent scale.
enum AvatarSize {
  /// Extra small - 24px (compact lists, inline)
  xs(24),

  /// Small - 32px (list items, chips)
  sm(32),

  /// Medium - 40px (default, cards, tiles)
  md(40),

  /// Large - 48px (profile sections)
  lg(48),

  /// Extra large - 64px (profile headers)
  xl(64),

  /// Extra extra large - 80px (hero sections)
  xxl(80);

  const AvatarSize(this.pixels);

  /// The size in pixels
  final double pixels;

  /// Get icon size appropriate for this avatar size
  double get iconSize {
    switch (this) {
      case AvatarSize.xs:
        return 14;
      case AvatarSize.sm:
        return 16;
      case AvatarSize.md:
        return 20;
      case AvatarSize.lg:
        return 24;
      case AvatarSize.xl:
        return 32;
      case AvatarSize.xxl:
        return 40;
    }
  }

  /// Get font size for initials appropriate for this avatar size
  double get initialsSize {
    switch (this) {
      case AvatarSize.xs:
        return 10;
      case AvatarSize.sm:
        return 12;
      case AvatarSize.md:
        return 14;
      case AvatarSize.lg:
        return 16;
      case AvatarSize.xl:
        return 22;
      case AvatarSize.xxl:
        return 28;
    }
  }

  /// Get border width appropriate for this avatar size
  double get borderWidth {
    switch (this) {
      case AvatarSize.xs:
      case AvatarSize.sm:
        return 1.5;
      case AvatarSize.md:
      case AvatarSize.lg:
        return 2.0;
      case AvatarSize.xl:
      case AvatarSize.xxl:
        return 2.5;
    }
  }
}

/// Badge position options for the avatar badge.
enum BadgePosition {
  /// Top right corner
  topRight,

  /// Bottom right corner
  bottomRight,

  /// Top left corner
  topLeft,

  /// Bottom left corner
  bottomLeft,
}

/// Data class for individual avatars in a group.
class AvatarData {
  const AvatarData({
    this.imageUrl,
    this.name,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  }) : assert(
         imageUrl != null || name != null || icon != null,
         'At least one of imageUrl, name, or icon must be provided',
       );

  /// URL of the avatar image
  final String? imageUrl;

  /// Name for generating initials (fallback or primary)
  final String? name;

  /// Icon to display (fallback or primary)
  final IconData? icon;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color (for initials/icon)
  final Color? foregroundColor;
}

/// A premium, reusable avatar component with multiple variants.
class AppAvatar extends StatelessWidget {
  /// Creates an image-based avatar with optional fallback.
  const AppAvatar({
    super.key,
    required this.imageUrl,
    this.fallbackName,
    this.fallbackIcon,
    this.size = AvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.badge,
    this.badgePosition = BadgePosition.bottomRight,
    this.showShadow = false,
    this.heroTag,
  })  : _variant = _AvatarVariant.image,
        name = null,
        icon = null,
        avatars = null,
        maxDisplayed = null,
        overlapFactor = null;

  /// Creates an initials-based avatar from a name.
  const AppAvatar.initials({
    super.key,
    required this.name,
    this.size = AvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.badge,
    this.badgePosition = BadgePosition.bottomRight,
    this.showShadow = false,
    this.heroTag,
  })  : _variant = _AvatarVariant.initials,
        imageUrl = null,
        fallbackName = null,
        fallbackIcon = null,
        icon = null,
        avatars = null,
        maxDisplayed = null,
        overlapFactor = null;

  /// Creates an icon-based avatar.
  const AppAvatar.icon({
    super.key,
    required this.icon,
    this.size = AvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.badge,
    this.badgePosition = BadgePosition.bottomRight,
    this.showShadow = false,
    this.heroTag,
  })  : _variant = _AvatarVariant.icon,
        imageUrl = null,
        fallbackName = null,
        fallbackIcon = null,
        name = null,
        avatars = null,
        maxDisplayed = null,
        overlapFactor = null;

  /// Creates a group of overlapping avatars.
  const AppAvatar.group({
    super.key,
    required this.avatars,
    this.maxDisplayed = 3,
    this.overlapFactor = 0.3,
    this.size = AvatarSize.md,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.showShadow = false,
  })  : _variant = _AvatarVariant.group,
        imageUrl = null,
        fallbackName = null,
        fallbackIcon = null,
        name = null,
        icon = null,
        badge = null,
        badgePosition = BadgePosition.bottomRight,
        heroTag = null;

  final _AvatarVariant _variant;

  // Image variant properties
  /// URL of the avatar image
  final String? imageUrl;

  /// Fallback name for initials if image fails to load
  final String? fallbackName;

  /// Fallback icon if image fails to load
  final IconData? fallbackIcon;

  // Initials variant properties
  /// Name to extract initials from
  final String? name;

  // Icon variant properties
  /// Icon to display
  final IconData? icon;

  // Group variant properties
  /// List of avatar data for group display
  final List<AvatarData>? avatars;

  /// Maximum number of avatars to display before showing "+N"
  final int? maxDisplayed;

  /// How much avatars overlap (0.0 = no overlap, 1.0 = full overlap)
  final double? overlapFactor;

  // Common properties
  /// Size of the avatar
  final AvatarSize size;

  /// Custom background color (overrides theme default)
  final Color? backgroundColor;

  /// Custom foreground color for initials/icon (overrides theme default)
  final Color? foregroundColor;

  /// Border color (null for no border)
  final Color? borderColor;

  /// Border width (uses size-appropriate default if null)
  final double? borderWidth;

  /// Callback when avatar is tapped
  final VoidCallback? onTap;

  /// Widget to display as a badge (e.g., online indicator)
  final Widget? badge;

  /// Position of the badge
  final BadgePosition badgePosition;

  /// Whether to show a subtle shadow
  final bool showShadow;

  /// Hero animation tag for transitions
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayfulTheme(context);

    Widget avatar;
    switch (_variant) {
      case _AvatarVariant.image:
        avatar = _buildImageAvatar(context, isPlayful);
      case _AvatarVariant.initials:
        avatar = _buildInitialsAvatar(context, isPlayful);
      case _AvatarVariant.icon:
        avatar = _buildIconAvatar(context, isPlayful);
      case _AvatarVariant.group:
        return _buildGroupAvatar(context, isPlayful);
    }

    // Wrap with badge if provided
    if (badge != null) {
      avatar = _wrapWithBadge(avatar);
    }

    // Wrap with Hero if tag provided
    if (heroTag != null) {
      avatar = Hero(tag: heroTag!, child: avatar);
    }

    // Wrap with tap handler if provided
    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildImageAvatar(BuildContext context, bool isPlayful) {
    return _AvatarContainer(
      size: size,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      showShadow: showShadow,
      isPlayful: isPlayful,
      child: ClipOval(
        child: Image.network(
          imageUrl!,
          width: size.pixels,
          height: size.pixels,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return _buildLoadingPlaceholder(context, isPlayful);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorFallback(context, isPlayful);
          },
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar(BuildContext context, bool isPlayful) {
    final initials = _extractInitials(name!);
    final bgColor = backgroundColor ?? _getDefaultBackgroundColor(name!, isPlayful);
    final fgColor = foregroundColor ?? _getContrastingTextColor(bgColor);

    return _AvatarContainer(
      size: size,
      backgroundColor: bgColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      showShadow: showShadow,
      isPlayful: isPlayful,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size.initialsSize,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: fgColor,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildIconAvatar(BuildContext context, bool isPlayful) {
    final bgColor = backgroundColor ??
        (isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle);
    final fgColor = foregroundColor ??
        (isPlayful ? PlayfulColors.primary : CleanColors.primary);

    return _AvatarContainer(
      size: size,
      backgroundColor: bgColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      showShadow: showShadow,
      isPlayful: isPlayful,
      child: Center(
        child: Icon(
          icon,
          size: size.iconSize,
          color: fgColor,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context, bool isPlayful) {
    // Simple shimmer-like placeholder
    return Container(
      width: size.pixels,
      height: size.pixels,
      decoration: BoxDecoration(
        color: isPlayful ? PlayfulColors.surfaceSubtle : CleanColors.surfaceSubtle,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size.iconSize * 0.8,
          height: size.iconSize * 0.8,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              isPlayful ? PlayfulColors.primary : CleanColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorFallback(BuildContext context, bool isPlayful) {
    // Try fallback to initials
    if (fallbackName != null && fallbackName!.isNotEmpty) {
      final initials = _extractInitials(fallbackName!);
      final bgColor = backgroundColor ??
          _getDefaultBackgroundColor(fallbackName!, isPlayful);
      final fgColor = foregroundColor ?? _getContrastingTextColor(bgColor);

      return Container(
        width: size.pixels,
        height: size.pixels,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initials,
            style: TextStyle(
              fontSize: size.initialsSize,
              fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
              color: fgColor,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ),
      );
    }

    // Try fallback to icon
    if (fallbackIcon != null) {
      final bgColor = backgroundColor ??
          (isPlayful ? PlayfulColors.surfaceSubtle : CleanColors.surfaceSubtle);
      final fgColor = foregroundColor ??
          (isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary);

      return Container(
        width: size.pixels,
        height: size.pixels,
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            fallbackIcon,
            size: size.iconSize,
            color: fgColor,
          ),
        ),
      );
    }

    // Default fallback - person icon
    final bgColor = backgroundColor ??
        (isPlayful ? PlayfulColors.surfaceSubtle : CleanColors.surfaceSubtle);
    final fgColor = foregroundColor ??
        (isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary);

    return Container(
      width: size.pixels,
      height: size.pixels,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: size.iconSize,
          color: fgColor,
        ),
      ),
    );
  }

  Widget _buildGroupAvatar(BuildContext context, bool isPlayful) {
    final displayedAvatars = avatars!.take(maxDisplayed!).toList();
    final remainingCount = avatars!.length - maxDisplayed!;
    final overlap = size.pixels * (overlapFactor ?? 0.3);

    // Calculate total width
    final totalWidth = size.pixels +
        (displayedAvatars.length - 1) * (size.pixels - overlap) +
        (remainingCount > 0 ? (size.pixels - overlap) : 0);

    final borderClr = borderColor ??
        (isPlayful ? PlayfulColors.surface : CleanColors.surface);

    return SizedBox(
      width: totalWidth,
      height: size.pixels,
      child: Stack(
        children: [
          // Build individual avatars in reverse order for proper stacking
          ...displayedAvatars.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final left = index * (size.pixels - overlap);

            return Positioned(
              left: left,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderClr,
                    width: borderWidth ?? size.borderWidth,
                  ),
                  boxShadow: showShadow
                      ? AppShadows.avatar(isPlayful: isPlayful)
                      : null,
                ),
                child: ClipOval(
                  child: _buildGroupAvatarItem(data, isPlayful),
                ),
              ),
            );
          }),

          // Show "+N" indicator if there are more avatars
          if (remainingCount > 0)
            Positioned(
              left: displayedAvatars.length * (size.pixels - overlap),
              child: Container(
                width: size.pixels,
                height: size.pixels,
                decoration: BoxDecoration(
                  color: isPlayful
                      ? PlayfulColors.primarySubtle
                      : CleanColors.primarySubtle,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderClr,
                    width: borderWidth ?? size.borderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$remainingCount',
                    style: TextStyle(
                      fontSize: size.initialsSize * 0.9,
                      fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                      color: isPlayful
                          ? PlayfulColors.primary
                          : CleanColors.primary,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatarItem(AvatarData data, bool isPlayful) {
    // Priority: image > initials > icon
    if (data.imageUrl != null && data.imageUrl!.isNotEmpty) {
      return Image.network(
        data.imageUrl!,
        width: size.pixels,
        height: size.pixels,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (data.name != null) {
            return _buildGroupInitials(data, isPlayful);
          }
          if (data.icon != null) {
            return _buildGroupIcon(data, isPlayful);
          }
          return _buildGroupDefaultIcon(isPlayful);
        },
      );
    }

    if (data.name != null && data.name!.isNotEmpty) {
      return _buildGroupInitials(data, isPlayful);
    }

    if (data.icon != null) {
      return _buildGroupIcon(data, isPlayful);
    }

    return _buildGroupDefaultIcon(isPlayful);
  }

  Widget _buildGroupInitials(AvatarData data, bool isPlayful) {
    final initials = _extractInitials(data.name!);
    final bgColor = data.backgroundColor ??
        _getDefaultBackgroundColor(data.name!, isPlayful);
    final fgColor = data.foregroundColor ?? _getContrastingTextColor(bgColor);

    return Container(
      width: size.pixels,
      height: size.pixels,
      color: bgColor,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size.initialsSize,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: fgColor,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupIcon(AvatarData data, bool isPlayful) {
    final bgColor = data.backgroundColor ??
        (isPlayful ? PlayfulColors.surfaceSubtle : CleanColors.surfaceSubtle);
    final fgColor = data.foregroundColor ??
        (isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary);

    return Container(
      width: size.pixels,
      height: size.pixels,
      color: bgColor,
      child: Center(
        child: Icon(
          data.icon,
          size: size.iconSize,
          color: fgColor,
        ),
      ),
    );
  }

  Widget _buildGroupDefaultIcon(bool isPlayful) {
    return Container(
      width: size.pixels,
      height: size.pixels,
      color: isPlayful
          ? PlayfulColors.surfaceSubtle
          : CleanColors.surfaceSubtle,
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: size.iconSize,
          color: isPlayful
              ? PlayfulColors.textTertiary
              : CleanColors.textTertiary,
        ),
      ),
    );
  }

  Widget _wrapWithBadge(Widget avatar) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          top: badgePosition == BadgePosition.topRight ||
                  badgePosition == BadgePosition.topLeft
              ? -2
              : null,
          bottom: badgePosition == BadgePosition.bottomRight ||
                  badgePosition == BadgePosition.bottomLeft
              ? -2
              : null,
          right: badgePosition == BadgePosition.topRight ||
                  badgePosition == BadgePosition.bottomRight
              ? -2
              : null,
          left: badgePosition == BadgePosition.topLeft ||
                  badgePosition == BadgePosition.bottomLeft
              ? -2
              : null,
          child: badge!,
        ),
      ],
    );
  }

  // ==========================================================================
  // HELPER METHODS
  // ==========================================================================

  /// Determines if the current theme is playful
  bool _isPlayfulTheme(BuildContext context) {
    // Try to detect from theme brightness and primary color
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // Check if it's the playful violet color
    return _colorsEqual(primaryColor, PlayfulColors.primary) ||
        primaryColor.toARGB32() == 0xFF7C3AED;
  }

  /// Compare two colors for equality using ARGB values
  static bool _colorsEqual(Color a, Color b) {
    return a.toARGB32() == b.toARGB32();
  }

  /// Extracts up to 2 initials from a name
  String _extractInitials(String name) {
    if (name.isEmpty) return '';

    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';

    if (parts.length == 1) {
      // Single word - take first two characters or just the first
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }

    // Multiple words - take first letter of first and last word
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Generates a deterministic background color based on the name
  Color _getDefaultBackgroundColor(String name, bool isPlayful) {
    // Use a simple hash to pick a color from a curated palette
    final hash = name.toLowerCase().codeUnits.fold(0, (sum, char) => sum + char);

    final cleanPalette = [
      CleanColors.statBlue,
      CleanColors.statGreen,
      CleanColors.statOrange,
      CleanColors.statPurple,
      CleanColors.statPink,
      CleanColors.statTeal,
      CleanColors.statIndigo,
      CleanColors.statAmber,
    ];

    final playfulPalette = [
      PlayfulColors.statBlue,
      PlayfulColors.statGreen,
      PlayfulColors.statOrange,
      PlayfulColors.statPurple,
      PlayfulColors.statPink,
      PlayfulColors.statTeal,
      PlayfulColors.accentCyan,
      PlayfulColors.accentYellow,
    ];

    final palette = isPlayful ? playfulPalette : cleanPalette;
    return palette[hash % palette.length];
  }

  /// Gets a contrasting text color for the given background
  Color _getContrastingTextColor(Color background) {
    // Calculate relative luminance
    final luminance = background.computeLuminance();

    // Use white text for dark backgrounds, dark text for light backgrounds
    return luminance > 0.5 ? const Color(0xFF1C1917) : const Color(0xFFFAFAF9);
  }
}

// =============================================================================
// INTERNAL AVATAR CONTAINER
// =============================================================================

class _AvatarContainer extends StatelessWidget {
  const _AvatarContainer({
    required this.size,
    required this.child,
    required this.isPlayful,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.showShadow = false,
  });

  final AvatarSize size;
  final Widget child;
  final bool isPlayful;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.pixels,
      height: size.pixels,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null
            ? Border.all(
                color: borderColor!,
                width: borderWidth ?? size.borderWidth,
              )
            : null,
        boxShadow: showShadow ? AppShadows.avatar(isPlayful: isPlayful) : null,
      ),
      child: ClipOval(child: child),
    );
  }
}

/// Internal variant enum
enum _AvatarVariant {
  image,
  initials,
  icon,
  group,
}

// =============================================================================
// CONVENIENCE WIDGETS
// =============================================================================

/// A pre-styled online indicator badge for use with AppAvatar.
///
/// Usage:
/// ```dart
/// AppAvatar(
///   imageUrl: 'https://example.com/photo.jpg',
///   badge: OnlineIndicator(isOnline: true),
/// )
/// ```
class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({
    super.key,
    required this.isOnline,
    this.size = 12,
  });

  /// Whether the user is online
  final bool isOnline;

  /// Size of the indicator
  final double size;

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayfulTheme(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isOnline
            ? (isPlayful ? PlayfulColors.success : CleanColors.success)
            : (isPlayful ? PlayfulColors.textMuted : CleanColors.textMuted),
        shape: BoxShape.circle,
        border: Border.all(
          color: isPlayful ? PlayfulColors.surface : CleanColors.surface,
          width: 2,
        ),
      ),
    );
  }

  bool _isPlayfulTheme(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        primaryColor.toARGB32() == 0xFF7C3AED;
  }
}

/// A notification count badge for use with AppAvatar.
///
/// Usage:
/// ```dart
/// AppAvatar(
///   imageUrl: 'https://example.com/photo.jpg',
///   badge: NotificationBadge(count: 5),
///   badgePosition: BadgePosition.topRight,
/// )
/// ```
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.size = 18,
  });

  /// Number of notifications
  final int count;

  /// Maximum count to display (shows "99+" if exceeded)
  final int maxCount;

  /// Size of the badge
  final double size;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final isPlayful = _isPlayfulTheme(context);
    final displayCount = count > maxCount ? '$maxCount+' : '$count';

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isPlayful ? PlayfulColors.error : CleanColors.error,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(
          color: isPlayful ? PlayfulColors.surface : CleanColors.surface,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            fontSize: size * 0.55,
            fontWeight: FontWeight.w600,
            color: isPlayful ? PlayfulColors.onError : CleanColors.onError,
            height: 1.0,
          ),
        ),
      ),
    );
  }

  bool _isPlayfulTheme(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        primaryColor.toARGB32() == 0xFF7C3AED;
  }
}
