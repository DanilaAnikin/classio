import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.error.withValues(alpha:0.6),
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading profile',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
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
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This user may have been removed or does not exist.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 16),

          // Name
          Text(
            user.displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(theme, user.role).withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _getRoleDisplayName(user.role),
              style: TextStyle(
                color: _getRoleColor(theme, user.role),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Info Cards
          _buildInfoCard(
            theme,
            Icons.email_outlined,
            'Email',
            user.email ?? 'Not provided',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            theme,
            Icons.calendar_today_outlined,
            'Member since',
            user.createdAt != null
                ? _formatDate(user.createdAt!)
                : 'Unknown',
          ),
          const SizedBox(height: 24),

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
                padding: const EdgeInsets.symmetric(vertical: 16),
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 2),
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
    switch (role) {
      case UserRole.superadmin:
        return Colors.purple;
      case UserRole.bigadmin:
        return Colors.indigo;
      case UserRole.admin:
        return Colors.blue;
      case UserRole.teacher:
        return Colors.teal;
      case UserRole.student:
        return Colors.green;
      case UserRole.parent:
        return Colors.orange;
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
