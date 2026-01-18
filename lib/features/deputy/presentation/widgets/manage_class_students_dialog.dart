import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../providers/deputy_provider.dart';

/// Dialog for managing students in a class.
///
/// Features:
/// - View students currently in the class
/// - Add students from unassigned students list
/// - Remove students from the class
class ManageClassStudentsDialog extends ConsumerStatefulWidget {
  const ManageClassStudentsDialog({
    super.key,
    required this.classInfo,
    required this.schoolId,
  });

  final ClassInfo classInfo;
  final String schoolId;

  @override
  ConsumerState<ManageClassStudentsDialog> createState() =>
      _ManageClassStudentsDialogState();
}

class _ManageClassStudentsDialogState
    extends ConsumerState<ManageClassStudentsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.group_rounded,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manage Students',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          widget.classInfo.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onPrimaryContainer
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Current Students'),
                Tab(text: 'Add Students'),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _CurrentStudentsTab(
                    classId: widget.classInfo.id,
                    schoolId: widget.schoolId,
                  ),
                  _AddStudentsTab(
                    classId: widget.classInfo.id,
                    schoolId: widget.schoolId,
                  ),
                ],
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab showing current students in the class.
class _CurrentStudentsTab extends ConsumerWidget {
  const _CurrentStudentsTab({
    required this.classId,
    required this.schoolId,
  });

  final String classId;
  final String schoolId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(classStudentsProvider(classId));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No students in this class',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to "Add Students" tab to add students',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _StudentListTile(
              student: student,
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                tooltip: 'Remove from class',
                onPressed: () => _confirmRemove(context, ref, student),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text('Error: $error'),
            TextButton(
              onPressed: () => ref.invalidate(classStudentsProvider(classId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, WidgetRef ref, AppUser student) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text(
          'Are you sure you want to remove ${student.fullName} from this class?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(deputyNotifierProvider.notifier).removeStudentFromClass(
                    classId,
                    student.id,
                    schoolId,
                  );
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

/// Tab for adding students to the class.
class _AddStudentsTab extends ConsumerStatefulWidget {
  const _AddStudentsTab({
    required this.classId,
    required this.schoolId,
  });

  final String classId;
  final String schoolId;

  @override
  ConsumerState<_AddStudentsTab> createState() => _AddStudentsTabState();
}

class _AddStudentsTabState extends ConsumerState<_AddStudentsTab> {
  final Set<String> _loadingStudentIds = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(studentsWithoutClassProvider(widget.schoolId));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'All students are assigned',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'There are no unassigned students',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            final isLoading = _loadingStudentIds.contains(student.id);
            return _StudentListTile(
              student: student,
              trailing: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(Icons.add_circle_outline,
                          color: theme.colorScheme.primary),
                      tooltip: 'Add to class',
                      onPressed: () => _addStudent(student),
                    ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(height: 8),
            Text('Error: $error'),
            TextButton(
              onPressed: () =>
                  ref.invalidate(studentsWithoutClassProvider(widget.schoolId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addStudent(AppUser student) async {
    setState(() {
      _loadingStudentIds.add(student.id);
    });

    try {
      final success = await ref
          .read(deputyNotifierProvider.notifier)
          .addStudentToClass(widget.classId, student.id, widget.schoolId);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student.fullName} added to class'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage = ref.read(deputyNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to add student to class'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingStudentIds.remove(student.id);
        });
      }
    }
  }
}

/// List tile widget for displaying a student.
class _StudentListTile extends StatelessWidget {
  const _StudentListTile({
    required this.student,
    this.trailing,
  });

  final AppUser student;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: student.avatarUrl != null
              ? NetworkImage(student.avatarUrl!)
              : null,
          child: student.avatarUrl == null
              ? Text(
                  _getInitials(student),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                )
              : null,
        ),
        title: Text(
          student.fullName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: student.email != null
            ? Text(
                student.email!,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: trailing,
      ),
    );
  }

  String _getInitials(AppUser user) {
    final first = user.firstName?.isNotEmpty == true ? user.firstName![0] : '';
    final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
    if (first.isEmpty && last.isEmpty) {
      return user.email?.substring(0, 1).toUpperCase() ?? '?';
    }
    return '$first$last'.toUpperCase();
  }
}

/// Button widget that opens the manage class students dialog.
class ManageClassStudentsButton extends StatelessWidget {
  const ManageClassStudentsButton({
    super.key,
    required this.classInfo,
    required this.schoolId,
    this.isPlayful = false,
  });

  final ClassInfo classInfo;
  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => ManageClassStudentsDialog(
            classInfo: classInfo,
            schoolId: schoolId,
          ),
        );
      },
      icon: const Icon(Icons.group_rounded, size: 18),
      label: const Text('Manage Students'),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.primary,
        side: BorderSide(color: theme.colorScheme.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
        ),
      ),
    );
  }
}
