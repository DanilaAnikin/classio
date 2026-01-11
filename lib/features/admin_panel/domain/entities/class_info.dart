/// ClassInfo entity.
///
/// Represents a class/classroom in a school. Named ClassInfo to avoid
/// conflict with Dart's built-in Class type.
class ClassInfo {
  /// Creates a [ClassInfo] instance.
  const ClassInfo({
    required this.id,
    required this.schoolId,
    required this.name,
    this.gradeLevel,
    this.academicYear,
    this.createdAt,
  });

  /// Unique identifier for the class.
  final String id;

  /// School ID this class belongs to.
  final String schoolId;

  /// Name of the class (e.g., "Class 1A", "Grade 5B").
  final String name;

  /// Grade level of the class (e.g., 1, 2, 3, etc.).
  final int? gradeLevel;

  /// Academic year for this class (e.g., "2024-2025").
  final String? academicYear;

  /// Timestamp when the class was created.
  final DateTime? createdAt;

  /// Creates a [ClassInfo] from a JSON map.
  ///
  /// Throws an [ArgumentError] if the JSON is invalid or missing required fields.
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final schoolId = json['school_id'] as String?;
    final name = json['name'] as String?;

    if (id == null || schoolId == null || name == null) {
      throw ArgumentError(
          'Invalid JSON: missing required fields (id, school_id, name)');
    }

    // Parse createdAt from string if present
    DateTime? createdAt;
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        createdAt = DateTime.parse(createdAtStr);
      } catch (_) {
        createdAt = null;
      }
    }

    return ClassInfo(
      id: id,
      schoolId: schoolId,
      name: name,
      gradeLevel: json['grade_level'] as int?,
      academicYear: json['academic_year'] as String?,
      createdAt: createdAt,
    );
  }

  /// Converts this [ClassInfo] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'name': name,
      'grade_level': gradeLevel,
      'academic_year': academicYear,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [ClassInfo] with the given fields replaced
  /// with new values.
  ClassInfo copyWith({
    String? id,
    String? schoolId,
    String? name,
    int? gradeLevel,
    String? academicYear,
    DateTime? createdAt,
  }) {
    return ClassInfo(
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

    return other is ClassInfo &&
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
  String toString() => 'ClassInfo(id: $id, schoolId: $schoolId, name: $name, '
      'gradeLevel: $gradeLevel, academicYear: $academicYear)';
}
