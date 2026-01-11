import 'package:flutter/material.dart';

import 'package:classio/features/dashboard/domain/entities/assignment.dart';
import 'course_material.dart';
import 'course_post.dart';

/// Represents detailed information about a subject.
///
/// Aggregates all data related to a subject including posts,
/// materials, and assignments.
class SubjectDetail {
  /// Creates a [SubjectDetail] instance.
  const SubjectDetail({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.teacherName,
    required this.posts,
    required this.materials,
    required this.assignments,
  });

  /// Unique identifier for the subject.
  final String subjectId;

  /// Name of the subject.
  final String subjectName;

  /// Theme color for the subject for visual identification.
  final Color subjectColor;

  /// Name of the teacher teaching this subject.
  final String teacherName;

  /// List of posts in this subject.
  final List<CoursePost> posts;

  /// List of course materials for this subject.
  final List<CourseMaterial> materials;

  /// List of assignments for this subject.
  final List<Assignment> assignments;

  /// Creates a copy of this [SubjectDetail] with the given fields replaced
  /// with new values.
  SubjectDetail copyWith({
    String? subjectId,
    String? subjectName,
    Color? subjectColor,
    String? teacherName,
    List<CoursePost>? posts,
    List<CourseMaterial>? materials,
    List<Assignment>? assignments,
  }) {
    return SubjectDetail(
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      subjectColor: subjectColor ?? this.subjectColor,
      teacherName: teacherName ?? this.teacherName,
      posts: posts ?? this.posts,
      materials: materials ?? this.materials,
      assignments: assignments ?? this.assignments,
    );
  }

  /// Creates a [SubjectDetail] from a JSON map.
  ///
  /// Note: This implementation assumes the Assignment entity will have
  /// fromJson support. Until then, assignments must be provided separately.
  factory SubjectDetail.fromJson(Map<String, dynamic> json) {
    return SubjectDetail(
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      subjectColor: Color(json['subjectColor'] as int),
      teacherName: json['teacherName'] as String,
      posts: (json['posts'] as List<dynamic>)
          .map((e) => CoursePost.fromJson(e as Map<String, dynamic>))
          .toList(),
      materials: (json['materials'] as List<dynamic>)
          .map((e) => CourseMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Assignments list is initialized as empty since Assignment
      // doesn't have fromJson yet. This should be updated in the data layer.
      assignments: const [],
    );
  }

  /// Converts this [SubjectDetail] to a JSON map.
  ///
  /// Note: This implementation excludes assignments as the Assignment entity
  /// doesn't have toJson support yet. This should be handled in the data layer.
  Map<String, dynamic> toJson() {
    return {
      'subjectId': subjectId,
      'subjectName': subjectName,
      'subjectColor': subjectColor.toARGB32(),
      'teacherName': teacherName,
      'posts': posts.map((e) => e.toJson()).toList(),
      'materials': materials.map((e) => e.toJson()).toList(),
      // Assignments are not serialized since Assignment doesn't have toJson yet
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SubjectDetail &&
        other.subjectId == subjectId &&
        other.subjectName == subjectName &&
        other.subjectColor == subjectColor &&
        other.teacherName == teacherName &&
        _listEquals(other.posts, posts) &&
        _listEquals(other.materials, materials) &&
        _listEquals(other.assignments, assignments);
  }

  @override
  int get hashCode => Object.hash(
        subjectId,
        subjectName,
        subjectColor,
        teacherName,
        Object.hashAll(posts),
        Object.hashAll(materials),
        Object.hashAll(assignments),
      );

  @override
  String toString() =>
      'SubjectDetail(subjectId: $subjectId, subjectName: $subjectName, '
      'teacherName: $teacherName, posts: ${posts.length}, '
      'materials: ${materials.length}, assignments: ${assignments.length})';

  /// Helper method to compare lists for equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
