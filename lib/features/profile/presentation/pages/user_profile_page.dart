import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:classio/core/theme/app_colors.dart';
import 'package:classio/core/theme/app_radius.dart';
import 'package:classio/core/theme/spacing.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Provider that fetches a user's profile by their ID.
final userProfileProvider =
    FutureProvider.family<AppUser?, String>((ref, userId) async {
  final supabase = Supabase.instance.client;
  final response =
      await supabase.from('profiles').select().eq('id', userId).maybeSingle();

  if (response == null) return null;
  return AppUser.fromJson(response);
});

/// A read-only page for viewing another user's profile.
///
/// This page displays:
/// - Avatar
/// - Name
/// - Role badge
/// - Email
/// - Member since date
/// - Message button to start a chat
class UserProfilePage extends ConsumerWidget {
  /// Creates a [UserProfilePage].
  const UserProfilePage({super.key, required this.userId});

  /// The ID of the user whose profile is being viewed.
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(userId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: AppSpacing.dialogInsets,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: AppIconSize.xxl + AppSpacing.md,
                  color: theme.colorScheme.error.withValues(alpha:0.6),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'Error loading profile',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  err.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.md),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(userProfileProvider(userId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off_outlined,
                    size: AppIconSize.xxl + AppSpacing.md,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.3),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'User not found',
                    style: theme.textTheme.titleMedium,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'This user may have been removed or does not exist.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }
          return _buildUserProfile(context, theme, user);
        },
      ),
    );
  }

  Widget _buildUserProfile(
      BuildContext context, ThemeData theme, AppUser user) {
    return SingleChildScrollView(
      padding: AppSpacing.dialogInsets,
      child: Column(
        children: [
          // Large Avatar
          CircleAvatar(
            radius: 60,
            backgroundColor: theme.colorScheme.primary.withValues(alpha:0.2),
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 48,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : null,
          ),
          SizedBox(height: AppSpacing.md),

          // Name
          Text(
            user.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),

          // Role Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
            decoration: BoxDecoration(
              color: _getRoleColor(theme, user.role).withValues(alpha:0.1),
              borderRadius: AppRadius.dialogBorderRadius,
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: TextStyle(
                color: _getRoleColor(theme, user.role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.xxl),

          // Info Cards
          _buildInfoCard(
            theme,
            Icons.email_outlined,
            'Email',
            user.email ?? 'Not provided',
          ),
          SizedBox(height: AppSpacing.sm),
          _buildInfoCard(
            theme,
            Icons.calendar_today_outlined,
            'Member since',
            user.createdAt != null
                ? _formatDate(user.createdAt!)
                : 'Unknown',
          ),
          SizedBox(height: AppSpacing.xl),

          // Message Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to chat with this user
                context.push('/chat/${user.id}?isGroup=false');
              },
              icon: const Icon(Icons.message_outlined),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.cardBorderRadius,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppSpacing.xs),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs / 2),
                  Text(
                    value,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(ThemeData theme, UserRole role) {
    // Using CleanColors as default since this is a standalone profile page
    switch (role) {
      case UserRole.superadmin:
        return CleanColors.superadminRole;
      case UserRole.bigadmin:
        return CleanColors.principalRole;
      case UserRole.admin:
        return CleanColors.deputyRole;
      case UserRole.teacher:
        return CleanColors.teacherRole;
      case UserRole.student:
        return CleanColors.studentRole;
      case UserRole.parent:
        return CleanColors.parentRole;
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
