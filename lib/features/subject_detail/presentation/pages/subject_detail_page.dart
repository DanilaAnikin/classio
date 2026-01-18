import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/localization.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../dashboard/domain/entities/assignment.dart';
import '../../domain/entities/entities.dart';
import '../providers/subject_detail_provider.dart';

/// Main Subject Detail page for the Classio app.
///
/// Displays detailed information about a subject with three tabs:
/// - Stream: Posts and announcements from the teacher
/// - Assignments: List of assignments for this subject
/// - Materials: Course materials (PDFs, links, videos)
///
/// Supports two theme modes: Clean (minimal/professional) and Playful (colorful/fun).
class SubjectDetailPage extends ConsumerStatefulWidget {
  const SubjectDetailPage({
    super.key,
    required this.subjectId,
  });

  /// Unique identifier for the subject to display.
  final String subjectId;

  @override
  ConsumerState<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends ConsumerState<SubjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final state = ref.watch(subjectDetailNotifierProvider(widget.subjectId));
    final l10n = context.l10n;

    return Scaffold(
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.hasError
              ? _buildErrorView(state.error!, theme, isPlayful, l10n)
              : state.hasData
                  ? _buildContent(state.data!, theme, isPlayful, l10n)
                  : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorView(
    String error,
    ThemeData theme,
    bool isPlayful,
    AppLocalizations l10n,
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
              l10n.subjectFailedToLoad,
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
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(subjectDetailNotifierProvider(widget.subjectId).notifier)
                    .refresh(widget.subjectId);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.dashboardRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    SubjectDetail data,
    ThemeData theme,
    bool isPlayful,
    AppLocalizations l10n,
  ) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: data.subjectColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.subjectName,
                    style: TextStyle(
                      fontSize: isPlayful ? 22 : 20,
                      fontWeight: isPlayful ? FontWeight.w800 : FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: isPlayful ? 0.3 : -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.teacherName,
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      data.subjectColor,
                      data.subjectColor.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
              labelStyle: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: isPlayful ? 0.5 : 0,
              ),
              tabs: [
                Tab(text: l10n.subjectStream, icon: const Icon(Icons.dynamic_feed_rounded)),
                Tab(text: l10n.subjectAssignments, icon: const Icon(Icons.assignment_outlined)),
                Tab(text: l10n.subjectMaterials, icon: const Icon(Icons.folder_outlined)),
              ],
            ),
          ),
        ];
      },
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(subjectDetailNotifierProvider(widget.subjectId).notifier)
              .refresh(widget.subjectId);
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _StreamTab(subjectId: widget.subjectId),
            _AssignmentsTab(subjectId: widget.subjectId),
            _MaterialsTab(subjectId: widget.subjectId),
          ],
        ),
      ),
    );
  }
}

/// Stream tab showing course posts and announcements.
class _StreamTab extends ConsumerWidget {
  const _StreamTab({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(subjectPostsProvider(subjectId));
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final l10n = context.l10n;

    if (posts.isEmpty) {
      return _buildEmptyState(
        theme,
        isPlayful,
        Icons.dynamic_feed_rounded,
        l10n.subjectNoPostsYet,
        l10n.subjectPostsWillAppear,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: isPlayful ? 16 : 12),
          child: _PostCard(post: posts[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    bool isPlayful,
    IconData icon,
    String title,
    String subtitle,
  ) {
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
                icon,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 28 : 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
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
}

/// Individual post card.
class _PostCard extends ConsumerWidget {
  const _PostCard({required this.post});

  final CoursePost post;

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final postDate = DateTime(date.year, date.month, date.day);
    final timeStr = DateFormat('H:mm').format(date);

    if (postDate == today) {
      return l10n.subjectTodayAt(timeStr);
    } else if (postDate == yesterday) {
      return l10n.subjectYesterdayAt(timeStr);
    } else if (now.difference(date).inDays < 7) {
      return l10n.subjectDayAt(DateFormat('EEEE').format(date), timeStr);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: isPlayful ? 10 : 6,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 16 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info and type badge
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: isPlayful ? 20 : 18,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: post.authorAvatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            post.authorAvatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildAvatarFallback(theme, isPlayful),
                          ),
                        )
                      : _buildAvatarFallback(theme, isPlayful),
                ),
                SizedBox(width: isPlayful ? 12 : 10),

                // Author name and date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: TextStyle(
                          fontSize: isPlayful ? 16 : 15,
                          fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDate(post.date, context),
                        style: TextStyle(
                          fontSize: isPlayful ? 13 : 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPlayful ? 12 : 10,
                    vertical: isPlayful ? 6 : 5,
                  ),
                  decoration: BoxDecoration(
                    color: post.type == CoursePostType.assignment
                        ? theme.colorScheme.tertiaryContainer
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.type == CoursePostType.assignment
                            ? Icons.assignment_outlined
                            : Icons.campaign_rounded,
                        size: isPlayful ? 16 : 14,
                        color: post.type == CoursePostType.assignment
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.type.displayName,
                        style: TextStyle(
                          fontSize: isPlayful ? 12 : 11,
                          fontWeight: FontWeight.w600,
                          color: post.type == CoursePostType.assignment
                              ? theme.colorScheme.onTertiaryContainer
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isPlayful ? 16 : 12),

            // Content
            Text(
              post.content,
              style: TextStyle(
                fontSize: isPlayful ? 15 : 14,
                height: 1.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarFallback(ThemeData theme, bool isPlayful) {
    return Icon(
      Icons.person_rounded,
      size: isPlayful ? 24 : 20,
      color: theme.colorScheme.onPrimaryContainer,
    );
  }
}

/// Assignments tab showing assignments for this subject.
class _AssignmentsTab extends ConsumerWidget {
  const _AssignmentsTab({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignments = ref.watch(subjectAssignmentsProvider(subjectId));
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final l10n = context.l10n;

    if (assignments.isEmpty) {
      return _buildEmptyState(
        theme,
        isPlayful,
        Icons.assignment_turned_in_outlined,
        l10n.subjectNoAssignments,
        l10n.subjectAssignmentsWillAppear,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: isPlayful ? 12 : 10),
          child: _AssignmentCard(assignment: assignments[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    bool isPlayful,
    IconData icon,
    String title,
    String subtitle,
  ) {
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
                icon,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 28 : 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
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
}

/// Individual assignment card.
class _AssignmentCard extends ConsumerWidget {
  const _AssignmentCard({required this.assignment});

  final Assignment assignment;

  String _formatDueDate(DateTime dueDate, BuildContext context) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final assignmentDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (assignmentDate == today) {
      return l10n.subjectDueToday;
    } else if (assignmentDate == tomorrow) {
      return l10n.subjectDueTomorrow;
    } else {
      return l10n.subjectDueDate(DateFormat('MMM d, yyyy').format(dueDate));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final isOverdue = assignment.isOverdue;
    final isCompleted = assignment.isCompleted;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        gradient: isPlayful && !isCompleted
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(assignment.subject.color).withValues(alpha: 0.1),
                  Color(assignment.subject.color).withValues(alpha: 0.02),
                ],
              )
            : null,
        color: isPlayful
            ? null
            : isCompleted
                ? theme.colorScheme.surface.withValues(alpha: 0.5)
                : theme.colorScheme.surface,
        border: isPlayful
            ? null
            : Border.all(
                color: isOverdue && !isCompleted
                    ? theme.colorScheme.error.withValues(alpha: 0.3)
                    : theme.colorScheme.outline.withValues(alpha: 0.15),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: isPlayful
                ? Color(assignment.subject.color).withValues(alpha: isCompleted ? 0.03 : 0.1)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: isPlayful ? 10 : 4,
            offset: Offset(0, isPlayful ? 3 : 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isPlayful ? 16 : 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assignment.title,
                        style: TextStyle(
                          fontSize: isPlayful ? 16 : 15,
                          fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                          color: isCompleted
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.4)
                              : theme.colorScheme.onSurface,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: isPlayful ? 16 : 14,
                            color: isOverdue && !isCompleted
                                ? theme.colorScheme.error
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDueDate(assignment.dueDate, context),
                            style: TextStyle(
                              fontSize: isPlayful ? 14 : 13,
                              color: isOverdue && !isCompleted
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: isOverdue && !isCompleted
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Icon(
                    Icons.check_circle_rounded,
                    color: theme.colorScheme.primary,
                    size: isPlayful ? 28 : 24,
                  )
                else if (isOverdue)
                  Icon(
                    Icons.error_outline_rounded,
                    color: theme.colorScheme.error,
                    size: isPlayful ? 28 : 24,
                  ),
              ],
            ),

            if (assignment.description != null && assignment.description!.isNotEmpty) ...[
              SizedBox(height: isPlayful ? 12 : 10),
              Text(
                assignment.description!,
                style: TextStyle(
                  fontSize: isPlayful ? 14 : 13,
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (!isCompleted) ...[
              SizedBox(height: isPlayful ? 16 : 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.subjectSubmitted),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(context.l10n.subjectSubmit),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isPlayful ? 14 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Materials tab showing course materials.
class _MaterialsTab extends ConsumerWidget {
  const _MaterialsTab({required this.subjectId});

  final String subjectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materials = ref.watch(subjectMaterialsProvider(subjectId));
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final l10n = context.l10n;

    if (materials.isEmpty) {
      return _buildEmptyState(
        theme,
        isPlayful,
        Icons.folder_open_rounded,
        l10n.subjectNoMaterials,
        l10n.subjectMaterialsWillAppear,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isPlayful ? 16 : 12),
      itemCount: materials.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: isPlayful ? 12 : 10),
          child: _MaterialCard(material: materials[index]),
        );
      },
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    bool isPlayful,
    IconData icon,
    String title,
    String subtitle,
  ) {
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
                icon,
                size: isPlayful ? 56 : 48,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: isPlayful ? 28 : 24),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: isPlayful ? 0.3 : -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
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
}

/// Individual material card.
class _MaterialCard extends ConsumerWidget {
  const _MaterialCard({required this.material});

  final CourseMaterial material;

  IconData _getIconForType(CourseMaterialType type) {
    switch (type) {
      case CourseMaterialType.pdf:
        return Icons.picture_as_pdf_rounded;
      case CourseMaterialType.link:
        return Icons.link_rounded;
      case CourseMaterialType.video:
        return Icons.play_circle_outline_rounded;
    }
  }

  Color _getColorForType(CourseMaterialType type, ColorScheme colorScheme) {
    switch (type) {
      case CourseMaterialType.pdf:
        return Colors.red;
      case CourseMaterialType.link:
        return Colors.blue;
      case CourseMaterialType.video:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _openUrl(String url, BuildContext context) async {
    // For now, just show a message that the URL would be opened
    // In a real app, you would use url_launcher package
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.subjectOpening(url)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final iconColor = _getColorForType(material.type, theme.colorScheme);

    return InkWell(
      onTap: () => _openUrl(material.url, context),
      borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
          color: theme.colorScheme.surface,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPlayful
                  ? iconColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isPlayful ? 10 : 4,
              offset: Offset(0, isPlayful ? 3 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(isPlayful ? 16 : 14),
          child: Row(
            children: [
              // Icon
              Container(
                width: isPlayful ? 52 : 48,
                height: isPlayful ? 52 : 48,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 12),
                ),
                child: Icon(
                  _getIconForType(material.type),
                  size: isPlayful ? 28 : 24,
                  color: iconColor,
                ),
              ),
              SizedBox(width: isPlayful ? 16 : 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      style: TextStyle(
                        fontSize: isPlayful ? 16 : 15,
                        fontWeight: isPlayful ? FontWeight.w700 : FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isPlayful ? 8 : 6,
                            vertical: isPlayful ? 4 : 3,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(isPlayful ? 8 : 6),
                          ),
                          child: Text(
                            material.type.displayName,
                            style: TextStyle(
                              fontSize: isPlayful ? 12 : 11,
                              fontWeight: FontWeight.w600,
                              color: iconColor,
                            ),
                          ),
                        ),
                        SizedBox(width: isPlayful ? 12 : 10),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: isPlayful ? 14 : 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(material.dateAdded),
                          style: TextStyle(
                            fontSize: isPlayful ? 13 : 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: isPlayful ? 20 : 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
