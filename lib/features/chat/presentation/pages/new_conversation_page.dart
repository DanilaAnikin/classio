import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/widgets.dart';

/// Page for starting a new conversation.
///
/// Features:
/// - Search for users
/// - Filter by role
/// - Recent conversations shortcut
/// - Create group option
class NewConversationPage extends ConsumerStatefulWidget {
  /// Creates a [NewConversationPage] widget.
  const NewConversationPage({super.key});

  @override
  ConsumerState<NewConversationPage> createState() =>
      _NewConversationPageState();
}

class _NewConversationPageState extends ConsumerState<NewConversationPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final recipientsAsync = ref.watch(availableRecipientsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isPlayful
            ? theme.colorScheme.surface.withValues(alpha: 0.95)
            : theme.colorScheme.surface,
        elevation: isPlayful ? 0 : 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'New Message',
          style: TextStyle(
            fontSize: isPlayful ? 22 : 20,
            fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.2 : -0.3,
          ),
        ),
        actions: [
          // Create group button
          TextButton.icon(
            onPressed: () => context.push('/chat/create-group'),
            icon: Icon(
              Icons.group_add_rounded,
              color: theme.colorScheme.primary,
              size: isPlayful ? 22 : 20,
            ),
            label: Text(
              'Group',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.02),
                    theme.colorScheme.secondary.withValues(alpha: 0.02),
                  ],
                ),
              )
            : null,
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(theme, isPlayful),

            // Role filter chips
            _buildRoleFilters(theme, isPlayful),

            // Recipients list
            Expanded(
              child: recipientsAsync.when(
                data: (recipients) => _buildRecipientsList(
                  theme,
                  isPlayful,
                  _filterRecipients(recipients),
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => _buildErrorState(
                  theme,
                  isPlayful,
                  error.toString(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isPlayful) {
    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: TextStyle(
          fontSize: isPlayful ? 16 : 15,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or email...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 20 : 16,
            vertical: isPlayful ? 16 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRoleFilters(ThemeData theme, bool isPlayful) {
    final roles = [
      null, // All
      UserRole.teacher,
      UserRole.student,
      UserRole.admin,
      UserRole.parent,
    ];

    return SizedBox(
      height: isPlayful ? 48 : 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isPlayful ? 16 : 12),
        itemCount: roles.length,
        separatorBuilder: (_, _) => SizedBox(width: isPlayful ? 10 : 8),
        itemBuilder: (context, index) {
          final role = roles[index];
          final isSelected = _selectedRoleFilter == role;
          final label = role == null ? 'All' : _getRoleLabel(role);

          return FilterChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: isPlayful ? 14 : 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedRoleFilter = selected ? role : null;
              });
            },
            selectedColor: theme.colorScheme.primary,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            checkmarkColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: isPlayful ? 4 : 2,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipientsList(
    ThemeData theme,
    bool isPlayful,
    List<AppUser> recipients,
  ) {
    // Get current user's role to filter recipients by hierarchy
    final currentUser = ref.watch(currentUserProvider);
    final currentUserRole = currentUser?.role;

    // Filter recipients: only show users the current user CAN message
    // Using the centralized role hierarchy function from chat_provider.dart
    final messageableRecipients = currentUserRole != null
        ? recipients
            .where((user) => canUserRoleInitiateConversation(currentUserRole, user.role))
            .toList()
        : recipients;

    if (messageableRecipients.isEmpty) {
      return _buildEmptyState(theme, isPlayful);
    }

    // Group recipients by role
    final groupedRecipients = <UserRole, List<AppUser>>{};
    for (final recipient in messageableRecipients) {
      groupedRecipients.putIfAbsent(recipient.role, () => []).add(recipient);
    }

    // Sort roles by hierarchy (using the centralized hierarchy)
    final sortedRoles = groupedRecipients.keys.toList()
      ..sort((a, b) => getUserRoleHierarchyLevel(a).compareTo(getUserRoleHierarchyLevel(b)));

    return ResponsiveCenterScrollView(
      maxWidth: 800,
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 12 : 8,
        vertical: isPlayful ? 8 : 4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final role in sortedRoles) ...[
            RecipientSectionHeader(
              title: _getRolePluralLabel(role),
              count: groupedRecipients[role]!.length,
              isPlayful: isPlayful,
            ),
            ...groupedRecipients[role]!.map(
              (user) => Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isPlayful ? 4 : 2,
                ),
                child: RecipientTile(
                  user: user,
                  isPlayful: isPlayful,
                  onTap: () => _startConversation(user),
                  // No need for displayNameOverride - RecipientTile now uses user.displayName
                ),
              ),
            ),
            SizedBox(height: isPlayful ? 16 : 12),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isPlayful) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isPlayful ? 24 : 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.person_search_rounded,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: isPlayful ? 24 : 20),
            Text(
              'No recipients found',
              style: TextStyle(
                fontSize: isPlayful ? 20 : 18,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Try a different search term'
                  : 'No users available to message',
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, bool isPlayful, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 64 : 56,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: isPlayful ? 20 : 16),
            Text(
              'Failed to load recipients',
              style: TextStyle(
                fontSize: isPlayful ? 18 : 16,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(availableRecipientsNotifierProvider.notifier)
                    .refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<AppUser> _filterRecipients(List<AppUser> recipients) {
    var filtered = recipients;

    // Filter by search query - search both displayName and fullName for flexibility
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        return user.displayName.toLowerCase().contains(query) ||
            user.fullName.toLowerCase().contains(query) ||
            (user.email?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Filter by role
    if (_selectedRoleFilter != null) {
      filtered =
          filtered.where((user) => user.role == _selectedRoleFilter).toList();
    }

    return filtered;
  }

  String _getRoleLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
      case UserRole.admin:
        return 'Administrator';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  String _getRolePluralLabel(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admins';
      case UserRole.bigadmin:
        return 'Principals';
      case UserRole.admin:
        return 'Administrators';
      case UserRole.teacher:
        return 'Teachers';
      case UserRole.student:
        return 'Students';
      case UserRole.parent:
        return 'Parents';
    }
  }

  void _startConversation(AppUser user) {
    // Navigate to chat page with the user's ID
    // The chat page will handle creating the conversation if needed
    context.push('/chat/${user.id}?isGroup=false');
  }
}
