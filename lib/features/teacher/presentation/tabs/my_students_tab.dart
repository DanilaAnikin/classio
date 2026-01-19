import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../providers/teacher_provider.dart';
import '../widgets/student_card.dart';
import '../dialogs/invite_student_dialog.dart';

/// My Students tab displaying students by class with onboarding capabilities.
class MyStudentsTab extends ConsumerStatefulWidget {
  const MyStudentsTab({super.key});

  @override
  ConsumerState<MyStudentsTab> createState() => _MyStudentsTabState();
}

class _MyStudentsTabState extends ConsumerState<MyStudentsTab> {
  @override
  Widget build(BuildContext context) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final selectedClassId = ref.watch(selectedClassProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Class Selector
        _ClassSelector(isPlayful: isPlayful),

        // Students List
        Expanded(
          child: selectedClassId == null
              ? _EmptyStudents(isPlayful: isPlayful)
              : _StudentsList(
                  classId: selectedClassId,
                  isPlayful: isPlayful,
                ),
        ),
      ],
    );
  }
}

class _ClassSelector extends ConsumerWidget {
  const _ClassSelector({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(myClassesProvider);
    final selectedClassId = ref.watch(selectedClassProvider);

    return Container(
      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: AppOpacity.soft + 0.03),
          ),
        ),
      ),
      child: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return Text(
              'No classes assigned',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: classes.map((classInfo) {
                final isSelected = selectedClassId == classInfo.id;
                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.xs),
                  child: FilterChip(
                    label: Text(classInfo.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedClassProvider.notifier).select(
                            selected ? classInfo.id : null,
                          );
                    },
                    avatar: Icon(
                      Icons.class_rounded,
                      size: AppIconSize.sm - 2,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => Center(
          child: SizedBox(
            height: AppIconSize.md,
            width: AppIconSize.md,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => Text(
          'Failed to load classes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class _EmptyStudents extends StatelessWidget {
  const _EmptyStudents({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_rounded,
            size: isPlayful ? AppIconSize.hero + 8 : AppIconSize.hero,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.heavy - 0.08),
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            'Select a class to view students',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            'Choose a class from the chips above',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentsList extends ConsumerWidget {
  const _StudentsList({
    required this.classId,
    required this.isPlayful,
  });

  final String classId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(classStudentsProvider(classId));
    final classesAsync = ref.watch(myClassesProvider);

    // Get current class name
    final className = classesAsync.whenOrNull(
      data: (classes) =>
          classes.firstWhere((c) => c.id == classId).name,
    );

    return Scaffold(
      body: studentsAsync.when(
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_rounded,
                    size: isPlayful ? AppIconSize.hero : AppIconSize.xxl + 8,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.heavy - 0.08),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text(
                    'No students in this class',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Use the button below to invite students',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      color: theme.colorScheme.primary,
                      size: isPlayful ? AppIconSize.md : AppIconSize.sm + 2,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      '${students.length} students',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (className != null) ...[
                      Text(
                        ' in $className',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Students Grid
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 800
                        ? 3
                        : constraints.maxWidth > 500
                            ? 2
                            : 1;

                    return GridView.builder(
                      padding: EdgeInsets.all(isPlayful ? AppSpacing.md : AppSpacing.sm),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return StudentCard(
                          student: student,
                          isPlayful: isPlayful,
                          onTap: () => _showStudentDetails(context, student),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: AppIconSize.xxl,
                color: theme.colorScheme.error,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Failed to load students',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(classStudentsProvider(classId)),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInviteDialog(context, classId, className),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Student'),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, AppUser student) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: AppSpacing.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: AppOpacity.medium + 0.14),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: AppSpacing.dialogInsets,
                  children: [
                    // Avatar
                    Center(
                      child: CircleAvatar(
                        radius: AppIconSize.xxl,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: student.avatarUrl != null
                            ? NetworkImage(student.avatarUrl!)
                            : null,
                        child: student.avatarUrl == null
                            ? Text(
                                student.fullName.isNotEmpty
                                    ? student.fullName[0].toUpperCase()
                                    : '?',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Name
                    Center(
                      child: Text(
                        student.fullName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),

                    // Email
                    Center(
                      child: Text(
                        student.email ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Stats (placeholder)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(
                          label: 'Grade Avg',
                          value: '--',
                          icon: Icons.grade_rounded,
                          color: theme.colorScheme.primary,
                          isPlayful: isPlayful,
                        ),
                        _StatItem(
                          label: 'Attendance',
                          value: '--',
                          icon: Icons.how_to_reg_rounded,
                          color: isPlayful ? PlayfulColors.success : CleanColors.success,
                          isPlayful: isPlayful,
                        ),
                        _StatItem(
                          label: 'Assignments',
                          value: '--',
                          icon: Icons.assignment_rounded,
                          color: theme.colorScheme.tertiary,
                          isPlayful: isPlayful,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, String classId, String? className) {
    showDialog(
      context: context,
      builder: (context) => InviteStudentDialog(
        classId: classId,
        className: className ?? 'Unknown Class',
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: AppOpacity.soft - 0.02),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: AppIconSize.md),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
