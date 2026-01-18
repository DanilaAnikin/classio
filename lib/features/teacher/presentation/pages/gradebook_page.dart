import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../dialogs/add_grade_dialog.dart';

/// Gradebook Page for a specific subject.
///
/// Shows a grid of students and their grades for a specific subject.
/// Allows teachers to add, edit, and delete grades.
class GradebookPage extends ConsumerWidget {
  const GradebookPage({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gradebook'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Grade',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddGradeDialog(subjectId: subjectId),
              );
            },
          ),
        ],
      ),
      body: ResponsiveCenterScrollView(
        maxWidth: 1200,
        padding: EdgeInsets.all(isPlayful ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Subject Info Card
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
                        Icons.grade_rounded,
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
                            'Subject Gradebook',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Subject ID: $subjectId',
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

            // Gradebook Placeholder
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
                      Icons.table_chart_outlined,
                      size: 64,
                      color: theme.colorScheme.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gradebook',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View and manage student grades for this subject',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
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
