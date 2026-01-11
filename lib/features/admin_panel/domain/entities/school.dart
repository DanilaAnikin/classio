/// School entity.
///
/// Represents a school in the Classio application with basic
/// information such as name and creation timestamp.
class School {
  /// Creates a [School] instance.
  const School({
    required this.id,
    required this.name,
    this.createdAt,
  });

  /// Unique identifier for the school.
  final String id;

  /// Name of the school.
  final String name;

  /// Timestamp when the school was created.
  final DateTime? createdAt;

  /// Creates a [School] from a JSON map.
  ///
  /// Throws an [ArgumentError] if the JSON is invalid or missing required fields.
  factory School.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String?;
    final name = json['name'] as String?;

    if (id == null || name == null) {
      throw ArgumentError('Invalid JSON: missing required fields (id, name)');
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

    return School(
      id: id,
      name: name,
      createdAt: createdAt,
    );
  }

  /// Converts this [School] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [School] with the given fields replaced
  /// with new values.
  School copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is School &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);

  @override
  String toString() => 'School(id: $id, name: $name, createdAt: $createdAt)';
}
