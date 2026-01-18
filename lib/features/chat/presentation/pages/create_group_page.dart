import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/widgets.dart';

/// Page for creating a new group conversation.
///
/// Features:
/// - Group name input
/// - Member selection with search
/// - Selected members display
/// - Create group button
class CreateGroupPage extends ConsumerStatefulWidget {
  /// Creates a [CreateGroupPage] widget.
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  final Set<String> _selectedMemberIds = {};
  final Map<String, AppUser> _selectedMembers = {};

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _nameFocusNode.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final recipientsAsync = ref.watch(availableRecipientsNotifierProvider);
    final createState = ref.watch(createGroupNotifierProvider);

    final canCreate = _nameController.text.trim().isNotEmpty &&
        _selectedMemberIds.length >= 2 &&
        !createState.isCreating;

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
          'Create Group',
          style: TextStyle(
            fontSize: isPlayful ? 22 : 20,
            fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.2 : -0.3,
          ),
        ),
        actions: [
          // Create button
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: canCreate ? _createGroup : null,
              child: createState.isCreating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Text(
                      'Create',
                      style: TextStyle(
                        color: canCreate
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        fontWeight: FontWeight.w600,
                        fontSize: isPlayful ? 16 : 15,
                      ),
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
            // Group name input
            _buildGroupNameInput(theme, isPlayful),

            // Selected members
            if (_selectedMemberIds.isNotEmpty)
              _buildSelectedMembers(theme, isPlayful),

            // Search bar
            _buildSearchBar(theme, isPlayful),

            // Available members list
            Expanded(
              child: recipientsAsync.when(
                data: (recipients) => _buildMembersList(
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

  Widget _buildGroupNameInput(ThemeData theme, bool isPlayful) {
    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Group avatar preview
          Container(
            width: isPlayful ? 60 : 56,
            height: isPlayful ? 60 : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.group_rounded,
              size: isPlayful ? 30 : 28,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(width: isPlayful ? 16 : 12),

          // Name input
          Expanded(
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.words,
              style: TextStyle(
                fontSize: isPlayful ? 18 : 17,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Group name',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMembers(ThemeData theme, bool isPlayful) {
    return Container(
      height: isPlayful ? 100 : 90,
      padding: EdgeInsets.symmetric(vertical: isPlayful ? 12 : 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isPlayful ? 16 : 12),
            child: Text(
              '${_selectedMemberIds.length} members selected',
              style: TextStyle(
                fontSize: isPlayful ? 13 : 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: isPlayful ? 8 : 6),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: isPlayful ? 16 : 12),
              itemCount: _selectedMemberIds.length,
              separatorBuilder: (_, _) => SizedBox(width: isPlayful ? 12 : 8),
              itemBuilder: (context, index) {
                final memberId = _selectedMemberIds.elementAt(index);
                final member = _selectedMembers[memberId];
                if (member == null) return const SizedBox.shrink();

                return _buildSelectedMemberChip(theme, isPlayful, member);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedMemberChip(
    ThemeData theme,
    bool isPlayful,
    AppUser member,
  ) {
    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: isPlayful ? 24 : 22,
              backgroundColor: theme.colorScheme.primaryContainer,
              backgroundImage: member.avatarUrl != null
                  ? NetworkImage(member.avatarUrl!)
                  : null,
              child: member.avatarUrl == null
                  ? Text(
                      member.displayName.isNotEmpty
                          ? member.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: isPlayful ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: -2,
              top: -2,
              child: GestureDetector(
                onTap: () => _toggleMember(member),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.error,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: theme.colorScheme.onError,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: isPlayful ? 60 : 55,
          child: Text(
            // Use displayName which handles superadmin display correctly
            member.displayName.split(' ').first,
            style: TextStyle(
              fontSize: isPlayful ? 12 : 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
          hintText: 'Search members...',
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
            vertical: isPlayful ? 14 : 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMembersList(
    ThemeData theme,
    bool isPlayful,
    List<AppUser> recipients,
  ) {
    if (recipients.isEmpty) {
      return _buildEmptyState(theme, isPlayful);
    }

    // Get current user's role to filter who can be added to groups
    final currentUser = ref.watch(currentUserProvider);
    final currentUserRole = currentUser?.role;

    return ResponsiveCenterScrollView(
      maxWidth: 800,
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 12 : 8,
        vertical: isPlayful ? 4 : 2,
      ),
      child: Column(
        children: [
          ...recipients.map(
            (user) {
              // Check if current user can add this user to a group
              // Uses the centralized role hierarchy function from chat_provider.dart
              final canAdd = currentUserRole != null &&
                  canUserRoleInitiateConversation(currentUserRole, user.role);

              return Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isPlayful ? 4 : 2,
                ),
                child: RecipientTile(
                  user: user,
                  isPlayful: isPlayful,
                  isSelected: _selectedMemberIds.contains(user.id),
                  showCheckbox: true,
                  isDisabled: !canAdd,
                  // RecipientTile now uses user.displayName by default
                  onTap: () => _toggleMember(user),
                ),
              );
            },
          ),
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
              'No users found',
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
                  : 'No users available to add',
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
              'Failed to load users',
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
    if (_searchQuery.isEmpty) return recipients;

    final query = _searchQuery.toLowerCase();
    return recipients.where((user) {
      return user.displayName.toLowerCase().contains(query) ||
          user.fullName.toLowerCase().contains(query) ||
          (user.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _toggleMember(AppUser user) {
    setState(() {
      if (_selectedMemberIds.contains(user.id)) {
        _selectedMemberIds.remove(user.id);
        _selectedMembers.remove(user.id);
      } else {
        _selectedMemberIds.add(user.id);
        _selectedMembers[user.id] = user;
      }
    });
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedMemberIds.length < 2) return;

    final group = await ref.read(createGroupNotifierProvider.notifier).createGroup(
          name,
          _selectedMemberIds.toList(),
        );

    if (group != null && mounted) {
      // Navigate to the new group chat - use pushReplacement to replace
      // the create group page so back button goes to messages list
      context.pushReplacement('/chat/${group.id}?isGroup=true');
    } else {
      // Show error snackbar
      final createState = ref.read(createGroupNotifierProvider);
      if (createState.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create group: ${createState.error}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
