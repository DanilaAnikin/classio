import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../../../student/domain/entities/entities.dart';
import '../../data/repositories/supabase_parent_repository.dart';
import '../../domain/repositories/parent_repository.dart';

part 'parent_provider.g.dart';

/// Provider for the ParentRepository instance.
@riverpod
ParentRepository parentRepository(Ref ref) {
  return SupabaseParentRepository();
}

// ============== Children Providers ==============

/// Provider for the parent's children.
@riverpod
Future<List<AppUser>> myChildren(Ref ref) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getMyChildren();
}

/// Provider for the currently selected child.
@riverpod
class SelectedChild extends _$SelectedChild {
  @override
  String? build() {
    // Auto-select first child when children are loaded
    ref.listen(myChildrenProvider, (previous, next) {
      next.whenData((children) {
        if (children.isNotEmpty && state == null) {
          state = children.first.id;
        }
      });
    });
    return null;
  }

  void selectChild(String childId) {
    state = childId;
  }
}

/// Provider for the currently selected child's data.
@riverpod
AppUser? selectedChildData(Ref ref) {
  final selectedChildId = ref.watch(selectedChildProvider);
  final childrenAsync = ref.watch(myChildrenProvider);

  if (selectedChildId == null) return null;

  return childrenAsync.whenData((children) {
    return children.firstWhere(
      (child) => child.id == selectedChildId,
      orElse: () => children.first,
    );
  }).valueOrNull;
}

// ============== Child Attendance Providers ==============

/// Provider for a child's attendance records.
@riverpod
Future<List<AttendanceEntity>> childAttendance(
  Ref ref,
  String childId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildAttendance(
    childId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Provider for a child's attendance statistics.
@riverpod
Future<AttendanceStats> childAttendanceStats(
  Ref ref,
  String childId, {
  String? month,
}) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildAttendanceStats(childId, month);
}

/// Provider for a child's attendance calendar.
@riverpod
Future<Map<DateTime, DailyAttendanceStatus>> childAttendanceCalendar(
  Ref ref,
  String childId,
  int month,
  int year,
) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildAttendanceCalendar(childId, month, year);
}

/// Provider for a child's attendance issues.
@riverpod
Future<List<AttendanceEntity>> childAttendanceIssues(
  Ref ref,
  String childId,
) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildAttendanceIssues(childId);
}

// ============== Child Grades Providers ==============

/// Provider for a child's grades.
@riverpod
Future<List<SubjectGradeStats>> childGrades(Ref ref, String childId) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildGrades(childId);
}

/// Provider for a child's subject averages.
@riverpod
Future<Map<String, double>> childSubjectAverages(
  Ref ref,
  String childId,
) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildSubjectAverages(childId);
}

/// Provider for the selected child's overall grade average.
@riverpod
double childOverallAverage(Ref ref, String childId) {
  final gradesAsync = ref.watch(childGradesProvider(childId));
  return gradesAsync.when(
    data: (grades) {
      if (grades.isEmpty) return 0.0;
      final sum = grades.fold<double>(0.0, (sum, s) => sum + s.average);
      return sum / grades.length;
    },
    loading: () => 0.0,
    error: (_, _) => 0.0,
  );
}

// ============== Child Schedule Providers ==============

/// Provider for a child's today's lessons.
@riverpod
Future<List<Lesson>> childTodaysLessons(Ref ref, String childId) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildTodaysLessons(childId);
}

/// Provider for a child's weekly schedule.
@riverpod
Future<Map<int, List<Lesson>>> childWeeklySchedule(
  Ref ref,
  String childId,
) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildWeeklySchedule(childId);
}

/// Provider for a child's weekly schedule for a specific week.
///
/// Takes a record with childId and weekStart to fetch schedule
/// for any given week (not just current week).
@riverpod
Future<Map<int, List<Lesson>>> childWeeklyScheduleForWeek(
  Ref ref,
  ({String childId, DateTime weekStart}) params,
) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildWeeklyScheduleForWeek(params.childId, params.weekStart);
}

// ============== Child Assignments Providers ==============

/// Provider for a child's upcoming assignments.
@riverpod
Future<List<Assignment>> childAssignments(Ref ref, String childId) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getChildAssignments(childId);
}

// ============== Excuse Providers ==============

/// Provider for a child's pending excuses.
@riverpod
Future<List<AttendanceEntity>> pendingExcuses(Ref ref, String childId) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getPendingExcuses(childId);
}

/// Provider for all excuses for a child.
@riverpod
Future<List<AttendanceEntity>> allExcuses(Ref ref, String childId) async {
  final repository = ref.watch(parentRepositoryProvider);
  return repository.getAllExcuses(childId);
}

/// Notifier for submitting excuses.
@riverpod
class ExcuseSubmitter extends _$ExcuseSubmitter {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> submitExcuse(
    String attendanceId,
    String excuseNote, {
    String? attachmentUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(parentRepositoryProvider);
      await repository.submitExcuse(
        attendanceId,
        excuseNote,
        attachmentUrl: attachmentUrl,
      );
      state = const AsyncValue.data(null);

      // Refresh attendance data after submission
      // Get the selected child and invalidate their providers
      final selectedChildId = ref.read(selectedChildProvider);
      if (selectedChildId != null) {
        ref.invalidate(childAttendanceProvider(selectedChildId));
        ref.invalidate(childAttendanceIssuesProvider(selectedChildId));
        ref.invalidate(pendingExcusesProvider(selectedChildId));
        ref.invalidate(allExcusesProvider(selectedChildId));
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// ============== State Providers ==============

/// Provider for the selected month in attendance view.
@riverpod
class ParentSelectedAttendanceMonth extends _$ParentSelectedAttendanceMonth {
  @override
  DateTime build() {
    return DateTime.now();
  }

  void setMonth(DateTime month) {
    state = DateTime(month.year, month.month, 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1, 1);
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1, 1);
  }
}
