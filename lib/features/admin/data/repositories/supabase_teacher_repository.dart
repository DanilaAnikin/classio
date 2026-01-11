import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/repositories/teacher_repository.dart';

/// Exception thrown when teacher operations fail.
class TeacherException implements Exception {
  const TeacherException(this.message);

  final String message;

  @override
  String toString() => 'TeacherException: $message';
}

/// Supabase implementation of [TeacherRepository].
///
/// Provides teacher-specific functionality using Supabase as the data source.
/// This includes operations for fetching subjects assigned to a teacher.
class SupabaseTeacherRepository implements TeacherRepository {
  /// Creates a [SupabaseTeacherRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  /// If not provided, uses the default Supabase instance.
  SupabaseTeacherRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// Default colors for subjects that don't have a specified color.
  static const List<Color> _subjectColors = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.red,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.pink,
    Colors.lime,
    Colors.brown,
  ];

  @override
  Future<List<Subject>> getMySubjects(String teacherId) async {
    try {
      final response = await _supabase
          .from('subjects')
          .select('id, name, description, teacher_id')
          .eq('teacher_id', teacherId)
          .order('name', ascending: true);

      var colorIndex = 0;
      return (response as List).map((json) {
        final data = json as Map<String, dynamic>;
        final color = _subjectColors[colorIndex % _subjectColors.length];
        colorIndex++;

        return Subject(
          id: data['id'] as String,
          name: data['name'] as String,
          color: color,
          teacherName: null, // Teacher is the current user
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw TeacherException('Failed to fetch teacher subjects: ${e.message}');
    } catch (e) {
      if (e is TeacherException) rethrow;
      throw TeacherException('Failed to fetch teacher subjects: ${e.toString()}');
    }
  }
}
