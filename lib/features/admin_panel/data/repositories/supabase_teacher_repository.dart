import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/domain.dart';

/// Exception thrown when teacher operations fail.
class TeacherException implements Exception {
  const TeacherException(this.message);

  final String message;

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

  /// Predefined colors for subjects based on hash of subject ID.
  static const List<Color> _subjectColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lime,
    Colors.deepPurple,
    Colors.brown,
  ];

  /// Generates a deterministic color for a subject based on its ID.
  Color _getSubjectColor(String subjectId) {
    final hash = subjectId.hashCode.abs();
    return _subjectColors[hash % _subjectColors.length];
  }

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
        // This queries the lessons table to count distinct class_ids
        int classCount = 0;
        try {
          final lessonsResponse = await _supabase
              .from('lessons')
              .select('class_id')
              .eq('subject_id', subjectId);

          // Count unique class_ids
          final uniqueClassIds = <String>{};
          for (final lesson in lessonsResponse) {
            final classId = lesson['class_id'] as String?;
            if (classId != null) {
              uniqueClassIds.add(classId);
            }
          }
          classCount = uniqueClassIds.length;
        } catch (_) {
          // If we can't get the class count, default to 0
          classCount = 0;
        }

        subjects.add(TeacherSubject(
          id: subjectId,
          name: name,
          description: description,
          color: _getSubjectColor(subjectId),
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
