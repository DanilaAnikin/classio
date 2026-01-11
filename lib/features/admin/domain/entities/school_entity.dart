/// Represents a school in the Classio system.
///
/// Contains information about the school such as its name and creation date.
class SchoolEntity {
  /// Creates a [SchoolEntity] instance.
  const SchoolEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// Unique identifier for the school.
  final String id;

  /// Name of the school.
  final String name;

  /// Timestamp when the school was created.
  final DateTime createdAt;

  /// Creates a [SchoolEntity] from a JSON map.
  factory SchoolEntity.fromJson(Map<String, dynamic> json) {
    return SchoolEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [SchoolEntity] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [SchoolEntity] with the given fields replaced
  /// with new values.
  SchoolEntity copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return SchoolEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SchoolEntity &&
        other.id == id &&
        other.name == name &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);

  @override
  String toString() => 'SchoolEntity(id: $id, name: $name, createdAt: $createdAt)';
}
