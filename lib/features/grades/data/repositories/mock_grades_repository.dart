import '../../../../core/utils/subject_colors.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/grades_repository.dart';

/// Mock implementation of [GradesRepository] for testing and development.
///
/// Provides realistic fake grade data for multiple subjects including:
/// - Multiple subjects with different colors
/// - Various types of assessments (exams, quizzes, homework, projects)
/// - Different weights for different assignment types
/// - Realistic grade distributions
/// - Dates spread over the last 2-3 months
/// - Weighted average calculation: sum(score * weight) / sum(weights)
class MockGradesRepository implements GradesRepository {
  /// Creates a [MockGradesRepository] instance.
  MockGradesRepository() {
    _initializeMockData();
  }

  // Mock data
  late final List<SubjectGradeStats> _subjectStats;

  /// Initializes all mock grade data.
  void _initializeMockData() {
    final now = DateTime.now();

    // Helper to create a date going back from now
    DateTime daysAgo(int days) => now.subtract(Duration(days: days));

    // Mathematics grades
    final mathGrades = [
      Grade(
        id: 'grade-math-1',
        subjectId: 'math-1',
        score: 1.0,
        weight: 1.0,
        description: 'Midterm Exam',
        date: daysAgo(65),
      ),
      Grade(
        id: 'grade-math-2',
        subjectId: 'math-1',
        score: 2.0,
        weight: 0.5,
        description: 'Quiz 1 - Linear Algebra',
        date: daysAgo(58),
      ),
      Grade(
        id: 'grade-math-3',
        subjectId: 'math-1',
        score: 1.0,
        weight: 0.5,
        description: 'Homework 3',
        date: daysAgo(50),
      ),
      Grade(
        id: 'grade-math-4',
        subjectId: 'math-1',
        score: 2.0,
        weight: 0.75,
        description: 'Quiz 2 - Calculus',
        date: daysAgo(42),
      ),
      Grade(
        id: 'grade-math-5',
        subjectId: 'math-1',
        score: 1.0,
        weight: 1.0,
        description: 'Final Test',
        date: daysAgo(28),
      ),
      Grade(
        id: 'grade-math-6',
        subjectId: 'math-1',
        score: 1.0,
        weight: 0.5,
        description: 'Homework 5',
        date: daysAgo(14),
      ),
    ];

    // Physics grades
    final physicsGrades = [
      Grade(
        id: 'grade-phys-1',
        subjectId: 'phys-1',
        score: 2.0,
        weight: 1.0,
        description: 'Mechanics Exam',
        date: daysAgo(70),
      ),
      Grade(
        id: 'grade-phys-2',
        subjectId: 'phys-1',
        score: 1.0,
        weight: 0.75,
        description: 'Lab Report - Pendulum',
        date: daysAgo(62),
      ),
      Grade(
        id: 'grade-phys-3',
        subjectId: 'phys-1',
        score: 2.0,
        weight: 0.5,
        description: 'Quiz - Energy Conservation',
        date: daysAgo(55),
      ),
      Grade(
        id: 'grade-phys-4',
        subjectId: 'phys-1',
        score: 1.0,
        weight: 0.75,
        description: 'Lab Report - Optics',
        date: daysAgo(48),
      ),
      Grade(
        id: 'grade-phys-5',
        subjectId: 'phys-1',
        score: 2.0,
        weight: 1.0,
        description: 'Thermodynamics Test',
        date: daysAgo(34),
      ),
      Grade(
        id: 'grade-phys-6',
        subjectId: 'phys-1',
        score: 1.0,
        weight: 0.5,
        description: 'Homework 4',
        date: daysAgo(20),
      ),
    ];

    // Chemistry grades
    final chemistryGrades = [
      Grade(
        id: 'grade-chem-1',
        subjectId: 'chem-1',
        score: 1.0,
        weight: 1.0,
        description: 'Organic Chemistry Exam',
        date: daysAgo(75),
      ),
      Grade(
        id: 'grade-chem-2',
        subjectId: 'chem-1',
        score: 1.0,
        weight: 0.75,
        description: 'Lab - Titration',
        date: daysAgo(68),
      ),
      Grade(
        id: 'grade-chem-3',
        subjectId: 'chem-1',
        score: 2.0,
        weight: 0.5,
        description: 'Quiz - Periodic Table',
        date: daysAgo(60),
      ),
      Grade(
        id: 'grade-chem-4',
        subjectId: 'chem-1',
        score: 1.0,
        weight: 0.5,
        description: 'Homework 2',
        date: daysAgo(53),
      ),
      Grade(
        id: 'grade-chem-5',
        subjectId: 'chem-1',
        score: 1.0,
        weight: 1.0,
        description: 'Inorganic Chemistry Test',
        date: daysAgo(40),
      ),
      Grade(
        id: 'grade-chem-6',
        subjectId: 'chem-1',
        score: 2.0,
        weight: 0.75,
        description: 'Lab - Synthesis',
        date: daysAgo(32),
      ),
      Grade(
        id: 'grade-chem-7',
        subjectId: 'chem-1',
        score: 1.0,
        weight: 0.5,
        description: 'Homework 4',
        date: daysAgo(18),
      ),
    ];

    // History grades
    final historyGrades = [
      Grade(
        id: 'grade-hist-1',
        subjectId: 'hist-1',
        score: 2.0,
        weight: 1.0,
        description: 'World War II Essay',
        date: daysAgo(80),
      ),
      Grade(
        id: 'grade-hist-2',
        subjectId: 'hist-1',
        score: 1.0,
        weight: 0.75,
        description: 'Renaissance Project',
        date: daysAgo(72),
      ),
      Grade(
        id: 'grade-hist-3',
        subjectId: 'hist-1',
        score: 2.0,
        weight: 0.5,
        description: 'Quiz - Ancient Rome',
        date: daysAgo(64),
      ),
      Grade(
        id: 'grade-hist-4',
        subjectId: 'hist-1',
        score: 1.0,
        weight: 1.0,
        description: 'Cold War Exam',
        date: daysAgo(45),
      ),
      Grade(
        id: 'grade-hist-5',
        subjectId: 'hist-1',
        score: 2.0,
        weight: 0.5,
        description: 'Reading Assignment',
        date: daysAgo(38),
      ),
      Grade(
        id: 'grade-hist-6',
        subjectId: 'hist-1',
        score: 1.0,
        weight: 0.75,
        description: 'Industrial Revolution Paper',
        date: daysAgo(24),
      ),
    ];

    // English grades
    final englishGrades = [
      Grade(
        id: 'grade-eng-1',
        subjectId: 'eng-1',
        score: 1.0,
        weight: 1.0,
        description: 'Shakespeare Essay',
        date: daysAgo(78),
      ),
      Grade(
        id: 'grade-eng-2',
        subjectId: 'eng-1',
        score: 2.0,
        weight: 0.5,
        description: 'Grammar Quiz',
        date: daysAgo(71),
      ),
      Grade(
        id: 'grade-eng-3',
        subjectId: 'eng-1',
        score: 1.0,
        weight: 0.75,
        description: 'Poetry Analysis',
        date: daysAgo(63),
      ),
      Grade(
        id: 'grade-eng-4',
        subjectId: 'eng-1',
        score: 1.0,
        weight: 0.5,
        description: 'Vocabulary Test',
        date: daysAgo(56),
      ),
      Grade(
        id: 'grade-eng-5',
        subjectId: 'eng-1',
        score: 2.0,
        weight: 1.0,
        description: 'Literary Analysis Essay',
        date: daysAgo(49),
      ),
      Grade(
        id: 'grade-eng-6',
        subjectId: 'eng-1',
        score: 1.0,
        weight: 0.75,
        description: 'Presentation',
        date: daysAgo(35),
      ),
      Grade(
        id: 'grade-eng-7',
        subjectId: 'eng-1',
        score: 1.0,
        weight: 0.5,
        description: 'Reading Comprehension',
        date: daysAgo(21),
      ),
    ];

    // Computer Science grades
    final csGrades = [
      Grade(
        id: 'grade-cs-1',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 1.0,
        description: 'Data Structures Exam',
        date: daysAgo(82),
      ),
      Grade(
        id: 'grade-cs-2',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 0.75,
        description: 'Project - Binary Search Tree',
        date: daysAgo(74),
      ),
      Grade(
        id: 'grade-cs-3',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 0.5,
        description: 'Quiz - Algorithms',
        date: daysAgo(66),
      ),
      Grade(
        id: 'grade-cs-4',
        subjectId: 'cs-1',
        score: 2.0,
        weight: 0.75,
        description: 'Project - Graph Traversal',
        date: daysAgo(57),
      ),
      Grade(
        id: 'grade-cs-5',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 1.0,
        description: 'OOP Midterm',
        date: daysAgo(47),
      ),
      Grade(
        id: 'grade-cs-6',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 0.5,
        description: 'Homework - Recursion',
        date: daysAgo(36),
      ),
      Grade(
        id: 'grade-cs-7',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 0.75,
        description: 'Project - Final App',
        date: daysAgo(26),
      ),
      Grade(
        id: 'grade-cs-8',
        subjectId: 'cs-1',
        score: 1.0,
        weight: 0.5,
        description: 'Quiz - Design Patterns',
        date: daysAgo(12),
      ),
    ];

    // Create subject stats with calculated weighted averages
    _subjectStats = [
      SubjectGradeStats(
        subjectId: 'math-1',
        subjectName: 'Mathematics',
        subjectColor: SubjectColors.palette[0], // Blue
        average: _calculateWeightedAverage(mathGrades),
        grades: mathGrades,
      ),
      SubjectGradeStats(
        subjectId: 'phys-1',
        subjectName: 'Physics',
        subjectColor: SubjectColors.palette[1], // Deep Orange
        average: _calculateWeightedAverage(physicsGrades),
        grades: physicsGrades,
      ),
      SubjectGradeStats(
        subjectId: 'chem-1',
        subjectName: 'Chemistry',
        subjectColor: SubjectColors.palette[2], // Green
        average: _calculateWeightedAverage(chemistryGrades),
        grades: chemistryGrades,
      ),
      SubjectGradeStats(
        subjectId: 'hist-1',
        subjectName: 'History',
        subjectColor: SubjectColors.palette[11], // Brown
        average: _calculateWeightedAverage(historyGrades),
        grades: historyGrades,
      ),
      SubjectGradeStats(
        subjectId: 'eng-1',
        subjectName: 'English',
        subjectColor: SubjectColors.palette[3], // Purple
        average: _calculateWeightedAverage(englishGrades),
        grades: englishGrades,
      ),
      SubjectGradeStats(
        subjectId: 'cs-1',
        subjectName: 'Computer Science',
        subjectColor: SubjectColors.palette[4], // Teal
        average: _calculateWeightedAverage(csGrades),
        grades: csGrades,
      ),
    ];
  }

  /// Calculates the weighted average of a list of grades.
  ///
  /// Formula: sum(score * weight) / sum(weights)
  double _calculateWeightedAverage(List<Grade> grades) {
    if (grades.isEmpty) return 0.0;

    double totalWeightedScore = 0.0;
    double totalWeight = 0.0;

    for (final grade in grades) {
      totalWeightedScore += grade.score * grade.weight;
      totalWeight += grade.weight;
    }

    return totalWeight > 0 ? totalWeightedScore / totalWeight : 0.0;
  }

  @override
  Future<List<SubjectGradeStats>> getAllSubjectStats() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    return _subjectStats;
  }

  @override
  Future<SubjectGradeStats?> getSubjectStats(String subjectId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _subjectStats.firstWhere(
        (stats) => stats.subjectId == subjectId,
      );
    } catch (e) {
      return null;
    }
  }
}
