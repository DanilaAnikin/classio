import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../shared/widgets/responsive_center.dart';
import '../../../attendance/presentation/providers/absence_excuse_provider.dart';
import '../../../student/domain/entities/entities.dart';

/// Page for parents to submit an absence excuse for an attendance record.
///
/// This page shows the attendance details and provides a form to enter
/// the excuse reason.
class SubmitAbsenceExcusePage extends ConsumerStatefulWidget {
  const SubmitAbsenceExcusePage({
    super.key,
    required this.childId,
    required this.attendanceId,
    this.attendance,
  });

  /// The child (student) ID.
  final String childId;

  /// The attendance record ID to excuse.
  final String attendanceId;

  /// Optional pre-loaded attendance entity for display.
  final AttendanceEntity? attendance;

  @override
  ConsumerState<SubmitAbsenceExcusePage> createState() =>
      _SubmitAbsenceExcusePageState();
}

class _SubmitAbsenceExcusePageState
    extends ConsumerState<SubmitAbsenceExcusePage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlayful = ref.watch(themeNotifierProvider) == ThemeType.playful;
    final submitterState = ref.watch(excuseSubmitterProvider);
    final existingExcuse = ref.watch(
      excuseForAttendanceProvider(widget.attendanceId),
    );

    // Listen for submission success
    ref.listen(excuseSubmitterProvider, (previous, current) {
      if (current.success && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Excuse submitted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
          ),
        );
        ref.read(excuseSubmitterProvider.notifier).reset();
        context.pop();
      } else if (current.error != null && !current.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${current.error}'),
            backgroundColor: theme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isPlayful ? 12 : 8),
            ),
          ),
        );
        ref.read(excuseSubmitterProvider.notifier).reset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Excuse'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveCenterScrollView(
        maxWidth: 600,
        padding: EdgeInsets.all(isPlayful ? 20 : 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Attendance Info Card
              if (widget.attendance case final attendance?) ...[
                _AttendanceInfoCard(
                  attendance: attendance,
                  isPlayful: isPlayful,
                ),
                SizedBox(height: isPlayful ? 24 : 20),
              ],

              // Check if excuse already exists
              existingExcuse.when(
                data: (excuse) {
                  if (excuse != null) {
                    return _ExistingExcuseCard(
                      status: excuse.status.label,
                      reason: excuse.reason,
                      teacherResponse: excuse.teacherResponse,
                      isPlayful: isPlayful,
                    );
                  }
                  return _ExcuseFormSection(
                    formKey: _formKey,
                    reasonController: _reasonController,
                    isPlayful: isPlayful,
                    isLoading: submitterState.isLoading,
                    onSubmit: _submitExcuse,
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => _ExcuseFormSection(
                  formKey: _formKey,
                  reasonController: _reasonController,
                  isPlayful: isPlayful,
                  isLoading: submitterState.isLoading,
                  onSubmit: _submitExcuse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitExcuse() {
    if (_formKey.currentState?.validate() != true) return;
    ref.read(excuseSubmitterProvider.notifier).submitExcuse(
          attendanceId: widget.attendanceId,
          studentId: widget.childId,
          reason: _reasonController.text.trim(),
        );
  }
}

/// Card showing attendance record information.
class _AttendanceInfoCard extends StatelessWidget {
  const _AttendanceInfoCard({
    required this.attendance,
    required this.isPlayful,
  });

  final AttendanceEntity attendance;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isPlayful ? 20 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isPlayful ? 20 : 12),
        color: attendance.status.color.withValues(alpha: 0.1),
        border: Border.all(
          color: attendance.status.color.withValues(alpha: 0.3),
          width: isPlayful ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: attendance.status.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
                ),
                child: Icon(
                  attendance.status.icon,
                  color: attendance.status.color,
                  size: isPlayful ? 28 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attendance.status.label,
                      style: TextStyle(
                        fontSize: isPlayful ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        color: attendance.status.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(attendance.date),
                      style: TextStyle(
                        fontSize: isPlayful ? 14 : 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (attendance.subjectName case final subjectName?) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.book_outlined,
                  size: isPlayful ? 18 : 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  subjectName,
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (attendance.lessonStartTime case final lessonStartTime?) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: isPlayful ? 18 : 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('HH:mm').format(lessonStartTime)}${attendance.lessonEndTime != null ? ' - ${DateFormat('HH:mm').format(attendance.lessonEndTime!)}' : ''}',
                  style: TextStyle(
                    fontSize: isPlayful ? 14 : 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Card showing an existing excuse.
class _ExistingExcuseCard extends StatelessWidget {
  const _ExistingExcuseCard({
    required this.status,
    required this.reason,
    this.teacherResponse,
    required this.isPlayful,
  });

  final String status;
  final String reason;
  final String? teacherResponse;
  final bool isPlayful;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(isPlayful ? 20 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: isPlayful ? 24 : 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Excuse Already Submitted',
                      style: TextStyle(
                        fontSize: isPlayful ? 17 : 15,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isPlayful ? 12 : 10,
                      vertical: isPlayful ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(isPlayful ? 10 : 6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: isPlayful ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Your Reason:',
                style: TextStyle(
                  fontSize: isPlayful ? 13 : 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                style: TextStyle(
                  fontSize: isPlayful ? 15 : 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (teacherResponse?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'Teacher Response:',
                  style: TextStyle(
                    fontSize: isPlayful ? 13 : 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  teacherResponse ?? '',
                  style: TextStyle(
                    fontSize: isPlayful ? 15 : 14,
                    color: theme.colorScheme.onSurface,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }
}

/// Form section for entering excuse reason.
class _ExcuseFormSection extends StatelessWidget {
  const _ExcuseFormSection({
    required this.formKey,
    required this.reasonController,
    required this.isPlayful,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController reasonController;
  final bool isPlayful;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Excuse Reason',
          style: TextStyle(
            fontSize: isPlayful ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: isPlayful ? 12 : 8),
        TextFormField(
          controller: reasonController,
          maxLines: 6,
          decoration: InputDecoration(
            hintText:
                'Please explain the reason for the absence or tardiness...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isPlayful ? 16 : 12),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerLow,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a reason for the excuse';
            }
            if (value.trim().length < 10) {
              return 'Please provide a more detailed reason';
            }
            return null;
          },
        ),
        SizedBox(height: isPlayful ? 16 : 12),
        Text(
          'Your excuse will be reviewed by the teacher. You will be notified once it has been processed.',
          style: TextStyle(
            fontSize: isPlayful ? 13 : 12,
            color: theme.colorScheme.onSurfaceVariant,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: isPlayful ? 32 : 24),
        FilledButton.icon(
          onPressed: isLoading ? null : onSubmit,
          icon: isLoading
              ? SizedBox(
                  width: isPlayful ? 22 : 20,
                  height: isPlayful ? 22 : 20,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  size: isPlayful ? 22 : 20,
                ),
          label: Text(
            isLoading ? 'Submitting...' : 'Submit Excuse',
            style: TextStyle(
              fontSize: isPlayful ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(
              vertical: isPlayful ? 16 : 14,
              horizontal: isPlayful ? 24 : 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isPlayful ? 14 : 10),
            ),
          ),
        ),
      ],
    );
  }
}
