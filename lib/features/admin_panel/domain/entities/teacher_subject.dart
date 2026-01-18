/// Represents a subject taught by a teacher in the admin panel.
///
/// Contains information about the subject including:
/// - Basic subject information (id, name, description, color)
/// - Number of classes this subject is assigned to
class TeacherSubject {
  /// Creates a [TeacherSubject] instance.
  const TeacherSubject({
    required this.id,
    required this.name,
    required this.color,
    this.description,
    this.classCount = 0,
  });

  /// Unique identifier for the subject.
  final String id;

  /// Name of the subject (e.g., "Mathematics", "Physics").
  final String name;

  /// Optional description of the subject.
  final String? description;

  /// Theme color for the subject for visual identification (ARGB int value).
  /// Convert to Flutter Color in UI layer using: Color(color)
  final int color;

  /// Number of classes this subject is taught to.
  final int classCount;

  /// Creates a copy of this [TeacherSubject] with the given fields replaced
  /// with new values.
  TeacherSubject copyWith({
    String? id,
    String? name,
    String? description,
    int? color,
    int? classCount,
  }) {
    return TeacherSubject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      classCount: classCount ?? this.classCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TeacherSubject &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.color == color &&
        other.classCount == classCount;
  }

  @override
  int get hashCode => Object.hash(id, name, description, color, classCount);

  @override
  String toString() =>
      'TeacherSubject(id: $id, name: $name, description: $description, '
      'color: $color, classCount: $classCount)';
}
