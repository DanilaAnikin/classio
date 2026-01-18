import '../../../admin_panel/domain/entities/class_info.dart';
import '../../../auth/domain/entities/app_user.dart';

/// ClassInfo with additional details for the principal panel.
///
/// Extends [ClassInfo] functionality with head teacher info and student count.
class ClassWithDetails {
  /// Creates a [ClassWithDetails] instance.
  const ClassWithDetails({
    required this.classInfo,
    this.headTeacher,
    this.studentCount = 0,
  });

  /// The underlying class information.
  final ClassInfo classInfo;

  /// The head teacher assigned to this class.
  final AppUser? headTeacher;

  /// Number of students in this class.
  final int studentCount;

  /// Convenience getter for the class ID.
  String get id => classInfo.id;

  /// Convenience getter for the school ID.
  String get schoolId => classInfo.schoolId;

  /// Convenience getter for the class name.
  String get name => classInfo.name;

  /// Convenience getter for the grade level.
  int? get gradeLevel => classInfo.gradeLevel;

  /// Convenience getter for the academic year.
  String? get academicYear => classInfo.academicYear;

  /// Convenience getter for the created at timestamp.
  DateTime? get createdAt => classInfo.createdAt;

  /// Creates a copy of this [ClassWithDetails] with the given fields replaced.
  ClassWithDetails copyWith({
    ClassInfo? classInfo,
    AppUser? headTeacher,
    int? studentCount,
  }) {
    return ClassWithDetails(
      classInfo: classInfo ?? this.classInfo,
      headTeacher: headTeacher ?? this.headTeacher,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassWithDetails &&
        other.classInfo == classInfo &&
        other.headTeacher == headTeacher &&
        other.studentCount == studentCount;
  }

  @override
  int get hashCode => Object.hash(classInfo, headTeacher, studentCount);

  @override
  String toString() => 'ClassWithDetails('
      'classInfo: $classInfo, '
      'headTeacher: ${headTeacher?.fullName}, '
      'studentCount: $studentCount)';
}
