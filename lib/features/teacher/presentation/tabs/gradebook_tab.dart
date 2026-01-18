import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../domain/entities/teacher_grade_entity.dart';
import '../providers/teacher_provider.dart';
import '../widgets/grade_cell.dart';
import '../widgets/grade_entry_dialog.dart';

/// Gradebook tab with class/subject selector and grade grid.
class GradebookTab extends ConsumerStatefulWidget {
  const GradebookTab({super.key});

  @override
  ConsumerState<GradebookTab> createState() => _GradebookTabState();
}

class _GradebookTabState extends ConsumerState<GradebookTab> {
  @override
  Widget build(BuildContext context) {
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final selectedSubjectId = ref.watch(selectedSubjectProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subject Selector
        _SubjectSelector(isPlayful: isPlayful),

        // Gradebook Grid
        Expanded(
          child: selectedSubjectId == null
              ? _EmptyGradebook(isPlayful: isPlayful)
              : _GradebookContent(
                  subjectId: selectedSubjectId,
                  isPlayful: isPlayful,
                ),
        ),
      ],
    );
  }
}

class _SubjectSelector extends ConsumerWidget {
  const _SubjectSelector({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjectsAsync = ref.watch(mySubjectsProvider);
    final selectedSubjectId = ref.watch(selectedSubjectProvider);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: subjectsAsync.when(
        data: (subjects) {
          if (subjects.isEmpty) {
            return Text(
              'No subjects assigned',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: subjects.map((subject) {
                final isSelected = selectedSubjectId == subject.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(subject.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      ref.read(selectedSubjectProvider.notifier).select(
                            selected ? subject.id : null,
                          );
                    },
                    avatar: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Color(subject.color),
                        shape: BoxShape.circle,
                      ),
                    ),
                    selectedColor: Color(subject.color).withValues(alpha: 0.2),
                    checkmarkColor: Color(subject.color),
                  ),
                );
              }).toList(),
            ),
          );
        },
        loading: () => const Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (_, _) => Text(
          'Failed to load subjects',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }
}

class _EmptyGradebook extends StatelessWidget {
  const _EmptyGradebook({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.grid_view_rounded,
            size: isPlayful ? 72 : 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a subject to view gradebook',
            style: TextStyle(
              fontSize: isPlayful ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a subject from the chips above',
            style: TextStyle(
              fontSize: isPlayful ? 14 : 13,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _GradebookContent extends ConsumerWidget {
  const _GradebookContent({
    required this.subjectId,
    required this.isPlayful,
  });

  final String subjectId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gradesAsync = ref.watch(subjectGradesProvider(subjectId));
    final classesAsync = ref.watch(myClassesProvider);

    return gradesAsync.when(
      data: (grades) {
        return classesAsync.when(
          data: (classes) {
            if (classes.isEmpty) {
              return Center(
                child: Text(
                  'No classes found for this subject',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              );
            }

            // Get students for the first class (simplified)
            final classId = classes.first.id;
            return _GradebookGrid(
              classId: classId,
              subjectId: subjectId,
              grades: grades,
              isPlayful: isPlayful,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Failed to load classes: $e',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load grades',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () =>
                  ref.invalidate(subjectGradesProvider(subjectId)),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradebookGrid extends ConsumerWidget {
  const _GradebookGrid({
    required this.classId,
    required this.subjectId,
    required this.grades,
    required this.isPlayful,
  });

  final String classId;
  final String subjectId;
  final List<TeacherGradeEntity> grades;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final studentsAsync = ref.watch(classStudentsProvider(classId));

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Text(
              'No students in this class',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          );
        }

        // Group grades by student
        final gradesByStudent = <String, List<TeacherGradeEntity>>{};
        for (final grade in grades) {
          gradesByStudent.putIfAbsent(grade.studentId, () => []);
          gradesByStudent[grade.studentId]!.add(grade);
        }

        // Get unique grade types
        final gradeTypes = grades.map((g) => g.gradeType ?? 'Grade').toSet().toList();
        if (gradeTypes.isEmpty) gradeTypes.add('Grade');

        return Column(
          children: [
            // Add Grade Button
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.icon(
                    onPressed: () => _showAddGradeDialog(context, ref, students),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Grade'),
                  ),
                ],
              ),
            ),

            // Grid Header
            Container(
              color: theme.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 180,
                    child: Text(
                      'Student',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isPlayful ? 14 : 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  ...gradeTypes.map((type) => Expanded(
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isPlayful ? 13 : 12,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )),
                  SizedBox(
                    width: 80,
                    child: Center(
                      child: Text(
                        'Average',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isPlayful ? 14 : 13,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Student Rows
            Expanded(
              child: ListView.builder(
                itemCount: students.length,
                itemBuilder: (context, index) {
                  final student = students[index];
                  final studentGrades = gradesByStudent[student.id] ?? [];

                  // Calculate average
                  double average = 0;
                  if (studentGrades.isNotEmpty) {
                    double totalWeight = 0;
                    double weightedSum = 0;
                    for (final g in studentGrades) {
                      weightedSum += g.score * g.weight;
                      totalWeight += g.weight;
                    }
                    if (totalWeight > 0) {
                      average = weightedSum / totalWeight;
                    }
                  }

                  return _StudentGradeRow(
                    student: student,
                    grades: studentGrades,
                    gradeTypes: gradeTypes,
                    average: average,
                    subjectId: subjectId,
                    isPlayful: isPlayful,
                    isEven: index.isEven,
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Failed to load students: $e',
          style: TextStyle(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  void _showAddGradeDialog(
    BuildContext context,
    WidgetRef ref,
    List<AppUser> students,
  ) {
    showDialog(
      context: context,
      builder: (context) => GradeEntryDialog(
        students: students,
        subjectId: subjectId,
      ),
    );
  }
}

class _StudentGradeRow extends ConsumerWidget {
  const _StudentGradeRow({
    required this.student,
    required this.grades,
    required this.gradeTypes,
    required this.average,
    required this.subjectId,
    required this.isPlayful,
    required this.isEven,
  });

  final AppUser student;
  final List<TeacherGradeEntity> grades;
  final List<String> gradeTypes;
  final double average;
  final String subjectId;
  final bool isPlayful;
  final bool isEven;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: isEven
          ? theme.colorScheme.surface
          : theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Student Name
          SizedBox(
            width: 180,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: student.avatarUrl != null
                      ? NetworkImage(student.avatarUrl!)
                      : null,
                  child: student.avatarUrl == null
                      ? Text(
                          student.fullName.isNotEmpty
                              ? student.fullName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    student.fullName,
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Grade Cells for each type
          ...gradeTypes.map((type) {
            final gradeForType = grades
                .where((g) => (g.gradeType ?? 'Grade') == type)
                .toList();
            final grade = gradeForType.isNotEmpty ? gradeForType.first : null;

            return Expanded(
              child: Center(
                child: GradeCell(
                  grade: grade,
                  onTap: () => _showGradeDialog(context, ref, grade, type),
                  isPlayful: isPlayful,
                ),
              ),
            );
          }),

          // Average
          SizedBox(
            width: 80,
            child: Center(
              child: GradeCell(
                score: average,
                isAverage: true,
                isPlayful: isPlayful,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGradeDialog(
    BuildContext context,
    WidgetRef ref,
    TeacherGradeEntity? existingGrade,
    String gradeType,
  ) {
    showDialog(
      context: context,
      builder: (context) => GradeEntryDialog(
        students: [student],
        subjectId: subjectId,
        existingGrade: existingGrade,
        preselectedStudent: student,
        preselectedGradeType: gradeType,
      ),
    );
  }
}
