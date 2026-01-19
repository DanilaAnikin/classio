import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/grades/data/dtos/grade_dto.dart';
import 'package:classio/features/grades/domain/entities/grade.dart';

void main() {
  group('GradeDTO', () {
    group('fromJson', () {
      test('should parse valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'grade_type': 'Final Exam',
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.id, equals('grade-123'));
        expect(dto.subjectId, equals('subject-456'));
        expect(dto.score, equals(85.5));
        expect(dto.weight, equals(1.0));
        expect(dto.description, equals('Final Exam'));
        expect(dto.date?.year, equals(2024));
        expect(dto.date?.month, equals(3));
        expect(dto.date?.day, equals(15));
      });

      test('should use default weight of 1.0 when weight is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'grade_type': 'Test',
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.weight, equals(1.0));
      });

      test('should use default description when grade_type is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.description, equals('Grade'));
      });

      test('should parse description from comment field', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'comment': 'Teacher comment',
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.description, equals('Teacher comment'));
      });

      test('should parse description from description field', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Description field',
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.description, equals('Description field'));
      });

      test('should prioritize grade_type over comment for description', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'grade_type': 'Grade Type Value',
          'comment': 'Comment Value',
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.description, equals('Grade Type Value'));
      });

      test('should parse date from date field when created_at is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'grade_type': 'Test',
          'date': '2024-06-20T14:00:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.date?.month, equals(6));
        expect(dto.date?.day, equals(20));
      });

      test('should handle integer score', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85,
          'weight': 1,
          'grade_type': 'Test',
          'created_at': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.score, equals(85.0));
        expect(dto.weight, equals(1.0));
      });

      test('should handle null fields gracefully', () {
        // Arrange
        final json = <String, dynamic>{
          'id': null,
          'subject_id': null,
          'score': null,
          'weight': null,
          'grade_type': null,
          'created_at': null,
        };

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.id, isNull);
        expect(dto.subjectId, isNull);
        expect(dto.score, isNull);
        expect(dto.weight, equals(1.0)); // Default value
        expect(dto.description, equals('Grade')); // Default value
        expect(dto.date, isNull);
      });

      test('should handle empty JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final dto = GradeDTO.fromJson(json);

        // Assert
        expect(dto.id, isNull);
        expect(dto.subjectId, isNull);
        expect(dto.score, isNull);
        expect(dto.weight, equals(1.0)); // Default
        expect(dto.description, equals('Grade')); // Default
        expect(dto.date, isNull);
      });
    });

    group('isValid', () {
      test('should return true for valid DTO with all required fields', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should return false when id is null', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when id is empty', () {
        // Arrange
        final dto = GradeDTO(
          id: '',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when subjectId is null', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: null,
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when subjectId is empty', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: '',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when score is null', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: null,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when date is null', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: null,
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when weight is null', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: null,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when weight is zero', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 0.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should return false when weight is negative', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: -0.5,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });
    });

    group('score range validation (0-100)', () {
      test('should be valid for score of 0', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 0.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should be valid for score of 100', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 100.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should be valid for score between 0 and 100', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 50.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should be invalid for score below 0', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: -1.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should be invalid for score above 100', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 101.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should be invalid for very negative score', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: -100.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should be invalid for very high score', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 1000.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });
    });

    group('weight validation (positive)', () {
      test('should be valid for weight of 0.01', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 0.01,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should be valid for weight of 1.0', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should be valid for weight greater than 1.0', () {
        // Arrange - Some systems allow weights > 1
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 2.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isTrue);
      });

      test('should be invalid for weight of exactly 0', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 0.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });

      test('should be invalid for negative weight', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: -1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.isValid, isFalse);
      });
    });

    group('validationErrors', () {
      test('should return empty list for valid DTO', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.validationErrors, isEmpty);
      });

      test('should include error for missing id', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: 'subject-456',
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.validationErrors, contains('id is required'));
      });

      test('should include error for empty id', () {
        // Arrange
        final dto = GradeDTO(
          id: '',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.validationErrors, contains('id is required'));
      });

      test('should include error for missing subject_id', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: null,
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.validationErrors, contains('subject_id is required'));
      });

      test('should include error for missing score', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: null,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(dto.validationErrors, contains('score is required'));
      });

      test('should include error for score out of range', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 150.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(
          dto.validationErrors,
          contains('score must be between 0 and 100 (got: 150.0)'),
        );
      });

      test('should include error for missing date', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: null,
        );

        // Assert
        expect(
          dto.validationErrors,
          contains('date (created_at) is required'),
        );
      });

      test('should include error for non-positive weight', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.0,
          weight: 0.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Assert
        expect(
          dto.validationErrors,
          contains('weight must be positive (got: 0.0)'),
        );
      });

      test('should include all errors when multiple validations fail', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: null,
          score: 150.0,
          weight: -1.0,
          description: 'Test',
          date: null,
        );

        // Assert
        expect(dto.validationErrors.length, equals(5));
        expect(dto.validationErrors, contains('id is required'));
        expect(dto.validationErrors, contains('subject_id is required'));
        expect(
          dto.validationErrors,
          contains('score must be between 0 and 100 (got: 150.0)'),
        );
        expect(dto.validationErrors, contains('date (created_at) is required'));
        expect(
          dto.validationErrors,
          contains('weight must be positive (got: -1.0)'),
        );
      });
    });

    group('toEntity', () {
      test('should convert valid DTO to Grade entity', () {
        // Arrange
        final date = DateTime(2024, 3, 15, 10, 30);
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 0.75,
          description: 'Final Exam',
          date: date,
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity, isA<Grade>());
        expect(entity.id, equals('grade-123'));
        expect(entity.subjectId, equals('subject-456'));
        expect(entity.score, equals(85.5));
        expect(entity.weight, equals(0.75));
        expect(entity.description, equals('Final Exam'));
        expect(entity.date, equals(date));
      });

      test('should use default description if null', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: null,
          date: DateTime.now(),
        );

        // Act
        final entity = dto.toEntity();

        // Assert
        expect(entity.description, equals('Grade'));
      });

      test('should throw StateError when converting invalid DTO', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Act & Assert
        expect(
          () => dto.toEntity(),
          throwsA(isA<StateError>()),
        );
      });

      test('should include validation errors in StateError message', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: null,
          score: null,
          weight: null,
          description: 'Test',
          date: null,
        );

        // Act & Assert
        expect(
          () => dto.toEntity(),
          throwsA(
            predicate<StateError>(
              (e) =>
                  e.message.contains('id is required') &&
                  e.message.contains('subject_id is required'),
            ),
          ),
        );
      });
    });

    group('toEntityOrNull', () {
      test('should return entity for valid DTO', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Act
        final entity = dto.toEntityOrNull(logErrors: false);

        // Assert
        expect(entity, isNotNull);
        expect(entity?.id, equals('grade-123'));
      });

      test('should return null for invalid DTO', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Act
        final entity = dto.toEntityOrNull(logErrors: false);

        // Assert
        expect(entity, isNull);
      });
    });

    group('toJson', () {
      test('should convert DTO to valid JSON', () {
        // Arrange
        final date = DateTime(2024, 3, 15, 10, 30);
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 0.75,
          description: 'Final Exam',
          date: date,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], equals('grade-123'));
        expect(json['subject_id'], equals('subject-456'));
        expect(json['score'], equals(85.5));
        expect(json['weight'], equals(0.75));
        expect(json['grade_type'], equals('Final Exam'));
        expect(json['created_at'], equals('2024-03-15T10:30:00.000'));
      });

      test('should handle null values in toJson', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: null,
          score: null,
          weight: null,
          description: null,
          date: null,
        );

        // Act
        final json = dto.toJson();

        // Assert
        expect(json['id'], isNull);
        expect(json['subject_id'], isNull);
        expect(json['score'], isNull);
        expect(json['weight'], isNull);
        expect(json['grade_type'], isNull);
        expect(json['created_at'], isNull);
      });
    });

    group('toString', () {
      test('should include relevant information', () {
        // Arrange
        final dto = GradeDTO(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Test',
          date: DateTime.now(),
        );

        // Act
        final string = dto.toString();

        // Assert
        expect(string, contains('grade-123'));
        expect(string, contains('subject-456'));
        expect(string, contains('85.5'));
        expect(string, contains('isValid: true'));
      });

      test('should show isValid as false for invalid DTO', () {
        // Arrange
        final dto = GradeDTO(
          id: null,
          subjectId: null,
          score: null,
          weight: null,
          description: null,
          date: null,
        );

        // Act
        final string = dto.toString();

        // Assert
        expect(string, contains('isValid: false'));
      });
    });

    group('GradeDTOListParser extension', () {
      test('toGradeDTOs should convert list of JSON to DTOs', () {
        // Arrange
        final jsonList = [
          {
            'id': 'g1',
            'subject_id': 's1',
            'score': 80.0,
            'weight': 1.0,
            'grade_type': 'Test 1',
            'created_at': '2024-03-15T10:30:00.000Z',
          },
          {
            'id': 'g2',
            'subject_id': 's1',
            'score': 90.0,
            'weight': 0.5,
            'grade_type': 'Test 2',
            'created_at': '2024-03-16T10:30:00.000Z',
          },
        ];

        // Act
        final dtos = jsonList.toGradeDTOs();

        // Assert
        expect(dtos.length, equals(2));
        expect(dtos[0].id, equals('g1'));
        expect(dtos[1].id, equals('g2'));
      });

      test('toGrades should convert valid DTOs to entities', () {
        // Arrange
        final jsonList = [
          {
            'id': 'g1',
            'subject_id': 's1',
            'score': 80.0,
            'weight': 1.0,
            'grade_type': 'Test 1',
            'created_at': '2024-03-15T10:30:00.000Z',
          },
          {
            'id': 'g2',
            'subject_id': 's1',
            'score': 90.0,
            'weight': 0.5,
            'grade_type': 'Test 2',
            'created_at': '2024-03-16T10:30:00.000Z',
          },
        ];

        // Act
        final grades = jsonList.toGrades(logErrors: false);

        // Assert
        expect(grades.length, equals(2));
        expect(grades[0].id, equals('g1'));
        expect(grades[1].id, equals('g2'));
      });

      test('toGrades should filter out invalid entries', () {
        // Arrange
        final jsonList = [
          {
            'id': 'g1',
            'subject_id': 's1',
            'score': 80.0,
            'weight': 1.0,
            'grade_type': 'Test 1',
            'created_at': '2024-03-15T10:30:00.000Z',
          },
          {
            // Invalid - missing id
            'subject_id': 's1',
            'score': 90.0,
            'weight': 0.5,
            'grade_type': 'Test 2',
            'created_at': '2024-03-16T10:30:00.000Z',
          },
          {
            'id': 'g3',
            'subject_id': 's1',
            'score': 85.0,
            'weight': 0.75,
            'grade_type': 'Test 3',
            'created_at': '2024-03-17T10:30:00.000Z',
          },
        ];

        // Act
        final grades = jsonList.toGrades(logErrors: false);

        // Assert
        expect(grades.length, equals(2));
        expect(grades[0].id, equals('g1'));
        expect(grades[1].id, equals('g3'));
      });

      test('toGrades should return empty list for all invalid entries', () {
        // Arrange
        final jsonList = [
          {
            // Missing id
            'subject_id': 's1',
            'score': 80.0,
            'weight': 1.0,
            'created_at': '2024-03-15T10:30:00.000Z',
          },
          {
            // Missing subject_id
            'id': 'g2',
            'score': 90.0,
            'weight': 0.5,
            'created_at': '2024-03-16T10:30:00.000Z',
          },
        ];

        // Act
        final grades = jsonList.toGrades(logErrors: false);

        // Assert
        expect(grades, isEmpty);
      });
    });
  });
}
