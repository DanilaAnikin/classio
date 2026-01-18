import 'subject.dart';

/// Represents a lesson status.
enum LessonStatus {
  /// Normal lesson that will take place as scheduled.
  normal,

  /// Lesson has been cancelled.
  cancelled,

  /// Lesson has a substitute teacher.
  substitution,
}

/// Represents a single lesson/class in the timetable.
///
/// Contains information about when the lesson takes place, what subject it is,
/// where it takes place, and any special status (cancelled, substitution).
///
/// Supports stable timetable functionality where lessons can be either:
/// - Stable: baseline lessons that repeat every week
/// - Week-specific: copies of stable lessons for a specific week that can be modified
class Lesson {
  /// Creates a [Lesson] instance.
  const Lesson({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.status = LessonStatus.normal,
    this.substituteTeacher,
    this.note,
    this.isStable = false,
    this.stableLessonId,
    this.modifiedFromStable = false,
    this.weekStartDate,
    this.stableLesson,
  });

  /// Unique identifier for the lesson.
  final String id;

  /// The subject being taught in this lesson.
  final Subject subject;

  /// When the lesson starts.
  final DateTime startTime;

  /// When the lesson ends.
  final DateTime endTime;

  /// Room/location where the lesson takes place (e.g., "A101", "Gym").
  final String room;

  /// Status of the lesson (normal, cancelled, substitution).
  final LessonStatus status;

  /// Name of substitute teacher if status is substitution.
  final String? substituteTeacher;

  /// Optional note about the lesson.
  final String? note;

  /// Whether this is a stable/baseline lesson that repeats weekly.
  final bool isStable;

  /// Reference to the original stable lesson if this is a week-specific copy.
  final String? stableLessonId;

  /// Whether this week-specific lesson differs from its stable version.
  final bool modifiedFromStable;

  /// The Monday of the week this lesson belongs to (null for stable lessons).
  final DateTime? weekStartDate;

  /// The original stable lesson for comparison (populated when needed).
  final Lesson? stableLesson;

  /// Returns true if this lesson is currently in progress.
  bool get isInProgress {
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  /// Returns true if this lesson is in the future.
  bool get isUpcoming {
    return DateTime.now().isBefore(startTime);
  }

  /// Returns true if this lesson has ended.
  bool get hasEnded {
    return DateTime.now().isAfter(endTime);
  }

  /// Creates a copy of this [Lesson] with the given fields replaced
  /// with new values.
  Lesson copyWith({
    String? id,
    Subject? subject,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    LessonStatus? status,
    String? substituteTeacher,
    String? note,
    bool? isStable,
    String? stableLessonId,
    bool? modifiedFromStable,
    DateTime? weekStartDate,
    Lesson? stableLesson,
  }) {
    return Lesson(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      status: status ?? this.status,
      substituteTeacher: substituteTeacher ?? this.substituteTeacher,
      note: note ?? this.note,
      isStable: isStable ?? this.isStable,
      stableLessonId: stableLessonId ?? this.stableLessonId,
      modifiedFromStable: modifiedFromStable ?? this.modifiedFromStable,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      stableLesson: stableLesson ?? this.stableLesson,
    );
  }

  /// Returns the changes from the stable lesson, if any.
  /// Returns a map of field names to (stable value, current value) pairs.
  Map<String, (String, String)> getChangesFromStable() {
    final changes = <String, (String, String)>{};

    if (stableLesson == null || !modifiedFromStable) {
      return changes;
    }

    if (subject.id != stableLesson!.subject.id) {
      changes['subject'] = (stableLesson!.subject.name, subject.name);
    }

    if (room != stableLesson!.room) {
      changes['room'] = (stableLesson!.room, room);
    }

    final stableStartStr = '${stableLesson!.startTime.hour}:${stableLesson!.startTime.minute.toString().padLeft(2, '0')}';
    final currentStartStr = '${startTime.hour}:${startTime.minute.toString().padLeft(2, '0')}';
    if (stableStartStr != currentStartStr) {
      changes['startTime'] = (stableStartStr, currentStartStr);
    }

    final stableEndStr = '${stableLesson!.endTime.hour}:${stableLesson!.endTime.minute.toString().padLeft(2, '0')}';
    final currentEndStr = '${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}';
    if (stableEndStr != currentEndStr) {
      changes['endTime'] = (stableEndStr, currentEndStr);
    }

    if (stableLesson!.subject.teacherName != subject.teacherName) {
      changes['teacher'] = (
        stableLesson!.subject.teacherName ?? 'N/A',
        subject.teacherName ?? 'N/A',
      );
    }

    return changes;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Lesson &&
        other.id == id &&
        other.subject == subject &&
        other.startTime == startTime &&
        other.endTime == endTime &&
        other.room == room &&
        other.status == status &&
        other.substituteTeacher == substituteTeacher &&
        other.note == note &&
        other.isStable == isStable &&
        other.stableLessonId == stableLessonId &&
        other.modifiedFromStable == modifiedFromStable &&
        other.weekStartDate == weekStartDate;
  }

  @override
  int get hashCode => Object.hash(
        id,
        subject,
        startTime,
        endTime,
        room,
        status,
        substituteTeacher,
        note,
        isStable,
        stableLessonId,
        modifiedFromStable,
        weekStartDate,
      );

  @override
  String toString() =>
      'Lesson(id: $id, subject: ${subject.name}, startTime: $startTime, '
      'endTime: $endTime, room: $room, status: $status, isStable: $isStable, '
      'modifiedFromStable: $modifiedFromStable)';
}
