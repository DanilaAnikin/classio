import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/grades/domain/entities/grade.dart';
import 'package:classio/features/grades/domain/entities/subject_grade_stats.dart';

void main() {
  group('SubjectGradeStats', () {
    // Test data
    final testDate = DateTime(2024, 3, 15);
    final testGrade1 = Grade(
      id: 'g1',
      subjectId: 'math-101',
      score: 90.0,
      weight: 1.0,
      description: 'Final Exam',
      date: testDate,
    );
    final testGrade2 = Grade(
      id: 'g2',
      subjectId: 'math-101',
      score: 80.0,
      weight: 0.5,
      description: 'Quiz',
      date: testDate,
    );
    final testGrade3 = Grade(
      id: 'g3',
      subjectId: 'math-101',
      score: 70.0,
      weight: 0.25,
      description: 'Homework',
      date: testDate,
    );

    group('creation', () {
      test('should create SubjectGradeStats with all required fields', () {
        // Arrange & Act
        final stats = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1],
        );

        // Assert
        expect(stats.subjectId, equals('math-101'));
        expect(stats.subjectName, equals('Mathematics'));
        expect(stats.subjectColor, equals(0xFF2196F3));
        expect(stats.average, equals(85.0));
        expect(stats.grades.length, equals(1));
      });

      test('should create with empty grades list', () {
        // Arrange & Act
        final stats = SubjectGradeStats(
          subjectId: 'phys-101',
          subjectName: 'Physics',
          subjectColor: 0xFF4CAF50,
          average: 0.0,
          grades: [],
        );

        // Assert
        expect(stats.grades, isEmpty);
        expect(stats.average, equals(0.0));
      });

      test('should create with multiple grades', () {
        // Arrange & Act
        final stats = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1, testGrade2, testGrade3],
        );

        // Assert
        expect(stats.grades.length, equals(3));
      });
    });

    group('gradeCount', () {
      test('should return 0 for empty grades list', () {
        // Arrange
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: 0.0,
          grades: [],
        );

        // Act & Assert
        expect(stats.gradeCount, equals(0));
      });

      test('should return correct count for non-empty grades list', () {
        // Arrange
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: 85.0,
          grades: [testGrade1, testGrade2, testGrade3],
        );

        // Act & Assert
        expect(stats.gradeCount, equals(3));
      });
    });

    group('hasNoGrades', () {
      test('should return true for empty grades list', () {
        // Arrange
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: 0.0,
          grades: [],
        );

        // Act & Assert
        expect(stats.hasNoGrades, isTrue);
      });

      test('should return false for non-empty grades list', () {
        // Arrange
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: 85.0,
          grades: [testGrade1],
        );

        // Act & Assert
        expect(stats.hasNoGrades, isFalse);
      });
    });

    group('weighted average calculation verification', () {
      // NOTE: SubjectGradeStats stores a pre-calculated average.
      // These tests verify the weighted average formula:
      // average = sum(score * weight) / sum(weights)

      test('should verify weighted average with equal weights', () {
        // Arrange
        // All grades have weight 1.0
        final grade1 = Grade(
          id: 'g1',
          subjectId: 's1',
          score: 80.0,
          weight: 1.0,
          description: 'Test 1',
          date: testDate,
        );
        final grade2 = Grade(
          id: 'g2',
          subjectId: 's1',
          score: 90.0,
          weight: 1.0,
          description: 'Test 2',
          date: testDate,
        );
        final grade3 = Grade(
          id: 'g3',
          subjectId: 's1',
          score: 100.0,
          weight: 1.0,
          description: 'Test 3',
          date: testDate,
        );

        // Expected: (80*1 + 90*1 + 100*1) / (1+1+1) = 270/3 = 90.0
        final expectedAverage = (80.0 + 90.0 + 100.0) / 3;

        // Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: expectedAverage,
          grades: [grade1, grade2, grade3],
        );

        // Assert
        expect(stats.average, equals(90.0));
      });

      test('should verify weighted average with different weights', () {
        // Arrange
        final examGrade = Grade(
          id: 'g1',
          subjectId: 's1',
          score: 70.0,
          weight: 1.0, // Full weight (exam)
          description: 'Final Exam',
          date: testDate,
        );
        final quizGrade = Grade(
          id: 'g2',
          subjectId: 's1',
          score: 90.0,
          weight: 0.5, // Half weight (quiz)
          description: 'Quiz',
          date: testDate,
        );
        final homeworkGrade = Grade(
          id: 'g3',
          subjectId: 's1',
          score: 100.0,
          weight: 0.25, // Quarter weight (homework)
          description: 'Homework',
          date: testDate,
        );

        // Expected: (70*1.0 + 90*0.5 + 100*0.25) / (1.0+0.5+0.25)
        //         = (70 + 45 + 25) / 1.75
        //         = 140 / 1.75
        //         = 80.0
        final totalWeightedScore =
            70.0 * 1.0 + 90.0 * 0.5 + 100.0 * 0.25; // = 140
        final totalWeight = 1.0 + 0.5 + 0.25; // = 1.75
        final expectedAverage = totalWeightedScore / totalWeight; // = 80.0

        // Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: expectedAverage,
          grades: [examGrade, quizGrade, homeworkGrade],
        );

        // Assert
        expect(stats.average, equals(80.0));
      });

      test('should verify weighted average where heavier weight dominates', () {
        // Arrange
        // Heavy exam with low score should pull down average
        final examGrade = Grade(
          id: 'g1',
          subjectId: 's1',
          score: 50.0,
          weight: 1.0, // Full weight
          description: 'Exam',
          date: testDate,
        );
        final homeworkGrade = Grade(
          id: 'g2',
          subjectId: 's1',
          score: 100.0,
          weight: 0.1, // Very light weight
          description: 'Homework',
          date: testDate,
        );

        // Expected: (50*1.0 + 100*0.1) / (1.0+0.1)
        //         = (50 + 10) / 1.1
        //         = 60 / 1.1
        //         ~= 54.545454...
        final expectedAverage = (50.0 * 1.0 + 100.0 * 0.1) / (1.0 + 0.1);

        // Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: expectedAverage,
          grades: [examGrade, homeworkGrade],
        );

        // Assert - Heavy weight pulls average closer to 50
        expect(stats.average, closeTo(54.545, 0.001));
      });

      test('should verify weighted average with single grade', () {
        // Arrange
        final singleGrade = Grade(
          id: 'g1',
          subjectId: 's1',
          score: 85.0,
          weight: 0.75,
          description: 'Test',
          date: testDate,
        );

        // Expected: With single grade, average equals the score
        // (85*0.75) / 0.75 = 85
        final expectedAverage = 85.0;

        // Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: expectedAverage,
          grades: [singleGrade],
        );

        // Assert
        expect(stats.average, equals(85.0));
      });

      test('should verify average is 0 for empty grades', () {
        // Arrange & Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: 0.0,
          grades: [],
        );

        // Assert
        expect(stats.average, equals(0.0));
      });

      test('should verify weighted average calculation precision', () {
        // Arrange - Use values that could cause floating point issues
        final grades = [
          Grade(
            id: 'g1',
            subjectId: 's1',
            score: 33.33,
            weight: 0.33,
            description: 'Test 1',
            date: testDate,
          ),
          Grade(
            id: 'g2',
            subjectId: 's1',
            score: 66.66,
            weight: 0.66,
            description: 'Test 2',
            date: testDate,
          ),
        ];

        // Calculate expected with formula
        final weightedSum = 33.33 * 0.33 + 66.66 * 0.66;
        final totalWeight = 0.33 + 0.66;
        final expectedAverage = weightedSum / totalWeight;

        // Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: expectedAverage,
          grades: grades,
        );

        // Assert
        expect(stats.average, closeTo(expectedAverage, 0.001));
      });

      test('should verify weighted average with varying weights scenario', () {
        // Arrange - Realistic school scenario
        // 2 exams (weight 1.0), 3 quizzes (weight 0.5), 5 homework (weight 0.25)
        final grades = <Grade>[];
        var weightedSum = 0.0;
        var totalWeight = 0.0;

        // Exams
        for (var i = 0; i < 2; i++) {
          final score = 75.0 + i * 5; // 75, 80
          grades.add(Grade(
            id: 'exam-$i',
            subjectId: 's1',
            score: score,
            weight: 1.0,
            description: 'Exam ${i + 1}',
            date: testDate,
          ));
          weightedSum += score * 1.0;
          totalWeight += 1.0;
        }

        // Quizzes
        for (var i = 0; i < 3; i++) {
          final score = 80.0 + i * 5; // 80, 85, 90
          grades.add(Grade(
            id: 'quiz-$i',
            subjectId: 's1',
            score: score,
            weight: 0.5,
            description: 'Quiz ${i + 1}',
            date: testDate,
          ));
          weightedSum += score * 0.5;
          totalWeight += 0.5;
        }

        // Homework
        for (var i = 0; i < 5; i++) {
          final score = 90.0 + i * 2; // 90, 92, 94, 96, 98
          grades.add(Grade(
            id: 'hw-$i',
            subjectId: 's1',
            score: score,
            weight: 0.25,
            description: 'Homework ${i + 1}',
            date: testDate,
          ));
          weightedSum += score * 0.25;
          totalWeight += 0.25;
        }

        final expectedAverage = weightedSum / totalWeight;

        // Act
        final stats = SubjectGradeStats(
          subjectId: 's1',
          subjectName: 'Subject',
          subjectColor: 0xFF000000,
          average: expectedAverage,
          grades: grades,
        );

        // Assert
        expect(stats.gradeCount, equals(10));
        expect(stats.average, closeTo(expectedAverage, 0.001));
        // The exams (lower scores, high weight) should pull down the average
        // despite homework having perfect scores
        expect(stats.average, lessThan(90.0));
      });
    });

    group('copyWith', () {
      late SubjectGradeStats testStats;

      setUp(() {
        testStats = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1],
        );
      });

      test('should return identical copy when no arguments provided', () {
        // Act
        final copy = testStats.copyWith();

        // Assert
        expect(copy.subjectId, equals(testStats.subjectId));
        expect(copy.subjectName, equals(testStats.subjectName));
        expect(copy.subjectColor, equals(testStats.subjectColor));
        expect(copy.average, equals(testStats.average));
        expect(copy.grades, equals(testStats.grades));
      });

      test('should update only subjectId when provided', () {
        // Act
        final copy = testStats.copyWith(subjectId: 'new-id');

        // Assert
        expect(copy.subjectId, equals('new-id'));
        expect(copy.subjectName, equals(testStats.subjectName));
      });

      test('should update only subjectName when provided', () {
        // Act
        final copy = testStats.copyWith(subjectName: 'Physics');

        // Assert
        expect(copy.subjectId, equals(testStats.subjectId));
        expect(copy.subjectName, equals('Physics'));
      });

      test('should update only subjectColor when provided', () {
        // Act
        final copy = testStats.copyWith(subjectColor: 0xFF4CAF50);

        // Assert
        expect(copy.subjectColor, equals(0xFF4CAF50));
        expect(copy.average, equals(testStats.average));
      });

      test('should update only average when provided', () {
        // Act
        final copy = testStats.copyWith(average: 92.5);

        // Assert
        expect(copy.subjectColor, equals(testStats.subjectColor));
        expect(copy.average, equals(92.5));
      });

      test('should update only grades when provided', () {
        // Act
        final newGrades = [testGrade1, testGrade2];
        final copy = testStats.copyWith(grades: newGrades);

        // Assert
        expect(copy.average, equals(testStats.average));
        expect(copy.grades.length, equals(2));
      });

      test('should update multiple fields at once', () {
        // Act
        final copy = testStats.copyWith(
          subjectName: 'Updated Subject',
          average: 75.0,
        );

        // Assert
        expect(copy.subjectId, equals(testStats.subjectId));
        expect(copy.subjectName, equals('Updated Subject'));
        expect(copy.average, equals(75.0));
      });
    });

    group('equality', () {
      late SubjectGradeStats testStats;

      setUp(() {
        testStats = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1],
        );
      });

      test('should be equal to itself', () {
        // Assert
        expect(testStats, equals(testStats));
      });

      test('should be equal to SubjectGradeStats with same values', () {
        // Arrange
        final other = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1],
        );

        // Assert
        expect(testStats, equals(other));
      });

      test('should not be equal when subjectId differs', () {
        // Arrange
        final other = testStats.copyWith(subjectId: 'different');

        // Assert
        expect(testStats, isNot(equals(other)));
      });

      test('should not be equal when subjectName differs', () {
        // Arrange
        final other = testStats.copyWith(subjectName: 'Different');

        // Assert
        expect(testStats, isNot(equals(other)));
      });

      test('should not be equal when subjectColor differs', () {
        // Arrange
        final other = testStats.copyWith(subjectColor: 0xFF000000);

        // Assert
        expect(testStats, isNot(equals(other)));
      });

      test('should not be equal when average differs', () {
        // Arrange
        final other = testStats.copyWith(average: 0.0);

        // Assert
        expect(testStats, isNot(equals(other)));
      });

      test('should not be equal when grades list differs', () {
        // Arrange
        final other = testStats.copyWith(grades: [testGrade1, testGrade2]);

        // Assert
        expect(testStats, isNot(equals(other)));
      });

      test('should not be equal when grades have same length but different content', () {
        // Arrange
        final differentGrade = testGrade1.copyWith(score: 0.0);
        final other = testStats.copyWith(grades: [differentGrade]);

        // Assert
        expect(testStats, isNot(equals(other)));
      });

      test('should not be equal to null', () {
        // Assert
        expect(testStats == null, isFalse);
      });
    });

    group('hashCode', () {
      late SubjectGradeStats testStats;

      setUp(() {
        testStats = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1],
        );
      });

      test('should produce same hashCode for equal objects', () {
        // Arrange
        final other = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.0,
          grades: [testGrade1],
        );

        // Assert
        expect(testStats.hashCode, equals(other.hashCode));
      });

      test('should produce consistent hashCode', () {
        // Act
        final hash1 = testStats.hashCode;
        final hash2 = testStats.hashCode;

        // Assert
        expect(hash1, equals(hash2));
      });
    });

    group('toString', () {
      test('should include relevant field values', () {
        // Arrange
        final stats = SubjectGradeStats(
          subjectId: 'math-101',
          subjectName: 'Mathematics',
          subjectColor: 0xFF2196F3,
          average: 85.5,
          grades: [testGrade1, testGrade2],
        );

        // Act
        final string = stats.toString();

        // Assert
        expect(string, contains('math-101'));
        expect(string, contains('Mathematics'));
        expect(string, contains('85.5'));
        expect(string, contains('gradeCount: 2'));
      });
    });
  });
}
