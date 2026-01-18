import '../../../auth/domain/entities/app_user.dart';

/// Represents a child linked to a parent.
///
/// This entity extends the basic user information with parent-specific
/// details like class name and student-specific data.
class ChildInfo {
  /// Creates a [ChildInfo] instance.
  const ChildInfo({
    required this.user,
    this.className,
    this.classId,
  });

  /// The child's user information.
  final AppUser user;

  /// The name of the class the child is enrolled in.
  final String? className;

  /// The ID of the class the child is enrolled in.
  final String? classId;

  /// Gets the child's ID.
  String get id => user.id;

  /// Gets the child's full name.
  String get fullName => user.fullName;

  /// Gets the child's avatar URL.
  String? get avatarUrl => user.avatarUrl;

  /// Creates a copy of this [ChildInfo] with the given fields replaced.
  ChildInfo copyWith({
    AppUser? user,
    String? className,
    String? classId,
  }) {
    return ChildInfo(
      user: user ?? this.user,
      className: className ?? this.className,
      classId: classId ?? this.classId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChildInfo &&
        other.user == user &&
        other.className == className &&
        other.classId == classId;
  }

  @override
  int get hashCode => Object.hash(user, className, classId);

  @override
  String toString() =>
      'ChildInfo(user: ${user.fullName}, className: $className)';
}
