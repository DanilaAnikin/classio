import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/absence_excuse.dart';
import '../../domain/repositories/absence_excuse_repository.dart';

/// Exception thrown when absence excuse operations fail.
class AbsenceExcuseException implements Exception {
  const AbsenceExcuseException(this.message);

  final String message;

  @override
  String toString() => 'AbsenceExcuseException: $message';
}

/// Supabase implementation of [AbsenceExcuseRepository].
///
/// Provides CRUD operations for absence excuses using Supabase as the backend.
class SupabaseAbsenceExcuseRepository implements AbsenceExcuseRepository {
  /// Creates a [SupabaseAbsenceExcuseRepository] instance.
  SupabaseAbsenceExcuseRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  /// Gets the current user's ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Standard select query for excuses with joined data.
  static const String _selectQuery = '''
    id,
    attendance_id,
    student_id,
    parent_id,
    reason,
    status,
    teacher_response,
    teacher_id,
    created_at,
    updated_at,
    student:profiles!absence_excuses_student_id_fkey (
      first_name,
      last_name,
      avatar_url
    ),
    parent:profiles!absence_excuses_parent_id_fkey (
      first_name,
      last_name
    ),
    teacher:profiles!absence_excuses_teacher_id_fkey (
      first_name,
      last_name
    ),
    attendance (
      date,
      status,
      lessons (
        start_time,
        end_time,
        subjects (
          name
        )
      )
    )
  ''';

  // ============== Parent Operations ==============

  @override
  Future<AbsenceExcuse> submitExcuse({
    required String attendanceId,
    required String studentId,
    required String reason,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      final id = _uuid.v4();
      final now = DateTime.now();

      final data = {
        'id': id,
        'attendance_id': attendanceId,
        'student_id': studentId,
        'parent_id': userId,
        'reason': reason,
        'status': 'pending',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _supabase.from('absence_excuses').insert(data);

      // Fetch the created excuse with full data
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('id', id)
          .single();

      return AbsenceExcuse.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const AbsenceExcuseException(
          'An excuse for this attendance record already exists',
        );
      }
      throw AbsenceExcuseException('Failed to submit excuse: ${e.message}');
    }
  }

  @override
  Future<List<AbsenceExcuse>> getExcusesForChild(String childId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('student_id', childId)
          .eq('parent_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<AbsenceExcuse>((json) => AbsenceExcuse.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to fetch excuses: ${e.message}');
    }
  }

  @override
  Future<List<AbsenceExcuse>> getAllParentExcuses() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('parent_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<AbsenceExcuse>((json) => AbsenceExcuse.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to fetch excuses: ${e.message}');
    }
  }

  @override
  Future<List<AbsenceExcuse>> getPendingExcusesForChild(String childId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('student_id', childId)
          .eq('parent_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response
          .map<AbsenceExcuse>((json) => AbsenceExcuse.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException(
        'Failed to fetch pending excuses: ${e.message}',
      );
    }
  }

  @override
  Future<AbsenceExcuse?> getExcuseByAttendanceId(String attendanceId) async {
    try {
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('attendance_id', attendanceId)
          .maybeSingle();

      if (response == null) return null;
      return AbsenceExcuse.fromJson(response);
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to fetch excuse: ${e.message}');
    }
  }

  // ============== Teacher Operations ==============

  @override
  Future<List<AbsenceExcuse>> getPendingExcusesForTeacher() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      // Get teacher's subject IDs first
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('teacher_id', userId);

      if (subjectsResponse.isEmpty) return [];

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      // Get lessons for those subjects
      final lessonsResponse = await _supabase
          .from('lessons')
          .select('id')
          .inFilter('subject_id', subjectIds);

      if (lessonsResponse.isEmpty) return [];

      final lessonIds = lessonsResponse.map((l) => l['id'] as String).toList();

      // Get attendance IDs for those lessons
      final attendanceResponse = await _supabase
          .from('attendance')
          .select('id')
          .inFilter('lesson_id', lessonIds);

      if (attendanceResponse.isEmpty) return [];

      final attendanceIds =
          attendanceResponse.map((a) => a['id'] as String).toList();

      // Get pending excuses for those attendance records
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .inFilter('attendance_id', attendanceIds)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return response
          .map<AbsenceExcuse>((json) => AbsenceExcuse.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException(
        'Failed to fetch pending excuses: ${e.message}',
      );
    }
  }

  @override
  Future<List<AbsenceExcuse>> getAllExcusesForTeacher() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      // Get teacher's subject IDs first
      final subjectsResponse = await _supabase
          .from('subjects')
          .select('id')
          .eq('teacher_id', userId);

      if (subjectsResponse.isEmpty) return [];

      final subjectIds =
          subjectsResponse.map((s) => s['id'] as String).toList();

      // Get lessons for those subjects
      final lessonsResponse = await _supabase
          .from('lessons')
          .select('id')
          .inFilter('subject_id', subjectIds);

      if (lessonsResponse.isEmpty) return [];

      final lessonIds = lessonsResponse.map((l) => l['id'] as String).toList();

      // Get attendance IDs for those lessons
      final attendanceResponse = await _supabase
          .from('attendance')
          .select('id')
          .inFilter('lesson_id', lessonIds);

      if (attendanceResponse.isEmpty) return [];

      final attendanceIds =
          attendanceResponse.map((a) => a['id'] as String).toList();

      // Get all excuses for those attendance records
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .inFilter('attendance_id', attendanceIds)
          .order('created_at', ascending: false);

      return response
          .map<AbsenceExcuse>((json) => AbsenceExcuse.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to fetch excuses: ${e.message}');
    }
  }

  @override
  Future<AbsenceExcuse> approveExcuse(String excuseId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      await _supabase
          .from('absence_excuses')
          .update({
            'status': 'approved',
            'teacher_id': userId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', excuseId);

      // Also update the attendance record to mark as excused
      final excuse = await getExcuseById(excuseId);
      if (excuse != null) {
        await _supabase
            .from('attendance')
            .update({
              'status': 'excused',
              'excuse_status': 'approved',
            })
            .eq('id', excuse.attendanceId);
      }

      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('id', excuseId)
          .single();

      return AbsenceExcuse.fromJson(response);
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to approve excuse: ${e.message}');
    }
  }

  @override
  Future<AbsenceExcuse> declineExcuse(String excuseId, {String? response}) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      await _supabase
          .from('absence_excuses')
          .update({
            'status': 'declined',
            'teacher_id': userId,
            'teacher_response': response,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', excuseId);

      // Also update the attendance record
      final excuse = await getExcuseById(excuseId);
      if (excuse != null) {
        await _supabase
            .from('attendance')
            .update({
              'excuse_status': 'rejected',
            })
            .eq('id', excuse.attendanceId);
      }

      final result = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('id', excuseId)
          .single();

      return AbsenceExcuse.fromJson(result);
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to decline excuse: ${e.message}');
    }
  }

  // ============== Student Operations ==============

  @override
  Future<List<AbsenceExcuse>> getStudentExcuses() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw const AbsenceExcuseException('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('student_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<AbsenceExcuse>((json) => AbsenceExcuse.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to fetch excuses: ${e.message}');
    }
  }

  @override
  Future<AbsenceExcuse?> getExcuseById(String excuseId) async {
    try {
      final response = await _supabase
          .from('absence_excuses')
          .select(_selectQuery)
          .eq('id', excuseId)
          .maybeSingle();

      if (response == null) return null;
      return AbsenceExcuse.fromJson(response);
    } on PostgrestException catch (e) {
      throw AbsenceExcuseException('Failed to fetch excuse: ${e.message}');
    }
  }

  // ============== Utility ==============

  @override
  Future<void> refresh() async {
    // No cached data to clear in this implementation
  }
}
