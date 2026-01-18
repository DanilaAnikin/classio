import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dashboard/domain/entities/subject.dart';
import '../providers/deputy_provider.dart';

/// Subjects Management Tab Widget.
///
/// Features:
/// - View all subjects in the school
/// - Create new subjects
/// - Edit existing subjects
/// - Assign subjects to classes
/// - Delete subjects
class SubjectsManagementTab extends ConsumerWidget {
  const SubjectsManagementTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjectsAsync = ref.watch(schoolSubjectsProvider(schoolId));

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(schoolSubjectsProvider(schoolId));
            ref.invalidate(deputySchoolTeachersProvider(schoolId));
          },
          child: subjectsAsync.when(
            data: (subjects) => subjects.isEmpty
                ? _EmptySubjectsState(isPlayful: isPlayful)
                : _SubjectsList(
                    subjects: subjects,
                    schoolId: schoolId,
                    isPlayful: isPlayful,
                  ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text('Error loading subjects: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(schoolSubjectsProvider(schoolId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _showSubjectDialog(context, ref),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Subject'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  void _showSubjectDialog(BuildContext context, WidgetRef ref,
      {Subject? existingSubject}) {
    showDialog(
      context: context,
      builder: (context) => SubjectFormDialog(
        schoolId: schoolId,
        existingSubject: existingSubject,
      ),
    );
  }
}

class _EmptySubjectsState extends StatelessWidget {
  const _EmptySubjectsState({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                  Icons.book_outlined,
                  size: isPlayful ? 64 : 56,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Subjects Yet',
                style: TextStyle(
                  fontSize: isPlayful ? 22 : 20,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first subject to start\nbuilding your school curriculum.',
                style: TextStyle(
                  fontSize: isPlayful ? 15 : 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubjectsList extends ConsumerWidget {
  const _SubjectsList({
    required this.subjects,
    required this.schoolId,
    required this.isPlayful,
  });

  final List<Subject> subjects;
  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _SubjectCard(
          subject: subject,
          schoolId: schoolId,
          isPlayful: isPlayful,
        );
      },
    );
  }
}

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({
    required this.subject,
    required this.schoolId,
    required this.isPlayful,
  });

  final Subject subject;
  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjectColor = Color(subject.color);

    return Card(
      margin: EdgeInsets.only(bottom: isPlayful ? 12 : 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: BorderSide(
          color: subjectColor.withValues(alpha: 0.3),
          width: isPlayful ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showSubjectOptions(context, ref),
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        child: Padding(
          padding: EdgeInsets.all(isPlayful ? 16 : 14),
          child: Row(
            children: [
              Container(
                width: isPlayful ? 48 : 44,
                height: isPlayful ? 48 : 44,
                decoration: BoxDecoration(
                  color: subjectColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 10),
                ),
                child: Icon(
                  Icons.book_rounded,
                  color: subjectColor,
                  size: isPlayful ? 26 : 24,
                ),
              ),
              SizedBox(width: isPlayful ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: isPlayful ? 17 : 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subject.teacherName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subject.teacherName!,
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 13,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (action) => _handleAction(context, ref, action),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'assign',
                    child: Row(
                      children: [
                        Icon(Icons.class_outlined),
                        SizedBox(width: 8),
                        Text('Assign to Class'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubjectOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit Subject'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => SubjectFormDialog(
                      schoolId: schoolId,
                      existingSubject: subject,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.class_outlined),
                title: const Text('Assign to Class'),
                onTap: () {
                  Navigator.pop(context);
                  _showAssignToClassDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outlined, color: Colors.red),
                title:
                    const Text('Delete Subject', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, String action) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => SubjectFormDialog(
            schoolId: schoolId,
            existingSubject: subject,
          ),
        );
        break;
      case 'assign':
        _showAssignToClassDialog(context, ref);
        break;
      case 'delete':
        _confirmDelete(context, ref);
        break;
    }
  }

  void _showAssignToClassDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AssignSubjectToClassDialog(
        subjectId: subject.id,
        subjectName: subject.name,
        schoolId: schoolId,
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text(
          'Are you sure you want to delete "${subject.name}"?\n\nThis will also remove it from all classes and schedules.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(deputyNotifierProvider.notifier)
                  .deleteSubject(subject.id, schoolId);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Dialog for creating or editing a subject.
class SubjectFormDialog extends ConsumerStatefulWidget {
  const SubjectFormDialog({
    super.key,
    required this.schoolId,
    this.existingSubject,
  });

  final String schoolId;
  final Subject? existingSubject;

  @override
  ConsumerState<SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends ConsumerState<SubjectFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  String? _selectedTeacherId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingSubject?.name ?? '');
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final teachersAsync = ref.watch(deputySchoolTeachersProvider(widget.schoolId));
    final isEditing = widget.existingSubject != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Subject' : 'Create Subject'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name',
                hintText: 'e.g., Mathematics',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of the subject',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            teachersAsync.when(
              data: (teachers) => DropdownButtonFormField<String>(
                initialValue: _selectedTeacherId,
                decoration: const InputDecoration(
                  labelText: 'Assign Teacher (Optional)',
                  border: OutlineInputBorder(),
                ),
                isExpanded: true,
                hint: const Text('Select a teacher'),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('No teacher assigned'),
                  ),
                  ...teachers.map(
                    (teacher) => DropdownMenuItem(
                      value: teacher.id,
                      child: Text(
                        teacher.fullName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTeacherId = value;
                  });
                },
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(
                'Error loading teachers',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Save' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a subject name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(deputyNotifierProvider.notifier);
      bool success;

      if (widget.existingSubject != null) {
        success = await notifier.updateSubject(
          subjectId: widget.existingSubject!.id,
          name: name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          teacherId: _selectedTeacherId,
          schoolId: widget.schoolId,
        );
      } else {
        success = await notifier.createSubject(
          schoolId: widget.schoolId,
          name: name,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          teacherId: _selectedTeacherId,
        );
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context);
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

/// Dialog for assigning a subject to a class.
class AssignSubjectToClassDialog extends ConsumerStatefulWidget {
  const AssignSubjectToClassDialog({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.schoolId,
  });

  final String subjectId;
  final String subjectName;
  final String schoolId;

  @override
  ConsumerState<AssignSubjectToClassDialog> createState() =>
      _AssignSubjectToClassDialogState();
}

class _AssignSubjectToClassDialogState
    extends ConsumerState<AssignSubjectToClassDialog> {
  String? _selectedClassId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(deputySchoolClassesProvider(widget.schoolId));

    return AlertDialog(
      title: const Text('Assign to Class'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assign "${widget.subjectName}" to a class:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          classesAsync.when(
            data: (classes) => DropdownButtonFormField<String>(
              initialValue: _selectedClassId,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
              isExpanded: true,
              hint: const Text('Choose a class'),
              items: classes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(
                        '${c.name}${c.gradeLevel != null ? ' (Grade ${c.gradeLevel})' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClassId = value;
                });
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => Text(
              'Error loading classes',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading || _selectedClassId == null ? null : _assign,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }

  Future<void> _assign() async {
    if (_selectedClassId == null) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(deputyNotifierProvider.notifier)
          .assignSubjectToClass(widget.subjectId, _selectedClassId!, widget.schoolId);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subject assigned to class')),
          );
        }
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
