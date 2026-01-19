import '../../../../core/utils/dto_base.dart';
import '../../../../core/utils/json_parsing.dart';
import '../../domain/entities/grade.dart';

/// Data Transfer Object for Grade entities.
///
/// Handles safe parsing of grade data from Supabase responses and validates
/// all required fields before conversion to domain entities.
///
/// Required fields:
/// - id: Unique identifier
/// - subjectId: Associated subject ID
/// - score: The grade value (1-6 scale typically)
/// - date: When the grade was given (created_at from database)
///
/// Optional fields with defaults:
/// - weight: Grade weight for average calculation (default: 1.0)
/// - description: Grade type or comment (default: 'Grade')
class GradeDTO extends BaseDTO<Grade> {
  /// Creates a [GradeDTO] instance.
  GradeDTO({
    required this.id,
    required this.subjectId,
    required this.score,
    required this.weight,
    required this.description,
    required this.date,
  });

  /// Unique identifier for the grade.
  final String? id;

  /// ID of the subject this grade belongs to.
  final String? subjectId;

  /// The grade value (e.g., 1.0, 2.5, etc.).
  ///
  /// In European grading systems, lower is typically better.
  /// Validated to be within reasonable range (0-100).
  final double? score;

  /// Weight of the grade for average calculation.
  ///
  /// Typically between 0.5 and 1.0.
  /// Validated to be positive.
  final double? weight;

  /// Description of what this grade is for.
  ///
  /// Examples: "Linear Algebra Test", "Homework Assignment 3"
  final String? description;

  /// Date when the grade was given.
  final DateTime? date;

  /// Creates a [GradeDTO] from a JSON map.
  ///
  /// Handles the following field mappings:
  /// - 'id' -> id
  /// - 'subject_id' -> subjectId
  /// - 'score' -> score (as double)
  /// - 'weight' -> weight (defaults to 1.0)
  /// - 'grade_type' or 'comment' or 'description' -> description
  /// - 'created_at' or 'date' -> date
  factory GradeDTO.fromJson(Map<String, dynamic> json) {
    // Parse description from multiple possible fields
    final description = JsonParser.parseStringNullable(
          json['grade_type'],
          fieldName: 'grade_type',
        ) ??
        JsonParser.parseStringNullable(
          json['comment'],
          fieldName: 'comment',
        ) ??
        JsonParser.parseStringNullable(
          json['description'],
          fieldName: 'description',
        ) ??
        'Grade';

    // Parse date from created_at (Supabase) or date field
    final date = JsonParser.parseDateTime(
          json['created_at'],
          fieldName: 'created_at',
        ) ??
        JsonParser.parseDateTime(
          json['date'],
          fieldName: 'date',
        );

    return GradeDTO(
      id: JsonParser.parseStringNullable(json['id'], fieldName: 'id'),
      subjectId: JsonParser.parseStringNullable(
        json['subject_id'],
        fieldName: 'subject_id',
      ),
      score: JsonParser.parseDoubleNullable(json['score'], fieldName: 'score'),
      weight: JsonParser.parseDouble(
        json['weight'],
        fieldName: 'weight',
        defaultValue: 1.0,
      ),
      description: description,
      date: date,
    );
  }

  @override
  bool get isValid {
    // Required fields
    if (id == null || id!.isEmpty) return false;
    if (subjectId == null || subjectId!.isEmpty) return false;
    if (score == null) return false;
    if (date == null) return false;

    // Validate score is in reasonable range
    if (score! < 0 || score! > 100) return false;

    // Validate weight is positive
    if (weight == null || weight! <= 0) return false;

    return true;
  }

  @override
  List<String> get validationErrors {
    final errors = <String>[];

    if (id == null || id!.isEmpty) {
      errors.add('id is required');
    }

    if (subjectId == null || subjectId!.isEmpty) {
      errors.add('subject_id is required');
    }

    if (score == null) {
      errors.add('score is required');
    } else if (score! < 0 || score! > 100) {
      errors.add('score must be between 0 and 100 (got: $score)');
    }

    if (date == null) {
      errors.add('date (created_at) is required');
    }

    if (weight == null || weight! <= 0) {
      errors.add('weight must be positive (got: $weight)');
    }

    return errors;
  }

  @override
  Grade toEntity() {
    if (!isValid) {
      throw StateError(
        'Cannot convert invalid GradeDTO to Grade. Errors: ${validationErrors.join(', ')}',
      );
    }

    return Grade(
      id: id!,
      subjectId: subjectId!,
      score: score!,
      weight: weight!,
      description: description ?? 'Grade',
      date: date!,
    );
  }

  /// Converts back to JSON for caching or API calls.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'score': score,
      'weight': weight,
      'grade_type': description,
      'created_at': date?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'GradeDTO(id: $id, subjectId: $subjectId, score: $score, '
      'weight: $weight, description: $description, date: $date, isValid: $isValid)';
}

/// Extension for parsing lists of grades from API responses.
extension GradeDTOListParser on List<Map<String, dynamic>> {
  /// Parses a list of JSON maps to GradeDTOs.
  List<GradeDTO> toGradeDTOs() {
    return map((json) => GradeDTO.fromJson(json)).toList();
  }

  /// Parses and converts to Grade entities, filtering invalid entries.
  ///
  /// Logs warnings for any invalid grades that are skipped.
  List<Grade> toGrades({bool logErrors = true}) {
    final dtos = toGradeDTOs();
    final grades = <Grade>[];
    for (final dto in dtos) {
      final entity = dto.toEntityOrNull(logErrors: logErrors, context: 'Grade');
      if (entity != null) {
        grades.add(entity);
      }
    }
    return grades;
  }
}
