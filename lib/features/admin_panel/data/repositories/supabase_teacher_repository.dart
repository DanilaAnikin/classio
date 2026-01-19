import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../core/utils/subject_colors.dart';
import '../../domain/domain.dart';

/// Exception thrown when teacher operations fail.
class TeacherException extends RepositoryException {
  const TeacherException(super.message, {super.code, super.originalError});

  @override
  String toString() => 'TeacherException: $message';
}

/// Supabase implementation of [TeacherRepository].
///
/// Fetches teacher-specific data from the Supabase database including:
/// - Subjects taught by the teacher from the `subjects` table
/// - Class counts from the `lessons` table (unique classes per subject)
class SupabaseTeacherRepository implements TeacherRepository {
  /// Creates a [SupabaseTeacherRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseTeacherRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  @override
  Future<List<TeacherSubject>> getTeacherSubjects(String teacherId) async {
    try {
      // Fetch subjects where the teacher_id matches
      final response = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            description,
            class_id
          ''')
          .eq('teacher_id', teacherId)
          .order('name', ascending: true);

      final subjects = <TeacherSubject>[];

      for (final row in response) {
        final subjectId = row['id'] as String;
        final name = (row['name'] ?? 'Unknown Subject') as String;
        final description = row['description'] as String?;

        // Count unique classes where this subject is taught
        // Subjects have class_id directly (not lessons)
        int classCount = 0;
        try {
          // Each subject belongs to one class, so just check if class_id exists
          final classId = row['class_id'] as String?;
          classCount = classId != null ? 1 : 0;
        } catch (_) {
          // If we can't get the class count, default to 0
          classCount = 0;
        }

        subjects.add(TeacherSubject(
          id: subjectId,
          name: name,
          description: description,
          color: SubjectColors.getColorForId(subjectId),
          classCount: classCount,
        ));
      }

      return subjects;
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch teacher subjects: ${e.message}');
    }
  }

  @override
  Future<void> refreshTeacherData() async {
    // No caching implemented yet, but this method allows for future caching
  }
}
