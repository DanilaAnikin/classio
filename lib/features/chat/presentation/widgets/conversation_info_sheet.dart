import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_avatar.dart';
import '../../domain/entities/entities.dart';
import '../providers/chat_provider.dart';
import 'group_avatar.dart';
import 'info_section.dart';
import 'members_section.dart';

/// A bottom sheet that displays conversation information.
///
/// Shows conversation details including name, avatar, type,
/// creation date, and participant list for groups.
class ConversationInfoSheet extends ConsumerWidget {
  /// Creates a [ConversationInfoSheet] widget.
  const ConversationInfoSheet({
    super.key,
    required this.conversation,
    this.isPlayful = false,
  });

  /// The conversation to display info for.
  final ConversationEntity conversation;

  /// Whether to use playful theme styling.
  final bool isPlayful;

  /// Shows the conversation info sheet as a modal bottom sheet.
  static void show(
    BuildContext context, {
    required ConversationEntity conversation,
    bool isPlayful = false,
  }) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isPlayful ? AppRadius.xl : AppRadius.lg),
        ),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _ConversationInfoContent(
          conversation: conversation,
          scrollController: scrollController,
          isPlayful: isPlayful,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This build method is used when the widget is used directly
    // For the modal sheet, use ConversationInfoSheet.show()
    return const SizedBox.shrink();
  }
}

/// The content of the conversation info sheet.
class _ConversationInfoContent extends ConsumerWidget {
  const _ConversationInfoContent({
    required this.conversation,
    required this.scrollController,
    this.isPlayful = false,
  });

  final ConversationEntity conversation;
  final ScrollController scrollController;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // For group conversations, fetch member details
    if (conversation.isGroup) {
      return FutureBuilder<MessageGroupEntity?>(
        future: ref.read(chatRepositoryProvider).getGroup(conversation.id),
        builder: (context, snapshot) {
          final group = snapshot.data;
          final members = group?.members ?? [];
          final memberCount = members.isNotEmpty
              ? members.length
              : conversation.participantIds.length;

          return _buildScrollView(
            theme: theme,
            memberCount: memberCount,
            membersWidget: MembersSection(
              members: members,
              participantIds: conversation.participantIds,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              isPlayful: isPlayful,
            ),
          );
        },
      );
    }

    // For direct messages, no need to fetch members
    return _buildScrollView(
      theme: theme,
      memberCount: conversation.participantIds.length,
      membersWidget: null,
    );
  }

  Widget _buildScrollView({
    required ThemeData theme,
    required int memberCount,
    required Widget? membersWidget,
  }) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.all(isPlayful ? AppSpacing.xl : AppSpacing.lg + 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: AppSpacing.lg + 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: AppOpacity.medium + 0.14),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Avatar and name
          _buildHeader(theme),

          SizedBox(height: isPlayful ? AppSpacing.xxl : AppSpacing.xl),

          // Info sections
          InfoSection(
            icon: Icons.people_outline_rounded,
            title: 'Participants',
            value: '$memberCount member${memberCount != 1 ? 's' : ''}',
            isPlayful: isPlayful,
          ),

          if (conversation.createdAt != null)
            InfoSection(
              icon: Icons.calendar_today_rounded,
              title: 'Created',
              value: DateFormat.yMMMMd().format(conversation.createdAt ?? DateTime.now()),
              isPlayful: isPlayful,
            ),

          InfoSection(
            icon: conversation.isGroup
                ? Icons.group_rounded
                : Icons.person_rounded,
            title: 'Type',
            value: conversation.isGroup ? 'Group Chat' : 'Direct Message',
            isPlayful: isPlayful,
          ),

          SizedBox(height: isPlayful ? AppSpacing.xl : AppSpacing.lg + 4),

          // Participants list (for groups)
          if (membersWidget != null) membersWidget,
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          if (conversation.isGroup)
            GroupAvatar(
              name: conversation.name,
              size: isPlayful ? AvatarSize.xxl : AvatarSize.xl,
              isPlayful: isPlayful,
            )
          else
            CircleAvatar(
              radius: isPlayful ? 40 : 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: conversation.avatarUrl != null
                  ? NetworkImage(conversation.avatarUrl ?? '')
                  : null,
              child: conversation.avatarUrl == null
                  ? Text(
                      conversation.name.isNotEmpty
                          ? conversation.name[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
          SizedBox(height: isPlayful ? AppSpacing.md : AppSpacing.sm),
          Text(
            conversation.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (conversation.isGroup && conversation.groupType != null)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.xxs),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  (conversation.groupType ?? '').toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
