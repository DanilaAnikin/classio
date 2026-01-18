import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/superadmin_provider.dart';

/// Page displaying all users in a specific school.
///
/// Shows a list of users with their roles, with filtering and search capabilities.
class SchoolUsersPage extends ConsumerStatefulWidget {
  const SchoolUsersPage({
    super.key,
    required this.schoolId,
  });

  final String schoolId;

  @override
  ConsumerState<SchoolUsersPage> createState() => _SchoolUsersPageState();
}

class _SchoolUsersPageState extends ConsumerState<SchoolUsersPage> {
  String _searchQuery = '';
  String? _selectedRole;

  final List<String> _roleOptions = [
    'All',
    'Principal',
    'Deputy',
    'Teacher',
    'Student',
    'Parent',
  ];

  String _getRoleValue(String displayRole) {
    switch (displayRole.toLowerCase()) {
      case 'principal':
        return 'bigadmin';
      case 'deputy':
        return 'admin';
      case 'teacher':
        return 'teacher';
      case 'student':
        return 'student';
      case 'parent':
        return 'parent';
      default:
        return '';
    }
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return 'Super Admin';
      case UserRole.bigadmin:
        return 'Principal';
      case UserRole.admin:
        return 'Deputy';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superadmin:
        return Colors.purple;
      case UserRole.bigadmin:
        return Colors.blue;
      case UserRole.admin:
        return Colors.teal;
      case UserRole.teacher:
        return Colors.green;
      case UserRole.student:
        return Colors.orange;
      case UserRole.parent:
        return Colors.pink;
    }
  }

  List<AppUser> _filterUsers(List<AppUser> users) {
    return users.where((user) {
      // Filter by role
      if (_selectedRole != null && _selectedRole != 'All') {
        final roleValue = _getRoleValue(_selectedRole!);
        if (user.role.name != roleValue) {
          return false;
        }
      }

      // Filter by search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.toLowerCase();
        if (!fullName.contains(query)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final usersAsync = ref.watch(schoolUsersProvider(widget.schoolId));
    final schoolAsync = ref.watch(schoolDetailProvider(widget.schoolId));

    return Scaffold(
      appBar: AppBar(
        title: schoolAsync.when(
          data: (school) => Text('${school.name} - Users'),
          loading: () => const Text('Users'),
          error: (_, _) => const Text('Users'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
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
            child: Column(
              children: [
                // Search TextField
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(isPlayful ? 16 : 8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Role Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _roleOptions.map((role) {
                      final isSelected = _selectedRole == role ||
                          (_selectedRole == null && role == 'All');
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(role),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedRole = selected ? role : 'All';
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(isPlayful ? 16 : 8),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Users List
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = _filterUsers(users);

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          users.isEmpty
                              ? 'No users in this school'
                              : 'No users match your search',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(schoolUsersProvider(widget.schoolId));
                  },
                  child: ResponsiveCenterScrollView(
                    maxWidth: 800,
                    padding: EdgeInsets.all(isPlayful ? 16 : 12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User count
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            '${filteredUsers.length} user${filteredUsers.length == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Users list
                        ...filteredUsers.map((user) =>
                            _buildUserCard(context, user, isPlayful)),
                        SizedBox(height: isPlayful ? 80 : 72),
                      ],
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load users',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          ref.invalidate(schoolUsersProvider(widget.schoolId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, AppUser user, bool isPlayful) {
    final theme = Theme.of(context);
    final roleColor = _getRoleColor(user.role);

    return Card(
      margin: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isPlayful ? 16 : 12,
          vertical: isPlayful ? 8 : 4,
        ),
        leading: CircleAvatar(
          backgroundColor: roleColor.withValues(alpha: 0.2),
          child: user.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    user.avatarUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.person,
                      color: roleColor,
                    ),
                  ),
                )
              : Icon(
                  Icons.person,
                  color: roleColor,
                ),
        ),
        title: Text(
          user.fullName.isNotEmpty ? user.fullName : 'No Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _getRoleDisplayName(user.role),
          style: theme.textTheme.bodySmall?.copyWith(
            color: roleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getRoleDisplayName(user.role),
            style: theme.textTheme.labelSmall?.copyWith(
              color: roleColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
