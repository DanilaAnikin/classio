import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:classio/features/grades/data/repositories/supabase_grades_repository.dart';
import 'package:classio/features/grades/domain/entities/grade.dart';
import 'package:classio/features/grades/domain/entities/subject_grade_stats.dart';
import 'package:classio/features/grades/domain/repositories/grades_repository.dart';

// Mock classes
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockGradesRepository extends Mock implements GradesRepository {}

void main() {
  group('SupabaseGradesRepository', () {
    late MockSupabaseClient mockSupabase;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;
    late SupabaseGradesRepository repository;

    const testUserId = 'test-user-123';

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();

      when(() => mockSupabase.auth).thenReturn(mockAuth);
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.id).thenReturn(testUserId);

      repository = SupabaseGradesRepository(supabaseClient: mockSupabase);
    });

    group('getAllSubjectStats', () {
      test('should throw GradesException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => repository.getAllSubjectStats(),
          throwsA(
            isA<GradesException>().having(
              (e) => e.message,
              'message',
              'User not authenticated',
            ),
          ),
        );
      });
    });

    group('getSubjectStats', () {
      test('should throw GradesException when user is not authenticated', () async {
        // Arrange
        when(() => mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => repository.getSubjectStats('any-subject-id'),
          throwsA(
            isA<GradesException>().having(
              (e) => e.message,
              'message',
              'User not authenticated',
            ),
          ),
        );
      });
    });
  });

  group('GradesException', () {
    test('should store message correctly', () {
      // Arrange & Act
      const exception = GradesException('Test error message');

      // Assert
      expect(exception.message, equals('Test error message'));
    });

    test('should have correct toString format', () {
      // Arrange
      const exception = GradesException('Database connection failed');

      // Act
      final result = exception.toString();

      // Assert
      expect(result, equals('GradesException: Database connection failed'));
    });

    test('should handle empty message', () {
      // Arrange & Act
      const exception = GradesException('');

      // Assert
      expect(exception.message, equals(''));
      expect(exception.toString(), equals('GradesException: '));
    });

    test('should handle long message', () {
      // Arrange
      final longMessage = 'Error: ' * 100;
      final exception = GradesException(longMessage);

      // Assert
      expect(exception.message, equals(longMessage));
    });
  });

  group('GradesRepository interface', () {
    // Tests using a mock repository to verify the interface contract

    late MockGradesRepository mockRepository;

    setUp(() {
      mockRepository = MockGradesRepository();
    });

    final testDate = DateTime(2024, 3, 15);
    final testGrade = Grade(
      id: 'g1',
      subjectId: 'math-101',
      score: 85.0,
      weight: 1.0,
      description: 'Test',
      date: testDate,
    );
    final testStats = SubjectGradeStats(
      subjectId: 'math-101',
      subjectName: 'Mathematics',
      subjectColor: 0xFF2196F3,
      average: 85.0,
      grades: [testGrade],
    );

    group('getAllSubjectStats contract', () {
      test('should return List<SubjectGradeStats>', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [testStats]);

        // Act
        final result = await mockRepository.getAllSubjectStats();

        // Assert
        expect(result, isA<List<SubjectGradeStats>>());
        expect(result.length, equals(1));
        expect(result[0].subjectId, equals('math-101'));
      });

      test('should return empty list when no grades', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => []);

        // Act
        final result = await mockRepository.getAllSubjectStats();

        // Assert
        expect(result, isEmpty);
      });

      test('should propagate exceptions', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenThrow(const GradesException('Failed to fetch'));

        // Act & Assert
        expect(
          () => mockRepository.getAllSubjectStats(),
          throwsA(isA<GradesException>()),
        );
      });
    });

    group('getSubjectStats contract', () {
      test('should return SubjectGradeStats for valid subject', () async {
        // Arrange
        when(() => mockRepository.getSubjectStats('math-101'))
            .thenAnswer((_) async => testStats);

        // Act
        final result = await mockRepository.getSubjectStats('math-101');

        // Assert
        expect(result, isNotNull);
        expect(result!.subjectId, equals('math-101'));
        expect(result.subjectName, equals('Mathematics'));
      });

      test('should return null for non-existent subject', () async {
        // Arrange
        when(() => mockRepository.getSubjectStats('nonexistent'))
            .thenAnswer((_) async => null);

        // Act
        final result = await mockRepository.getSubjectStats('nonexistent');

        // Assert
        expect(result, isNull);
      });

      test('should return stats with correct grades', () async {
        // Arrange
        when(() => mockRepository.getSubjectStats('math-101'))
            .thenAnswer((_) async => testStats);

        // Act
        final result = await mockRepository.getSubjectStats('math-101');

        // Assert
        expect(result!.grades.length, equals(1));
        expect(result.grades[0].id, equals('g1'));
        expect(result.grades[0].score, equals(85.0));
      });
    });
  });

  group('Weighted average calculation verification', () {
    // These tests verify the weighted average formula:
    // average = sum(score * weight) / sum(weights)

    double calculateWeightedAverage(List<Grade> grades) {
      if (grades.isEmpty) return 0.0;

      double totalWeightedScore = 0.0;
      double totalWeight = 0.0;

      for (final grade in grades) {
        totalWeightedScore += grade.score * grade.weight;
        totalWeight += grade.weight;
      }

      return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
    }

    final testDate = DateTime(2024, 3, 15);

    test('should return 0 for empty grades list', () {
      // Act
      final result = calculateWeightedAverage([]);

      // Assert
      expect(result, equals(0.0));
    });

    test('should return score for single grade', () {
      // Arrange
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 85.0,
          weight: 1.0,
          description: 'Test',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert
      expect(result, equals(85.0));
    });

    test('should calculate simple average for equal weights', () {
      // Arrange
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 80.0,
          weight: 1.0,
          description: 'Test 1',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 90.0,
          weight: 1.0,
          description: 'Test 2',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert - (80 + 90) / 2 = 85
      expect(result, equals(85.0));
    });

    test('should weight heavier grades more', () {
      // Arrange
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 70.0,
          weight: 1.0, // Heavy (exam)
          description: 'Exam',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 90.0,
          weight: 0.5, // Light (quiz)
          description: 'Quiz',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert - (70*1.0 + 90*0.5) / (1.0 + 0.5) = 115 / 1.5 = 76.67
      expect(result, closeTo(76.67, 0.01));
    });

    test('should handle very small weights', () {
      // Arrange
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 50.0,
          weight: 1.0,
          description: 'Exam',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 100.0,
          weight: 0.01, // Very small weight
          description: 'Bonus',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert - (50*1.0 + 100*0.01) / (1.0 + 0.01) = 51 / 1.01 ~= 50.5
      expect(result, closeTo(50.5, 0.1));
    });

    test('should handle multiple different weights', () {
      // Arrange - Typical school scenario
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 70.0,
          weight: 1.0, // Exam
          description: 'Final Exam',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 85.0,
          weight: 0.5, // Quiz
          description: 'Quiz',
          date: testDate,
        ),
        Grade(
          id: 'g3',
          subjectId: 's1',
          score: 95.0,
          weight: 0.25, // Homework
          description: 'Homework',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert
      // (70*1.0 + 85*0.5 + 95*0.25) / (1.0 + 0.5 + 0.25)
      // = (70 + 42.5 + 23.75) / 1.75
      // = 136.25 / 1.75
      // = 77.857...
      expect(result, closeTo(77.86, 0.01));
    });

    test('should give heavier weights more influence on average', () {
      // Arrange - Same scores, different weight distribution
      final gradesHeavyLow = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 60.0,
          weight: 1.0, // Heavy weight on low score
          description: 'Exam',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 100.0,
          weight: 0.1, // Light weight on high score
          description: 'Bonus',
          date: testDate,
        ),
      ];

      final gradesHeavyHigh = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 60.0,
          weight: 0.1, // Light weight on low score
          description: 'Homework',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 100.0,
          weight: 1.0, // Heavy weight on high score
          description: 'Exam',
          date: testDate,
        ),
      ];

      // Act
      final resultHeavyLow = calculateWeightedAverage(gradesHeavyLow);
      final resultHeavyHigh = calculateWeightedAverage(gradesHeavyHigh);

      // Assert - Heavy weight on low score should pull average down
      expect(resultHeavyLow, lessThan(resultHeavyHigh));
      expect(resultHeavyLow, closeTo(63.64, 0.1)); // Closer to 60
      expect(resultHeavyHigh, closeTo(96.36, 0.1)); // Closer to 100
    });

    test('should handle weights that sum to less than 1', () {
      // Arrange
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 80.0,
          weight: 0.25,
          description: 'Quiz 1',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 90.0,
          weight: 0.25,
          description: 'Quiz 2',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert - (80*0.25 + 90*0.25) / 0.5 = 42.5 / 0.5 = 85
      expect(result, equals(85.0));
    });

    test('should handle weights that sum to more than 1', () {
      // Arrange
      final grades = [
        Grade(
          id: 'g1',
          subjectId: 's1',
          score: 80.0,
          weight: 1.0,
          description: 'Midterm',
          date: testDate,
        ),
        Grade(
          id: 'g2',
          subjectId: 's1',
          score: 90.0,
          weight: 1.0,
          description: 'Final',
          date: testDate,
        ),
      ];

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert - (80*1 + 90*1) / 2 = 85
      expect(result, equals(85.0));
    });

    test('should maintain precision with many grades', () {
      // Arrange - 10 grades with varying scores and weights
      final grades = List.generate(
        10,
        (i) => Grade(
          id: 'g$i',
          subjectId: 's1',
          score: 70.0 + i * 3, // 70, 73, 76, ..., 97
          weight: 0.5 + (i % 3) * 0.25, // 0.5, 0.75, 1.0, ...
          description: 'Test $i',
          date: testDate,
        ),
      );

      // Manually calculate expected
      double expectedSum = 0.0;
      double expectedWeight = 0.0;
      for (var i = 0; i < 10; i++) {
        final score = 70.0 + i * 3;
        final weight = 0.5 + (i % 3) * 0.25;
        expectedSum += score * weight;
        expectedWeight += weight;
      }
      final expected = expectedSum / expectedWeight;

      // Act
      final result = calculateWeightedAverage(grades);

      // Assert
      expect(result, closeTo(expected, 0.001));
    });
  });
}
