/// Represents a subject/course in the school.
///
/// Contains information about the subject such as its name and theme color.
class Subject {
  /// Creates a [Subject] instance.
  const Subject({
    required this.id,
    required this.name,
    required this.color,
    this.teacherName,
  });

  /// Unique identifier for the subject.
  final String id;

  /// Name of the subject (e.g., "Mathematics", "Physics").
  final String name;

  /// Theme color for the subject for visual identification (ARGB int value).
  /// Convert to Flutter Color in UI layer using: Color(color)
  final int color;

  /// Name of the teacher teaching this subject.
  final String? teacherName;

  /// Creates a copy of this [Subject] with the given fields replaced
  /// with new values.
  Subject copyWith({
    String? id,
    String? name,
    int? color,
    String? teacherName,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      teacherName: teacherName ?? this.teacherName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subject &&
        other.id == id &&
        other.name == name &&
        other.color == color &&
        other.teacherName == teacherName;
  }

  @override
  int get hashCode => Object.hash(id, name, color, teacherName);

  @override
  String toString() =>
      'Subject(id: $id, name: $name, color: $color, teacherName: $teacherName)';
}
