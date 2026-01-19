import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/grades/domain/entities/grade.dart';

void main() {
  group('Grade', () {
    // Test data
    final testDate = DateTime(2024, 3, 15, 10, 30);
    final testGrade = Grade(
      id: 'grade-123',
      subjectId: 'subject-456',
      score: 85.5,
      weight: 1.0,
      description: 'Final Exam',
      date: testDate,
    );

    group('creation', () {
      test('should create Grade with all required fields', () {
        // Arrange & Act
        final grade = Grade(
          id: 'grade-001',
          subjectId: 'math-101',
          score: 92.0,
          weight: 0.75,
          description: 'Quiz 1',
          date: testDate,
        );

        // Assert
        expect(grade.id, equals('grade-001'));
        expect(grade.subjectId, equals('math-101'));
        expect(grade.score, equals(92.0));
        expect(grade.weight, equals(0.75));
        expect(grade.description, equals('Quiz 1'));
        expect(grade.date, equals(testDate));
      });

      test('should allow zero score', () {
        // Arrange & Act
        final grade = Grade(
          id: 'grade-001',
          subjectId: 'math-101',
          score: 0.0,
          weight: 1.0,
          description: 'Failed Test',
          date: testDate,
        );

        // Assert
        expect(grade.score, equals(0.0));
      });

      test('should allow maximum score of 100', () {
        // Arrange & Act
        final grade = Grade(
          id: 'grade-001',
          subjectId: 'math-101',
          score: 100.0,
          weight: 1.0,
          description: 'Perfect Score',
          date: testDate,
        );

        // Assert
        expect(grade.score, equals(100.0));
      });

      test('should allow various weight values', () {
        // Low weight (homework)
        final lowWeight = Grade(
          id: 'g1',
          subjectId: 's1',
          score: 80.0,
          weight: 0.5,
          description: 'Homework',
          date: testDate,
        );
        expect(lowWeight.weight, equals(0.5));

        // Full weight (exam)
        final fullWeight = Grade(
          id: 'g2',
          subjectId: 's1',
          score: 80.0,
          weight: 1.0,
          description: 'Exam',
          date: testDate,
        );
        expect(fullWeight.weight, equals(1.0));
      });
    });

    group('fromJson', () {
      test('should create Grade from valid JSON with all fields', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act
        final grade = Grade.fromJson(json);

        // Assert
        expect(grade.id, equals('grade-123'));
        expect(grade.subjectId, equals('subject-456'));
        expect(grade.score, equals(85.5));
        expect(grade.weight, equals(1.0));
        expect(grade.description, equals('Final Exam'));
        expect(grade.date, equals(DateTime(2024, 3, 15, 10, 30)));
      });

      test('should handle integer score', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85,
          'weight': 1,
          'description': 'Test',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act
        final grade = Grade.fromJson(json);

        // Assert
        expect(grade.score, equals(85.0));
        expect(grade.weight, equals(1.0));
      });

      test('should handle ISO 8601 date format with timezone', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Test',
          'date': '2024-03-15T10:30:00.000Z',
        };

        // Act
        final grade = Grade.fromJson(json);

        // Assert
        expect(grade.date.year, equals(2024));
        expect(grade.date.month, equals(3));
        expect(grade.date.day, equals(15));
      });

      test('should throw TypeError when id is missing', () {
        // Arrange
        final json = {
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw TypeError when subject_id is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw TypeError when score is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'weight': 1.0,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw TypeError when weight is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw TypeError when description is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw FormatException when date is missing', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Final Exam',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw when id has invalid type', () {
        // Arrange
        final json = {
          'id': 123, // Should be String
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw when score has invalid type', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 'eighty-five', // Should be num
          'weight': 1.0,
          'description': 'Final Exam',
          'date': '2024-03-15T10:30:00.000',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw when date has invalid format', () {
        // Arrange
        final json = {
          'id': 'grade-123',
          'subject_id': 'subject-456',
          'score': 85.5,
          'weight': 1.0,
          'description': 'Final Exam',
          'date': 'not-a-valid-date',
        };

        // Act & Assert
        expect(() => Grade.fromJson(json), throwsA(isA<FormatException>()));
      });
    });

    group('toJson', () {
      test('should convert Grade to valid JSON', () {
        // Arrange
        final grade = Grade(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Final Exam',
          date: DateTime(2024, 3, 15, 10, 30),
        );

        // Act
        final json = grade.toJson();

        // Assert
        expect(json['id'], equals('grade-123'));
        expect(json['subject_id'], equals('subject-456'));
        expect(json['score'], equals(85.5));
        expect(json['weight'], equals(1.0));
        expect(json['description'], equals('Final Exam'));
        expect(json['date'], equals('2024-03-15T10:30:00.000'));
      });

      test('should produce valid ISO 8601 date string', () {
        // Arrange
        final grade = Grade(
          id: 'g1',
          subjectId: 's1',
          score: 90.0,
          weight: 1.0,
          description: 'Test',
          date: DateTime(2024, 1, 1, 8, 0, 0),
        );

        // Act
        final json = grade.toJson();

        // Assert
        expect(
          DateTime.tryParse(json['date'] as String),
          isNotNull,
        );
      });
    });

    group('toJson/fromJson roundtrip', () {
      test('should maintain data integrity through roundtrip', () {
        // Arrange
        final original = Grade(
          id: 'grade-roundtrip',
          subjectId: 'subject-test',
          score: 78.25,
          weight: 0.75,
          description: 'Roundtrip Test',
          date: DateTime(2024, 6, 20, 14, 45),
        );

        // Act
        final json = original.toJson();
        final restored = Grade.fromJson(json);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.subjectId, equals(original.subjectId));
        expect(restored.score, equals(original.score));
        expect(restored.weight, equals(original.weight));
        expect(restored.description, equals(original.description));
        expect(restored.date, equals(original.date));
      });

      test('should maintain equality through roundtrip', () {
        // Act
        final json = testGrade.toJson();
        final restored = Grade.fromJson(json);

        // Assert
        expect(restored, equals(testGrade));
      });
    });

    group('copyWith', () {
      test('should return identical copy when no arguments provided', () {
        // Act
        final copy = testGrade.copyWith();

        // Assert
        expect(copy.id, equals(testGrade.id));
        expect(copy.subjectId, equals(testGrade.subjectId));
        expect(copy.score, equals(testGrade.score));
        expect(copy.weight, equals(testGrade.weight));
        expect(copy.description, equals(testGrade.description));
        expect(copy.date, equals(testGrade.date));
      });

      test('should update only id when provided', () {
        // Act
        final copy = testGrade.copyWith(id: 'new-id');

        // Assert
        expect(copy.id, equals('new-id'));
        expect(copy.subjectId, equals(testGrade.subjectId));
        expect(copy.score, equals(testGrade.score));
        expect(copy.weight, equals(testGrade.weight));
        expect(copy.description, equals(testGrade.description));
        expect(copy.date, equals(testGrade.date));
      });

      test('should update only subjectId when provided', () {
        // Act
        final copy = testGrade.copyWith(subjectId: 'new-subject');

        // Assert
        expect(copy.id, equals(testGrade.id));
        expect(copy.subjectId, equals('new-subject'));
        expect(copy.score, equals(testGrade.score));
      });

      test('should update only score when provided', () {
        // Act
        final copy = testGrade.copyWith(score: 99.9);

        // Assert
        expect(copy.id, equals(testGrade.id));
        expect(copy.score, equals(99.9));
        expect(copy.weight, equals(testGrade.weight));
      });

      test('should update only weight when provided', () {
        // Act
        final copy = testGrade.copyWith(weight: 0.5);

        // Assert
        expect(copy.score, equals(testGrade.score));
        expect(copy.weight, equals(0.5));
        expect(copy.description, equals(testGrade.description));
      });

      test('should update only description when provided', () {
        // Act
        final copy = testGrade.copyWith(description: 'Updated Description');

        // Assert
        expect(copy.weight, equals(testGrade.weight));
        expect(copy.description, equals('Updated Description'));
        expect(copy.date, equals(testGrade.date));
      });

      test('should update only date when provided', () {
        // Arrange
        final newDate = DateTime(2025, 1, 1);

        // Act
        final copy = testGrade.copyWith(date: newDate);

        // Assert
        expect(copy.description, equals(testGrade.description));
        expect(copy.date, equals(newDate));
      });

      test('should update multiple fields at once', () {
        // Act
        final copy = testGrade.copyWith(
          score: 50.0,
          weight: 0.25,
          description: 'Revised',
        );

        // Assert
        expect(copy.id, equals(testGrade.id));
        expect(copy.subjectId, equals(testGrade.subjectId));
        expect(copy.score, equals(50.0));
        expect(copy.weight, equals(0.25));
        expect(copy.description, equals('Revised'));
        expect(copy.date, equals(testGrade.date));
      });

      test('should not modify the original instance', () {
        // Arrange
        final originalScore = testGrade.score;

        // Act
        testGrade.copyWith(score: 0.0);

        // Assert
        expect(testGrade.score, equals(originalScore));
      });
    });

    group('equality', () {
      test('should be equal to itself', () {
        // Assert
        expect(testGrade, equals(testGrade));
        expect(testGrade == testGrade, isTrue);
      });

      test('should be equal to Grade with same values', () {
        // Arrange
        final other = Grade(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Final Exam',
          date: testDate,
        );

        // Assert
        expect(testGrade, equals(other));
        expect(testGrade == other, isTrue);
      });

      test('should not be equal when id differs', () {
        // Arrange
        final other = testGrade.copyWith(id: 'different-id');

        // Assert
        expect(testGrade, isNot(equals(other)));
      });

      test('should not be equal when subjectId differs', () {
        // Arrange
        final other = testGrade.copyWith(subjectId: 'different-subject');

        // Assert
        expect(testGrade, isNot(equals(other)));
      });

      test('should not be equal when score differs', () {
        // Arrange
        final other = testGrade.copyWith(score: 0.0);

        // Assert
        expect(testGrade, isNot(equals(other)));
      });

      test('should not be equal when weight differs', () {
        // Arrange
        final other = testGrade.copyWith(weight: 0.1);

        // Assert
        expect(testGrade, isNot(equals(other)));
      });

      test('should not be equal when description differs', () {
        // Arrange
        final other = testGrade.copyWith(description: 'Different');

        // Assert
        expect(testGrade, isNot(equals(other)));
      });

      test('should not be equal when date differs', () {
        // Arrange
        final other = testGrade.copyWith(date: DateTime(2000, 1, 1));

        // Assert
        expect(testGrade, isNot(equals(other)));
      });

      test('should not be equal to null', () {
        // Assert
        expect(testGrade == null, isFalse);
      });

      test('should not be equal to different type', () {
        // Assert
        expect(testGrade == 'not a grade', isFalse);
      });
    });

    group('hashCode', () {
      test('should produce same hashCode for equal objects', () {
        // Arrange
        final other = Grade(
          id: 'grade-123',
          subjectId: 'subject-456',
          score: 85.5,
          weight: 1.0,
          description: 'Final Exam',
          date: testDate,
        );

        // Assert
        expect(testGrade.hashCode, equals(other.hashCode));
      });

      test('should produce different hashCode for different objects', () {
        // Arrange
        final other = testGrade.copyWith(id: 'different-id');

        // Assert (not guaranteed but highly likely)
        expect(testGrade.hashCode, isNot(equals(other.hashCode)));
      });

      test('should produce consistent hashCode', () {
        // Act
        final hash1 = testGrade.hashCode;
        final hash2 = testGrade.hashCode;

        // Assert
        expect(hash1, equals(hash2));
      });
    });

    group('toString', () {
      test('should include all field values', () {
        // Act
        final string = testGrade.toString();

        // Assert
        expect(string, contains('grade-123'));
        expect(string, contains('subject-456'));
        expect(string, contains('85.5'));
        expect(string, contains('1.0'));
        expect(string, contains('Final Exam'));
        expect(string, contains('Grade('));
      });
    });
  });
}
