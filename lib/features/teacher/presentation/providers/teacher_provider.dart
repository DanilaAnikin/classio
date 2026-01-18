import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../dashboard/domain/entities/lesson.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../data/repositories/supabase_teacher_repository.dart';
import '../../domain/domain.dart';

part 'teacher_provider.g.dart';

// ========== Repository Provider ==========

/// Provider for the [TeacherRepository] implementation.
@riverpod
TeacherRepository teacherRepository(Ref ref) {
  return SupabaseTeacherRepository();
}

// ========== My Subjects/Classes Providers ==========

/// Provider for fetching teacher's subjects.
@riverpod
Future<List<Subject>> mySubjects(Ref ref) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getMySubjects();
}

/// Provider for fetching teacher's classes.
@riverpod
Future<List<ClassInfo>> myClasses(Ref ref) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getMyClasses();
}

// ========== Selection State Providers ==========

/// Currently selected subject ID.
@riverpod
class SelectedSubject extends _$SelectedSubject {
  @override
  String? build() => null;

  void select(String? subjectId) => state = subjectId;
}

/// Currently selected class ID.
@riverpod
class SelectedClass extends _$SelectedClass {
  @override
  String? build() => null;

  void select(String? classId) => state = classId;
}

/// Currently selected date for attendance.
@riverpod
class SelectedDate extends _$SelectedDate {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) => state = date;
}

// ========== Gradebook Providers ==========

/// Provider for fetching students in a class.
@riverpod
Future<List<AppUser>> classStudents(Ref ref, String classId) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getClassStudents(classId);
}

/// Provider for fetching students for a subject.
@riverpod
Future<List<AppUser>> subjectStudents(Ref ref, String subjectId) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getSubjectStudents(subjectId);
}

/// Provider for fetching grades for a subject.
@riverpod
Future<List<TeacherGradeEntity>> subjectGrades(Ref ref, String subjectId) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getSubjectGrades(subjectId);
}

/// Provider for fetching a student's grades in a subject.
@riverpod
Future<List<TeacherGradeEntity>> studentGrades(
  Ref ref,
  String studentId,
  String subjectId,
) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getStudentGrades(studentId, subjectId);
}

/// Notifier for adding grades.
@riverpod
class AddGradeNotifier extends _$AddGradeNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> addGrade({
    required String studentId,
    required String subjectId,
    required double score,
    double weight = 1.0,
    String? gradeType,
    String? comment,
    String? assignmentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.addGrade(
        studentId: studentId,
        subjectId: subjectId,
        score: score,
        weight: weight,
        gradeType: gradeType,
        comment: comment,
        assignmentId: assignmentId,
      );
      state = const AsyncValue.data(null);
      // Invalidate grades to refresh
      ref.invalidate(subjectGradesProvider(subjectId));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateGrade(TeacherGradeEntity grade) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.updateGrade(grade);
      state = const AsyncValue.data(null);
      ref.invalidate(subjectGradesProvider(grade.subjectId));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteGrade(String gradeId, String subjectId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.deleteGrade(gradeId);
      state = const AsyncValue.data(null);
      ref.invalidate(subjectGradesProvider(subjectId));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

// ========== Attendance Providers ==========

/// Provider for today's lessons.
@riverpod
Future<List<Lesson>> todaysLessons(Ref ref) async {
  final date = ref.watch(selectedDateProvider);
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getTodaysLessons(date);
}

/// Provider for lesson attendance.
@riverpod
Future<List<AttendanceEntity>> lessonAttendance(
  Ref ref,
  String lessonId,
  DateTime date,
) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getLessonAttendance(lessonId, date);
}

/// Provider for students in a lesson.
@riverpod
Future<List<AppUser>> lessonStudents(Ref ref, String lessonId) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getStudentsForLesson(lessonId);
}

/// Notifier for managing attendance marking state.
@riverpod
class AttendanceNotifier extends _$AttendanceNotifier {
  @override
  Map<String, AttendanceStatus> build() => {};

  void setStatus(String studentId, AttendanceStatus status) {
    state = {...state, studentId: status};
  }

  void setAllPresent(List<String> studentIds) {
    state = {
      for (final id in studentIds) id: AttendanceStatus.present,
    };
  }

  void clear() {
    state = {};
  }

  Future<bool> saveAttendance(String lessonId, DateTime date) async {
    if (state.isEmpty) return true;

    try {
      final repository = ref.read(teacherRepositoryProvider);
      final records = state.entries
          .map((e) => AttendanceRecord(
                studentId: e.key,
                lessonId: lessonId,
                date: date,
                status: e.value,
              ))
          .toList();

      await repository.bulkMarkAttendance(records);
      ref.invalidate(lessonAttendanceProvider(lessonId, date));
      clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ========== Assignment Providers ==========

/// Provider for fetching subject assignments.
@riverpod
Future<List<AssignmentEntity>> subjectAssignments(
  Ref ref,
  String subjectId,
) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getSubjectAssignments(subjectId);
}

/// Provider for fetching all teacher's assignments.
@riverpod
Future<List<AssignmentEntity>> myAssignments(Ref ref) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getMyAssignments();
}

/// Provider for assignment submissions.
@riverpod
Future<List<SubmissionEntity>> assignmentSubmissions(
  Ref ref,
  String assignmentId,
) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getAssignmentSubmissions(assignmentId);
}

/// Notifier for managing assignments.
@riverpod
class AssignmentNotifier extends _$AssignmentNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> createAssignment({
    required String subjectId,
    required String title,
    String? description,
    DateTime? dueDate,
    int maxScore = 100,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.createAssignment(
        subjectId: subjectId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxScore: maxScore,
      );
      state = const AsyncValue.data(null);
      ref.invalidate(subjectAssignmentsProvider(subjectId));
      ref.invalidate(myAssignmentsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteAssignment(String assignmentId, String subjectId) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.deleteAssignment(assignmentId);
      state = const AsyncValue.data(null);
      ref.invalidate(subjectAssignmentsProvider(subjectId));
      ref.invalidate(myAssignmentsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> gradeSubmission(
    String submissionId,
    double grade,
    String? comment,
    String assignmentId,
  ) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.gradeSubmission(submissionId, grade, comment);
      state = const AsyncValue.data(null);
      ref.invalidate(assignmentSubmissionsProvider(assignmentId));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

// ========== Excuse Providers ==========

/// Provider for pending excuses.
@riverpod
Future<List<AttendanceEntity>> pendingExcuses(Ref ref) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getPendingExcuses();
}

/// Notifier for reviewing excuses.
@riverpod
class ExcuseNotifier extends _$ExcuseNotifier {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<bool> reviewExcuse(String attendanceId, ExcuseStatus status) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(teacherRepositoryProvider);
      await repository.reviewExcuse(attendanceId, status);
      state = const AsyncValue.data(null);
      ref.invalidate(pendingExcusesProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

// ========== Stats Provider ==========

/// Provider for teacher dashboard statistics.
@riverpod
Future<TeacherStats> teacherStats(Ref ref) async {
  final repository = ref.watch(teacherRepositoryProvider);
  return repository.getTeacherStats();
}
