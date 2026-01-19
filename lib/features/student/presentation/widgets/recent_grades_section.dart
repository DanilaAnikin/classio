import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../grades/domain/entities/entities.dart';
import 'grade_card.dart';

/// Section displaying recent grades on the dashboard overview.
///
/// Shows a list of recent grades with proper spacing and animations,
/// or an empty state message when there are no grades yet.
/// Uses design tokens for consistent styling across themes.
class RecentGradesSection extends StatelessWidget {
  const RecentGradesSection({
    super.key,
    required this.grades,
    required this.isPlayful,
    this.onGradeTap,
    this.maxItems = 5,
  });

  final List<Grade> grades;
  final bool isPlayful;
  final void Function(Grade grade)? onGradeTap;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (grades.isEmpty) {
      return EmptyState(
        icon: Icons.grade_outlined,
        title: 'No Recent Grades',
        message: 'Your grades will appear here when added.',
      );
    }

    // Limit to maxItems
    final displayGrades = grades.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grades list with proper spacing
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayGrades.length,
          separatorBuilder: (context, index) => SizedBox(
            height: isPlayful ? AppSpacing.sm : AppSpacing.xs,
          ),
          itemBuilder: (context, index) {
            final grade = displayGrades[index];
            return _AnimatedGradeCard(
              grade: grade,
              isPlayful: isPlayful,
              index: index,
              onTap: onGradeTap != null ? () => onGradeTap!(grade) : null,
            );
          },
        ),
      ],
    );
  }
}

/// Animated grade card wrapper for staggered entrance animation.
class _AnimatedGradeCard extends StatefulWidget {
  const _AnimatedGradeCard({
    required this.grade,
    required this.isPlayful,
    required this.index,
    this.onTap,
  });

  final Grade grade;
  final bool isPlayful;
  final int index;
  final VoidCallback? onTap;

  @override
  State<_AnimatedGradeCard> createState() => _AnimatedGradeCardState();
}

class _AnimatedGradeCardState extends State<_AnimatedGradeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDuration.medium,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.decelerate,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.decelerate,
    ));

    // Stagger animation based on index
    Future.delayed(
      Duration(milliseconds: widget.index * 50),
      () {
        if (mounted) {
          _controller.forward();
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GradeCard(
          grade: widget.grade,
          isPlayful: widget.isPlayful,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
