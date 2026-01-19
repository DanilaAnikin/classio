import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';

/// An avatar widget for group conversations.
///
/// Features:
/// - Shows group initials with deterministic background color
/// - Gradient background for playful theme
/// - Consistent styling using AppAvatar design patterns
class GroupAvatar extends StatelessWidget {
  /// Creates a [GroupAvatar] widget.
  const GroupAvatar({
    super.key,
    required this.name,
    this.size = AvatarSize.lg,
    this.isPlayful = false,
  });

  /// The name of the group (used to generate initials).
  final String name;

  /// The size of the avatar.
  final AvatarSize size;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  String _getInitials() {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'G';

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : 'G';
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  Color _getBackgroundColor() {
    // Generate consistent color based on name hash
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

  Color _getContrastingTextColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.5
        ? const Color(0xFF1C1917)
        : const Color(0xFFFAFAF9);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final initials = _getInitials();
    final textColor = _getContrastingTextColor(bgColor);

    return Container(
      width: size.pixels,
      height: size.pixels,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  bgColor.withValues(alpha: AppOpacity.almostOpaque),
                ],
              )
            : null,
        color: isPlayful ? null : bgColor,
        boxShadow: isPlayful ? AppShadows.avatar(isPlayful: true) : null,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontSize: size.initialsSize,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            letterSpacing: isPlayful ? 0.5 : 0,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// A stacked group avatar showing multiple member avatars.
///
/// Shows up to 3 member avatars in a stacked layout with
/// an optional "+N" indicator for additional members.
class StackedGroupAvatar extends StatelessWidget {
  /// Creates a [StackedGroupAvatar] widget.
  const StackedGroupAvatar({
    super.key,
    required this.memberNames,
    this.memberAvatarUrls,
    this.size = AvatarSize.lg,
    this.isPlayful = false,
    this.maxVisible = 3,
  });

  /// Names of group members.
  final List<String> memberNames;

  /// Optional avatar URLs for members (parallel to memberNames).
  final List<String?>? memberAvatarUrls;

  /// The overall size of the widget.
  final AvatarSize size;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Maximum number of avatars to show.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (memberNames.isEmpty) {
      return GroupAvatar(
        name: 'Group',
        size: size,
        isPlayful: isPlayful,
      );
    }

    if (memberNames.length == 1) {
      final avatarUrl = memberAvatarUrls?.isNotEmpty == true
          ? memberAvatarUrls![0]
          : null;

      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        return AppAvatar(
          imageUrl: avatarUrl,
          fallbackName: memberNames[0],
          size: size,
        );
      }

      return AppAvatar.initials(
        name: memberNames[0],
        size: size,
      );
    }

    // Build avatar data list for AppAvatar.group
    final avatarDataList = <AvatarData>[];
    for (var i = 0; i < memberNames.length && i < maxVisible; i++) {
      final avatarUrl = memberAvatarUrls != null && i < memberAvatarUrls!.length
          ? memberAvatarUrls![i]
          : null;

      avatarDataList.add(AvatarData(
        imageUrl: avatarUrl,
        name: memberNames[i],
      ));
    }

    return AppAvatar.group(
      avatars: avatarDataList,
      maxDisplayed: maxVisible,
      size: size,
      overlapFactor: 0.35,
      borderColor: isPlayful ? PlayfulColors.surface : CleanColors.surface,
      showShadow: isPlayful,
    );
  }
}

/// Simple stacked avatar using custom implementation for more control.
///
/// An alternative to AppAvatar.group with more visual customization options.
class CustomStackedGroupAvatar extends StatelessWidget {
  /// Creates a [CustomStackedGroupAvatar] widget.
  const CustomStackedGroupAvatar({
    super.key,
    required this.memberNames,
    this.size = AvatarSize.lg,
    this.isPlayful = false,
    this.maxVisible = 3,
  });

  /// Names of group members.
  final List<String> memberNames;

  /// The overall size of the widget.
  final AvatarSize size;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Maximum number of avatars to show.
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    if (memberNames.isEmpty) {
      return GroupAvatar(
        name: 'Group',
        size: size,
        isPlayful: isPlayful,
      );
    }

    if (memberNames.length == 1) {
      return AppAvatar.initials(
        name: memberNames[0],
        size: size,
      );
    }

    final visibleCount = memberNames.length > maxVisible
        ? maxVisible - 1
        : memberNames.length;
    final extraCount = memberNames.length - visibleCount;
    final smallSize = AvatarSize.values.firstWhere(
      (s) => s.pixels <= size.pixels * 0.65,
      orElse: () => AvatarSize.sm,
    );

    final borderColor = isPlayful ? PlayfulColors.surface : CleanColors.surface;
    final badgeBackgroundColor = isPlayful
        ? PlayfulColors.primarySubtle
        : CleanColors.primarySubtle;
    final badgeTextColor = isPlayful
        ? PlayfulColors.primary
        : CleanColors.primary;

    return SizedBox(
      width: size.pixels,
      height: size.pixels,
      child: Stack(
        children: [
          // First avatar (bottom right)
          if (memberNames.isNotEmpty)
            Positioned(
              right: 0,
              bottom: 0,
              child: _buildMemberAvatar(
                memberNames[0],
                smallSize,
                borderColor,
              ),
            ),
          // Second avatar (top left)
          if (memberNames.length > 1)
            Positioned(
              left: 0,
              top: 0,
              child: _buildMemberAvatar(
                memberNames[1],
                smallSize,
                borderColor,
              ),
            ),
          // Extra count badge
          if (extraCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: smallSize.pixels * 0.75,
                height: smallSize.pixels * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeBackgroundColor,
                  border: Border.all(
                    color: borderColor,
                    width: smallSize.borderWidth,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: TextStyle(
                      fontSize: smallSize.initialsSize * 0.7,
                      fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                      color: badgeTextColor,
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

  Widget _buildMemberAvatar(String name, AvatarSize avatarSize, Color borderColor) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: avatarSize.borderWidth,
        ),
        boxShadow: isPlayful ? AppShadows.avatar(isPlayful: true) : null,
      ),
      child: AppAvatar.initials(
        name: name,
        size: avatarSize,
      ),
    );
  }
}
