import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/responsive_center.dart';
import '../providers/student_provider.dart';
import '../widgets/widgets.dart';

/// Grades tab displaying all grades by subject.
///
/// Shows:
/// - Overall average card with gradient
/// - List of subject averages with progress bars
class GradesTab extends ConsumerWidget {
  const GradesTab({
    super.key,
    required this.isPlayful,
  });

  final bool isPlayful;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjectAverages = ref.watch(subjectAveragesProvider);
    final overallAverage = ref.watch(myOverallAverageProvider);

    return ResponsiveCenterScrollView(
      maxWidth: 800,
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Overall Average Card
          OverallAverageCard(
            average: overallAverage,
            isPlayful: isPlayful,
          ),
          SizedBox(height: isPlayful ? 24 : 20),

          // Subject Averages
          Text(
            'Grades by Subject',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: isPlayful ? 12 : 8),
          subjectAverages.when(
            data: (averages) {
              if (averages.isEmpty) {
                return _EmptyGradesCard(isPlayful: isPlayful);
              }
              return Column(
                children: averages.entries.map((entry) {
                  return SubjectAverageCard(
                    subjectName: entry.key,
                    average: entry.value,
                    isPlayful: isPlayful,
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Center(
              child: Text('Error loading grades: $e'),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// Empty state card when no grades are available.
class _EmptyGradesCard extends StatelessWidget {
  const _EmptyGradesCard({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPlayful ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        side: isPlayful
            ? BorderSide.none
            : BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 24 : 16),
        child: Column(
          children: [
            Icon(
              Icons.grade_outlined,
              size: 48,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No grades yet',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
