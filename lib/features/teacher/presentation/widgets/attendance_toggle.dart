import 'package:flutter/material.dart';

import '../../domain/entities/attendance_entity.dart';

/// A toggle button group for attendance status.
class AttendanceToggle extends StatelessWidget {
  const AttendanceToggle({
    super.key,
    required this.status,
    required this.onStatusChanged,
    required this.isPlayful,
  });

  final AttendanceStatus status;
  final ValueChanged<AttendanceStatus> onStatusChanged;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleButton(
          icon: Icons.check_rounded,
          label: 'P',
          color: Colors.green,
          isSelected: status == AttendanceStatus.present,
          onTap: () => onStatusChanged(AttendanceStatus.present),
          isPlayful: isPlayful,
          isFirst: true,
        ),
        _ToggleButton(
          icon: Icons.close_rounded,
          label: 'A',
          color: Colors.red,
          isSelected: status == AttendanceStatus.absent,
          onTap: () => onStatusChanged(AttendanceStatus.absent),
          isPlayful: isPlayful,
        ),
        _ToggleButton(
          icon: Icons.schedule_rounded,
          label: 'L',
          color: Colors.orange,
          isSelected: status == AttendanceStatus.late,
          onTap: () => onStatusChanged(AttendanceStatus.late),
          isPlayful: isPlayful,
          isLast: true,
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.isPlayful,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isPlayful;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? Radius.circular(isPlayful ? 12 : 8) : Radius.zero,
          right: isLast ? Radius.circular(isPlayful ? 12 : 8) : Radius.zero,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isPlayful ? 44 : 40,
          height: isPlayful ? 40 : 36,
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.horizontal(
              left: isFirst ? Radius.circular(isPlayful ? 12 : 8) : Radius.zero,
              right: isLast ? Radius.circular(isPlayful ? 12 : 8) : Radius.zero,
            ),
            border: Border.all(
              color: isSelected
                  ? color
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: isSelected
                ? Icon(
                    icon,
                    color: color,
                    size: isPlayful ? 22 : 20,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: isPlayful ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
