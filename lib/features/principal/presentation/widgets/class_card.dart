import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../domain/entities/class_with_details.dart';

// =============================================================================
// CLASS CARD - Principal Dashboard Class Display
// =============================================================================
// A premium card component for displaying class information with proper
// hierarchy, theme-aware styling, and interactive actions.
//
// Features:
// - Uses AppCard.interactive for consistent card styling
// - AppTypography for all text styles
// - AppSpacing for all margins/padding
// - AppRadius for border radius
// - AppShadows for elevation
// - Theme-aware colors (Clean vs Playful)
// =============================================================================

/// A card widget displaying class information with premium styling.
///
/// Shows the class name, grade level, head teacher, student count,
/// and provides action buttons. Uses design system tokens for
/// consistent styling across themes.
class ClassCard extends StatelessWidget {
  /// Creates a [ClassCard].
  const ClassCard({
    super.key,
    required this.classDetails,
    this.onEdit,
    this.onAssignTeacher,
    this.onViewStudents,
    this.onDelete,
  });

  /// The class details to display.
  final ClassWithDetails classDetails;

  /// Callback when the edit action is triggered.
  final VoidCallback? onEdit;

  /// Callback when assign head teacher is triggered.
  final VoidCallback? onAssignTeacher;

  /// Callback when view students is triggered.
  final VoidCallback? onViewStudents;

  /// Callback when delete is triggered.
  final VoidCallback? onDelete;

  /// Detects if the current theme is playful.
  bool _isPlayful(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return primaryColor.toARGB32() == PlayfulColors.primary.toARGB32() ||
        (primaryColor.r * 255 > 100 && primaryColor.b * 255 > 200);
  }

  @override
  Widget build(BuildContext context) {
    final isPlayful = _isPlayful(context);

    return AppCard.interactive(
      onTap: onViewStudents,
      semanticLabel: 'Class ${classDetails.name}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon, info, and actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Class icon container
              _ClassIconBadge(isPlayful: isPlayful),
              SizedBox(width: AppSpacing.md),
              // Class info
              Expanded(
                child: _ClassInfo(
                  classDetails: classDetails,
                  isPlayful: isPlayful,
                ),
              ),
              // Actions menu
              _ActionsMenu(
                isPlayful: isPlayful,
                onEdit: onEdit,
                onAssignTeacher: onAssignTeacher,
                onViewStudents: onViewStudents,
                onDelete: onDelete,
              ),
            ],
          ),
          // Divider
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(
              height: 1,
              color: isPlayful ? PlayfulColors.divider : CleanColors.divider,
            ),
          ),
          // Bottom row with head teacher and student count
          Row(
            children: [
              // Head teacher info
              Expanded(
                child: _InfoItem(
                  icon: Icons.school_outlined,
                  label: 'Head Teacher',
                  value: classDetails.headTeacher?.fullName ?? 'Not assigned',
                  isPlaceholder: classDetails.headTeacher == null,
                  isPlayful: isPlayful,
                ),
              ),
              // Vertical divider
              Container(
                height: AppSpacing.xxxl,
                width: 1,
                color: isPlayful ? PlayfulColors.divider : CleanColors.divider,
              ),
              // Student count
              Expanded(
                child: _InfoItem(
                  icon: Icons.people_outline,
                  label: 'Students',
                  value: classDetails.studentCount.toString(),
                  isPlayful: isPlayful,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUBCOMPONENTS
// =============================================================================

/// Icon badge for the class card header.
class _ClassIconBadge extends StatelessWidget {
  const _ClassIconBadge({required this.isPlayful});

  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        isPlayful ? PlayfulColors.primary : CleanColors.primary;
    final backgroundColor =
        isPlayful ? PlayfulColors.primarySubtle : CleanColors.primarySubtle;

    return Container(
      width: AppSpacing.xxxxl,
      height: AppSpacing.xxxxl,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.button(isPlayful: isPlayful),
      ),
      child: Icon(
        Icons.class_outlined,
        color: primaryColor,
        size: AppIconSize.lg,
      ),
    );
  }
}

/// Class information section showing name, grade, and academic year.
class _ClassInfo extends StatelessWidget {
  const _ClassInfo({
    required this.classDetails,
    required this.isPlayful,
  });

  final ClassWithDetails classDetails;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Class name
        Text(
          classDetails.name,
          style: AppTypography.cardTitle(isPlayful: isPlayful),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: AppSpacing.xxs),
        // Grade level
        if (classDetails.gradeLevel != null)
          Text(
            'Grade ${classDetails.gradeLevel}',
            style: AppTypography.secondaryText(isPlayful: isPlayful),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        // Academic year
        if (classDetails.academicYear case final academicYear?) ...[
          SizedBox(height: AppSpacing.space2),
          Text(
            academicYear,
            style: AppTypography.tertiaryText(isPlayful: isPlayful),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

/// Popup menu with card actions.
class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({
    required this.isPlayful,
    this.onEdit,
    this.onAssignTeacher,
    this.onViewStudents,
    this.onDelete,
  });

  final bool isPlayful;
  final VoidCallback? onEdit;
  final VoidCallback? onAssignTeacher;
  final VoidCallback? onViewStudents;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary;

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: iconColor,
        size: AppIconSize.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card(isPlayful: isPlayful),
      ),
      elevation: isPlayful ? AppElevation.md : AppElevation.sm,
      itemBuilder: (context) => [
        _buildMenuItem(
          context: context,
          value: 'edit',
          icon: Icons.edit_outlined,
          label: 'Edit Class',
        ),
        _buildMenuItem(
          context: context,
          value: 'assign',
          icon: Icons.person_add_outlined,
          label: 'Assign Head Teacher',
        ),
        _buildMenuItem(
          context: context,
          value: 'students',
          icon: Icons.people_outline,
          label: 'View Students',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context: context,
          value: 'delete',
          icon: Icons.delete_outline,
          label: 'Delete Class',
          isDestructive: true,
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
          case 'assign':
            onAssignTeacher?.call();
          case 'students':
            onViewStudents?.call();
          case 'delete':
            onDelete?.call();
        }
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required BuildContext context,
    required String value,
    required IconData icon,
    required String label,
    bool isDestructive = false,
  }) {
    final textColor = isDestructive
        ? (isPlayful ? PlayfulColors.error : CleanColors.error)
        : (isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary);

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.sm, color: textColor),
          SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info item showing icon, value, and label for bottom stats.
class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.isPlayful,
    this.isPlaceholder = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isPlayful;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    final iconColor = isPlaceholder
        ? (isPlayful ? PlayfulColors.textMuted : CleanColors.textMuted)
        : (isPlayful ? PlayfulColors.textSecondary : CleanColors.textSecondary);

    final valueColor = isPlaceholder
        ? (isPlayful ? PlayfulColors.textDisabled : CleanColors.textDisabled)
        : (isPlayful ? PlayfulColors.textPrimary : CleanColors.textPrimary);

    final labelColor =
        isPlayful ? PlayfulColors.textTertiary : CleanColors.textTertiary;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        children: [
          Icon(
            icon,
            size: AppIconSize.sm,
            color: iconColor,
          ),
          SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTypography.secondaryText(isPlayful: isPlayful).copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor,
              fontStyle: isPlaceholder ? FontStyle.italic : FontStyle.normal,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: AppSpacing.space2),
          Text(
            label,
            style: AppTypography.caption(isPlayful: isPlayful).copyWith(
              color: labelColor,
            ),
          ),
        ],
      ),
    );
  }
}
