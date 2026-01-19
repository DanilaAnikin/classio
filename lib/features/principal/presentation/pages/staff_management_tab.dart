import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/principal_providers.dart';
import '../widgets/staff_card.dart';

/// Staff management tab for listing and managing staff members.
class StaffManagementTab extends ConsumerStatefulWidget {
  /// Creates a [StaffManagementTab].
  const StaffManagementTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  ConsumerState<StaffManagementTab> createState() => _StaffManagementTabState();
}

class _StaffManagementTabState extends ConsumerState<StaffManagementTab> {
  String _searchQuery = '';
  UserRole? _selectedRoleFilter;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staffAsync = ref.watch(schoolStaffProvider(widget.schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schoolStaffProvider(widget.schoolId));
      },
      child: Column(
        children: [
          // Search and filter header
          Container(
            padding: EdgeInsets.all(widget.isPlayful ? 16 : 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search staff...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          widget.isPlayful ? 14 : 10),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
                SizedBox(height: widget.isPlayful ? 14 : 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(theme, null, 'All'),
                      SizedBox(width: widget.isPlayful ? 10 : 8),
                      _buildFilterChip(theme, UserRole.bigadmin, 'Principals'),
                      SizedBox(width: widget.isPlayful ? 10 : 8),
                      _buildFilterChip(theme, UserRole.admin, 'Admins'),
                      SizedBox(width: widget.isPlayful ? 10 : 8),
                      _buildFilterChip(theme, UserRole.teacher, 'Teachers'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Staff list
          Expanded(
            child: staffAsync.when(
              data: (staff) {
                final filteredStaff = _filterStaff(staff);

                if (filteredStaff.isEmpty) {
                  return _buildEmptyState(theme);
                }

                return ResponsiveCenterScrollView(
                  maxWidth: 1000,
                  padding: EdgeInsets.all(widget.isPlayful ? 16 : 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Staff count
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: widget.isPlayful ? 12 : 8,
                        ),
                        child: Text(
                          '${filteredStaff.length} staff member${filteredStaff.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            fontSize: widget.isPlayful ? 14 : 13,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                      ...filteredStaff.map((staffMember) => Padding(
                            padding: EdgeInsets.only(
                              bottom: widget.isPlayful ? 10 : 8,
                            ),
                            child: StaffCard(
                              staff: staffMember,
                              onViewProfile: () => _viewProfile(staffMember),
                              onRemove: () => _confirmRemoveStaff(
                                context,
                                staffMember,
                              ),
                            ),
                          )),
                      SizedBox(height: widget.isPlayful ? 80 : 72),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(theme, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, UserRole? role, String label) {
    final isSelected = _selectedRoleFilter == role;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedRoleFilter = selected ? role : null);
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: widget.isPlayful ? 14 : 13,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.isPlayful ? 4 : 2,
        vertical: widget.isPlayful ? 2 : 0,
      ),
    );
  }

  List<AppUser> _filterStaff(List<AppUser> staff) {
    return staff.where((s) {
      // Apply role filter
      if (_selectedRoleFilter != null && s.role != _selectedRoleFilter) {
        return false;
      }

      // Apply search filter
      if (_searchQuery.isNotEmpty) {
        final name = s.fullName.toLowerCase();
        final email = (s.email ?? '').toLowerCase();
        if (!name.contains(_searchQuery) && !email.contains(_searchQuery)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildEmptyState(ThemeData theme) {
    if (_searchQuery.isNotEmpty || _selectedRoleFilter != null) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: widget.isPlayful ? 64 : 56,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  'No staff found',
                  style: TextStyle(
                    fontSize: widget.isPlayful ? 20 : 18,
                    fontWeight:
                        widget.isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Try adjusting your search or filters',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedRoleFilter = null;
                    });
                  },
                  child: const Text('Clear filters'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(widget.isPlayful ? 24 : 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.people_outline,
                  size: widget.isPlayful ? 56 : 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'No staff members yet',
                style: TextStyle(
                  fontSize: widget.isPlayful ? 22 : 20,
                  fontWeight:
                      widget.isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Invite admins and teachers to get started',
                style: TextStyle(
                  fontSize: widget.isPlayful ? 15 : 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, Object error) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: AppSpacing.dialogInsets,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error.withValues(alpha: 0.6),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(schoolStaffProvider(widget.schoolId));
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _viewProfile(AppUser staff) {
    // Navigate to user profile page for viewing this staff member's profile
    context.push(AppRoutes.getUserProfile(staff.id));
  }

  Future<void> _confirmRemoveStaff(
    BuildContext context,
    AppUser staff,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Staff Member'),
        content: Text(
          'Are you sure you want to remove ${staff.fullName} from the school? '
          'They will lose access to all school resources.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref
          .read(principalNotifierProvider.notifier)
          .removeStaffMember(staff.id, widget.schoolId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${staff.fullName} has been removed'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
