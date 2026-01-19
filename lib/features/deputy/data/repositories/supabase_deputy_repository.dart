import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/subject_colors.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/deputy_repository.dart';

/// Exception thrown when deputy operations fail.
class DeputyException extends RepositoryException {
  const DeputyException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'DeputyException: $message';
}

/// Supabase implementation of [DeputyRepository].
///
/// Provides deputy panel functionality using Supabase as the data source.
/// This includes schedule management and parent onboarding operations.
class SupabaseDeputyRepository implements DeputyRepository {
  /// Creates a [SupabaseDeputyRepository] instance.
  SupabaseDeputyRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ============== Schedule Management ==============

  /// Standard select query for lessons with all necessary joins.
  static const String _lessonSelectQuery = '''
    id,
    subject_id,
    day_of_week,
    start_time,
    end_time,
    room,
    is_stable,
    stable_lesson_id,
    modified_from_stable,
    week_start_date,
    created_at,
    subjects (
      id,
      name,
      class_id,
      teacher_id,
      teacher:profiles!subjects_teacher_id_fkey (
        first_name,
        last_name
      )
    )
  ''';

  /// Returns the Monday of the week containing the given date.
  DateTime _getMondayOfWeek(DateTime date) {
    // weekday: 1=Monday, 7=Sunday
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  /// Formats a DateTime to a date string suitable for the database (YYYY-MM-DD).
  String _formatDateForDb(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<ScheduleLesson>> getClassSchedule(String classId, {DateTime? weekStartDate}) async {
    // Input validation
    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }

    try {
      // First get subject IDs for this class, then get lessons for those subjects
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('class_id', classId);

      final subjectIds = (subjectsResponse as List)
          .map((s) => s['id'] as String)
          .toList();

      if (subjectIds.isEmpty) {
        return [];
      }

      List<dynamic> response;

      if (weekStartDate != null) {
        // Fetch week-specific lessons first
        final mondayOfWeek = _getMondayOfWeek(weekStartDate);
        final weekDateStr = _formatDateForDb(mondayOfWeek);

        response = await _supabase
            .from('lessons')
            .select(_lessonSelectQuery)
            .inFilter('subject_id', subjectIds)
            .eq('week_start_date', weekDateStr)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);

        // If no week-specific lessons exist, fall back to stable timetable
        if (response.isEmpty) {
          response = await _supabase
              .from('lessons')
              .select(_lessonSelectQuery)
              .inFilter('subject_id', subjectIds)
              .eq('is_stable', true)
              .order('day_of_week', ascending: true)
              .order('start_time', ascending: true);
        }
      } else {
        // Fetch stable timetable lessons
        response = await _supabase
            .from('lessons')
            .select(_lessonSelectQuery)
            .inFilter('subject_id', subjectIds)
            .eq('is_stable', true)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);
      }

      return response.map((json) {
        final lesson = ScheduleLesson.fromJson(json as Map<String, dynamic>);
        // Add color to lesson
        return lesson.copyWith(
          subjectColor: SubjectColors.getColorForId(lesson.subjectId),
        );
      }).toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch class schedule: ${e.message}');
      throw DeputyException('Failed to fetch class schedule: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch class schedule: ${e.toString()}');
      throw DeputyException('Failed to fetch class schedule: ${e.toString()}');
    }
  }

  @override
  Future<List<ScheduleLesson>> getStableSchedule(String classId) async {
    return getClassSchedule(classId, weekStartDate: null);
  }

  @override
  Future<ScheduleLesson> createLesson({
    required String classId,
    required String subjectId,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    String? room,
    bool isStable = true,
    DateTime? weekStartDate,
  }) async {
    // Input validation
    if (dayOfWeek < 1 || dayOfWeek > 7) {
      debugPrint('DeputyException: dayOfWeek must be between 1 and 7 (1=Monday, 7=Sunday), got $dayOfWeek');
      throw DeputyException(
        'dayOfWeek must be between 1 and 7 (1=Monday, 7=Sunday), got $dayOfWeek',
      );
    }

    final timeRegex = RegExp(r'^\d{2}:\d{2}(:\d{2})?$');
    if (!timeRegex.hasMatch(startTime)) {
      debugPrint('DeputyException: startTime must be in HH:MM or HH:MM:SS format, got "$startTime"');
      throw DeputyException(
        'startTime must be in HH:MM or HH:MM:SS format, got "$startTime"',
      );
    }
    if (!timeRegex.hasMatch(endTime)) {
      debugPrint('DeputyException: endTime must be in HH:MM or HH:MM:SS format, got "$endTime"');
      throw DeputyException(
        'endTime must be in HH:MM or HH:MM:SS format, got "$endTime"',
      );
    }

    // Validate that end time is after start time
    try {
      final startParts = startTime.split(':');
      final endParts = endTime.split(':');
      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      if (endMinutes <= startMinutes) {
        debugPrint('DeputyException: endTime ($endTime) must be after startTime ($startTime)');
        throw DeputyException(
          'endTime ($endTime) must be after startTime ($startTime)',
        );
      }
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Invalid time format: $e');
      throw DeputyException('Invalid time format: $e');
    }

    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }
    if (subjectId.isEmpty) {
      debugPrint('DeputyException: subjectId cannot be empty');
      throw DeputyException('subjectId cannot be empty');
    }

    try {
      // Convert dayOfWeek from app format (1=Monday, 7=Sunday) to DB format (0=Sunday, 1-6=Monday-Saturday)
      final dbDayOfWeek = dayOfWeek == 7 ? 0 : dayOfWeek;

      // Verify that the subject belongs to the specified class
      final subjectCheck = await _supabase
          .from('subjects')
          .select('id, class_id')
          .eq('id', subjectId)
          .eq('class_id', classId)
          .maybeSingle();

      if (subjectCheck == null) {
        throw DeputyException('Subject does not belong to the specified class');
      }

      // Build insert data
      final insertData = <String, dynamic>{
        'subject_id': subjectId,
        'day_of_week': dbDayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'room': room,
        'is_stable': isStable,
      };

      // Add week_start_date for week-specific lessons
      if (!isStable && weekStartDate != null) {
        final mondayOfWeek = _getMondayOfWeek(weekStartDate);
        insertData['week_start_date'] = _formatDateForDb(mondayOfWeek);
      }

      // Lessons table doesn't have class_id - it's linked through subject_id
      final response = await _supabase
          .from('lessons')
          .insert(insertData)
          .select(_lessonSelectQuery)
          .maybeSingle();

      if (response == null) {
        throw const DeputyException('Failed to create lesson: no data returned');
      }

      final lesson = ScheduleLesson.fromJson(response);
      return lesson.copyWith(subjectColor: SubjectColors.getColorForId(lesson.subjectId));
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to create lesson: ${e.message}');
      throw DeputyException('Failed to create lesson: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to create lesson: ${e.toString()}');
      throw DeputyException('Failed to create lesson: ${e.toString()}');
    }
  }

  @override
  Future<ScheduleLesson> updateLesson({
    required String lessonId,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
  }) async {
    // Input validation
    if (lessonId.isEmpty) {
      debugPrint('DeputyException: lessonId cannot be empty');
      throw DeputyException('lessonId cannot be empty');
    }

    if (dayOfWeek != null && (dayOfWeek < 1 || dayOfWeek > 7)) {
      debugPrint('DeputyException: dayOfWeek must be between 1 and 7 (1=Monday, 7=Sunday), got $dayOfWeek');
      throw DeputyException(
        'dayOfWeek must be between 1 and 7 (1=Monday, 7=Sunday), got $dayOfWeek',
      );
    }

    final timeRegex = RegExp(r'^\d{2}:\d{2}(:\d{2})?$');
    if (startTime != null && !timeRegex.hasMatch(startTime)) {
      debugPrint('DeputyException: startTime must be in HH:MM or HH:MM:SS format, got "$startTime"');
      throw DeputyException(
        'startTime must be in HH:MM or HH:MM:SS format, got "$startTime"',
      );
    }
    if (endTime != null && !timeRegex.hasMatch(endTime)) {
      debugPrint('DeputyException: endTime must be in HH:MM or HH:MM:SS format, got "$endTime"');
      throw DeputyException(
        'endTime must be in HH:MM or HH:MM:SS format, got "$endTime"',
      );
    }

    // Validate that end time is after start time (if both are provided)
    if (startTime != null && endTime != null) {
      try {
        final startParts = startTime.split(':');
        final endParts = endTime.split(':');
        final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
        final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

        if (endMinutes <= startMinutes) {
          debugPrint('DeputyException: endTime ($endTime) must be after startTime ($startTime)');
          throw DeputyException(
            'endTime ($endTime) must be after startTime ($startTime)',
          );
        }
      } catch (e) {
        if (e is DeputyException) rethrow;
        debugPrint('DeputyException: Invalid time format: $e');
        throw DeputyException('Invalid time format: $e');
      }
    }

    if (subjectId != null && subjectId.isEmpty) {
      debugPrint('DeputyException: subjectId cannot be empty');
      throw DeputyException('subjectId cannot be empty');
    }

    try {
      final updateData = <String, dynamic>{};
      if (subjectId != null) updateData['subject_id'] = subjectId;
      if (dayOfWeek != null) {
        // Convert dayOfWeek from app format (1=Monday, 7=Sunday) to DB format (0=Sunday, 1-6=Monday-Saturday)
        updateData['day_of_week'] = dayOfWeek == 7 ? 0 : dayOfWeek;
      }
      if (startTime != null) updateData['start_time'] = startTime;
      if (endTime != null) updateData['end_time'] = endTime;
      // Handle room: non-null means update (empty string sets to null in DB)
      if (room != null) {
        updateData['room'] = room.isNotEmpty ? room : null;
      }

      final response = await _supabase
          .from('lessons')
          .update(updateData)
          .eq('id', lessonId)
          .select(_lessonSelectQuery)
          .maybeSingle();

      if (response == null) {
        throw DeputyException('Failed to update lesson: lesson not found with id $lessonId');
      }

      final lesson = ScheduleLesson.fromJson(response);
      return lesson.copyWith(subjectColor: SubjectColors.getColorForId(lesson.subjectId));
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to update lesson: ${e.message}');
      throw DeputyException('Failed to update lesson: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to update lesson: ${e.toString()}');
      throw DeputyException('Failed to update lesson: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteLesson(String lessonId) async {
    // Input validation
    if (lessonId.isEmpty) {
      debugPrint('DeputyException: lessonId cannot be empty');
      throw DeputyException('lessonId cannot be empty');
    }

    try {
      await _supabase.from('lessons').delete().eq('id', lessonId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to delete lesson: ${e.message}');
      throw DeputyException('Failed to delete lesson: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to delete lesson: ${e.toString()}');
      throw DeputyException('Failed to delete lesson: ${e.toString()}');
    }
  }

  @override
  Future<List<Subject>> getClassSubjects(String classId) async {
    try {
      // Subjects are linked directly to classes via class_id column
      final response = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            description,
            teacher_id,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .eq('class_id', classId)
          .order('name', ascending: true);

      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final subjectId = data['id'] as String;

        // Parse teacher name
        String? teacherName;
        final teacherData = data['teacher'] as Map<String, dynamic>?;
        if (teacherData != null) {
          final firstName = teacherData['first_name'] as String?;
          final lastName = teacherData['last_name'] as String?;
          if (firstName != null || lastName != null) {
            teacherName = [firstName, lastName]
                .where((s) => s != null && s.isNotEmpty)
                .join(' ');
          }
        }

        return Subject(
          id: subjectId,
          name: data['name'] as String? ?? 'Unknown',
          color: SubjectColors.getColorForId(subjectId),
          teacherName: teacherName,
        );
      }).toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch class subjects: ${e.message}');
      throw DeputyException('Failed to fetch class subjects: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch class subjects: ${e.toString()}');
      throw DeputyException('Failed to fetch class subjects: ${e.toString()}');
    }
  }

  @override
  Future<List<ClassInfo>> getSchoolClasses(String schoolId) async {
    try {
      final response = await _supabase
          .from('classes')
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .eq('school_id', schoolId)
          .order('grade_level', ascending: true)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => ClassInfo.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch school classes: ${e.message}');
      throw DeputyException('Failed to fetch school classes: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch school classes: ${e.toString()}');
      throw DeputyException('Failed to fetch school classes: ${e.toString()}');
    }
  }

  // ============== Parent Onboarding ==============

  @override
  Future<List<StudentWithoutParent>> getStudentsWithoutParents(String schoolId) async {
    try {
      // Get all students in the school
      final studentsResponse = await _supabase
          .from('profiles')
          .select('''
            id,
            first_name,
            last_name,
            avatar_url,
            created_at,
            class_students!inner (
              class_id,
              classes (
                id,
                name
              )
            )
          ''')
          .eq('school_id', schoolId)
          .eq('role', UserRole.student.name);

      // Get students who have parents linked (via parent_student table)
      // Note: parent_student table doesn't have school_id, we get all linked students
      final linkedStudentsResponse = await _supabase
          .from('parent_student')
          .select('student_id');

      final linkedStudentIds = (linkedStudentsResponse as List)
          .map((row) => row['student_id'] as String)
          .toSet();

      // Filter out students who already have parents
      final studentsWithoutParents = <StudentWithoutParent>[];
      for (final student in studentsResponse as List) {
        final studentId = student['id'] as String;
        if (!linkedStudentIds.contains(studentId)) {
          // Parse class data
          String? className;
          String? classId;
          final classStudents = student['class_students'] as List?;
          if (classStudents != null && classStudents.isNotEmpty) {
            final classData = classStudents[0]['classes'] as Map<String, dynamic>?;
            if (classData != null) {
              className = classData['name'] as String?;
              classId = classData['id'] as String?;
            }
          }

          // Email may be null if not available - UI should handle this gracefully
          studentsWithoutParents.add(StudentWithoutParent(
            id: studentId,
            email: student['email'] as String?,
            firstName: student['first_name'] as String?,
            lastName: student['last_name'] as String?,
            className: className,
            classId: classId,
            avatarUrl: student['avatar_url'] as String?,
          ));
        }
      }

      return studentsWithoutParents;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch students without parents: ${e.message}');
      throw DeputyException('Failed to fetch students without parents: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch students without parents: ${e.toString()}');
      throw DeputyException('Failed to fetch students without parents: ${e.toString()}');
    }
  }

  @override
  Future<ParentInvite> generateParentInviteForStudent({
    required String studentId,
    required String schoolId,
    DateTime? expiresAt,
  }) async {
    // Input validation
    if (studentId.isEmpty) {
      debugPrint('DeputyException: studentId cannot be empty');
      throw DeputyException('studentId cannot be empty');
    }
    if (schoolId.isEmpty) {
      debugPrint('DeputyException: schoolId cannot be empty');
      throw DeputyException('schoolId cannot be empty');
    }

    try {
      // Generate a unique code
      final code = _generateInviteCode();

      final response = await _supabase
          .from('parent_invites')
          .insert({
            'code': code,
            'student_id': studentId,
            'school_id': schoolId,
            'times_used': 0,
            'usage_limit': 1,
            'expires_at': expiresAt?.toIso8601String(),
          })
          .select('''
            id,
            code,
            student_id,
            school_id,
            times_used,
            usage_limit,
            created_at,
            expires_at,
            student:profiles!parent_invites_student_id_fkey (
              first_name,
              last_name
            )
          ''')
          .maybeSingle();

      if (response == null) {
        throw const DeputyException('Failed to generate parent invite: no data returned');
      }

      return ParentInvite.fromJson(response);
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to generate parent invite: ${e.message}');
      throw DeputyException('Failed to generate parent invite: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to generate parent invite: ${e.toString()}');
      throw DeputyException('Failed to generate parent invite: ${e.toString()}');
    }
  }

  @override
  Future<List<ParentInvite>> getPendingParentInvites(String schoolId) async {
    try {
      // Fetch all invites and filter in Dart for times_used < usage_limit
      final response = await _supabase
          .from('parent_invites')
          .select('''
            id,
            code,
            student_id,
            school_id,
            times_used,
            usage_limit,
            created_at,
            expires_at,
            student:profiles!parent_invites_student_id_fkey (
              first_name,
              last_name
            )
          ''')
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      // Filter for active (not fully used) invites in Dart
      return (response as List)
          .map((json) => ParentInvite.fromJson(json as Map<String, dynamic>))
          .where((invite) => invite.isActive)
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch pending invites: ${e.message}');
      throw DeputyException('Failed to fetch pending invites: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch pending invites: ${e.toString()}');
      throw DeputyException('Failed to fetch pending invites: ${e.toString()}');
    }
  }

  @override
  Future<List<ParentInvite>> getAllParentInvites(String schoolId) async {
    try {
      final response = await _supabase
          .from('parent_invites')
          .select('''
            id,
            code,
            student_id,
            school_id,
            times_used,
            usage_limit,
            created_at,
            used_at,
            expires_at,
            parent_id,
            student:profiles!parent_invites_student_id_fkey (
              first_name,
              last_name
            )
          ''')
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ParentInvite.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch parent invites: ${e.message}');
      throw DeputyException('Failed to fetch parent invites: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch parent invites: ${e.toString()}');
      throw DeputyException('Failed to fetch parent invites: ${e.toString()}');
    }
  }

  @override
  Future<bool> revokeParentInvite(String inviteId) async {
    try {
      await _supabase.from('parent_invites').delete().eq('id', inviteId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to revoke invite: ${e.message}');
      throw DeputyException('Failed to revoke invite: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to revoke invite: ${e.toString()}');
      throw DeputyException('Failed to revoke invite: ${e.toString()}');
    }
  }

  // ============== Stats ==============

  @override
  Future<DeputyStats> getDeputyStats(String schoolId) async {
    try {
      // Get total classes count first (needed for lessons/subjects queries)
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('school_id', schoolId);
      final totalClasses = (classesResponse as List).length;

      // Get class IDs from this school
      final schoolClassIds = (classesResponse as List)
          .map((c) => c['id'] as String)
          .toList();

      // Get total subjects count - subjects are linked to classes via class_id
      int totalSubjects = 0;
      List<String> subjectIds = [];
      if (schoolClassIds.isNotEmpty) {
        final subjectsResponse = await _supabase
            .from('subjects')
            .select('id')
            .inFilter('class_id', schoolClassIds);
        totalSubjects = (subjectsResponse as List).length;
        subjectIds = (subjectsResponse as List)
            .map((s) => s['id'] as String)
            .toList();
      }

      // Get total lessons count - lessons are linked to subjects via subject_id
      int totalLessons = 0;
      if (subjectIds.isNotEmpty) {
        final lessonsResponse = await _supabase
            .from('lessons')
            .select('id')
            .inFilter('subject_id', subjectIds);
        totalLessons = (lessonsResponse as List).length;
      }

      // Get total teachers count
      final teachersResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('school_id', schoolId)
          .eq('role', UserRole.teacher.name);
      final totalTeachers = (teachersResponse as List).length;

      // Get students without parents count
      final studentsWithoutParents = await getStudentsWithoutParents(schoolId);

      // Get pending parent invites count
      final pendingInvites = await getPendingParentInvites(schoolId);

      return DeputyStats(
        totalLessons: totalLessons,
        totalClasses: totalClasses,
        studentsWithoutParents: studentsWithoutParents.length,
        pendingParentInvites: pendingInvites.length,
        totalSubjects: totalSubjects,
        totalTeachers: totalTeachers,
      );
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch deputy stats: ${e.message}');
      throw DeputyException('Failed to fetch deputy stats: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch deputy stats: ${e.toString()}');
      throw DeputyException('Failed to fetch deputy stats: ${e.toString()}');
    }
  }

  @override
  Future<List<Subject>> getSchoolSubjects(String schoolId) async {
    try {
      // Subjects are linked to classes via class_id, need to join through classes
      // First get all class IDs for this school
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('school_id', schoolId);

      final classIds = (classesResponse as List)
          .map((c) => c['id'] as String)
          .toList();

      if (classIds.isEmpty) {
        return [];
      }

      final response = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            description,
            teacher_id,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .inFilter('class_id', classIds)
          .order('name', ascending: true);

      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final subjectId = data['id'] as String;

        // Parse teacher name
        String? teacherName;
        final teacherData = data['teacher'] as Map<String, dynamic>?;
        if (teacherData != null) {
          final firstName = teacherData['first_name'] as String?;
          final lastName = teacherData['last_name'] as String?;
          if (firstName != null || lastName != null) {
            teacherName = [firstName, lastName]
                .where((s) => s != null && s.isNotEmpty)
                .join(' ');
          }
        }

        return Subject(
          id: subjectId,
          name: data['name'] as String? ?? 'Unknown',
          color: SubjectColors.getColorForId(subjectId),
          teacherName: teacherName,
          teacherId: data['teacher_id'] as String?,
        );
      }).toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch school subjects: ${e.message}');
      throw DeputyException('Failed to fetch school subjects: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch school subjects: ${e.toString()}');
      throw DeputyException('Failed to fetch school subjects: ${e.toString()}');
    }
  }

  /// Generates a cryptographically secure random alphanumeric invite code.
  /// Uses 62 characters (uppercase, lowercase, digits) for maximum entropy.
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return 'P-${List.generate(16, (_) => chars[random.nextInt(chars.length)]).join()}';
  }

  // ============== Class Management ==============

  @override
  Future<bool> addStudentToClass(String classId, String studentId) async {
    // Input validation
    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }
    if (studentId.isEmpty) {
      debugPrint('DeputyException: studentId cannot be empty');
      throw DeputyException('studentId cannot be empty');
    }

    try {
      await _supabase.from('class_students').insert({
        'class_id': classId,
        'student_id': studentId,
      });
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to add student to class: ${e.message}');
      throw DeputyException('Failed to add student to class: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to add student to class: ${e.toString()}');
      throw DeputyException('Failed to add student to class: ${e.toString()}');
    }
  }

  @override
  Future<bool> removeStudentFromClass(String classId, String studentId) async {
    // Input validation
    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }
    if (studentId.isEmpty) {
      debugPrint('DeputyException: studentId cannot be empty');
      throw DeputyException('studentId cannot be empty');
    }

    try {
      await _supabase
          .from('class_students')
          .delete()
          .eq('class_id', classId)
          .eq('student_id', studentId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to remove student from class: ${e.message}');
      throw DeputyException('Failed to remove student from class: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to remove student from class: ${e.toString()}');
      throw DeputyException('Failed to remove student from class: ${e.toString()}');
    }
  }

  @override
  Future<List<AppUser>> getClassStudents(String classId) async {
    // Input validation
    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }

    try {
      final response = await _supabase
          .from('class_students')
          .select('student:profiles!class_students_student_id_fkey(*)')
          .eq('class_id', classId);

      return (response as List)
          .map((r) => AppUser.fromJson(r['student'] as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch class students: ${e.message}');
      throw DeputyException('Failed to fetch class students: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch class students: ${e.toString()}');
      throw DeputyException('Failed to fetch class students: ${e.toString()}');
    }
  }

  @override
  Future<List<AppUser>> getStudentsWithoutClass(String schoolId) async {
    // Input validation
    if (schoolId.isEmpty) {
      debugPrint('DeputyException: schoolId cannot be empty');
      throw DeputyException('schoolId cannot be empty');
    }

    try {
      // Get all students in the school
      final allStudents = await _supabase
          .from('profiles')
          .select()
          .eq('school_id', schoolId)
          .eq('role', UserRole.student.name);

      // Get students who are enrolled in a class
      final enrolledStudentIds = await _supabase
          .from('class_students')
          .select('student_id');

      final enrolledIds = (enrolledStudentIds as List)
          .map((r) => r['student_id'] as String)
          .toSet();

      return (allStudents as List)
          .map((r) => AppUser.fromJson(r as Map<String, dynamic>))
          .where((student) => !enrolledIds.contains(student.id))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch students without class: ${e.message}');
      throw DeputyException('Failed to fetch students without class: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch students without class: ${e.toString()}');
      throw DeputyException('Failed to fetch students without class: ${e.toString()}');
    }
  }

  // ============== Subject CRUD ==============

  @override
  Future<Subject> createSubject({
    required String schoolId,
    required String name,
    String? description,
    String? teacherId,
  }) async {
    // Note: The database schema requires class_id, not school_id.
    // This method needs a classId to create a subject.
    // Since the interface passes schoolId, we need to get the first class from the school
    // or throw an error. For now, we throw a clear error.
    // TODO: Update interface to use classId instead of schoolId.

    // Input validation
    if (schoolId.isEmpty) {
      debugPrint('DeputyException: schoolId cannot be empty');
      throw DeputyException('schoolId cannot be empty');
    }
    if (name.isEmpty) {
      debugPrint('DeputyException: name cannot be empty');
      throw DeputyException('name cannot be empty');
    }

    try {
      // Get the first class from the school to use as the class_id
      // This is a workaround since the interface doesn't provide classId
      final classesResponse = await _supabase
          .from('classes')
          .select('id')
          .eq('school_id', schoolId)
          .limit(1);

      if ((classesResponse as List).isEmpty) {
        throw DeputyException('No classes found in school. Create a class first before adding subjects.');
      }

      final classId = classesResponse[0]['id'] as String;

      final response = await _supabase
          .from('subjects')
          .insert({
            'class_id': classId,
            'school_id': schoolId,
            'name': name,
            'description': description,
            'teacher_id': teacherId,
          })
          .select('''
            id,
            name,
            description,
            teacher_id,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .maybeSingle();

      if (response == null) {
        throw const DeputyException('Failed to create subject: no data returned');
      }

      final subjectId = response['id'] as String;

      // Parse teacher name
      String? teacherName;
      final teacherData = response['teacher'] as Map<String, dynamic>?;
      if (teacherData != null) {
        final firstName = teacherData['first_name'] as String?;
        final lastName = teacherData['last_name'] as String?;
        if (firstName != null || lastName != null) {
          teacherName = [firstName, lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
        }
      }

      return Subject(
        id: subjectId,
        name: response['name'] as String? ?? 'Unknown',
        color: SubjectColors.getColorForId(subjectId),
        teacherName: teacherName,
      );
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to create subject: ${e.message}');
      throw DeputyException('Failed to create subject: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to create subject: ${e.toString()}');
      throw DeputyException('Failed to create subject: ${e.toString()}');
    }
  }

  @override
  Future<bool> deleteSubject(String subjectId) async {
    // Input validation
    if (subjectId.isEmpty) {
      debugPrint('DeputyException: subjectId cannot be empty');
      throw DeputyException('subjectId cannot be empty');
    }

    try {
      await _supabase.from('subjects').delete().eq('id', subjectId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to delete subject: ${e.message}');
      throw DeputyException('Failed to delete subject: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to delete subject: ${e.toString()}');
      throw DeputyException('Failed to delete subject: ${e.toString()}');
    }
  }

  @override
  Future<Subject> updateSubject({
    required String subjectId,
    String? name,
    String? description,
    String? teacherId,
  }) async {
    // Input validation
    if (subjectId.isEmpty) {
      debugPrint('DeputyException: subjectId cannot be empty');
      throw DeputyException('subjectId cannot be empty');
    }

    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (teacherId != null) updates['teacher_id'] = teacherId;

      final response = await _supabase
          .from('subjects')
          .update(updates)
          .eq('id', subjectId)
          .select('''
            id,
            name,
            description,
            teacher_id,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .maybeSingle();

      if (response == null) {
        throw DeputyException('Failed to update subject: subject not found with id $subjectId');
      }

      final id = response['id'] as String;

      // Parse teacher name
      String? teacherName;
      final teacherData = response['teacher'] as Map<String, dynamic>?;
      if (teacherData != null) {
        final firstName = teacherData['first_name'] as String?;
        final lastName = teacherData['last_name'] as String?;
        if (firstName != null || lastName != null) {
          teacherName = [firstName, lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
        }
      }

      return Subject(
        id: id,
        name: response['name'] as String? ?? 'Unknown',
        color: SubjectColors.getColorForId(id),
        teacherName: teacherName,
      );
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to update subject: ${e.message}');
      throw DeputyException('Failed to update subject: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to update subject: ${e.toString()}');
      throw DeputyException('Failed to update subject: ${e.toString()}');
    }
  }

  @override
  Future<bool> assignSubjectToClass(String subjectId, String classId) async {
    // Note: The database schema has subjects directly linked to classes via class_id.
    // There is no class_subjects junction table. This method updates the subject's class_id.

    // Input validation
    if (subjectId.isEmpty) {
      debugPrint('DeputyException: subjectId cannot be empty');
      throw DeputyException('subjectId cannot be empty');
    }
    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }

    try {
      // Update the subject's class_id to assign it to the new class
      await _supabase
          .from('subjects')
          .update({'class_id': classId})
          .eq('id', subjectId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to assign subject to class: ${e.message}');
      throw DeputyException('Failed to assign subject to class: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to assign subject to class: ${e.toString()}');
      throw DeputyException('Failed to assign subject to class: ${e.toString()}');
    }
  }

  @override
  Future<bool> removeSubjectFromClass(String subjectId, String classId) async {
    // Note: The database schema has subjects directly linked to classes via class_id.
    // Since class_id is NOT NULL, we cannot truly "remove" a subject from a class
    // without deleting it or assigning it to another class.
    // This implementation verifies the subject belongs to the class, but cannot
    // nullify the class_id due to the NOT NULL constraint.

    // Input validation
    if (subjectId.isEmpty) {
      debugPrint('DeputyException: subjectId cannot be empty');
      throw DeputyException('subjectId cannot be empty');
    }
    if (classId.isEmpty) {
      debugPrint('DeputyException: classId cannot be empty');
      throw DeputyException('classId cannot be empty');
    }

    try {
      // Since class_id is NOT NULL in the schema, we cannot set it to null.
      // Instead, we delete the subject if the caller wants to remove it from a class.
      // This is a breaking change from the junction table design.
      await _supabase
          .from('subjects')
          .delete()
          .eq('id', subjectId)
          .eq('class_id', classId);
      return true;
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to remove subject from class: ${e.message}');
      throw DeputyException('Failed to remove subject from class: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to remove subject from class: ${e.toString()}');
      throw DeputyException('Failed to remove subject from class: ${e.toString()}');
    }
  }

  @override
  Future<List<AppUser>> getSchoolTeachers(String schoolId) async {
    // Input validation
    if (schoolId.isEmpty) {
      debugPrint('DeputyException: schoolId cannot be empty');
      throw DeputyException('schoolId cannot be empty');
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('school_id', schoolId)
          .eq('role', UserRole.teacher.name)
          .order('last_name', ascending: true);

      return (response as List)
          .map((r) => AppUser.fromJson(r as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      debugPrint('DeputyException: Failed to fetch school teachers: ${e.message}');
      throw DeputyException('Failed to fetch school teachers: ${e.message}');
    } catch (e) {
      if (e is DeputyException) rethrow;
      debugPrint('DeputyException: Failed to fetch school teachers: ${e.toString()}');
      throw DeputyException('Failed to fetch school teachers: ${e.toString()}');
    }
  }
}
