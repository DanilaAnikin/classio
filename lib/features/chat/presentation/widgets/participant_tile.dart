import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// A tile displaying a single participant in a conversation.
///
/// Shows the participant's avatar, name, and optionally their role.
class ParticipantTile extends StatelessWidget {
  /// Creates a [ParticipantTile] widget.
  const ParticipantTile({
    super.key,
    required this.participantId,
    this.participantName,
    this.participantRole,
    this.avatarUrl,
    this.isPlayful = false,
  });

  /// The unique identifier of the participant.
  final String participantId;

  /// The display name of the participant.
  final String? participantName;

  /// The role of the participant (e.g., 'teacher', 'student').
  final String? participantRole;

  /// The URL of the participant's avatar image.
  final String? avatarUrl;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardRadius = AppRadius.getCardRadius(isPlayful: isPlayful);

    return Container(
      margin: EdgeInsets.only(bottom: isPlayful ? AppSpacing.xs : AppSpacing.xs - 2),
      padding: EdgeInsets.all(isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: cardRadius,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isPlayful ? AppIconSize.sm - 2 : AppIconSize.xs,
            backgroundColor: theme.colorScheme.primaryContainer,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    (participantName?.isNotEmpty == true)
                        ? (participantName ?? '?')[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          SizedBox(width: isPlayful ? AppSpacing.sm : AppSpacing.xs + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participantName ?? 'Unknown User',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (participantRole != null)
                  Text(
                    participantRole!.replaceAll('_', ' ').toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
