import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../../data/repositories/supabase_student_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/student_repository.dart';

part 'student_provider.g.dart';

/// Provider for the StudentRepository instance.
@riverpod
StudentRepository studentRepository(Ref ref) {
  return SupabaseStudentRepository();
}

// ============== Attendance Providers ==============

/// Provider for the student's attendance records.
@riverpod
Future<List<AttendanceEntity>> myAttendance(
  Ref ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getMyAttendance(startDate: startDate, endDate: endDate);
}

/// Provider for the student's attendance statistics.
@riverpod
Future<AttendanceStats> myAttendanceStats(Ref ref, {String? month}) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getMyAttendanceStats(month);
}

/// Provider for the attendance calendar data.
@riverpod
Future<Map<DateTime, DailyAttendanceStatus>> attendanceCalendar(
  Ref ref,
  int month,
  int year,
) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getAttendanceCalendar(month, year);
}

/// Provider for recent attendance issues.
@riverpod
Future<List<AttendanceEntity>> recentAttendanceIssues(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getRecentAttendanceIssues();
}

// ============== Grades Providers ==============

/// Provider for the student's grades.
@riverpod
Future<List<SubjectGradeStats>> myGrades(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getMyGrades();
}

/// Provider for subject averages.
@riverpod
Future<Map<String, double>> subjectAverages(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getSubjectAverages();
}

/// Provider for recent grades.
@riverpod
Future<List<Grade>> recentGrades(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getRecentGrades();
}

/// Provider for the overall grade average.
@riverpod
double myOverallAverage(Ref ref) {
  final gradesAsync = ref.watch(myGradesProvider);
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

// ============== Schedule Providers ==============

/// Provider for today's lessons.
@riverpod
Future<List<Lesson>> myTodaysLessons(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getTodaysLessons();
}

/// Provider for the weekly schedule.
@riverpod
Future<Map<int, List<Lesson>>> myWeeklySchedule(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getWeeklySchedule();
}

// ============== Assignment Providers ==============

/// Provider for upcoming assignments.
@riverpod
Future<List<Assignment>> myUpcomingAssignments(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getUpcomingAssignments();
}

/// Provider for all assignments.
@riverpod
Future<List<Assignment>> myAssignments(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getMyAssignments();
}

/// Provider for assignment submissions.
@riverpod
Future<List<AssignmentSubmission>> mySubmissions(Ref ref) async {
  final repository = ref.watch(studentRepositoryProvider);
  return repository.getMySubmissions();
}

// ============== State Providers ==============

/// Provider for the selected month in attendance view.
@riverpod
class SelectedAttendanceMonth extends _$SelectedAttendanceMonth {
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

/// Notifier for submitting assignments.
@riverpod
class AssignmentSubmitter extends _$AssignmentSubmitter {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> submit(
    String assignmentId, {
    String? content,
    String? fileUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(studentRepositoryProvider);
      await repository.submitAssignment(
        assignmentId,
        content: content,
        fileUrl: fileUrl,
      );
      state = const AsyncValue.data(null);
      // Refresh assignments after submission
      ref.invalidate(myUpcomingAssignmentsProvider);
      ref.invalidate(myAssignmentsProvider);
      ref.invalidate(mySubmissionsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
