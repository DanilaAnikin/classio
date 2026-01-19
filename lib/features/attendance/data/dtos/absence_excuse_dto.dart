import '../../../../core/utils/dto_base.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/absence_excuse.dart';

/// Data Transfer Object for AbsenceExcuse entities.
///
/// Handles safe parsing of absence excuse data from Supabase responses,
/// including nested profile data for students, parents, and teachers,
/// as well as attendance and lesson information.
///
/// Required fields:
/// - id: Unique identifier
/// - attendanceId: The attendance record being excused
/// - studentId: Student for whom the excuse is submitted
/// - parentId: Parent who submitted the excuse
/// - reason: The excuse reason text
/// - status: pending, approved, declined
/// - createdAt: When the excuse was created
/// - updatedAt: When the excuse was last updated
///
/// Optional fields (from joins):
/// - studentName, parentName, teacherName: Display names
/// - subjectName: The subject for the lesson
/// - attendanceDate: Date of the attendance record
/// - lessonStartTime, lessonEndTime: Lesson timing
class AbsenceExcuseDTO extends BaseDTO<AbsenceExcuse> {
  /// Creates an [AbsenceExcuseDTO] instance.
  AbsenceExcuseDTO({
    required this.id,
    required this.attendanceId,
    required this.studentId,
    required this.parentId,
    required this.reason,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.teacherResponse,
    this.teacherId,
    this.studentName,
    this.parentName,
    this.teacherName,
    this.subjectName,
    this.attendanceDate,
    this.lessonStartTime,
    this.lessonEndTime,
  });

  /// Unique identifier for the excuse.
  final String? id;

  /// ID of the attendance record being excused.
  final String? attendanceId;

  /// ID of the student for whom the excuse is submitted.
  final String? studentId;

  /// ID of the parent who submitted the excuse.
  final String? parentId;

  /// The excuse reason text.
  final String? reason;

  /// Current status of the excuse.
  final AbsenceExcuseStatus? status;

  /// Optional response message from teacher.
  final String? teacherResponse;

  /// ID of the teacher who reviewed the excuse.
  final String? teacherId;

  /// Timestamp when the excuse was created.
  final DateTime? createdAt;

  /// Timestamp when the excuse was last updated.
  final DateTime? updatedAt;

  /// Name of the student (from joined profile).
  final String? studentName;

  /// Name of the parent (from joined profile).
  final String? parentName;

  /// Name of the teacher who reviewed (from joined profile).
  final String? teacherName;

  /// Name of the subject for the lesson.
  final String? subjectName;

  /// Date of the attendance record.
  final DateTime? attendanceDate;

  /// Start time of the lesson.
  final DateTime? lessonStartTime;

  /// End time of the lesson.
  final DateTime? lessonEndTime;

  /// Creates an [AbsenceExcuseDTO] from a Supabase response.
  ///
  /// Handles complex nested data including:
  /// - student, parent, teacher profiles with first_name, last_name
  /// - attendance record with date and lesson information
  /// - lessons with start_time, end_time, and subjects
  factory AbsenceExcuseDTO.fromJson(Map<String, dynamic> json) {
    // Extract student info
    final studentProfile = JsonParser.parseMap(json['student'], fieldName: 'student');
    final studentName = JsonParser.parseProfileName(studentProfile, fieldName: 'student');

    // Extract parent info
    final parentProfile = JsonParser.parseMap(json['parent'], fieldName: 'parent');
    final parentName = JsonParser.parseProfileName(parentProfile, fieldName: 'parent');

    // Extract teacher info
    final teacherProfile = JsonParser.parseMap(json['teacher'], fieldName: 'teacher');
    final teacherName = JsonParser.parseProfileName(teacherProfile, fieldName: 'teacher');

    // Extract attendance and lesson info
    final attendance = JsonParser.parseMap(json['attendance'], fieldName: 'attendance');
    DateTime? attendanceDate;
    String? subjectName;
    DateTime? lessonStartTime;
    DateTime? lessonEndTime;

    if (attendance != null) {
      // Parse attendance date
      attendanceDate = JsonParser.parseDateTime(
        attendance['date'],
        fieldName: 'attendance.date',
      );

      // Parse lesson info
      final lessons = JsonParser.parseMap(attendance['lessons'], fieldName: 'lessons');
      if (lessons != null) {
        // Parse subject name from nested subjects
        final subjects = JsonParser.parseMap(lessons['subjects'], fieldName: 'subjects');
        if (subjects != null) {
          subjectName = JsonParser.parseStringNullable(
            subjects['name'],
            fieldName: 'subjects.name',
          );
        }

        // Parse lesson times (combine with attendance date)
        if (attendanceDate != null) {
          final startTimeStr = JsonParser.parseStringNullable(
            lessons['start_time'],
            fieldName: 'lessons.start_time',
          );
          final endTimeStr = JsonParser.parseStringNullable(
            lessons['end_time'],
            fieldName: 'lessons.end_time',
          );

          lessonStartTime = JsonParser.parseTimeString(
            startTimeStr,
            attendanceDate,
            fieldName: 'lessons.start_time',
          );
          lessonEndTime = JsonParser.parseTimeString(
            endTimeStr,
            attendanceDate,
            fieldName: 'lessons.end_time',
          );
        }
      }
    }

    // Parse status enum
    final statusStr = JsonParser.parseStringNullable(json['status'], fieldName: 'status');
    final status = JsonParser.parseEnum<AbsenceExcuseStatus>(
      statusStr,
      AbsenceExcuseStatus.values,
      fieldName: 'status',
      defaultValue: AbsenceExcuseStatus.pending,
    );

    return AbsenceExcuseDTO(
      id: JsonParser.parseStringNullable(json['id'], fieldName: 'id'),
      attendanceId: JsonParser.parseStringNullable(
        json['attendance_id'],
        fieldName: 'attendance_id',
      ),
      studentId: JsonParser.parseStringNullable(
        json['student_id'],
        fieldName: 'student_id',
      ),
      parentId: JsonParser.parseStringNullable(
        json['parent_id'],
        fieldName: 'parent_id',
      ),
      reason: JsonParser.parseStringNullable(json['reason'], fieldName: 'reason'),
      status: status,
      teacherResponse: JsonParser.parseStringNullable(
        json['teacher_response'],
        fieldName: 'teacher_response',
      ),
      teacherId: JsonParser.parseStringNullable(
        json['teacher_id'],
        fieldName: 'teacher_id',
      ),
      createdAt: JsonParser.parseDateTime(
        json['created_at'],
        fieldName: 'created_at',
      ),
      updatedAt: JsonParser.parseDateTime(
        json['updated_at'],
        fieldName: 'updated_at',
      ),
      studentName: studentName,
      parentName: parentName,
      teacherName: teacherName,
      subjectName: subjectName,
      attendanceDate: attendanceDate,
      lessonStartTime: lessonStartTime,
      lessonEndTime: lessonEndTime,
    );
  }

  @override
  bool get isValid {
    // Required fields
    if (id == null || id!.isEmpty) return false;
    if (attendanceId == null || attendanceId!.isEmpty) return false;
    if (studentId == null || studentId!.isEmpty) return false;
    if (parentId == null || parentId!.isEmpty) return false;
    if (reason == null || reason!.isEmpty) return false;
    if (status == null) return false;
    if (createdAt == null) return false;
    if (updatedAt == null) return false;

    return true;
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (id == null || id!.isEmpty) {
      errors.add('id is required');
    }

    if (attendanceId == null || attendanceId!.isEmpty) {
      errors.add('attendance_id is required');
    }

    if (studentId == null || studentId!.isEmpty) {
      errors.add('student_id is required');
    }

    if (parentId == null || parentId!.isEmpty) {
      errors.add('parent_id is required');
    }

    if (reason == null || reason!.isEmpty) {
      errors.add('reason is required');
    }

    if (status == null) {
      errors.add('status is required');
    }

    if (createdAt == null) {
      errors.add('created_at is required');
    }

    if (updatedAt == null) {
      errors.add('updated_at is required');
    }

    return errors;
  }

  @override
  AbsenceExcuse toEntity() {
    if (!isValid) {
      throw StateError(
        'Cannot convert invalid AbsenceExcuseDTO to AbsenceExcuse. '
        'Errors: ${validationErrors.join(', ')}',
      );
    }

    return AbsenceExcuse(
      id: id!,
      attendanceId: attendanceId!,
      studentId: studentId!,
      parentId: parentId!,
      reason: reason!,
      status: status!,
      teacherResponse: teacherResponse,
      teacherId: teacherId,
      createdAt: createdAt!,
      updatedAt: updatedAt!,
      studentName: studentName,
      parentName: parentName,
      teacherName: teacherName,
      subjectName: subjectName,
      attendanceDate: attendanceDate,
      lessonStartTime: lessonStartTime,
      lessonEndTime: lessonEndTime,
    );
  }

  /// Converts back to JSON for API calls.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'student_id': studentId,
      'parent_id': parentId,
      'reason': reason,
      'status': status?.name,
      'teacher_response': teacherResponse,
      'teacher_id': teacherId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'AbsenceExcuseDTO(id: $id, studentId: $studentId, status: ${status?.name}, '
      'isValid: $isValid)';
}

/// Extension for parsing lists of absence excuses from API responses.
extension AbsenceExcuseDTOListParser on List<Map<String, dynamic>> {
  /// Parses a list of JSON maps to AbsenceExcuseDTOs.
  List<AbsenceExcuseDTO> toAbsenceExcuseDTOs() {
    return map((json) => AbsenceExcuseDTO.fromJson(json)).toList();
  }

  /// Parses and converts to AbsenceExcuse entities, filtering invalid entries.
  List<AbsenceExcuse> toAbsenceExcuses({bool logErrors = true}) {
    final dtos = toAbsenceExcuseDTOs();
    final excuses = <AbsenceExcuse>[];
    for (final dto in dtos) {
      final entity = dto.toEntityOrNull(
        logErrors: logErrors,
        context: 'AbsenceExcuse',
      );
      if (entity != null) {
        excuses.add(entity);
      }
    }
    return excuses;
  }
}
