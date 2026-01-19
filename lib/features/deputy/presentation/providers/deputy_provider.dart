import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../schedule/presentation/widgets/week_selector.dart';
import '../../data/repositories/supabase_deputy_repository.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/deputy_repository.dart';

part 'deputy_provider.g.dart';

// ============== Repository Provider ==============

/// Provider for the DeputyRepository instance.
///
/// Provides the Supabase implementation for production use.
/// Can be overridden in tests to provide a mock implementation.
@riverpod
DeputyRepository deputyRepository(Ref ref) {
  return SupabaseDeputyRepository();
}

// ============== Schedule Providers ==============

/// Provider that fetches the schedule for a specific class based on selected week.
///
/// Returns lessons for the class based on the currently selected week view:
/// - For WeekViewType.stable: returns stable timetable lessons
/// - For specific weeks: returns week-specific lessons (or stable as fallback)
@riverpod
Future<List<ScheduleLesson>> classSchedule(Ref ref, String classId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  final weekView = ref.watch(selectedWeekViewProvider);
  final weekStartDate = ref.watch(selectedWeekStartDateProvider);

  // For stable view, fetch stable schedule
  if (weekView == WeekViewType.stable) {
    return repository.getStableSchedule(classId);
  }

  // For specific weeks, fetch week-specific schedule
  return repository.getClassSchedule(classId, weekStartDate: weekStartDate);
}

/// Provider that fetches subjects available for a specific class.
///
/// Used for the subject dropdown in the lesson form.
@riverpod
Future<List<Subject>> classSubjects(Ref ref, String classId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getClassSubjects(classId);
}

/// Provider that fetches all classes for a school.
///
/// Used for the class selector dropdown in the schedule editor.
@riverpod
Future<List<ClassInfo>> deputySchoolClasses(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getSchoolClasses(schoolId);
}

/// Provider for the currently selected class in the schedule editor.
@riverpod
class SelectedScheduleClass extends _$SelectedScheduleClass {
  @override
  String? build() => null;

  void select(String? classId) {
    state = classId;
  }
}

/// Provider that returns lessons grouped by day of week.
///
/// Useful for rendering the schedule grid.
@riverpod
Map<int, List<ScheduleLesson>> scheduleLessonsByDay(Ref ref, String classId) {
  final scheduleAsync = ref.watch(classScheduleProvider(classId));

  return scheduleAsync.when(
    data: (lessons) {
      final byDay = <int, List<ScheduleLesson>>{
        for (int i = 1; i <= 7; i++) i: <ScheduleLesson>[],
      };

      for (final lesson in lessons) {
        byDay[lesson.dayOfWeek]?.add(lesson);
      }

      // Sort each day by start time
      for (final day in byDay.keys) {
        byDay[day]?.sort((a, b) {
          final aMinutes = a.startTime.hour * 60 + a.startTime.minute;
          final bMinutes = b.startTime.hour * 60 + b.startTime.minute;
          return aMinutes.compareTo(bMinutes);
        });
      }

      return byDay;
    },
    loading: () => {for (int i = 1; i <= 7; i++) i: <ScheduleLesson>[]},
    error: (_, _) => {for (int i = 1; i <= 7; i++) i: <ScheduleLesson>[]},
  );
}

// ============== Parent Onboarding Providers ==============

/// Provider that fetches students without parents for a school.
@riverpod
Future<List<StudentWithoutParent>> studentsWithoutParents(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getStudentsWithoutParents(schoolId);
}

/// Provider that fetches pending parent invites for a school.
@riverpod
Future<List<ParentInvite>> pendingParentInvites(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getPendingParentInvites(schoolId);
}

/// Provider that fetches all parent invites for a school.
@riverpod
Future<List<ParentInvite>> allParentInvites(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getAllParentInvites(schoolId);
}

// ============== Stats Provider ==============

/// Provider that fetches deputy dashboard statistics.
@riverpod
Future<DeputyStats> deputyStats(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getDeputyStats(schoolId);
}

// ============== Subject Management Providers ==============

/// Provider that fetches all subjects for a school.
@riverpod
Future<List<Subject>> schoolSubjects(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getSchoolSubjects(schoolId);
}

/// Provider that fetches all teachers for a school.
@riverpod
Future<List<AppUser>> deputySchoolTeachers(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getSchoolTeachers(schoolId);
}

// ============== Class Student Management Providers ==============

/// Provider that fetches students in a specific class.
@riverpod
Future<List<AppUser>> classStudents(Ref ref, String classId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getClassStudents(classId);
}

/// Provider that fetches students not assigned to any class.
@riverpod
Future<List<AppUser>> studentsWithoutClass(Ref ref, String schoolId) async {
  final repository = ref.watch(deputyRepositoryProvider);
  return repository.getStudentsWithoutClass(schoolId);
}

// ============== Lesson Form State ==============

/// State for the lesson form dialog.
class LessonFormState {
  const LessonFormState({
    this.selectedSubjectId,
    this.selectedDayOfWeek = 1,
    this.startTime = const TimeOfDay(hour: 8, minute: 0),
    this.endTime = const TimeOfDay(hour: 8, minute: 45),
    this.room = '',
    this.isLoading = false,
    this.errorMessage,
  });

  final String? selectedSubjectId;
  final int selectedDayOfWeek;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String room;
  final bool isLoading;
  final String? errorMessage;

  LessonFormState copyWith({
    String? selectedSubjectId,
    int? selectedDayOfWeek,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? room,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LessonFormState(
      selectedSubjectId: selectedSubjectId ?? this.selectedSubjectId,
      selectedDayOfWeek: selectedDayOfWeek ?? this.selectedDayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier for managing lesson form state and operations.
@riverpod
class LessonFormNotifier extends _$LessonFormNotifier {
  @override
  LessonFormState build() {
    return const LessonFormState();
  }

  void setSubject(String? subjectId) {
    state = state.copyWith(selectedSubjectId: subjectId);
  }

  void setDayOfWeek(int day) {
    state = state.copyWith(selectedDayOfWeek: day);
  }

  void setStartTime(TimeOfDay time) {
    state = state.copyWith(startTime: time);
    // Auto-adjust end time to maintain 45 min duration
    final endMinutes = time.hour * 60 + time.minute + 45;
    state = state.copyWith(
      endTime: TimeOfDay(
        hour: endMinutes ~/ 60,
        minute: endMinutes % 60,
      ),
    );
  }

  void setEndTime(TimeOfDay time) {
    state = state.copyWith(endTime: time);
  }

  void setRoom(String room) {
    state = state.copyWith(room: room);
  }

  void reset() {
    state = const LessonFormState();
  }

  void loadFromLesson(ScheduleLesson lesson) {
    state = LessonFormState(
      selectedSubjectId: lesson.subjectId,
      selectedDayOfWeek: lesson.dayOfWeek,
      startTime: lesson.startTime,
      endTime: lesson.endTime,
      room: lesson.room ?? '',
    );
  }

  /// Creates a new lesson.
  ///
  /// If [isStable] is true, creates a stable (recurring) lesson.
  /// If [weekStartDate] is provided, creates a week-specific lesson.
  Future<bool> createLesson(
    String classId, {
    bool isStable = true,
    DateTime? weekStartDate,
  }) async {
    if (state.selectedSubjectId == null) {
      state = state.copyWith(errorMessage: 'Please select a subject');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.createLesson(
        classId: classId,
        subjectId: state.selectedSubjectId!,
        dayOfWeek: state.selectedDayOfWeek,
        startTime: _formatTime(state.startTime),
        endTime: _formatTime(state.endTime),
        room: state.room.isNotEmpty ? state.room : null,
        isStable: isStable,
        weekStartDate: weekStartDate,
      );

      // Invalidate the schedule to refresh
      ref.invalidate(classScheduleProvider(classId));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Updates an existing lesson.
  Future<bool> updateLesson(String lessonId, String classId) async {
    if (state.selectedSubjectId == null) {
      state = state.copyWith(errorMessage: 'Please select a subject');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.updateLesson(
        lessonId: lessonId,
        subjectId: state.selectedSubjectId,
        dayOfWeek: state.selectedDayOfWeek,
        startTime: _formatTime(state.startTime),
        endTime: _formatTime(state.endTime),
        room: state.room.isNotEmpty ? state.room : null,
      );

      // Invalidate the schedule to refresh
      ref.invalidate(classScheduleProvider(classId));

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
}

// ============== Deputy Actions Notifier ==============

/// State for deputy operations.
class DeputyState {
  const DeputyState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  DeputyState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return DeputyState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

/// Notifier for deputy operations like deleting lessons, generating invites, etc.
@Riverpod(keepAlive: true)
class DeputyNotifier extends _$DeputyNotifier {
  @override
  DeputyState build() {
    return const DeputyState();
  }

  /// Deletes a lesson.
  Future<bool> deleteLesson(String lessonId, String classId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.deleteLesson(lessonId);

      // Invalidate the schedule to refresh
      ref.invalidate(classScheduleProvider(classId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Lesson deleted successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Generates a parent invite for a student.
  Future<ParentInvite?> generateParentInvite({
    required String studentId,
    required String schoolId,
    DateTime? expiresAt,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      final invite = await repository.generateParentInviteForStudent(
        studentId: studentId,
        schoolId: schoolId,
        expiresAt: expiresAt,
      );

      // Invalidate providers to refresh lists
      ref.invalidate(studentsWithoutParentsProvider(schoolId));
      ref.invalidate(pendingParentInvitesProvider(schoolId));
      ref.invalidate(deputyStatsProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Invite generated successfully',
      );
      return invite;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return null;
    }
  }

  /// Revokes a parent invite.
  Future<bool> revokeParentInvite(String inviteId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.revokeParentInvite(inviteId);

      // Invalidate providers to refresh lists
      ref.invalidate(pendingParentInvitesProvider(schoolId));
      ref.invalidate(allParentInvitesProvider(schoolId));
      ref.invalidate(deputyStatsProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Invite revoked successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ============== Subject Management ==============

  /// Creates a new subject.
  Future<bool> createSubject({
    required String schoolId,
    required String name,
    String? description,
    String? teacherId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.createSubject(
        schoolId: schoolId,
        name: name,
        description: description,
        teacherId: teacherId,
      );

      // Invalidate providers to refresh lists
      ref.invalidate(schoolSubjectsProvider(schoolId));
      ref.invalidate(deputyStatsProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Subject created successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Updates an existing subject.
  Future<bool> updateSubject({
    required String subjectId,
    required String schoolId,
    String? name,
    String? description,
    String? teacherId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.updateSubject(
        subjectId: subjectId,
        name: name,
        description: description,
        teacherId: teacherId,
      );

      // Invalidate providers to refresh lists
      ref.invalidate(schoolSubjectsProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Subject updated successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Deletes a subject.
  Future<bool> deleteSubject(String subjectId, String schoolId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.deleteSubject(subjectId);

      // Invalidate providers to refresh lists
      ref.invalidate(schoolSubjectsProvider(schoolId));
      ref.invalidate(deputyStatsProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Subject deleted successfully',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Assigns a subject to a class.
  Future<bool> assignSubjectToClass(
    String subjectId,
    String classId,
    String schoolId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.assignSubjectToClass(subjectId, classId);

      // Invalidate providers to refresh lists
      ref.invalidate(classSubjectsProvider(classId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Subject assigned to class',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Removes a subject from a class.
  Future<bool> removeSubjectFromClass(
    String subjectId,
    String classId,
    String schoolId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.removeSubjectFromClass(subjectId, classId);

      // Invalidate providers to refresh lists
      ref.invalidate(classSubjectsProvider(classId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Subject removed from class',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // ============== Class Student Management ==============

  /// Adds a student to a class.
  Future<bool> addStudentToClass(
    String classId,
    String studentId,
    String schoolId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.addStudentToClass(classId, studentId);

      // Invalidate providers to refresh lists
      ref.invalidate(classStudentsProvider(classId));
      ref.invalidate(studentsWithoutClassProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Student added to class',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Removes a student from a class.
  Future<bool> removeStudentFromClass(
    String classId,
    String studentId,
    String schoolId,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(deputyRepositoryProvider);
      await repository.removeStudentFromClass(classId, studentId);

      // Invalidate providers to refresh lists
      ref.invalidate(classStudentsProvider(classId));
      ref.invalidate(studentsWithoutClassProvider(schoolId));

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Student removed from class',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
