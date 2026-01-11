import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:classio/core/providers/theme_provider.dart';
import 'package:classio/core/router/routes.dart';
import 'package:classio/features/auth/auth.dart';
import 'package:classio/features/dashboard/domain/entities/subject.dart';
import 'package:classio/shared/widgets/widgets.dart';

import '../providers/providers.dart';

part 'teacher_dashboard_page.g.dart';

/// Provider that fetches subjects assigned to the current teacher.
///
/// Uses [TeacherRepository.getMySubjects] to fetch subjects where
/// teacher_id matches the current user's ID.
@riverpod
Future<List<Subject>> mySubjects(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return [];
  }

  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getMySubjects(user.id);
}

/// Teacher Dashboard page displaying subjects assigned to the current teacher.
///
/// Features:
/// - List of "My Subjects" where teacher_id equals current user
/// - Each subject card shows name (bold), description, and color indicator
/// - Tap navigation to teacher subject detail page
/// - Pull-to-refresh support
/// - Loading, error, and empty state handling
class TeacherDashboardPage extends ConsumerWidget {
  /// Creates a [TeacherDashboardPage] instance.
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(mySubjectsProvider);
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
            ref.invalidate(mySubjectsProvider);
          },
          child: subjectsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => _ErrorView(
              message: error.toString(),
              onRetry: () => ref.invalidate(mySubjectsProvider),
            ),
            data: (subjects) {
              if (subjects.isEmpty) {
                return _EmptyState(isPlayful: isPlayful);
              }
              return _SubjectsList(
                subjects: subjects,
                isPlayful: isPlayful,
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Widget displaying the list of subjects.
class _SubjectsList extends StatelessWidget {
  const _SubjectsList({
    required this.subjects,
    required this.isPlayful,
  });

  final List<Subject> subjects;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: ResponsiveCenter(
            maxWidth: 1000,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: isPlayful ? 22 : 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'My Subjects',
                      style: TextStyle(
                        fontSize: isPlayful ? 20 : 18,
                        fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: isPlayful ? 0.3 : -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subject Cards
                ...subjects.map(
                  (subject) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubjectCard(
                      subject: subject,
                      isPlayful: isPlayful,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Individual subject card widget.
class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.isPlayful,
  });

  final Subject subject;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = BorderRadius.circular(isPlayful ? 16 : 12);

    return InkWell(
      onTap: () => context.push(AppRoutes.getTeacherSubjectDetail(subject.id)),
      borderRadius: borderRadius,
      child: Container(
        padding: EdgeInsets.all(isPlayful ? 16 : 14),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: isPlayful
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    subject.color.withValues(alpha: 0.15),
                    subject.color.withValues(alpha: 0.05),
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
                  ? subject.color.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isPlayful ? 12 : 6,
              offset: Offset(0, isPlayful ? 4 : 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Color indicator
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: subject.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject name (bold)
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontSize: isPlayful ? 17 : 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: isPlayful ? 0.2 : -0.3,
                    ),
                  ),
                  // Subject description (if teacherName is available, use it as description placeholder)
                  if (subject.teacherName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subject.teacherName!,
                      style: TextStyle(
                        fontSize: isPlayful ? 14 : 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Arrow icon
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: isPlayful ? 26 : 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when teacher has no subjects assigned.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: ResponsiveCenter(
            maxWidth: 1000,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.school_outlined,
                  size: isPlayful ? 72 : 64,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Subjects Assigned',
                  style: TextStyle(
                    fontSize: isPlayful ? 20 : 18,
                    fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have not been assigned to any subjects yet.',
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
      ],
    );
  }
}

/// Error view with retry button.
class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
