import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/subject_colors.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/grades_repository.dart';
import '../dtos/grade_dto.dart';

/// Exception thrown when grade operations fail.
class GradesException extends RepositoryException {
  const GradesException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'GradesException: $message';
}

/// Supabase implementation of [GradesRepository].
///
/// Fetches grade data from the Supabase database for the currently
/// authenticated user. Grades are retrieved from the `grades` table
/// and joined with `subjects` for subject details.
///
/// Features:
/// - Fetches grades filtered by current user's student_id
/// - Joins with subjects table to get subject name
/// - Calculates weighted averages dynamically
/// - Groups grades by subject and creates SubjectGradeStats entities
class SupabaseGradesRepository implements GradesRepository {
  /// Creates a [SupabaseGradesRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseGradesRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Gets the current authenticated user's ID.
  ///
  /// Returns null if no user is authenticated.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<SubjectGradeStats>> getAllSubjectStats() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const GradesException('User not authenticated');
    }

    try {
      // Query grades with subject information for the current student
      // The grades table has student_id, subject_id, score, weight, etc.
      // We join with subjects to get the subject name
      final response = await _supabase
          .from('grades')
          .select('''
            id,
            subject_id,
            score,
            weight,
            grade_type,
            comment,
            created_at,
            subjects!inner (
              id,
              name
            )
          ''')
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      // Group grades by subject
      final Map<String, List<Map<String, dynamic>>> gradesBySubject = {};
      final Map<String, String> subjectNames = {};

      for (final gradeData in response) {
        final subjectId = gradeData['subject_id'] as String;
        final subjects = gradeData['subjects'] as Map<String, dynamic>;
        final subjectName = subjects['name'] as String;

        gradesBySubject.putIfAbsent(subjectId, () => []);
        gradesBySubject[subjectId]!.add(gradeData);
        subjectNames[subjectId] = subjectName;
      }

      // Convert to SubjectGradeStats list
      final List<SubjectGradeStats> subjectStats = [];
      var colorIndex = 0;

      for (final entry in gradesBySubject.entries) {
        final subjectId = entry.key;
        final gradesData = entry.value;
        final subjectName = subjectNames[subjectId] ?? 'Unknown Subject';

        // Convert grade data to Grade entities using DTO with validation
        final grades = _mapToGrades(gradesData);

        // Calculate weighted average
        final average = _calculateWeightedAverage(grades);

        // Assign color based on index using SubjectColors utility
        final color = SubjectColors.getColorForIndex(colorIndex);
        colorIndex++;

        subjectStats.add(SubjectGradeStats(
          subjectId: subjectId,
          subjectName: subjectName,
          subjectColor: color,
          average: average,
          grades: grades,
        ));
      }

      // Sort by subject name alphabetically
      subjectStats.sort((a, b) => a.subjectName.compareTo(b.subjectName));

      return subjectStats;
    } on PostgrestException catch (e) {
      throw GradesException('Failed to fetch grades: ${e.message}');
    } catch (e) {
      if (e is GradesException) rethrow;
      throw GradesException('Failed to fetch grades: ${e.toString()}');
    }
  }

  @override
  Future<SubjectGradeStats?> getSubjectStats(String subjectId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const GradesException('User not authenticated');
    }

    try {
      // Query grades for the specific subject
      final gradesResponse = await _supabase
          .from('grades')
          .select('''
            id,
            subject_id,
            score,
            weight,
            grade_type,
            comment,
            created_at
          ''')
          .eq('student_id', userId)
          .eq('subject_id', subjectId)
          .order('created_at', ascending: false);

      // Query subject information
      final subjectResponse = await _supabase
          .from('subjects')
          .select('id, name')
          .eq('id', subjectId)
          .maybeSingle();

      if (subjectResponse == null) {
        return null;
      }

      final subjectName = subjectResponse['name'] as String;

      // Convert grade data to Grade entities using DTO with validation
      final grades = _mapToGrades(
        List<Map<String, dynamic>>.from(gradesResponse),
      );

      // If no grades exist for this subject, return stats with empty grades
      final average = _calculateWeightedAverage(grades);

      // Get a consistent color for this subject based on its ID using SubjectColors utility
      final color = SubjectColors.getColorForId(subjectId);

      return SubjectGradeStats(
        subjectId: subjectId,
        subjectName: subjectName,
        subjectColor: color,
        average: average,
        grades: grades,
      );
    } on PostgrestException catch (e) {
      throw GradesException('Failed to fetch subject grades: ${e.message}');
    } catch (e) {
      if (e is GradesException) rethrow;
      throw GradesException('Failed to fetch subject grades: ${e.toString()}');
    }
  }

  /// Maps a database row to a [Grade] entity using DTO for safe parsing.
  ///
  /// The [data] map should contain the grade fields from the database.
  /// Uses [GradeDTO] for type-safe parsing with validation.
  /// Returns null and logs warning if the grade data is invalid.
  Grade? _mapToGrade(Map<String, dynamic> data) {
    final dto = GradeDTO.fromJson(data);

    if (!dto.isValid) {
      debugPrint('Warning: Invalid grade data received:');
      for (final error in dto.validationErrors) {
        debugPrint('  - $error');
      }
      debugPrint('  Raw data: $data');
      return null;
    }

    return dto.toEntity();
  }

  /// Maps a list of database rows to [Grade] entities, filtering invalid ones.
  ///
  /// Uses DTOs for safe parsing and logs warnings for invalid grades.
  List<Grade> _mapToGrades(List<Map<String, dynamic>> dataList) {
    final grades = <Grade>[];
    var invalidCount = 0;

    for (final data in dataList) {
      final grade = _mapToGrade(data);
      if (grade != null) {
        grades.add(grade);
      } else {
        invalidCount++;
      }
    }

    if (invalidCount > 0) {
      debugPrint(
        'Warning: $invalidCount invalid grade(s) were skipped during parsing',
      );
    }

    return grades;
  }

  /// Calculates the weighted average of a list of grades.
  ///
  /// Formula: sum(score * weight) / sum(weights)
  ///
  /// Returns 0.0 if the grades list is empty or total weight is zero.
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
}
