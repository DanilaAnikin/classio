import 'subject.dart';

/// Represents a homework assignment or task.
///
/// Contains information about what needs to be done, when it's due,
/// and whether it has been completed.
class Assignment {
  /// Creates an [Assignment] instance.
  const Assignment({
    required this.id,
    required this.subject,
    required this.title,
    required this.dueDate,
    this.description,
    this.isCompleted = false,
  });

  /// Unique identifier for the assignment.
  final String id;

  /// The subject this assignment belongs to.
  final Subject subject;

  /// Title of the assignment.
  final String title;

  /// When the assignment is due.
  final DateTime dueDate;

  /// Optional detailed description of the assignment.
  final String? description;

  /// Whether the assignment has been completed.
  final bool isCompleted;

  /// Returns true if the assignment is overdue.
  bool get isOverdue {
    return !isCompleted && DateTime.now().isAfter(dueDate);
  }

  /// Returns true if the assignment is due today.
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final assignmentDay =
        DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today == assignmentDay;
  }

  /// Returns true if the assignment is due tomorrow.
  bool get isDueTomorrow {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final assignmentDay =
        DateTime(dueDate.year, dueDate.month, dueDate.day);
    return tomorrow == assignmentDay;
  }

  /// Creates a copy of this [Assignment] with the given fields replaced
  /// with new values.
  Assignment copyWith({
    String? id,
    Subject? subject,
    String? title,
    DateTime? dueDate,
    String? description,
    bool? isCompleted,
  }) {
    return Assignment(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Assignment &&
        other.id == id &&
        other.subject == subject &&
        other.title == title &&
        other.dueDate == dueDate &&
        other.description == description &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode => Object.hash(
        id,
        subject,
        title,
        dueDate,
        description,
        isCompleted,
      );

  @override
  String toString() =>
      'Assignment(id: $id, subject: ${subject.name}, title: $title, '
      'dueDate: $dueDate, isCompleted: $isCompleted)';
}
