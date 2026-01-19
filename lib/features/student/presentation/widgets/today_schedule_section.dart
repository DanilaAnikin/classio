import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../dashboard/domain/entities/entities.dart';
import 'lesson_card.dart';

/// Section displaying today's schedule on the dashboard overview.
///
/// Shows a list of today's lessons with proper spacing and animations,
/// or an empty state message when there are no classes scheduled.
/// Uses design tokens for consistent styling across themes.
class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({
    super.key,
    required this.lessons,
    required this.isPlayful,
    this.onLessonTap,
  });

  final List<Lesson> lessons;
  final bool isPlayful;
  final void Function(Lesson lesson)? onLessonTap;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today_outlined,
        title: 'No Lessons Today',
        message: 'Enjoy your free time!',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lessons list with proper spacing
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          separatorBuilder: (context, index) => SizedBox(
            height: isPlayful ? AppSpacing.sm : AppSpacing.xs,
          ),
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            return _AnimatedLessonCard(
              lesson: lesson,
              isPlayful: isPlayful,
              index: index,
              onTap: onLessonTap != null ? () => onLessonTap!(lesson) : null,
            );
          },
        ),
      ],
    );
  }
}

/// Animated lesson card wrapper for staggered entrance animation.
class _AnimatedLessonCard extends StatefulWidget {
  const _AnimatedLessonCard({
    required this.lesson,
    required this.isPlayful,
    required this.index,
    this.onTap,
  });

  final Lesson lesson;
  final bool isPlayful;
  final int index;
  final VoidCallback? onTap;

  @override
  State<_AnimatedLessonCard> createState() => _AnimatedLessonCardState();
}

class _AnimatedLessonCardState extends State<_AnimatedLessonCard>
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
        child: LessonCard(
          lesson: widget.lesson,
          isPlayful: widget.isPlayful,
          onTap: widget.onTap,
        ),
      ),
    );
  }
}
