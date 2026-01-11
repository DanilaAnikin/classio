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
    );
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
        other.note == note;
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
      );

  @override
  String toString() =>
      'Lesson(id: $id, subject: ${subject.name}, startTime: $startTime, '
      'endTime: $endTime, room: $room, status: $status)';
}
