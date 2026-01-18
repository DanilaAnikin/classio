import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/student_repository.dart';

/// Exception thrown when student operations fail.
class StudentException implements Exception {
  const StudentException(this.message);

  final String message;

  @override
  String toString() => 'StudentException: $message';
}

/// Supabase implementation of [StudentRepository].
///
/// Fetches student data from the Supabase database for the currently
/// authenticated user.
class SupabaseStudentRepository implements StudentRepository {
  SupabaseStudentRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Cache for the current user's class ID.
  String? _cachedClassId;

  /// Subject colors for consistent visual representation.
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
  ];

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Gets the current user's class ID from the class_students table.
  Future<String?> _getCurrentUserClassId() async {
    if (_cachedClassId != null) return _cachedClassId;

    final userId = _currentUserId;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('class_students')
          .select('class_id')
          .eq('student_id', userId)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _cachedClassId = response['class_id'] as String?;
        return _cachedClassId;
      }
      return null;
    } on PostgrestException catch (e) {
      throw StudentException('Failed to get user class: ${e.message}');
    }
  }

  Color _getSubjectColor(String subjectId) {
    final hash = subjectId.hashCode.abs();
    return _subjectColors[hash % _subjectColors.length];
  }

  int _dartWeekdayToDbDayOfWeek(int dartWeekday) {
    return dartWeekday == 7 ? 0 : dartWeekday;
  }

  // ============== Attendance ==============

  @override
  Future<List<AttendanceEntity>> getMyAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      var query = _supabase
          .from('attendance')
          .select('''
            id,
            student_id,
            lesson_id,
            date,
            status,
            note,
            excuse_note,
            excuse_status,
            excuse_attachment_url,
            recorded_by,
            recorded_at,
            lessons!inner (
              id,
              subject_id,
              start_time,
              end_time,
              subjects (
                id,
                name
              )
            )
          ''')
          .eq('student_id', userId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('date', ascending: false);

      return response.map((data) => _mapToAttendance(data)).toList();
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch attendance: ${e.message}');
    }
  }

  @override
  Future<AttendanceStats> getMyAttendanceStats(String? month) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      // Determine date range
      DateTime startDate;
      DateTime endDate;

      if (month != null) {
        final parts = month.split('-');
        final year = int.parse(parts[0]);
        final monthNum = int.parse(parts[1]);
        startDate = DateTime(year, monthNum, 1);
        endDate = DateTime(year, monthNum + 1, 0);
      } else {
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
      }

      final response = await _supabase
          .from('attendance')
          .select('status')
          .eq('student_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0]);

      int presentDays = 0;
      int absentDays = 0;
      int lateDays = 0;
      int excusedDays = 0;

      for (final record in response) {
        final status = AttendanceStatus.fromString(record['status'] as String?);
        switch (status) {
          case AttendanceStatus.present:
            presentDays++;
            break;
          case AttendanceStatus.absent:
            absentDays++;
            break;
          case AttendanceStatus.late:
          case AttendanceStatus.leftEarly:
            lateDays++;
            break;
          case AttendanceStatus.excused:
            excusedDays++;
            break;
          default:
            break;
        }
      }

      return AttendanceStats(
        totalDays: response.length,
        presentDays: presentDays,
        absentDays: absentDays,
        lateDays: lateDays,
        excusedDays: excusedDays,
      );
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch attendance stats: ${e.message}');
    }
  }

  @override
  Future<Map<DateTime, DailyAttendanceStatus>> getAttendanceCalendar(
    int month,
    int year,
  ) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final response = await _supabase
          .from('attendance')
          .select('date, status')
          .eq('student_id', userId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0]);

      // Group by date
      final Map<DateTime, List<AttendanceStatus>> dateStatuses = {};
      for (final record in response) {
        final dateStr = record['date'] as String;
        final date = DateTime.parse(dateStr);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final status = AttendanceStatus.fromString(record['status'] as String?);

        if (status != null) {
          dateStatuses.putIfAbsent(normalizedDate, () => []);
          dateStatuses[normalizedDate]!.add(status);
        }
      }

      // Convert to daily status
      final Map<DateTime, DailyAttendanceStatus> calendar = {};
      for (final entry in dateStatuses.entries) {
        final statuses = entry.value;
        if (statuses.every((s) => s == AttendanceStatus.present)) {
          calendar[entry.key] = DailyAttendanceStatus.allPresent;
        } else if (statuses.every((s) => s == AttendanceStatus.absent)) {
          calendar[entry.key] = DailyAttendanceStatus.allAbsent;
        } else if (statuses.any((s) => s == AttendanceStatus.late)) {
          calendar[entry.key] = DailyAttendanceStatus.wasLate;
        } else if (statuses.any((s) => s == AttendanceStatus.absent)) {
          calendar[entry.key] = DailyAttendanceStatus.partialAbsent;
        } else {
          calendar[entry.key] = DailyAttendanceStatus.allPresent;
        }
      }

      return calendar;
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch attendance calendar: ${e.message}');
    }
  }

  @override
  Future<List<AttendanceEntity>> getRecentAttendanceIssues({int limit = 10}) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('attendance')
          .select('''
            id,
            student_id,
            lesson_id,
            date,
            status,
            note,
            excuse_note,
            excuse_status,
            excuse_attachment_url,
            recorded_by,
            recorded_at,
            lessons!inner (
              id,
              subject_id,
              start_time,
              end_time,
              subjects (
                id,
                name
              )
            )
          ''')
          .eq('student_id', userId)
          .inFilter('status', ['absent', 'late'])
          .order('date', ascending: false)
          .limit(limit);

      return response.map((data) => _mapToAttendance(data)).toList();
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch attendance issues: ${e.message}');
    }
  }

  AttendanceEntity _mapToAttendance(Map<String, dynamic> data) {
    final lessons = data['lessons'] as Map<String, dynamic>?;
    final subjects = lessons?['subjects'] as Map<String, dynamic>?;

    DateTime? lessonStartTime;
    DateTime? lessonEndTime;
    final dateStr = data['date'] as String;
    final date = DateTime.parse(dateStr);

    if (lessons != null) {
      final startTimeStr = lessons['start_time'] as String?;
      final endTimeStr = lessons['end_time'] as String?;

      if (startTimeStr != null) {
        final parts = startTimeStr.split(':');
        lessonStartTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
      if (endTimeStr != null) {
        final parts = endTimeStr.split(':');
        lessonEndTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(parts[0]),
          int.parse(parts[1]),
        );
      }
    }

    return AttendanceEntity(
      id: data['id'] as String,
      studentId: data['student_id'] as String,
      lessonId: data['lesson_id'] as String,
      date: date,
      status: AttendanceStatus.fromString(data['status'] as String?) ??
          AttendanceStatus.present,
      subjectId: subjects?['id'] as String?,
      subjectName: subjects?['name'] as String?,
      lessonStartTime: lessonStartTime,
      lessonEndTime: lessonEndTime,
      note: data['note'] as String?,
      excuseNote: data['excuse_note'] as String?,
      excuseStatus: ExcuseStatus.fromString(data['excuse_status'] as String?),
      excuseAttachmentUrl: data['excuse_attachment_url'] as String?,
      recordedBy: data['recorded_by'] as String?,
      recordedAt: data['recorded_at'] != null
          ? DateTime.parse(data['recorded_at'] as String)
          : null,
    );
  }

  // ============== Grades ==============

  @override
  Future<List<SubjectGradeStats>> getMyGrades() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('grades')
          .select('''
            id,
            subject_id,
            score,
            weight,
            grade_type,
            comment,
            created_at,
            subjects!inner (
              id,
              name
            )
          ''')
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      // Group grades by subject
      final Map<String, List<Map<String, dynamic>>> gradesBySubject = {};
      final Map<String, String> subjectNames = {};

      for (final gradeData in response) {
        final subjectId = gradeData['subject_id'] as String;
        final subjects = gradeData['subjects'] as Map<String, dynamic>;
        final subjectName = subjects['name'] as String;

        gradesBySubject.putIfAbsent(subjectId, () => []);
        gradesBySubject[subjectId]!.add(gradeData);
        subjectNames[subjectId] = subjectName;
      }

      // Convert to SubjectGradeStats list
      final List<SubjectGradeStats> subjectStats = [];
      var colorIndex = 0;

      for (final entry in gradesBySubject.entries) {
        final subjectId = entry.key;
        final gradesData = entry.value;
        final subjectName = subjectNames[subjectId] ?? 'Unknown Subject';

        final grades = gradesData.map((data) => Grade(
          id: data['id'] as String,
          subjectId: data['subject_id'] as String,
          score: (data['score'] as num).toDouble(),
          weight: (data['weight'] as num?)?.toDouble() ?? 1.0,
          description: data['grade_type'] as String? ??
              data['comment'] as String? ??
              'Grade',
          date: DateTime.parse(data['created_at'] as String),
        )).toList();

        final average = _calculateWeightedAverage(grades);
        final color = _subjectColors[colorIndex % _subjectColors.length];
        colorIndex++;

        subjectStats.add(SubjectGradeStats(
          subjectId: subjectId,
          subjectName: subjectName,
          subjectColor: color.toARGB32(),
          average: average,
          grades: grades,
        ));
      }

      subjectStats.sort((a, b) => a.subjectName.compareTo(b.subjectName));
      return subjectStats;
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch grades: ${e.message}');
    }
  }

  double _calculateWeightedAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0.0;

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (final grade in grades) {
      totalWeightedScore += grade.score * grade.weight;
      totalWeight += grade.weight;
    }

    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
  }

  @override
  Future<Map<String, double>> getSubjectAverages() async {
    final grades = await getMyGrades();
    return {for (final s in grades) s.subjectId: s.average};
  }

  @override
  Future<List<Grade>> getRecentGrades({int limit = 5}) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('grades')
          .select('''
            id,
            subject_id,
            score,
            weight,
            grade_type,
            comment,
            created_at
          ''')
          .eq('student_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((data) => Grade(
        id: data['id'] as String,
        subjectId: data['subject_id'] as String,
        score: (data['score'] as num).toDouble(),
        weight: (data['weight'] as num?)?.toDouble() ?? 1.0,
        description: data['grade_type'] as String? ??
            data['comment'] as String? ??
            'Grade',
        date: DateTime.parse(data['created_at'] as String),
      )).toList();
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch recent grades: ${e.message}');
    }
  }

  // ============== Schedule ==============

  @override
  Future<List<Lesson>> getTodaysLessons() async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) return [];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dbDayOfWeek = _dartWeekdayToDbDayOfWeek(now.weekday);

    try {
      // First get subject IDs for this class, then query lessons
      // (lessons don't have class_id - they link through subjects)
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('class_id', classId);

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      if (subjectIds.isEmpty) {
        return [];
      }

      final response = await _supabase
          .from('lessons')
          .select('''
            id,
            subject_id,
            day_of_week,
            start_time,
            end_time,
            room,
            subjects (
              id,
              name,
              teacher:profiles!subjects_teacher_id_fkey (
                first_name,
                last_name
              )
            )
          ''')
          .inFilter('subject_id', subjectIds)
          .eq('day_of_week', dbDayOfWeek)
          .order('start_time', ascending: true);

      return response.map((row) => _mapToLesson(row, today)).toList();
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch today lessons: ${e.message}');
    }
  }

  @override
  Future<Map<int, List<Lesson>>> getWeeklySchedule() async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) return {};

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    try {
      // First get subject IDs for this class, then query lessons
      // (lessons don't have class_id - they link through subjects)
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('class_id', classId);

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      if (subjectIds.isEmpty) {
        return {for (int i = 1; i <= 7; i++) i: <Lesson>[]};
      }

      final response = await _supabase
          .from('lessons')
          .select('''
            id,
            subject_id,
            day_of_week,
            start_time,
            end_time,
            room,
            subjects (
              id,
              name,
              teacher:profiles!subjects_teacher_id_fkey (
                first_name,
                last_name
              )
            )
          ''')
          .inFilter('subject_id', subjectIds)
          .order('start_time', ascending: true);

      final Map<int, List<Lesson>> weekLessons = {
        for (int i = 1; i <= 7; i++) i: []
      };

      for (final row in response) {
        final dbDayOfWeek = row['day_of_week'] as int;
        // Convert DB day (0=Sun, 1=Mon...) to Dart weekday (1=Mon...7=Sun)
        final dartWeekday = dbDayOfWeek == 0 ? 7 : dbDayOfWeek;
        final date = monday.add(Duration(days: dartWeekday - 1));
        weekLessons[dartWeekday]!.add(_mapToLesson(row, date));
      }

      return weekLessons;
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch weekly schedule: ${e.message}');
    }
  }

  Lesson _mapToLesson(Map<String, dynamic> row, DateTime date) {
    final subjectData = row['subjects'] as Map<String, dynamic>?;
    final teacherData = subjectData?['teacher'] as Map<String, dynamic>?;

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

    String? teacherName;
    if (teacherData != null) {
      final firstName = teacherData['first_name'] as String?;
      final lastName = teacherData['last_name'] as String?;
      if (firstName != null || lastName != null) {
        teacherName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    final subjectId = (subjectData?['id'] ?? row['subject_id'] ?? '') as String;
    final subjectName = (subjectData?['name'] ?? 'Unknown Subject') as String;

    final subject = Subject(
      id: subjectId,
      name: subjectName,
      color: _getSubjectColor(subjectId).toARGB32(),
      teacherName: teacherName,
    );

    return Lesson(
      id: row['id'] as String,
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      room: (row['room'] as String?) ?? '',
      status: LessonStatus.normal,
    );
  }

  // ============== Assignments ==============

  @override
  Future<List<Assignment>> getUpcomingAssignments({int days = 7}) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final classId = await _getCurrentUserClassId();
    if (classId == null) return [];

    final now = DateTime.now();
    final cutoffDate = now.add(Duration(days: days));

    try {
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .eq('class_id', classId);

      final subjectMap = <String, Map<String, dynamic>>{};
      for (final subject in subjectsResponse) {
        subjectMap[subject['id'] as String] = subject;
      }

      if (subjectMap.isEmpty) return [];

      final assignmentsResponse = await _supabase
          .from('assignments')
          .select('id, subject_id, title, description, due_date, created_at')
          .inFilter('subject_id', subjectMap.keys.toList())
          .gte('due_date', now.toIso8601String())
          .lte('due_date', cutoffDate.toIso8601String())
          .order('due_date', ascending: true);

      final assignmentIds =
          assignmentsResponse.map((a) => a['id'] as String).toList();
      final submissionsResponse = await _supabase
          .from('assignment_submissions')
          .select('assignment_id')
          .eq('student_id', userId)
          .inFilter('assignment_id', assignmentIds);

      final completedAssignmentIds = <String>{};
      for (final submission in submissionsResponse) {
        completedAssignmentIds.add(submission['assignment_id'] as String);
      }

      final assignments = <Assignment>[];
      for (final row in assignmentsResponse) {
        final subjectId = row['subject_id'] as String;
        final subjectData = subjectMap[subjectId];
        if (subjectData != null) {
          var assignment = _mapToAssignment(row, subjectData);
          if (completedAssignmentIds.contains(assignment.id)) {
            assignment = assignment.copyWith(isCompleted: true);
          }
          assignments.add(assignment);
        }
      }

      return assignments;
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch assignments: ${e.message}');
    }
  }

  @override
  Future<List<Assignment>> getMyAssignments() async {
    final classId = await _getCurrentUserClassId();
    if (classId == null) return [];

    try {
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            teacher:profiles!subjects_teacher_id_fkey (
              first_name,
              last_name
            )
          ''')
          .eq('class_id', classId);

      final subjectMap = <String, Map<String, dynamic>>{};
      for (final subject in subjectsResponse) {
        subjectMap[subject['id'] as String] = subject;
      }

      if (subjectMap.isEmpty) return [];

      final assignmentsResponse = await _supabase
          .from('assignments')
          .select('id, subject_id, title, description, due_date, created_at')
          .inFilter('subject_id', subjectMap.keys.toList())
          .order('due_date', ascending: false);

      return assignmentsResponse.map((row) {
        final subjectId = row['subject_id'] as String;
        final subjectData = subjectMap[subjectId];
        if (subjectData != null) {
          return _mapToAssignment(row, subjectData);
        }
        return null;
      }).whereType<Assignment>().toList();
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch assignments: ${e.message}');
    }
  }

  Assignment _mapToAssignment(
    Map<String, dynamic> row,
    Map<String, dynamic> subjectData,
  ) {
    final teacherData = subjectData['teacher'] as Map<String, dynamic>?;

    String? teacherName;
    if (teacherData != null) {
      final firstName = teacherData['first_name'] as String?;
      final lastName = teacherData['last_name'] as String?;
      if (firstName != null || lastName != null) {
        teacherName = [firstName, lastName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');
      }
    }

    final subjectId = subjectData['id'] as String;
    final subjectName = (subjectData['name'] ?? 'Unknown Subject') as String;

    final subject = Subject(
      id: subjectId,
      name: subjectName,
      color: _getSubjectColor(subjectId).toARGB32(),
      teacherName: teacherName,
    );

    return Assignment(
      id: row['id'] as String,
      subject: subject,
      title: row['title'] as String? ?? 'Untitled Assignment',
      description: row['description'] as String?,
      dueDate: row['due_date'] != null
          ? DateTime.parse(row['due_date'] as String)
          : DateTime.now().add(const Duration(days: 7)),
      isCompleted: false,
    );
  }

  @override
  Future<void> submitAssignment(
    String assignmentId, {
    String? content,
    String? fileUrl,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      await _supabase.from('assignment_submissions').insert({
        'assignment_id': assignmentId,
        'student_id': userId,
        'content': content,
        'file_url': fileUrl,
        'submitted_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw StudentException('Failed to submit assignment: ${e.message}');
    }
  }

  @override
  Future<List<AssignmentSubmission>> getMySubmissions() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const StudentException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('assignment_submissions')
          .select()
          .eq('student_id', userId)
          .order('submitted_at', ascending: false);

      return response.map((data) => AssignmentSubmission(
        id: data['id'] as String,
        assignmentId: data['assignment_id'] as String,
        studentId: data['student_id'] as String,
        submittedAt: DateTime.parse(data['submitted_at'] as String),
        content: data['content'] as String?,
        fileUrl: data['file_url'] as String?,
        grade: (data['grade'] as num?)?.toDouble(),
        feedback: data['feedback'] as String?,
      )).toList();
    } on PostgrestException catch (e) {
      throw StudentException('Failed to fetch submissions: ${e.message}');
    }
  }

  @override
  Future<void> refresh() async {
    _cachedClassId = null;
  }
}
