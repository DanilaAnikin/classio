import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/supabase_absence_excuse_repository.dart';
import '../../domain/entities/absence_excuse.dart';
import '../../domain/repositories/absence_excuse_repository.dart';

part 'absence_excuse_provider.g.dart';

/// Provider for the AbsenceExcuseRepository instance.
@riverpod
AbsenceExcuseRepository absenceExcuseRepository(Ref ref) {
  return SupabaseAbsenceExcuseRepository();
}

// ============== Parent Providers ==============

/// Provider for all excuses submitted by the parent for a specific child.
@riverpod
Future<List<AbsenceExcuse>> childAbsenceExcuses(
  Ref ref,
  String childId,
) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getExcusesForChild(childId);
}

/// Provider for pending excuses for a specific child.
@riverpod
Future<List<AbsenceExcuse>> pendingChildAbsenceExcuses(
  Ref ref,
  String childId,
) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getPendingExcusesForChild(childId);
}

/// Provider for all excuses submitted by the parent across all children.
@riverpod
Future<List<AbsenceExcuse>> allParentAbsenceExcuses(Ref ref) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getAllParentExcuses();
}

/// Provider for checking if an excuse exists for an attendance record.
@riverpod
Future<AbsenceExcuse?> excuseForAttendance(
  Ref ref,
  String attendanceId,
) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getExcuseByAttendanceId(attendanceId);
}

// ============== Teacher Providers ==============

/// Provider for pending excuses that need teacher review.
@riverpod
Future<List<AbsenceExcuse>> teacherPendingExcuses(Ref ref) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getPendingExcusesForTeacher();
}

/// Provider for all excuses for the teacher's classes.
@riverpod
Future<List<AbsenceExcuse>> teacherAllExcuses(Ref ref) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getAllExcusesForTeacher();
}

/// Provider for the count of pending excuses for the teacher.
@riverpod
int teacherPendingExcuseCount(Ref ref) {
  final excusesAsync = ref.watch(teacherPendingExcusesProvider);
  return excusesAsync.when(
    data: (excuses) => excuses.length,
    loading: () => 0,
    error: (_, _) => 0,
  );
}

// ============== Student Providers ==============

/// Provider for the student's own excuses.
@riverpod
Future<List<AbsenceExcuse>> studentAbsenceExcuses(Ref ref) async {
  final repository = ref.watch(absenceExcuseRepositoryProvider);
  return repository.getStudentExcuses();
}

// ============== Action Notifiers ==============

/// State class for submission/review operations.
class ExcuseOperationState {
  const ExcuseOperationState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.result,
  });

  final bool isLoading;
  final String? error;
  final bool success;
  final AbsenceExcuse? result;

  ExcuseOperationState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    AbsenceExcuse? result,
  }) {
    return ExcuseOperationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
      result: result ?? this.result,
    );
  }
}

/// Notifier for submitting absence excuses (parent action).
@riverpod
class ExcuseSubmitter extends _$ExcuseSubmitter {
  @override
  ExcuseOperationState build() {
    return const ExcuseOperationState();
  }

  /// Submits an absence excuse for an attendance record.
  Future<void> submitExcuse({
    required String attendanceId,
    required String studentId,
    required String reason,
  }) async {
    state = const ExcuseOperationState(isLoading: true);

    try {
      final repository = ref.read(absenceExcuseRepositoryProvider);
      final result = await repository.submitExcuse(
        attendanceId: attendanceId,
        studentId: studentId,
        reason: reason,
      );

      state = ExcuseOperationState(success: true, result: result);

      // Invalidate related providers to refresh data
      ref.invalidate(childAbsenceExcusesProvider(studentId));
      ref.invalidate(pendingChildAbsenceExcusesProvider(studentId));
      ref.invalidate(allParentAbsenceExcusesProvider);
      ref.invalidate(excuseForAttendanceProvider(attendanceId));
    } catch (e) {
      state = ExcuseOperationState(error: e.toString());
    }
  }

  /// Resets the state.
  void reset() {
    state = const ExcuseOperationState();
  }
}

/// Notifier for reviewing absence excuses (teacher action).
@riverpod
class ExcuseReviewer extends _$ExcuseReviewer {
  @override
  ExcuseOperationState build() {
    return const ExcuseOperationState();
  }

  /// Approves an absence excuse.
  Future<void> approveExcuse(String excuseId) async {
    state = const ExcuseOperationState(isLoading: true);

    try {
      final repository = ref.read(absenceExcuseRepositoryProvider);
      final result = await repository.approveExcuse(excuseId);

      state = ExcuseOperationState(success: true, result: result);

      // Invalidate teacher providers to refresh data
      ref.invalidate(teacherPendingExcusesProvider);
      ref.invalidate(teacherAllExcusesProvider);
    } catch (e) {
      state = ExcuseOperationState(error: e.toString());
    }
  }

  /// Declines an absence excuse with an optional response.
  Future<void> declineExcuse(String excuseId, {String? response}) async {
    state = const ExcuseOperationState(isLoading: true);

    try {
      final repository = ref.read(absenceExcuseRepositoryProvider);
      final result = await repository.declineExcuse(excuseId, response: response);

      state = ExcuseOperationState(success: true, result: result);

      // Invalidate teacher providers to refresh data
      ref.invalidate(teacherPendingExcusesProvider);
      ref.invalidate(teacherAllExcusesProvider);
    } catch (e) {
      state = ExcuseOperationState(error: e.toString());
    }
  }

  /// Resets the state.
  void reset() {
    state = const ExcuseOperationState();
  }
}

/// Provider for filtering excuse list by status.
@riverpod
class ExcuseStatusFilter extends _$ExcuseStatusFilter {
  @override
  AbsenceExcuseStatus? build() {
    return null; // null means show all
  }

  void setFilter(AbsenceExcuseStatus? status) {
    state = status;
  }

  void clearFilter() {
    state = null;
  }
}

/// Provider for filtered excuses based on current filter.
@riverpod
Future<List<AbsenceExcuse>> filteredTeacherExcuses(Ref ref) async {
  final filter = ref.watch(excuseStatusFilterProvider);
  final allExcuses = await ref.watch(teacherAllExcusesProvider.future);

  if (filter == null) {
    return allExcuses;
  }

  return allExcuses.where((e) => e.status == filter).toList();
}
