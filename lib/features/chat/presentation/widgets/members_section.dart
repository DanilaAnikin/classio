import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../domain/entities/entities.dart';
import 'participant_tile.dart';

/// A section displaying the list of group members.
///
/// Shows a loading indicator while fetching, member tiles when loaded,
/// or falls back to participant IDs when member details are unavailable.
class MembersSection extends StatelessWidget {
  /// Creates a [MembersSection] widget.
  const MembersSection({
    super.key,
    required this.members,
    required this.participantIds,
    this.isLoading = false,
    this.isPlayful = false,
  });

  /// The list of group members with full details.
  final List<GroupMemberEntity> members;

  /// The list of participant IDs (fallback when member details unavailable).
  final List<String> participantIds;

  /// Whether member details are currently loading.
  final bool isLoading;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Members',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isPlayful ? AppSpacing.sm : AppSpacing.xs),
        if (isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
          )
        else if (members.isNotEmpty)
          ...members.map(
            (member) => ParticipantTile(
              participantId: member.userId,
              participantName: member.userName,
              participantRole: member.userRole,
              avatarUrl: member.avatarUrl,
              isPlayful: isPlayful,
            ),
          )
        else
          // Fallback to participant IDs when no member details available
          ...participantIds.map(
            (id) => ParticipantTile(
              participantId: id,
              isPlayful: isPlayful,
            ),
          ),
      ],
    );
  }
}
