import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/theme/spacing.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../../domain/entities/entities.dart';
import '../providers/principal_providers.dart';
import '../widgets/widgets.dart';

/// Class Management Tab for Principal Dashboard.
///
/// Displays and manages all classes in the school, including
/// creating new classes and assigning head teachers.
class ClassManagementTab extends ConsumerWidget {
  const ClassManagementTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(principalSchoolClassesProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(principalSchoolClassesProvider(schoolId));
        ref.invalidate(schoolTeachersProvider(schoolId));
      },
      child: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Group classes by grade level
          final groupedClasses = <int, List<ClassWithDetails>>{};
          for (final schoolClass in classes) {
            final gradeLevel = schoolClass.gradeLevel ?? 0;
            final classList = groupedClasses.putIfAbsent(gradeLevel, () => []);
            classList.add(schoolClass);
          }

          // Sort grade levels
          final sortedGrades = groupedClasses.keys.toList()
            ..sort((a, b) => a.compareTo(b));

          return ResponsiveCenterScrollView(
            maxWidth: 1000,
            padding: EdgeInsets.all(isPlayful ? 20 : 16),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Class Stats Card
                _ClassStatsCard(
                  totalClasses: classes.length,
                  totalStudents: classes.fold(0, (sum, c) => sum + c.studentCount),
                  gradeCount: groupedClasses.length,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Classes by Grade
                ...sortedGrades.expand((grade) {
                      final gradeClasses = groupedClasses[grade] ?? [];
                      return [
                      _SectionHeader(
                        title: grade == 0 ? 'Ungraded' : 'Grade $grade',
                        icon: Icons.school_outlined,
                        count: gradeClasses.length,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: isPlayful ? 12 : 8),
                      ...gradeClasses.map((schoolClass) => Padding(
                            padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                            child: ClassCard(
                              classDetails: schoolClass,
                              onEdit: () =>
                                  _showEditClassDialog(context, ref, schoolClass),
                              onAssignTeacher: () =>
                                  _showAssignTeacherDialog(context, ref, schoolClass),
                              onViewStudents: () =>
                                  _showViewStudentsDialog(context, ref, schoolClass),
                              onDelete: () =>
                                  _confirmDeleteClass(context, ref, schoolClass),
                            ),
                          )),
                      SizedBox(height: isPlayful ? 16 : 12),
                    ];
                    }),

                SizedBox(height: isPlayful ? 80 : 72), // Space for FAB
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
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
                  Icons.class_outlined,
                  size: isPlayful ? 56 : 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              Text(
                'No Classes Yet',
                style: TextStyle(
                  fontSize: isPlayful ? 22 : 20,
                  fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Text(
                'Create classes to organize your students.',
                style: TextStyle(
                  fontSize: isPlayful ? 15 : 14,
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

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
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
                  ref.invalidate(principalSchoolClassesProvider(schoolId));
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

  void _showAssignTeacherDialog(
    BuildContext context,
    WidgetRef ref,
    ClassWithDetails classDetails,
  ) {
    showDialog(
      context: context,
      builder: (context) => AssignTeacherDialog(
        schoolId: schoolId,
        classDetails: classDetails,
      ),
    );
  }

  void _showEditClassDialog(
    BuildContext context,
    WidgetRef ref,
    ClassWithDetails classDetails,
  ) {
    showDialog(
      context: context,
      builder: (context) => CreateClassDialog(
        schoolId: classDetails.schoolId,
        classId: classDetails.id,
        initialName: classDetails.name,
        initialGradeLevel: classDetails.gradeLevel?.toString(),
        initialAcademicYear: classDetails.academicYear,
        initialHeadTeacherId: classDetails.headTeacher?.id,
      ),
    ).then((result) {
      if (result == true) {
        ref.invalidate(principalSchoolClassesProvider(schoolId));
      }
    });
  }

  void _showViewStudentsDialog(
    BuildContext context,
    WidgetRef ref,
    ClassWithDetails classDetails,
  ) {
    showDialog(
      context: context,
      builder: (context) => ViewClassStudentsDialog(
        classId: classDetails.id,
        className: classDetails.name,
      ),
    );
  }

  Future<void> _confirmDeleteClass(
    BuildContext context,
    WidgetRef ref,
    ClassWithDetails classDetails,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text(
          'Are you sure you want to delete "${classDetails.name}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(principalNotifierProvider.notifier)
          .deleteClass(classDetails.id, schoolId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Class "${classDetails.name}" has been deleted.'
                  : 'Failed to delete class.',
            ),
            backgroundColor: success ? null : Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// Class stats card
class _ClassStatsCard extends StatelessWidget {
  const _ClassStatsCard({
    required this.totalClasses,
    required this.totalStudents,
    required this.gradeCount,
    required this.isPlayful,
  });

  final int totalClasses;
  final int totalStudents;
  final int gradeCount;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isPlayful ? 16 : 8,
            offset: Offset(0, isPlayful ? 6 : 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.class_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Classes',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalClasses.toString(),
                  style: TextStyle(
                    fontSize: isPlayful ? 28 : 24,
                    fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatBadge(
                label: 'Grades',
                count: gradeCount,
                color: Colors.green,
                isPlayful: isPlayful,
              ),
              SizedBox(height: isPlayful ? 6 : 4),
              _StatBadge(
                label: 'Students',
                count: totalStudents,
                color: Colors.blue,
                isPlayful: isPlayful,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small stat badge
class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.label,
    required this.count,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final int count;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count ',
          style: TextStyle(
            fontSize: isPlayful ? 14 : 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isPlayful ? 12 : 11,
            color: color.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

/// Section header widget
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.isPlayful,
  });

  final String title;
  final IconData icon;
  final int count;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: isPlayful ? 22 : 20,
          color: theme.colorScheme.primary,
        ),
        SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: isPlayful ? 0.3 : -0.3,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isPlayful ? 10 : 8,
            vertical: isPlayful ? 4 : 2,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: isPlayful ? 14 : 12,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
