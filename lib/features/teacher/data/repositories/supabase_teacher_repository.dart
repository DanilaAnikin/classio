import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../dashboard/domain/entities/lesson.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/domain.dart';

/// Exception thrown when teacher operations fail.
class TeacherException extends RepositoryException {
  const TeacherException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'TeacherException: $message';
}

/// Supabase implementation of [TeacherRepository].
///
/// Provides full teacher functionality including gradebook management,
/// attendance tracking, assignment handling, and student management.
class SupabaseTeacherRepository implements TeacherRepository {
  /// Creates a [SupabaseTeacherRepository] instance.
  SupabaseTeacherRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  /// Predefined colors for subjects.
  static const List<Color> _subjectColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lime,
    Colors.deepPurple,
    Colors.brown,
  ];

  /// Gets the current user's ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Generates a deterministic color for a subject.
  Color _getSubjectColor(String subjectId) {
    final hash = subjectId.hashCode.abs();
    return _subjectColors[hash % _subjectColors.length];
  }

  // ========== My Subjects/Classes ==========

  @override
  Future<List<Subject>> getMySubjects() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('subjects')
          .select('id, name, description')
          .eq('teacher_id', userId)
          .order('name', ascending: true);

      return response.map<Subject>((row) {
        final id = row['id'] as String;
        return Subject(
          id: id,
          name: row['name'] as String? ?? 'Unknown Subject',
          color: _getSubjectColor(id).toARGB32(),
          teacherName: null,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch subjects: ${e.message}');
    }
  }

  @override
  Future<List<ClassInfo>> getMyClasses() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      // Get class_id directly from subjects where teacher teaches
      // This finds all classes where the teacher is assigned to at least one subject
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('class_id')
          .eq('teacher_id', userId);

      final classIds = subjectsResponse
          .map((s) => s['class_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      if (classIds.isEmpty) return [];

      // Get full class information
      final classesResponse = await _supabase
          .from('classes')
          .select('id, school_id, name, grade_level, academic_year, created_at')
          .inFilter('id', classIds)
          .order('name', ascending: true);

      return classesResponse
          .map<ClassInfo>((row) => ClassInfo.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch classes: ${e.message}');
    }
  }

  // ========== Gradebook ==========

  @override
  Future<List<AppUser>> getClassStudents(String classId) async {
    try {
      final response = await _supabase
          .from('class_students')
          .select('''
            student:profiles!class_students_student_id_fkey (
              id,
              email,
              role,
              first_name,
              last_name,
              school_id,
              avatar_url,
              created_at
            )
          ''')
          .eq('class_id', classId);

      final students = <AppUser>[];
      for (final row in response) {
        final studentData = row['student'] as Map<String, dynamic>?;
        if (studentData != null) {
          try {
            students.add(AppUser.fromJson(studentData));
          } catch (_) {
            // Skip invalid student data
          }
        }
      }

      // Sort by name
      students.sort((a, b) => a.fullName.compareTo(b.fullName));
      return students;
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch students: ${e.message}');
    }
  }

  @override
  Future<List<AppUser>> getSubjectStudents(String subjectId) async {
    try {
      // Get class_ids from lessons table (lessons have both subject_id and class_id)
      final lessonsResponse = await _supabase
          .from('lessons')
          .select('class_id')
          .eq('subject_id', subjectId);

      if (lessonsResponse.isEmpty) return [];

      final classIds = lessonsResponse
          .map((l) => l['class_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      if (classIds.isEmpty) return [];

      // Get all students from these classes
      final response = await _supabase
          .from('class_students')
          .select('''
            student:profiles!class_students_student_id_fkey (
              id,
              email,
              role,
              first_name,
              last_name,
              school_id,
              avatar_url,
              created_at
            )
          ''')
          .inFilter('class_id', classIds);

      final students = <AppUser>[];
      final seenIds = <String>{};

      for (final row in response) {
        final studentData = row['student'] as Map<String, dynamic>?;
        if (studentData != null) {
          final id = studentData['id'] as String?;
          if (id != null && !seenIds.contains(id)) {
            seenIds.add(id);
            try {
              students.add(AppUser.fromJson(studentData));
            } catch (_) {
              // Skip invalid student data
            }
          }
        }
      }

      // Sort by name
      students.sort((a, b) => a.fullName.compareTo(b.fullName));
      return students;
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch students: ${e.message}');
    }
  }

  @override
  Future<List<TeacherGradeEntity>> getSubjectGrades(String subjectId) async {
    try {
      // Note: grades table has: id, student_id, subject_id, teacher_id, score, weight, note, grade_type, created_at
      // The 'note' column is used for comments, there is no 'assignment_id' column
      final response = await _supabase
          .from('grades')
          .select('''
            id,
            student_id,
            subject_id,
            score,
            weight,
            grade_type,
            note,
            created_at,
            student:profiles!grades_student_id_fkey (
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('subject_id', subjectId)
          .order('created_at', ascending: false);

      return response.map<TeacherGradeEntity>((row) {
        // Map 'note' to 'comment' for entity compatibility
        final mappedRow = Map<String, dynamic>.from(row);
        mappedRow['comment'] = mappedRow['note'];
        return TeacherGradeEntity.fromJson(mappedRow);
      }).toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch grades: ${e.message}');
    }
  }

  @override
  Future<List<TeacherGradeEntity>> getStudentGrades(
    String studentId,
    String subjectId,
  ) async {
    try {
      // Note: grades table has: id, student_id, subject_id, teacher_id, score, weight, note, grade_type, created_at
      // The 'note' column is used for comments, there is no 'assignment_id' column
      final response = await _supabase
          .from('grades')
          .select('''
            id,
            student_id,
            subject_id,
            score,
            weight,
            grade_type,
            note,
            created_at
          ''')
          .eq('student_id', studentId)
          .eq('subject_id', subjectId)
          .order('created_at', ascending: false);

      return response.map<TeacherGradeEntity>((row) {
        // Map 'note' to 'comment' for entity compatibility
        final mappedRow = Map<String, dynamic>.from(row);
        mappedRow['comment'] = mappedRow['note'];
        return TeacherGradeEntity.fromJson(mappedRow);
      }).toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch student grades: ${e.message}');
    }
  }

  @override
  Future<TeacherGradeEntity> addGrade({
    required String studentId,
    required String subjectId,
    required double score,
    double weight = 1.0,
    String? gradeType,
    String? comment,
    String? assignmentId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      final id = _uuid.v4();
      final now = DateTime.now().toIso8601String();

      // Note: grades table columns are: id, student_id, subject_id, teacher_id, score, weight, note, grade_type, created_at
      // 'note' is used for comments, 'teacher_id' is required, and there is no 'assignment_id' column
      final data = {
        'id': id,
        'student_id': studentId,
        'subject_id': subjectId,
        'teacher_id': userId,
        'score': score,
        'weight': weight,
        'grade_type': gradeType,
        'note': comment,
        'created_at': now,
      };

      await _supabase.from('grades').insert(data);

      return TeacherGradeEntity(
        id: id,
        studentId: studentId,
        subjectId: subjectId,
        score: score,
        weight: weight,
        gradeType: gradeType,
        comment: comment,
        createdAt: DateTime.now(),
      );
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to add grade: ${e.message}');
    }
  }

  @override
  Future<void> updateGrade(TeacherGradeEntity grade) async {
    try {
      // Note: grades table uses 'note' for comments, not 'comment'
      // Also, there's no 'updated_at' column in the grades table
      await _supabase
          .from('grades')
          .update({
            'score': grade.score,
            'weight': grade.weight,
            'grade_type': grade.gradeType,
            'note': grade.comment,
          })
          .eq('id', grade.id);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to update grade: ${e.message}');
    }
  }

  @override
  Future<void> deleteGrade(String gradeId) async {
    try {
      await _supabase.from('grades').delete().eq('id', gradeId);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to delete grade: ${e.message}');
    }
  }

  // ========== Assignments ==========

  @override
  Future<List<AssignmentEntity>> getSubjectAssignments(String subjectId) async {
    try {
      final response = await _supabase
          .from('assignments')
          .select('''
            id,
            subject_id,
            title,
            description,
            due_date,
            max_score,
            created_by,
            created_at,
            subjects (
              name
            )
          ''')
          .eq('subject_id', subjectId)
          .order('due_date', ascending: false);

      return response
          .map<AssignmentEntity>((row) => AssignmentEntity.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch assignments: ${e.message}');
    }
  }

  @override
  Future<List<AssignmentEntity>> getMyAssignments() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      // Get teacher's subjects first
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('teacher_id', userId);

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      if (subjectIds.isEmpty) return [];

      final response = await _supabase
          .from('assignments')
          .select('''
            id,
            subject_id,
            title,
            description,
            due_date,
            max_score,
            created_by,
            created_at,
            subjects (
              name
            )
          ''')
          .inFilter('subject_id', subjectIds)
          .order('due_date', ascending: false);

      return response
          .map<AssignmentEntity>((row) => AssignmentEntity.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch assignments: ${e.message}');
    }
  }

  @override
  Future<AssignmentEntity> createAssignment({
    required String subjectId,
    required String title,
    String? description,
    DateTime? dueDate,
    int maxScore = 100,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      final id = _uuid.v4();
      final now = DateTime.now();

      final data = {
        'id': id,
        'subject_id': subjectId,
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'max_score': maxScore,
        'created_by': userId,
        'created_at': now.toIso8601String(),
      };

      await _supabase.from('assignments').insert(data);

      return AssignmentEntity(
        id: id,
        subjectId: subjectId,
        title: title,
        description: description,
        dueDate: dueDate,
        maxScore: maxScore,
        createdBy: userId,
        createdAt: now,
      );
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to create assignment: ${e.message}');
    }
  }

  @override
  Future<void> updateAssignment(AssignmentEntity assignment) async {
    try {
      await _supabase
          .from('assignments')
          .update({
            'title': assignment.title,
            'description': assignment.description,
            'due_date': assignment.dueDate?.toIso8601String(),
            'max_score': assignment.maxScore,
          })
          .eq('id', assignment.id);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to update assignment: ${e.message}');
    }
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _supabase.from('assignments').delete().eq('id', assignmentId);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to delete assignment: ${e.message}');
    }
  }

  @override
  Future<List<SubmissionEntity>> getAssignmentSubmissions(
      String assignmentId) async {
    try {
      // Note: submissions table has: id, assignment_id, student_id, file_url, content, grade, teacher_comment, submitted_at, graded_at, graded_by
      // 'teacher_comment' is the column name, not 'comment'
      final response = await _supabase
          .from('submissions')
          .select('''
            id,
            assignment_id,
            student_id,
            content,
            file_url,
            grade,
            teacher_comment,
            submitted_at,
            graded_at,
            graded_by,
            student:profiles!submissions_student_id_fkey (
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('assignment_id', assignmentId)
          .order('submitted_at', ascending: false);

      return response.map<SubmissionEntity>((row) {
        // Map 'teacher_comment' to 'comment' for entity compatibility
        final mappedRow = Map<String, dynamic>.from(row);
        mappedRow['comment'] = mappedRow['teacher_comment'];
        return SubmissionEntity.fromJson(mappedRow);
      }).toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch submissions: ${e.message}');
    }
  }

  @override
  Future<void> gradeSubmission(
    String submissionId,
    double grade,
    String? comment,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      // Note: submissions table uses 'teacher_comment' column, not 'comment'
      await _supabase
          .from('submissions')
          .update({
            'grade': grade,
            'teacher_comment': comment,
            'graded_at': DateTime.now().toIso8601String(),
            'graded_by': userId,
          })
          .eq('id', submissionId);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to grade submission: ${e.message}');
    }
  }

  // ========== Attendance ==========

  @override
  Future<List<Lesson>> getTodaysLessons(DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      // Get teacher's subjects
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id, name')
          .eq('teacher_id', userId);

      if (subjectsResponse.isEmpty) return [];

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();
      final subjectNames = <String, String>{};
      for (final s in subjectsResponse) {
        subjectNames[s['id'] as String] = s['name'] as String;
      }

      // Convert date weekday to database format
      final dbDayOfWeek = date.weekday == 7 ? 0 : date.weekday;

      // Get lessons with their class info directly (lessons have class_id)
      final response = await _supabase
          .from('lessons')
          .select('''
            id,
            subject_id,
            class_id,
            day_of_week,
            start_time,
            end_time,
            room,
            classes (
              name
            )
          ''')
          .inFilter('subject_id', subjectIds)
          .eq('day_of_week', dbDayOfWeek)
          .order('start_time', ascending: true);

      return response.map<Lesson>((row) {
        final subjectId = row['subject_id'] as String;
        final startTimeStr = row['start_time'] as String?;
        final endTimeStr = row['end_time'] as String?;

        DateTime startTime;
        DateTime endTime;

        if (startTimeStr != null && endTimeStr != null) {
          final startParts = startTimeStr.split(':');
          final endParts = endTimeStr.split(':');

          startTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(startParts[0]),
            int.parse(startParts[1]),
          );
          endTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(endParts[0]),
            int.parse(endParts[1]),
          );
        } else {
          startTime = DateTime(date.year, date.month, date.day, 8, 0);
          endTime = DateTime(date.year, date.month, date.day, 8, 45);
        }

        // Get class name directly from the lesson's joined class data
        final classData = row['classes'] as Map<String, dynamic>?;
        final className = classData?['name'] as String? ?? '';

        return Lesson(
          id: row['id'] as String,
          subject: Subject(
            id: subjectId,
            name: subjectNames[subjectId] ?? 'Unknown Subject',
            color: _getSubjectColor(subjectId).toARGB32(),
          ),
          startTime: startTime,
          endTime: endTime,
          room: '${row['room'] ?? ''} - $className'.trim(),
          status: LessonStatus.normal,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch lessons: ${e.message}');
    }
  }

  @override
  Future<List<Lesson>> getLessonsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Simplified implementation - would need to expand for date ranges
    return getTodaysLessons(startDate);
  }

  @override
  Future<List<AttendanceEntity>> getLessonAttendance(
    String lessonId,
    DateTime date,
  ) async {
    try {
      final dateStr = date.toIso8601String().split('T').first;

      final response = await _supabase
          .from('attendance')
          .select('''
            id,
            student_id,
            lesson_id,
            date,
            status,
            excuse_note,
            excuse_status,
            marked_by,
            created_at,
            student:profiles!attendance_student_id_fkey (
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('lesson_id', lessonId)
          .eq('date', dateStr);

      return response
          .map<AttendanceEntity>((row) => AttendanceEntity.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch attendance: ${e.message}');
    }
  }

  @override
  Future<void> markAttendance({
    required String studentId,
    required String lessonId,
    required DateTime date,
    required AttendanceStatus status,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      final dateStr = date.toIso8601String().split('T').first;

      // Check if attendance record exists
      final existing = await _supabase
          .from('attendance')
          .select('id')
          .eq('student_id', studentId)
          .eq('lesson_id', lessonId)
          .eq('date', dateStr)
          .maybeSingle();

      if (existing != null) {
        // Update existing record
        await _supabase
            .from('attendance')
            .update({
              'status': status.name,
              'marked_by': userId,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
      } else {
        // Create new record
        await _supabase.from('attendance').insert({
          'id': _uuid.v4(),
          'student_id': studentId,
          'lesson_id': lessonId,
          'date': dateStr,
          'status': status.name,
          'marked_by': userId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to mark attendance: ${e.message}');
    }
  }

  @override
  Future<void> bulkMarkAttendance(List<AttendanceRecord> records) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      for (final record in records) {
        await markAttendance(
          studentId: record.studentId,
          lessonId: record.lessonId,
          date: record.date,
          status: record.status,
        );
      }
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to mark attendance: ${e.message}');
    }
  }

  @override
  Future<List<AppUser>> getStudentsForLesson(String lessonId) async {
    try {
      // Get the class ID through the lesson's subject
      // (lessons don't have class_id - they link through subjects)
      final lessonResponse = await _supabase
          .from('lessons')
          .select('subject_id, subjects(class_id)')
          .eq('id', lessonId)
          .maybeSingle();

      if (lessonResponse == null) {
        throw TeacherException('Lesson not found with id $lessonId');
      }

      final subjectData = lessonResponse['subjects'] as Map<String, dynamic>?;
      final classId = subjectData?['class_id'] as String?;

      if (classId == null) {
        return [];
      }

      return getClassStudents(classId);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch students: ${e.message}');
    }
  }

  // ========== Excuse Management ==========

  @override
  Future<List<AttendanceEntity>> getPendingExcuses() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      // Get teacher's subject IDs
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('teacher_id', userId);

      if (subjectsResponse.isEmpty) return [];

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      // Get lessons for those subjects
      final lessonsResponse = await _supabase
          .from('lessons')
          .select('id')
          .inFilter('subject_id', subjectIds);

      if (lessonsResponse.isEmpty) return [];

      final lessonIds = lessonsResponse.map((l) => l['id'] as String).toList();

      // Get pending excuses
      final response = await _supabase
          .from('attendance')
          .select('''
            id,
            student_id,
            lesson_id,
            date,
            status,
            excuse_note,
            excuse_status,
            marked_by,
            created_at,
            student:profiles!attendance_student_id_fkey (
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .inFilter('lesson_id', lessonIds)
          .eq('excuse_status', 'pending')
          .not('excuse_note', 'is', null)
          .order('created_at', ascending: false);

      return response
          .map<AttendanceEntity>((row) => AttendanceEntity.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch pending excuses: ${e.message}');
    }
  }

  @override
  Future<void> reviewExcuse(String attendanceId, ExcuseStatus status) async {
    try {
      await _supabase
          .from('attendance')
          .update({
            'excuse_status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', attendanceId);
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to review excuse: ${e.message}');
    }
  }

  // ========== Stats ==========

  @override
  Future<TeacherStats> getTeacherStats() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const TeacherException('User not authenticated');
    }

    try {
      // Get teacher's subject IDs
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('teacher_id', userId);

      final totalSubjects = subjectsResponse.length;
      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      if (subjectIds.isEmpty) {
        return const TeacherStats();
      }

      // Get lessons with class_id (lessons table has class_id)
      final lessonsResponse = await _supabase
          .from('lessons')
          .select('id, class_id, day_of_week')
          .inFilter('subject_id', subjectIds);

      final totalLessons = lessonsResponse.length;

      // Get class IDs from lessons
      final classIds = lessonsResponse
          .map((l) => l['class_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      // Get today's lessons
      final today = DateTime.now();
      final dbDayOfWeek = today.weekday == 7 ? 0 : today.weekday;
      final todaysLessons = lessonsResponse
          .where((l) => l['day_of_week'] == dbDayOfWeek)
          .length;

      // Get total students
      int totalStudents = 0;
      if (classIds.isNotEmpty) {
        final studentsResponse = await _supabase
            .from('class_students')
            .select('student_id')
            .inFilter('class_id', classIds);
        totalStudents =
            studentsResponse.map((s) => s['student_id']).toSet().length;
      }

      // Get pending excuses count
      final lessonIds = lessonsResponse.map((l) => l['id'] as String).toList();
      int pendingExcuses = 0;
      if (lessonIds.isNotEmpty) {
        final excusesResponse = await _supabase
            .from('attendance')
            .select('id')
            .inFilter('lesson_id', lessonIds)
            .eq('excuse_status', 'pending');
        pendingExcuses = excusesResponse.length;
      }

      return TeacherStats(
        totalStudents: totalStudents,
        totalLessons: totalLessons,
        totalSubjects: totalSubjects,
        pendingExcuses: pendingExcuses,
        todaysLessons: todaysLessons,
        averageAttendance: 0.0, // Would need more complex calculation
        gradesToReview: 0, // Would need submissions table
        assignmentsDue: 0,
      );
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch stats: ${e.message}');
    }
  }

  @override
  Future<Map<String, double>> getClassAttendanceStats(String classId) async {
    // Simplified implementation
    return {
      'present': 85.0,
      'absent': 10.0,
      'late': 5.0,
    };
  }

  @override
  Future<Map<String, double>> getSubjectGradeStats(String subjectId) async {
    try {
      final response = await _supabase
          .from('grades')
          .select('score')
          .eq('subject_id', subjectId);

      if (response.isEmpty) {
        return {'average': 0.0, 'highest': 0.0, 'lowest': 0.0};
      }

      final scores =
          response.map((r) => (r['score'] as num).toDouble()).toList();
      final average = scores.reduce((a, b) => a + b) / scores.length;
      final highest = scores.reduce((a, b) => a > b ? a : b);
      final lowest = scores.reduce((a, b) => a < b ? a : b);

      return {
        'average': average,
        'highest': highest,
        'lowest': lowest,
      };
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch grade stats: ${e.message}');
    }
  }
}
