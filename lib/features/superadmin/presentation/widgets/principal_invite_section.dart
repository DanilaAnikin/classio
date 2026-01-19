import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/superadmin_provider.dart';
import 'invite_token_cards.dart';

/// Widget for displaying and managing the principal invitation code.
///
/// Allows superadmins to view, copy, and regenerate invitation codes
/// that principals use to register for a school.
class PrincipalInviteSection extends ConsumerWidget {
  const PrincipalInviteSection({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenAsync = ref.watch(schoolPrincipalTokenProvider(schoolId));
    final superAdminState = ref.watch(superAdminNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.key_rounded,
              size: isPlayful ? 24 : 20,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: isPlayful ? 8 : 6),
            Text(
              'Principal Invitation Code',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: isPlayful ? 8 : 6),
        Text(
          'Share this code with the school principal to allow them to register.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        tokenAsync.when(
          data: (token) => InviteTokenCard(
            schoolId: schoolId,
            token: token,
            isLoading: superAdminState.isLoading,
            isPlayful: isPlayful,
          ),
          loading: () => InviteTokenLoadingCard(isPlayful: isPlayful),
          error: (error, _) => InviteTokenErrorCard(
            schoolId: schoolId,
            error: error.toString(),
            isPlayful: isPlayful,
          ),
        ),
      ],
    );
  }
}
