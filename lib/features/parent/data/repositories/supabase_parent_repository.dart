import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/entities.dart';
import '../../../grades/domain/entities/entities.dart';
import '../../../student/domain/entities/entities.dart';
import '../../domain/repositories/parent_repository.dart';

/// Exception thrown when parent operations fail.
class ParentException extends RepositoryException {
  const ParentException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'ParentException: $message';
}

/// Supabase implementation of [ParentRepository].
///
/// Fetches child data and manages excuses for the currently
/// authenticated parent user.
class SupabaseParentRepository implements ParentRepository {
  SupabaseParentRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Cache for children data.
  List<AppUser>? _cachedChildren;

  /// Cache for child class IDs.
  final Map<String, String?> _childClassIds = {};

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

  Color _getSubjectColor(String subjectId) {
    final hash = subjectId.hashCode.abs();
    return _subjectColors[hash % _subjectColors.length];
  }

  int _dartWeekdayToDbDayOfWeek(int dartWeekday) {
    return dartWeekday == 7 ? 0 : dartWeekday;
  }

  /// Gets a child's class ID.
  Future<String?> _getChildClassId(String childId) async {
    if (_childClassIds.containsKey(childId)) {
      return _childClassIds[childId];
    }

    try {
      final response = await _supabase
          .from('class_students')
          .select('class_id')
          .eq('student_id', childId)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _childClassIds[childId] = response['class_id'] as String?;
        return _childClassIds[childId];
      }
      return null;
    } on PostgrestException catch (e) {
      throw ParentException('Failed to get child class: ${e.message}');
    }
  }

  // ============== Children ==============

  @override
  Future<List<AppUser>> getMyChildren() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const ParentException('User not authenticated');
    }

    final cached = _cachedChildren;
    if (cached != null) {
      return cached;
    }

    try {
      // Query the parent_student relationship table (not the view parent_students)
      // The actual table has proper foreign key relationships for PostgREST joins
      final response = await _supabase
          .from('parent_student')
          .select('''
            student_id,
            profiles!parent_student_student_id_fkey (
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
          .eq('parent_id', userId);

      final children = response.map((data) {
        final profile = data['profiles'] as Map<String, dynamic>;
        return AppUser.fromJson(profile);
      }).toList();

      _cachedChildren = children;
      return children;
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch children: ${e.message}');
    }
  }

  // ============== Child Attendance ==============

  @override
  Future<List<AttendanceEntity>> getChildAttendance(
    String childId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const ParentException('User not authenticated');
    }

    // Verify this is the parent's child
    await _verifyParentChild(childId);

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
          .eq('student_id', childId);

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String().split('T')[0]);
      }

      final response = await query.order('date', ascending: false);

      return response.map((data) => _mapToAttendance(data)).toList();
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch child attendance: ${e.message}');
    }
  }

  @override
  Future<AttendanceStats> getChildAttendanceStats(
    String childId,
    String? month,
  ) async {
    await _verifyParentChild(childId);

    try {
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
          .eq('student_id', childId)
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
      throw ParentException('Failed to fetch attendance stats: ${e.message}');
    }
  }

  @override
  Future<Map<DateTime, DailyAttendanceStatus>> getChildAttendanceCalendar(
    String childId,
    int month,
    int year,
  ) async {
    await _verifyParentChild(childId);

    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final response = await _supabase
          .from('attendance')
          .select('date, status')
          .eq('student_id', childId)
          .gte('date', startDate.toIso8601String().split('T')[0])
          .lte('date', endDate.toIso8601String().split('T')[0]);

      final Map<DateTime, List<AttendanceStatus>> dateStatuses = {};
      for (final record in response) {
        final dateStr = record['date'] as String;
        final date = DateTime.parse(dateStr);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final status = AttendanceStatus.fromString(record['status'] as String?);

        if (status != null) {
          dateStatuses.putIfAbsent(normalizedDate, () => []);
          dateStatuses[normalizedDate]?.add(status);
        }
      }

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
      throw ParentException('Failed to fetch attendance calendar: ${e.message}');
    }
  }

  @override
  Future<List<AttendanceEntity>> getChildAttendanceIssues(
    String childId, {
    int limit = 10,
  }) async {
    await _verifyParentChild(childId);

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
          .eq('student_id', childId)
          .inFilter('status', ['absent', 'late'])
          .order('date', ascending: false)
          .limit(limit);

      return response.map((data) => _mapToAttendance(data)).toList();
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch attendance issues: ${e.message}');
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

  // ============== Child Grades ==============

  @override
  Future<List<SubjectGradeStats>> getChildGrades(String childId) async {
    await _verifyParentChild(childId);

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
          .eq('student_id', childId)
          .order('created_at', ascending: false);

      final Map<String, List<Map<String, dynamic>>> gradesBySubject = {};
      final Map<String, String> subjectNames = {};

      for (final gradeData in response) {
        final subjectId = gradeData['subject_id'] as String;
        final subjects = gradeData['subjects'] as Map<String, dynamic>;
        final subjectName = subjects['name'] as String;

        gradesBySubject.putIfAbsent(subjectId, () => []);
        gradesBySubject[subjectId]?.add(gradeData);
        subjectNames[subjectId] = subjectName;
      }

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
      throw ParentException('Failed to fetch child grades: ${e.message}');
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
  Future<Map<String, double>> getChildSubjectAverages(String childId) async {
    final grades = await getChildGrades(childId);
    return {for (final s in grades) s.subjectId: s.average};
  }

  // ============== Child Schedule ==============

  @override
  Future<List<Lesson>> getChildTodaysLessons(String childId) async {
    await _verifyParentChild(childId);

    final classId = await _getChildClassId(childId);
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
      throw ParentException('Failed to fetch child lessons: ${e.message}');
    }
  }

  @override
  Future<Map<int, List<Lesson>>> getChildWeeklySchedule(String childId) async {
    await _verifyParentChild(childId);

    final classId = await _getChildClassId(childId);
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
        final dartWeekday = dbDayOfWeek == 0 ? 7 : dbDayOfWeek;
        final date = monday.add(Duration(days: dartWeekday - 1));
        weekLessons[dartWeekday]?.add(_mapToLesson(row, date));
      }

      return weekLessons;
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch child schedule: ${e.message}');
    }
  }

  @override
  Future<Map<int, List<Lesson>>> getChildWeeklyScheduleForWeek(
    String childId,
    DateTime weekStart,
  ) async {
    await _verifyParentChild(childId);

    final classId = await _getChildClassId(childId);
    if (classId == null) return {};

    // Ensure weekStart is the Monday of the week
    final monday = weekStart.subtract(Duration(days: weekStart.weekday - 1));

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
        final dartWeekday = dbDayOfWeek == 0 ? 7 : dbDayOfWeek;
        final date = monday.add(Duration(days: dartWeekday - 1));
        weekLessons[dartWeekday]?.add(_mapToLesson(row, date));
      }

      return weekLessons;
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch child schedule: ${e.message}');
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

  // ============== Child Assignments ==============

  @override
  Future<List<Assignment>> getChildAssignments(
    String childId, {
    int days = 7,
  }) async {
    await _verifyParentChild(childId);

    final classId = await _getChildClassId(childId);
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
          .eq('student_id', childId)
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
      throw ParentException('Failed to fetch child assignments: ${e.message}');
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

  // ============== Excuse Submission ==============

  @override
  Future<void> submitExcuse(
    String attendanceId,
    String excuseNote, {
    String? attachmentUrl,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const ParentException('User not authenticated');
    }

    try {
      // First verify this attendance belongs to parent's child
      final attendance = await _supabase
          .from('attendance')
          .select('student_id')
          .eq('id', attendanceId)
          .maybeSingle();

      if (attendance == null) {
        throw ParentException('Attendance record not found with id $attendanceId');
      }

      final studentId = attendance['student_id'] as String;
      await _verifyParentChild(studentId);

      // Update the attendance record with excuse
      await _supabase.from('attendance').update({
        'excuse_note': excuseNote,
        'excuse_status': 'pending',
        'excuse_attachment_url': attachmentUrl,
      }).eq('id', attendanceId);
    } on PostgrestException catch (e) {
      throw ParentException('Failed to submit excuse: ${e.message}');
    }
  }

  @override
  Future<List<AttendanceEntity>> getPendingExcuses(String childId) async {
    await _verifyParentChild(childId);

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
          .eq('student_id', childId)
          .eq('excuse_status', 'pending')
          .order('date', ascending: false);

      return response.map((data) => _mapToAttendance(data)).toList();
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch pending excuses: ${e.message}');
    }
  }

  @override
  Future<List<AttendanceEntity>> getAllExcuses(String childId) async {
    await _verifyParentChild(childId);

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
          .eq('student_id', childId)
          .not('excuse_note', 'is', null)
          .order('date', ascending: false);

      return response.map((data) => _mapToAttendance(data)).toList();
    } on PostgrestException catch (e) {
      throw ParentException('Failed to fetch excuses: ${e.message}');
    }
  }

  /// Verifies that the given child ID belongs to the current parent.
  Future<void> _verifyParentChild(String childId) async {
    final children = await getMyChildren();
    final isChild = children.any((child) => child.id == childId);
    if (!isChild) {
      throw const ParentException('Child not found or access denied');
    }
  }

  @override
  Future<void> refresh() async {
    _cachedChildren = null;
    _childClassIds.clear();
  }
}
