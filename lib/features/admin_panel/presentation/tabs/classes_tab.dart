import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:classio/core/theme/spacing.dart';
import 'package:classio/shared/widgets/responsive_center.dart';
import '../../domain/entities/class_info.dart';
import '../providers/admin_providers.dart';
import '../widgets/widgets.dart';

/// Classes Tab - Displays list of classes in the school.
class ClassesTab extends ConsumerWidget {
  const ClassesTab({
    super.key,
    required this.schoolId,
    required this.isPlayful,
  });

  final String schoolId;
  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final classesAsync = ref.watch(schoolClassesProvider(schoolId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(schoolClassesProvider(schoolId));
      },
      child: classesAsync.when(
        data: (classes) {
          if (classes.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Group classes by grade level
          final groupedClasses = <int, List<ClassInfo>>{};
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
            padding: EdgeInsets.all(isPlayful ? 16 : 12),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Stats Card
                ClassStatsCard(
                  totalClasses: classes.length,
                  gradeCount: groupedClasses.length,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),

                // Classes by Grade
                ...sortedGrades.expand((grade) {
                      final gradeClasses = groupedClasses[grade] ?? [];
                      return [
                      SectionHeader(
                        title: 'Grade $grade',
                        icon: Icons.school_outlined,
                        count: gradeClasses.length,
                        isPlayful: isPlayful,
                      ),
                      SizedBox(height: isPlayful ? 12 : 8),
                      ...gradeClasses.map((schoolClass) => Padding(
                            padding: EdgeInsets.only(bottom: isPlayful ? 10 : 8),
                            child: ClassCard(
                              schoolClass: schoolClass,
                              isPlayful: isPlayful,
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
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorState(context, theme, error, ref),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
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
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ThemeData theme,
    Object error,
    WidgetRef ref,
  ) {
    return Center(
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
                ref.invalidate(schoolClassesProvider(schoolId));
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
