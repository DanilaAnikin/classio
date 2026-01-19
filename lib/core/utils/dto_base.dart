import 'package:flutter/foundation.dart';

/// Base class for Data Transfer Objects (DTOs).
///
/// DTOs serve as an intermediary layer between raw API/database responses
/// and domain entities. They handle:
/// - Safe parsing of potentially malformed data
/// - Validation of required fields
/// - Logging of parsing issues
/// - Conversion to domain entities
///
/// Example implementation:
/// ```dart
/// class GradeDTO extends BaseDTO<Grade> {
///   GradeDTO({
///     required this.id,
///     required this.subjectId,
///     this.score,
///     this.weight,
///     this.description,
///     this.date,
///   });
///
///   final String? id;
///   final String? subjectId;
///   final double? score;
///   final double? weight;
///   final String? description;
///   final DateTime? date;
///
///   factory GradeDTO.fromJson(Map<String, dynamic> json) {
///     return GradeDTO(
///       id: JsonParser.parseStringNullable(json['id'], fieldName: 'id'),
///       // ... other fields
///     );
///   }
///
///   @override
///   bool get isValid => id != null && subjectId != null && score != null;
///
///   @override
///   List<String> get validationErrors {
///     final errors = <String>[];
///     if (id == null) errors.add('id is required');
///     // ... other validations
///     return errors;
///   }
///
///   @override
///   Grade toEntity() {
///     if (!isValid) {
///       throw StateError('Cannot convert invalid DTO to entity');
///     }
///     return Grade(
///       id: id!,
///       subjectId: subjectId!,
///       score: score!,
///       // ...
///     );
///   }
/// }
/// ```
abstract class BaseDTO<T> {
  /// Whether all required fields are present and valid.
  ///
  /// Returns true if the DTO can be safely converted to an entity.
  bool get isValid;

  /// List of validation error messages.
  ///
  /// Returns an empty list if the DTO is valid.
  /// Each error should clearly identify the field and the issue.
  List<String> get validationErrors;

  /// Converts this DTO to a domain entity.
  ///
  /// Throws [StateError] if [isValid] is false.
  /// Implementations should check [isValid] before converting.
  T toEntity();

  /// Logs validation errors to debug console.
  ///
  /// Useful for debugging parsing issues during development.
  void logValidationErrors({String? context}) {
    if (validationErrors.isNotEmpty) {
      final prefix = context != null ? '[$context] ' : '';
      debugPrint('${prefix}DTO Validation Errors:');
      for (final error in validationErrors) {
        debugPrint('  - $error');
      }
    }
  }

  /// Attempts to convert to entity, returning null if invalid.
  ///
  /// Logs validation errors if [logErrors] is true (default).
  /// This is a safe alternative to [toEntity] that won't throw.
  T? toEntityOrNull({bool logErrors = true, String? context}) {
    if (!isValid) {
      if (logErrors) {
        logValidationErrors(context: context);
      }
      return null;
    }
    return toEntity();
  }
}

/// Exception thrown when DTO validation fails.
///
/// Contains the list of validation errors for debugging.
class DTOValidationException implements Exception {
  /// Creates a [DTOValidationException] with the given errors.
  const DTOValidationException(this.errors, {this.dtoType});

  /// List of validation error messages.
  final List<String> errors;

  /// The type of DTO that failed validation.
  final String? dtoType;

  @override
  String toString() {
    final type = dtoType != null ? ' for $dtoType' : '';
    return 'DTOValidationException$type: ${errors.join(', ')}';
  }
}

/// Mixin for DTOs that can be converted back to JSON.
///
/// Useful for caching or sending data back to the API.
mixin DTOJsonSerializable {
  /// Converts this DTO to a JSON map.
  Map<String, dynamic> toJson();
}

/// Extension methods for working with lists of DTOs.
extension DTOListExtension<T, D extends BaseDTO<T>> on List<D> {
  /// Converts all valid DTOs to entities, skipping invalid ones.
  ///
  /// Logs errors for invalid DTOs if [logErrors] is true.
  List<T> toEntities({bool logErrors = true, String? context}) {
    final entities = <T>[];
    for (var i = 0; i < length; i++) {
      final dto = this[i];
      if (dto.isValid) {
        entities.add(dto.toEntity());
      } else if (logErrors) {
        dto.logValidationErrors(context: '$context[item $i]');
      }
    }
    return entities;
  }

  /// Returns only the valid DTOs from this list.
  List<D> get validOnly => where((dto) => dto.isValid).toList();

  /// Returns only the invalid DTOs from this list.
  List<D> get invalidOnly => where((dto) => !dto.isValid).toList();

  /// Returns the count of valid DTOs.
  int get validCount => where((dto) => dto.isValid).length;

  /// Returns the count of invalid DTOs.
  int get invalidCount => where((dto) => !dto.isValid).length;
}
