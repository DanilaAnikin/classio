/// Represents a course post type (announcement or assignment).
enum CoursePostType {
  /// Announcement post
  announcement,

  /// Assignment post
  assignment,
}

/// Extension to provide string representation of [CoursePostType].
extension CoursePostTypeExtension on CoursePostType {
  /// Returns a human-readable string representation.
  String get displayName {
    switch (this) {
      case CoursePostType.announcement:
        return 'Announcement';
      case CoursePostType.assignment:
        return 'Assignment';
    }
  }

  /// Converts the enum to a string for JSON serialization.
  String toJson() => name;
}

/// Represents a post in a course.
///
/// Contains information about announcements or assignments posted
/// by teachers in a course.
class CoursePost {
  /// Creates a [CoursePost] instance.
  const CoursePost({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.content,
    required this.date,
    required this.type,
  });

  /// Unique identifier for the course post.
  final String id;

  /// Name of the author who created the post.
  final String authorName;

  /// URL to the author's avatar image.
  final String? authorAvatarUrl;

  /// Content of the post.
  final String content;

  /// Date when the post was created.
  final DateTime date;

  /// Type of the post (announcement or assignment).
  final CoursePostType type;

  /// Creates a copy of this [CoursePost] with the given fields replaced
  /// with new values.
  CoursePost copyWith({
    String? id,
    String? authorName,
    String? authorAvatarUrl,
    String? content,
    DateTime? date,
    CoursePostType? type,
  }) {
    return CoursePost(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      date: date ?? this.date,
      type: type ?? this.type,
    );
  }

  /// Creates a [CoursePost] from a JSON map.
  factory CoursePost.fromJson(Map<String, dynamic> json) {
    return CoursePost(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      type: CoursePostType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
    );
  }

  /// Converts this [CoursePost] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'date': date.toIso8601String(),
      'type': type.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CoursePost &&
        other.id == id &&
        other.authorName == authorName &&
        other.authorAvatarUrl == authorAvatarUrl &&
        other.content == content &&
        other.date == date &&
        other.type == type;
  }

  @override
  int get hashCode => Object.hash(
        id,
        authorName,
        authorAvatarUrl,
        content,
        date,
        type,
      );

  @override
  String toString() =>
      'CoursePost(id: $id, authorName: $authorName, content: $content, '
      'date: $date, type: $type)';
}
