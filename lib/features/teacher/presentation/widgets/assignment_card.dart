import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/assignment_entity.dart';

/// A premium card widget displaying an assignment.
///
/// Features:
/// - Status indicator (active/past due)
/// - Subject and due date info
/// - Optional description preview
/// - Delete action with confirmation
/// - Fully theme-aware (Clean vs Playful)
///
/// Example:
/// ```dart
/// AssignmentCard(
///   assignment: assignmentEntity,
///   isPlayful: false,
///   onTap: () => navigateToAssignment(assignment.id),
///   onDelete: () => confirmDelete(assignment.id),
/// )
/// ```
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.isPlayful,
    this.onTap,
    this.onDelete,
  });

  /// The assignment entity to display.
  final AssignmentEntity assignment;

  /// Whether the playful theme is active.
  final bool isPlayful;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  /// Optional callback for delete action.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPastDue = assignment.isPastDue;

    return AppCard.interactive(
      onTap: onTap,
      padding: AppSpacing.cardInsets,
      borderColor: isPastDue
          ? (isPlayful ? PlayfulColors.error : CleanColors.error)
              .withValues(alpha: AppOpacity.medium)
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          _buildIconContainer(theme, isPastDue),
          AppSpacing.gapH16,

          // Content
          Expanded(
            child: _buildContent(theme, isPastDue),
          ),

          // Actions column
          _buildActionsColumn(theme, isPastDue),
        ],
      ),
    );
  }

  /// Builds the colored icon container.
  Widget _buildIconContainer(ThemeData theme, bool isPastDue) {
    final color = isPastDue
        ? (isPlayful ? PlayfulColors.error : CleanColors.error)
        : theme.colorScheme.primary;

    return Container(
      padding: AppSpacing.insets12,
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.button(isPlayful: isPlayful),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.medium),
          width: 1,
        ),
      ),
      child: Icon(
        Icons.assignment_rounded,
        color: color,
        size: isPlayful ? AppIconSize.lg : AppIconSize.md,
      ),
    );
  }

  /// Builds the main content column.
  Widget _buildContent(ThemeData theme, bool isPastDue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          assignment.title,
          style: AppTypography.cardTitle(isPlayful: isPlayful).copyWith(
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppSpacing.gap4,

        // Metadata row (subject + due date)
        _buildMetadataRow(theme, isPastDue),

        // Description (if available)
        if (assignment.description?.isNotEmpty ?? false) ...[
          AppSpacing.gapSm,
          _buildDescription(theme),
        ],
      ],
    );
  }

  /// Builds the metadata row with subject and due date.
  Widget _buildMetadataRow(ThemeData theme, bool isPastDue) {
    final textColor = theme.colorScheme.onSurfaceVariant;
    final errorColor = isPlayful ? PlayfulColors.error : CleanColors.error;

    return Row(
      children: [
        // Subject
        if (assignment.subjectName != null) ...[
          _MetadataChip(
            icon: Icons.menu_book_rounded,
            label: assignment.subjectName!,
            color: textColor,
            isPlayful: isPlayful,
          ),
          AppSpacing.gapH12,
        ],

        // Due date
        if (assignment.dueDate != null)
          _MetadataChip(
            icon: Icons.calendar_today_rounded,
            label: DateFormat('MMM d').format(assignment.dueDate!),
            color: isPastDue ? errorColor : textColor,
            isPlayful: isPlayful,
            isBold: isPastDue,
          ),
      ],
    );
  }

  /// Builds the description text.
  Widget _buildDescription(ThemeData theme) {
    return Text(
      assignment.description!,
      style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
        color: theme.colorScheme.onSurfaceVariant.withValues(
          alpha: AppOpacity.dominant,
        ),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Builds the actions column with status badge and delete button.
  Widget _buildActionsColumn(ThemeData theme, bool isPastDue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status badge
        _StatusBadge(
          isPastDue: isPastDue,
          isPlayful: isPlayful,
        ),

        // Delete button
        if (onDelete != null) ...[
          AppSpacing.gapSm,
          AppButton.icon(
            icon: Icons.delete_outline_rounded,
            onPressed: onDelete,
            size: ButtonSize.small,
            foregroundColor: isPlayful ? PlayfulColors.error : CleanColors.error,
            tooltip: 'Delete assignment',
          ),
        ],
      ],
    );
  }
}

/// A compact chip displaying metadata with icon.
class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isPlayful,
    this.isBold = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isPlayful;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: AppIconSize.xs,
          color: color,
        ),
        SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppFontSize.labelSmall,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A status badge indicating assignment state.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isPastDue,
    required this.isPlayful,
  });

  final bool isPastDue;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final color = isPastDue
        ? (isPlayful ? PlayfulColors.error : CleanColors.error)
        : (isPlayful ? PlayfulColors.success : CleanColors.success);

    final label = isPastDue ? 'Past Due' : 'Active';
    final icon = isPastDue ? Icons.warning_amber_rounded : Icons.check_circle_outline;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: AppOpacity.soft),
        borderRadius: AppRadius.badge(isPlayful: isPlayful),
        border: Border.all(
          color: color.withValues(alpha: AppOpacity.medium),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: AppIconSize.xs,
            color: color,
          ),
          SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSize.labelSmall,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
