import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/attendance_entity.dart';

/// A card widget displaying a pending excuse request.
class ExcuseCard extends StatelessWidget {
  const ExcuseCard({
    super.key,
    required this.attendance,
    required this.isPlayful,
    required this.onApprove,
    required this.onReject,
  });

  final AttendanceEntity attendance;
  final bool isPlayful;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 16 : 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
        color: theme.colorScheme.surface,
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.08),
            blurRadius: isPlayful ? 12 : 6,
            offset: Offset(0, isPlayful ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              CircleAvatar(
                radius: isPlayful ? 22 : 20,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: attendance.studentAvatarUrl != null
                    ? NetworkImage(attendance.studentAvatarUrl!)
                    : null,
                child: attendance.studentAvatarUrl == null
                    ? Text(
                        attendance.studentName?.isNotEmpty == true
                            ? attendance.studentName![0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: isPlayful ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.studentName ?? 'Unknown Student',
                      style: TextStyle(
                        fontSize: isPlayful ? 16 : 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('EEEE, MMMM d').format(attendance.date),
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(attendance.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  attendance.status.displayName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(attendance.status),
                  ),
                ),
              ),
            ],
          ),

          // Excuse Note
          if (attendance.excuseNote != null &&
              attendance.excuseNote!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isPlayful ? 14 : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Excuse Note',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    attendance.excuseNote!,
                    style: TextStyle(
                      fontSize: isPlayful ? 14 : 13,
                      color: theme.colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: onReject,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Reject'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: onApprove,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Approve'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Colors.green;
      case AttendanceStatus.absent:
        return Colors.red;
      case AttendanceStatus.late:
        return Colors.orange;
      case AttendanceStatus.excused:
        return Colors.blue;
    }
  }
}
