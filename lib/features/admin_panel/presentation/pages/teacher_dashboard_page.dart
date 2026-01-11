import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../auth/auth.dart';
import '../../domain/entities/teacher_subject.dart';
import '../providers/teacher_providers.dart';

/// Teacher Dashboard page for the Classio app.
///
/// Displays a list of subjects taught by the logged-in teacher with:
/// - Subject name
/// - Subject description
/// - Number of classes the subject is taught to
/// - Tap to navigate to Teacher Mode subject detail
///
/// Supports two theme modes: Clean (minimal/professional) and Playful (colorful/fun).
class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final currentUser = ref.watch(currentUserProvider);

    // Get the teacher's ID from auth state
    final teacherId = currentUser?.id;

    if (teacherId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Subjects'),
          centerTitle: true,
        ),
        body: _buildErrorState(
          theme,
          isPlayful,
          'Please log in to view your subjects',
          null,
        ),
      );
    }

    final subjectsAsync = ref.watch(teacherDashboardSubjectsProvider(teacherId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Subjects'),
        centerTitle: true,
        backgroundColor: isPlayful
            ? theme.colorScheme.surface.withValues(alpha: 0.95)
            : theme.colorScheme.surface,
        elevation: isPlayful ? 0 : 1,
      ),
      body: Container(
        decoration: isPlayful
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.03),
                    theme.colorScheme.secondary.withValues(alpha: 0.03),
                    theme.colorScheme.tertiary.withValues(alpha: 0.03),
                  ],
                ),
              )
            : null,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(teacherDashboardSubjectsProvider(teacherId));
          },
          child: subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) {
                return _buildEmptyState(theme, isPlayful);
              }

              return ResponsiveCenterScrollView(
                maxWidth: 1000,
                padding: EdgeInsets.all(isPlayful ? 16 : 12),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card with subject count
                    _SubjectCountHeader(
                      subjectCount: subjects.length,
                      isPlayful: isPlayful,
                    ),
                    SizedBox(height: isPlayful ? 20 : 16),

                    // Subject cards
                    ...subjects.map(
                      (subject) => Padding(
                        padding: EdgeInsets.only(bottom: isPlayful ? 12 : 8),
                        child: _SubjectCard(
                          subject: subject,
                          isPlayful: isPlayful,
                          onTap: () => _onSubjectTapped(context, subject),
                        ),
                      ),
                    ),
                    SizedBox(height: isPlayful ? 16 : 12),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => _buildErrorState(
              theme,
              isPlayful,
              error.toString(),
              () => ref.invalidate(teacherDashboardSubjectsProvider(teacherId)),
            ),
          ),
        ),
      ),
    );
  }

  void _onSubjectTapped(BuildContext context, TeacherSubject subject) {
    // TODO: Navigate to TeacherSubjectDetailPage when created
    // For now, show a snackbar indicating the navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening "${subject.name}" in Teacher Mode...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Placeholder navigation - uncomment when TeacherSubjectDetailPage is created:
    // context.push('/teacher/subject/${subject.id}');
  }

  Widget _buildEmptyState(ThemeData theme, bool isPlayful) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: isPlayful ? 120 : 100,
              height: isPlayful ? 120 : 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.school_outlined,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 28 : 24),
            Text(
              'No Subjects Assigned',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have not been assigned to teach any subjects yet.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    ThemeData theme,
    bool isPlayful,
    String error,
    VoidCallback? onRetry,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: isPlayful ? 72 : 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: isPlayful ? 24 : 20),
            Text(
              'Failed to load subjects',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Header card showing the total number of subjects.
class _SubjectCountHeader extends StatelessWidget {
  const _SubjectCountHeader({
    required this.subjectCount,
    required this.isPlayful,
  });

  final int subjectCount;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isPlayful ? 24 : 20),
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
          // Icon
          Container(
            width: isPlayful ? 56 : 48,
            height: isPlayful ? 56 : 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: isPlayful ? 32 : 28,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isPlayful ? 20 : 16),

          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Teaching',
                  style: TextStyle(
                    fontSize: isPlayful ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    letterSpacing: isPlayful ? 0.3 : 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$subjectCount ${subjectCount == 1 ? 'Subject' : 'Subjects'}',
                  style: TextStyle(
                    fontSize: isPlayful ? 32 : 28,
                    fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: isPlayful ? 0.5 : -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual subject card displaying subject details.
class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.isPlayful,
    required this.onTap,
  });

  final TeacherSubject subject;
  final bool isPlayful;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        gradient: isPlayful
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  subject.color.withValues(alpha: 0.12),
                  subject.color.withValues(alpha: 0.04),
                ],
              )
            : null,
        color: isPlayful ? null : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? subject.color.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 12 : 6,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        child: Padding(
          padding: EdgeInsets.all(isPlayful ? 18 : 14),
          child: Row(
            children: [
              // Subject Color Indicator
              Container(
                width: isPlayful ? 12 : 10,
                height: isPlayful ? 60 : 50,
                decoration: BoxDecoration(
                  color: subject.color,
                  borderRadius: BorderRadius.circular(isPlayful ? 6 : 4),
                  boxShadow: isPlayful
                      ? [
                          BoxShadow(
                            color: subject.color.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
              SizedBox(width: isPlayful ? 16 : 12),

              // Subject Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Name
                    Text(
                      subject.name,
                      style: TextStyle(
                        fontSize: isPlayful ? 18 : 16,
                        fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: isPlayful ? 0.3 : -0.3,
                      ),
                    ),

                    // Description (if available)
                    if (subject.description != null &&
                        subject.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subject.description!,
                        style: TextStyle(
                          fontSize: isPlayful ? 14 : 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Class count badge
                    Row(
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: isPlayful ? 18 : 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${subject.classCount} ${subject.classCount == 1 ? 'class' : 'classes'}',
                          style: TextStyle(
                            fontSize: isPlayful ? 14 : 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon indicating navigation
              Container(
                padding: EdgeInsets.all(isPlayful ? 10 : 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                  size: isPlayful ? 22 : 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
