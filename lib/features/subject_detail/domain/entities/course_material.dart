/// Represents a course material type (PDF, link, or video).
enum CourseMaterialType {
  /// PDF document
  pdf,

  /// External link
  link,

  /// Video content
  video,
}

/// Extension to provide string representation of [CourseMaterialType].
extension CourseMaterialTypeExtension on CourseMaterialType {
  /// Returns a human-readable string representation.
  String get displayName {
    switch (this) {
      case CourseMaterialType.pdf:
        return 'PDF';
      case CourseMaterialType.link:
        return 'Link';
      case CourseMaterialType.video:
        return 'Video';
    }
  }

  /// Converts the enum to a string for JSON serialization.
  String toJson() => name;
}

/// Represents a course material item.
///
/// Contains information about educational materials such as PDFs, links,
/// or videos that are part of a course.
class CourseMaterial {
  /// Creates a [CourseMaterial] instance.
  const CourseMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.dateAdded,
  });

  /// Unique identifier for the course material.
  final String id;

  /// Title of the course material.
  final String title;

  /// Type of the course material (PDF, link, or video).
  final CourseMaterialType type;

  /// URL where the material can be accessed.
  final String url;

  /// Date when the material was added.
  final DateTime dateAdded;

  /// Creates a copy of this [CourseMaterial] with the given fields replaced
  /// with new values.
  CourseMaterial copyWith({
    String? id,
    String? title,
    CourseMaterialType? type,
    String? url,
    DateTime? dateAdded,
  }) {
    return CourseMaterial(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      url: url ?? this.url,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  /// Creates a [CourseMaterial] from a JSON map.
  factory CourseMaterial.fromJson(Map<String, dynamic> json) {
    return CourseMaterial(
      id: json['id'] as String,
      title: json['title'] as String,
      type: CourseMaterialType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      url: json['url'] as String,
      dateAdded: DateTime.parse(json['dateAdded'] as String),
    );
  }

  /// Converts this [CourseMaterial] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toJson(),
      'url': url,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CourseMaterial &&
        other.id == id &&
        other.title == title &&
        other.type == type &&
        other.url == url &&
        other.dateAdded == dateAdded;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        type,
        url,
        dateAdded,
      );

  @override
  String toString() =>
      'CourseMaterial(id: $id, title: $title, type: $type, url: $url, '
      'dateAdded: $dateAdded)';
}
