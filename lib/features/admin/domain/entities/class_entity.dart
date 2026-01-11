/// Represents a class/classroom in the Classio system.
///
/// Contains information about the class such as its name, grade level,
/// and academic year.
class ClassEntity {
  /// Creates a [ClassEntity] instance.
  const ClassEntity({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.gradeLevel,
    required this.academicYear,
    required this.createdAt,
  });

  /// Unique identifier for the class.
  final String id;

  /// The school this class belongs to.
  final String schoolId;

  /// Name of the class (e.g., "Class 1A", "Grade 5B").
  final String name;

  /// The grade level of the class (e.g., 1, 2, 3).
  final int gradeLevel;

  /// The academic year (e.g., "2024-2025").
  final String academicYear;

  /// Timestamp when the class was created.
  final DateTime createdAt;

  /// Creates a [ClassEntity] from a JSON map.
  factory ClassEntity.fromJson(Map<String, dynamic> json) {
    return ClassEntity(
      id: json['id'] as String,
      schoolId: json['school_id'] as String,
      name: json['name'] as String,
      gradeLevel: json['grade_level'] as int,
      academicYear: json['academic_year'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [ClassEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'grade_level': gradeLevel,
      'academic_year': academicYear,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [ClassEntity] with the given fields replaced
  /// with new values.
  ClassEntity copyWith({
    String? id,
    String? schoolId,
    String? name,
    int? gradeLevel,
    String? academicYear,
    DateTime? createdAt,
  }) {
    return ClassEntity(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      academicYear: academicYear ?? this.academicYear,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassEntity &&
        other.id == id &&
        other.schoolId == schoolId &&
        other.name == name &&
        other.gradeLevel == gradeLevel &&
        other.academicYear == academicYear &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        schoolId,
        name,
        gradeLevel,
        academicYear,
        createdAt,
      );

  @override
  String toString() =>
      'ClassEntity(id: $id, schoolId: $schoolId, name: $name, '
      'gradeLevel: $gradeLevel, academicYear: $academicYear, createdAt: $createdAt)';
}
