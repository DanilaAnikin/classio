import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:classio/features/grades/domain/entities/grade.dart';
import 'package:classio/features/grades/domain/entities/subject_grade_stats.dart';
import 'package:classio/features/grades/domain/repositories/grades_repository.dart';
import 'package:classio/features/grades/presentation/providers/grades_provider.dart';

// Mock classes
class MockGradesRepository extends Mock implements GradesRepository {}

void main() {
  group('GradesProvider', () {
    late MockGradesRepository mockRepository;
    late ProviderContainer container;

    // Test data
    final testDate = DateTime(2024, 3, 15);
    final testGrade1 = Grade(
      id: 'g1',
      subjectId: 'math-101',
      score: 85.0,
      weight: 1.0,
      description: 'Final Exam',
      date: testDate,
    );
    final testGrade2 = Grade(
      id: 'g2',
      subjectId: 'math-101',
      score: 90.0,
      weight: 0.5,
      description: 'Quiz',
      date: testDate,
    );
    final testGrade3 = Grade(
      id: 'g3',
      subjectId: 'phys-101',
      score: 80.0,
      weight: 1.0,
      description: 'Exam',
      date: testDate,
    );

    final mathStats = SubjectGradeStats(
      subjectId: 'math-101',
      subjectName: 'Mathematics',
      subjectColor: 0xFF2196F3,
      average: 86.67, // (85*1 + 90*0.5) / 1.5 = 86.67
      grades: [testGrade1, testGrade2],
    );

    final physicsStats = SubjectGradeStats(
      subjectId: 'phys-101',
      subjectName: 'Physics',
      subjectColor: 0xFF4CAF50,
      average: 80.0,
      grades: [testGrade3],
    );

    setUp(() {
      mockRepository = MockGradesRepository();
    });

    tearDown(() {
      container.dispose();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          gradesRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    }

    group('gradesNotifierProvider', () {
      test('should load grades data successfully', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats, physicsStats]);

        container = createContainer();

        // Act
        final result = await container.read(gradesNotifierProvider.future);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].subjectId, equals('math-101'));
        expect(result[1].subjectId, equals('phys-101'));
        verify(() => mockRepository.getAllSubjectStats()).called(1);
      });

      test('should return empty list when no grades exist', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => []);

        container = createContainer();

        // Act
        final result = await container.read(gradesNotifierProvider.future);

        // Assert
        expect(result, isEmpty);
      });

      test('should set error state on failure', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenThrow(Exception('Failed to load grades'));

        container = createContainer();

        // Act - wait for the provider to settle
        // The future will throw, but the state will be error
        await expectLater(
          container.read(gradesNotifierProvider.future),
          throwsA(isA<Exception>()),
        );

        // Assert - state should be error
        final state = container.read(gradesNotifierProvider);
        expect(state.hasError, isTrue);
      });

      test('should be in loading state initially', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return [mathStats];
        });

        container = createContainer();

        // Act - check immediately
        final state = container.read(gradesNotifierProvider);

        // Assert
        expect(state.isLoading, isTrue);

        // Cleanup - wait for completion
        await container.read(gradesNotifierProvider.future);
      });

      test('should transition to data state after loading', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats]);

        container = createContainer();

        // Initially loading
        expect(container.read(gradesNotifierProvider).isLoading, isTrue);

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Assert - now has data
        final state = container.read(gradesNotifierProvider);
        expect(state.hasValue, isTrue);
        expect(state.value!.length, equals(1));
      });
    });

    group('refreshGrades', () {
      test('should refresh grades successfully', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats]);

        container = createContainer();

        // First load
        await container.read(gradesNotifierProvider.future);
        expect(
          container.read(gradesNotifierProvider).value!.length,
          equals(1),
        );

        // Update mock to return different data
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats, physicsStats]);

        // Act - refresh
        await container.read(gradesNotifierProvider.notifier).refreshGrades();

        // Assert
        expect(
          container.read(gradesNotifierProvider).value!.length,
          equals(2),
        );
        verify(() => mockRepository.getAllSubjectStats()).called(2);
      });

      test('should set error state on refresh failure', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats]);

        container = createContainer();

        // First load succeeds
        await container.read(gradesNotifierProvider.future);

        // Refresh fails
        when(() => mockRepository.getAllSubjectStats())
            .thenThrow(Exception('Refresh failed'));

        // Act
        await container.read(gradesNotifierProvider.notifier).refreshGrades();

        // Assert - state should be error
        final state = container.read(gradesNotifierProvider);
        expect(state.hasError, isTrue);
      });
    });

    group('subjectGradesListProvider', () {
      test('should return grades list when data is loaded', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats, physicsStats]);

        container = createContainer();

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Act
        final result = container.read(subjectGradesListProvider);

        // Assert
        expect(result.length, equals(2));
        expect(result[0], equals(mathStats));
        expect(result[1], equals(physicsStats));
      });

      test('should return empty list while loading', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return [mathStats];
        });

        container = createContainer();

        // Act - read immediately before loading completes
        final result = container.read(subjectGradesListProvider);

        // Assert
        expect(result, isEmpty);

        // Don't wait for completion - test is about loading state
      });

      test('should return empty list on error', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenThrow(Exception('Error'));

        container = createContainer();

        // Wait for error state (the future will throw)
        try {
          await container.read(gradesNotifierProvider.future);
        } catch (_) {
          // Expected to throw
        }

        // Act
        final result = container.read(subjectGradesListProvider);

        // Assert
        expect(result, isEmpty);
      });
    });

    group('overallAverageProvider', () {
      test('should compute overall average from all subjects', () async {
        // Arrange
        // mathStats.average = 86.67, physicsStats.average = 80.0
        // Overall = (86.67 + 80.0) / 2 = 83.335
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats, physicsStats]);

        container = createContainer();

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Act
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, closeTo(83.335, 0.01));
      });

      test('should return 0 when no subjects', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => []);

        container = createContainer();

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Act
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, equals(0.0));
      });

      test('should return single subject average for one subject', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats]);

        container = createContainer();

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Act
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, equals(mathStats.average));
      });

      test('should return 0 while loading', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(seconds: 1));
          return [mathStats];
        });

        container = createContainer();

        // Act - read immediately before loading completes
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, equals(0.0));
      });

      test('should return 0 on error', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenThrow(Exception('Error'));

        container = createContainer();

        // Wait for error state
        try {
          await container.read(gradesNotifierProvider.future);
        } catch (_) {
          // Expected
        }

        // Act
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, equals(0.0));
      });

      test('should compute correct average with varying subject averages', () async {
        // Arrange
        final subjects = [
          SubjectGradeStats(
            subjectId: 's1',
            subjectName: 'Subject 1',
            subjectColor: 0xFF000000,
            average: 90.0,
            grades: [],
          ),
          SubjectGradeStats(
            subjectId: 's2',
            subjectName: 'Subject 2',
            subjectColor: 0xFF000000,
            average: 80.0,
            grades: [],
          ),
          SubjectGradeStats(
            subjectId: 's3',
            subjectName: 'Subject 3',
            subjectColor: 0xFF000000,
            average: 70.0,
            grades: [],
          ),
          SubjectGradeStats(
            subjectId: 's4',
            subjectName: 'Subject 4',
            subjectColor: 0xFF000000,
            average: 60.0,
            grades: [],
          ),
        ];
        // Expected: (90 + 80 + 70 + 60) / 4 = 75.0

        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => subjects);

        container = createContainer();

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Act
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, equals(75.0));
      });

      test('should handle subjects with 0 average', () async {
        // Arrange
        final subjects = [
          SubjectGradeStats(
            subjectId: 's1',
            subjectName: 'Subject 1',
            subjectColor: 0xFF000000,
            average: 100.0,
            grades: [],
          ),
          SubjectGradeStats(
            subjectId: 's2',
            subjectName: 'Subject 2',
            subjectColor: 0xFF000000,
            average: 0.0, // No grades
            grades: [],
          ),
        ];
        // Expected: (100 + 0) / 2 = 50.0

        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => subjects);

        container = createContainer();

        // Wait for data to load
        await container.read(gradesNotifierProvider.future);

        // Act
        final result = container.read(overallAverageProvider);

        // Assert
        expect(result, equals(50.0));
      });
    });

    group('gradesRepositoryProvider', () {
      test('can be overridden with mock', () {
        // This verifies that we can properly override the provider

        container = ProviderContainer(
          overrides: [
            gradesRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );

        // Act
        final repository = container.read(gradesRepositoryProvider);

        // Assert
        expect(repository, equals(mockRepository));
      });
    });

    group('state transitions', () {
      test('should handle multiple refreshes correctly', () async {
        // Arrange
        var callCount = 0;
        when(() => mockRepository.getAllSubjectStats()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? [mathStats] : [mathStats, physicsStats];
        });

        container = createContainer();

        // First load
        await container.read(gradesNotifierProvider.future);
        expect(
          container.read(gradesNotifierProvider).value!.length,
          equals(1),
        );

        // Refresh
        await container.read(gradesNotifierProvider.notifier).refreshGrades();
        expect(
          container.read(gradesNotifierProvider).value!.length,
          equals(2),
        );
      });

      test('should maintain data integrity through state changes', () async {
        // Arrange
        when(() => mockRepository.getAllSubjectStats())
            .thenAnswer((_) async => [mathStats, physicsStats]);

        container = createContainer();

        // Load
        await container.read(gradesNotifierProvider.future);

        // Verify data
        final grades = container.read(subjectGradesListProvider);
        expect(grades[0].subjectName, equals('Mathematics'));
        expect(grades[0].grades.length, equals(2));
        expect(grades[1].subjectName, equals('Physics'));
        expect(grades[1].grades.length, equals(1));

        // Verify averages
        expect(grades[0].average, closeTo(86.67, 0.01));
        expect(grades[1].average, equals(80.0));

        // Verify overall average
        final overall = container.read(overallAverageProvider);
        expect(overall, closeTo(83.335, 0.01));
      });
    });
  });
}
