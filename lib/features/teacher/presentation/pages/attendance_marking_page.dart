import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:classio/core/theme/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';

/// Attendance Marking Page for a specific lesson.
///
/// Allows teachers to mark attendance for all students in a lesson.
class AttendanceMarkingPage extends ConsumerWidget {
  const AttendanceMarkingPage({
    super.key,
    required this.lessonId,
  });

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Save',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attendance saved')),
              );
            },
          ),
        ],
      ),
      body: ResponsiveCenterScrollView(
        maxWidth: 800,
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Lesson Info Card
            Card(
              elevation: isPlayful ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                side: isPlayful
                    ? BorderSide.none
                    : BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: EdgeInsets.all(isPlayful ? 16 : 12),
                child: Row(
                  children: [
                    Container(
                      width: isPlayful ? 56 : 48,
                      height: isPlayful ? 56 : 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                      ),
                      child: Icon(
                        Icons.how_to_reg_rounded,
                        size: isPlayful ? 28 : 24,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: isPlayful ? 16 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lesson Attendance',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lesson ID: $lessonId',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isPlayful ? 24 : 20),

            // Attendance Placeholder
            Card(
              elevation: isPlayful ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
                side: isPlayful
                    ? BorderSide.none
                    : BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: EdgeInsets.all(isPlayful ? 32 : 24),
                child: Column(
                  children: [
                    Icon(
                      Icons.fact_check_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Attendance List',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mark students as present, absent, late, or excused',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AttendanceChip(
                          label: 'Present',
                          color: isPlayful ? PlayfulColors.attendancePresent : CleanColors.attendancePresent,
                          isPlayful: isPlayful,
                        ),
                        SizedBox(width: isPlayful ? 8 : 6),
                        _AttendanceChip(
                          label: 'Absent',
                          color: isPlayful ? PlayfulColors.attendanceAbsent : CleanColors.attendanceAbsent,
                          isPlayful: isPlayful,
                        ),
                        SizedBox(width: isPlayful ? 8 : 6),
                        _AttendanceChip(
                          label: 'Late',
                          color: isPlayful ? PlayfulColors.attendanceLate : CleanColors.attendanceLate,
                          isPlayful: isPlayful,
                        ),
                        SizedBox(width: isPlayful ? 8 : 6),
                        _AttendanceChip(
                          label: 'Excused',
                          color: isPlayful ? PlayfulColors.attendanceExcused : CleanColors.attendanceExcused,
                          isPlayful: isPlayful,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceChip extends StatelessWidget {
  const _AttendanceChip({
    required this.label,
    required this.color,
    required this.isPlayful,
  });

  final String label;
  final Color color;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isPlayful ? 12 : 10,
        vertical: isPlayful ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isPlayful ? 12 : 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
