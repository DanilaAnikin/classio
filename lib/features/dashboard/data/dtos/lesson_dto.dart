import '../../../../core/utils/dto_base.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../../../core/utils/subject_colors.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/subject.dart';

/// Data Transfer Object for Subject entities (nested within Lesson).
///
/// Handles parsing of subject data typically joined from the subjects table.
class SubjectDTO extends BaseDTO<Subject> {
  /// Creates a [SubjectDTO] instance.
  SubjectDTO({
    required this.id,
    required this.name,
    this.color,
    this.teacherName,
  });

  /// Unique identifier for the subject.
  final String? id;

  /// Name of the subject.
  final String? name;

  /// Theme color (ARGB int value). Auto-generated if not provided.
  final int? color;

  /// Name of the teacher (from joined profile data).
  final String? teacherName;

  /// Creates a [SubjectDTO] from nested JSON data in a lesson response.
  ///
  /// Handles the Supabase join format:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "name": "Mathematics",
  ///   "teacher": {
  ///     "first_name": "John",
  ///     "last_name": "Doe"
  ///   }
  /// }
  /// ```
  factory SubjectDTO.fromJson(Map<String, dynamic>? json, {String? fallbackSubjectId}) {
    if (json == null) {
      return SubjectDTO(
        id: fallbackSubjectId,
        name: 'Unknown Subject',
      );
    }

    // Parse teacher name from nested profile
    final teacherData = JsonParser.parseMap(json['teacher'], fieldName: 'teacher');
    final teacherName = JsonParser.parseProfileName(teacherData, fieldName: 'teacher');

    return SubjectDTO(
      id: JsonParser.parseStringNullable(
            json['id'],
            fieldName: 'subject.id',
          ) ??
          fallbackSubjectId,
      name: JsonParser.parseString(
        json['name'],
        fieldName: 'subject.name',
        defaultValue: 'Unknown Subject',
      ),
      color: JsonParser.parseIntNullable(json['color'], fieldName: 'subject.color'),
      teacherName: teacherName,
    );
  }

  @override
  bool get isValid => id != null && id!.isNotEmpty && name != null && name!.isNotEmpty;

  @override
  List<String> get validationErrors {
    final errors = <String>[];
    if (id == null || id!.isEmpty) {
      errors.add('subject.id is required');
    }
    if (name == null || name!.isEmpty) {
      errors.add('subject.name is required');
    }
    return errors;
  }

  @override
  Subject toEntity() {
    if (!isValid) {
      throw StateError(
        'Cannot convert invalid SubjectDTO to Subject. Errors: ${validationErrors.join(', ')}',
      );
    }

    return Subject(
      id: id!,
      name: name!,
      color: color ?? SubjectColors.getColorForId(id!),
      teacherName: teacherName,
    );
  }
}

/// Data Transfer Object for Lesson entities.
///
/// Handles safe parsing of lesson data from Supabase responses including
/// nested subject data and time parsing.
///
/// Required fields:
/// - id: Unique identifier
/// - subject: Nested subject data (or subject_id)
/// - startTime: When the lesson starts (parsed from time string + date)
/// - endTime: When the lesson ends
///
/// Optional fields:
/// - room: Classroom location
/// - status: normal, cancelled, substitution
/// - substituteTeacher: For substitution lessons
/// - note: Additional notes
/// - Stable timetable fields (isStable, stableLessonId, modifiedFromStable, weekStartDate)
class LessonDTO extends BaseDTO<Lesson> {
  /// Creates a [LessonDTO] instance.
  LessonDTO({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    this.room,
    this.status,
    this.substituteTeacher,
    this.note,
    this.isStable = false,
    this.stableLessonId,
    this.modifiedFromStable = false,
    this.weekStartDate,
    this.stableLesson,
  });

  /// Unique identifier for the lesson.
  final String? id;

  /// The subject being taught (parsed from nested data).
  final SubjectDTO subject;

  /// When the lesson starts.
  final DateTime? startTime;

  /// When the lesson ends.
  final DateTime? endTime;

  /// Room/location where the lesson takes place.
  final String? room;

  /// Status of the lesson (normal, cancelled, substitution).
  final LessonStatus? status;

  /// Name of substitute teacher if status is substitution.
  final String? substituteTeacher;

  /// Optional note about the lesson.
  final String? note;

  /// Whether this is a stable/baseline lesson.
  final bool isStable;

  /// Reference to the original stable lesson.
  final String? stableLessonId;

  /// Whether this week-specific lesson differs from its stable version.
  final bool modifiedFromStable;

  /// The Monday of the week this lesson belongs to.
  final DateTime? weekStartDate;

  /// The original stable lesson for comparison.
  final Lesson? stableLesson;

  /// Creates a [LessonDTO] from a Supabase response.
  ///
  /// [json] - The lesson data from the database.
  /// [date] - The date for this lesson occurrence (used to construct DateTime from time strings).
  /// [stableLesson] - Optional reference to the stable lesson for comparison.
  ///
  /// Handles:
  /// - Time strings (HH:MM or HH:MM:SS) combined with the date
  /// - Nested subject data with teacher profile
  /// - Stable timetable fields
  factory LessonDTO.fromJson(
    Map<String, dynamic> json, {
    required DateTime date,
    Lesson? stableLesson,
  }) {
    // Parse nested subject data
    final subjectData = JsonParser.parseMap(json['subjects'], fieldName: 'subjects');
    final fallbackSubjectId = JsonParser.parseStringNullable(
      json['subject_id'],
      fieldName: 'subject_id',
    );
    final subject = SubjectDTO.fromJson(subjectData, fallbackSubjectId: fallbackSubjectId);

    // Parse time strings with the provided date
    final startTimeStr = JsonParser.parseStringNullable(
      json['start_time'],
      fieldName: 'start_time',
    );
    final endTimeStr = JsonParser.parseStringNullable(
      json['end_time'],
      fieldName: 'end_time',
    );

    final startTime = JsonParser.parseTimeString(startTimeStr, date, fieldName: 'start_time');
    final endTime = JsonParser.parseTimeString(endTimeStr, date, fieldName: 'end_time');

    // Parse status enum
    final statusStr = JsonParser.parseStringNullable(json['status'], fieldName: 'status');
    final status = JsonParser.parseEnum<LessonStatus>(
      statusStr,
      LessonStatus.values,
      fieldName: 'status',
      defaultValue: LessonStatus.normal,
    );

    // Parse week_start_date
    final weekStartDate = JsonParser.parseDateTime(
      json['week_start_date'],
      fieldName: 'week_start_date',
    );

    return LessonDTO(
      id: JsonParser.parseStringNullable(json['id'], fieldName: 'id'),
      subject: subject,
      startTime: startTime,
      endTime: endTime,
      room: JsonParser.parseStringNullable(json['room'], fieldName: 'room'),
      status: status,
      substituteTeacher: JsonParser.parseStringNullable(
        json['substitute_teacher'],
        fieldName: 'substitute_teacher',
      ),
      note: JsonParser.parseStringNullable(json['note'], fieldName: 'note'),
      isStable: JsonParser.parseBool(json['is_stable'], fieldName: 'is_stable'),
      stableLessonId: JsonParser.parseStringNullable(
        json['stable_lesson_id'],
        fieldName: 'stable_lesson_id',
      ),
      modifiedFromStable: JsonParser.parseBool(
        json['modified_from_stable'],
        fieldName: 'modified_from_stable',
      ),
      weekStartDate: weekStartDate,
      stableLesson: stableLesson,
    );
  }

  @override
  bool get isValid {
    // Required fields
    if (id == null || id!.isEmpty) return false;
    if (!subject.isValid) return false;
    if (startTime == null) return false;
    if (endTime == null) return false;

    // Validate time order
    if (startTime!.isAfter(endTime!)) return false;

    return true;
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (id == null || id!.isEmpty) {
      errors.add('id is required');
    }

    if (!subject.isValid) {
      errors.addAll(subject.validationErrors);
    }

    if (startTime == null) {
      errors.add('start_time is required (could not parse time string)');
    }

    if (endTime == null) {
      errors.add('end_time is required (could not parse time string)');
    }

    if (startTime != null && endTime != null && startTime!.isAfter(endTime!)) {
      errors.add('start_time must be before end_time');
    }

    return errors;
  }

  @override
  Lesson toEntity() {
    if (!isValid) {
      throw StateError(
        'Cannot convert invalid LessonDTO to Lesson. Errors: ${validationErrors.join(', ')}',
      );
    }

    return Lesson(
      id: id!,
      subject: subject.toEntity(),
      startTime: startTime!,
      endTime: endTime!,
      room: room ?? '',
      status: status ?? LessonStatus.normal,
      substituteTeacher: substituteTeacher,
      note: note,
      isStable: isStable,
      stableLessonId: stableLessonId,
      modifiedFromStable: modifiedFromStable,
      weekStartDate: weekStartDate,
      stableLesson: stableLesson,
    );
  }

  /// Creates a Lesson entity with fallback times if parsing failed.
  ///
  /// This is useful when you want to display something even if time
  /// parsing failed, using default times instead.
  Lesson toEntityWithFallback({
    DateTime? fallbackStartTime,
    DateTime? fallbackEndTime,
  }) {
    if (id == null || id!.isEmpty) {
      throw StateError('Cannot create Lesson: id is required');
    }

    if (!subject.isValid) {
      throw StateError('Cannot create Lesson: subject is invalid');
    }

    final actualStartTime = startTime ?? fallbackStartTime ?? DateTime.now();
    final actualEndTime =
        endTime ?? fallbackEndTime ?? actualStartTime.add(const Duration(minutes: 45));

    return Lesson(
      id: id!,
      subject: subject.toEntity(),
      startTime: actualStartTime,
      endTime: actualEndTime,
      room: room ?? '',
      status: status ?? LessonStatus.normal,
      substituteTeacher: substituteTeacher,
      note: note,
      isStable: isStable,
      stableLessonId: stableLessonId,
      modifiedFromStable: modifiedFromStable,
      weekStartDate: weekStartDate,
      stableLesson: stableLesson,
    );
  }

  @override
  String toString() =>
      'LessonDTO(id: $id, subject: ${subject.name}, '
      'startTime: $startTime, endTime: $endTime, room: $room, isValid: $isValid)';
}

/// Extension for parsing lists of lessons from API responses.
extension LessonDTOListParser on List<Map<String, dynamic>> {
  /// Parses a list of JSON maps to LessonDTOs.
  ///
  /// [date] is required to construct DateTime from time strings.
  List<LessonDTO> toLessonDTOs({required DateTime date}) {
    return map((json) => LessonDTO.fromJson(json, date: date)).toList();
  }

  /// Parses and converts to Lesson entities, filtering invalid entries.
  List<Lesson> toLessons({required DateTime date, bool logErrors = true}) {
    final dtos = toLessonDTOs(date: date);
    final lessons = <Lesson>[];
    for (final dto in dtos) {
      final entity = dto.toEntityOrNull(logErrors: logErrors, context: 'Lesson');
      if (entity != null) {
        lessons.add(entity);
      }
    }
    return lessons;
  }
}
