import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:classio/features/dashboard/domain/entities/assignment.dart';
import 'package:classio/features/dashboard/domain/entities/subject.dart';
import '../../domain/domain.dart';

/// Exception thrown when subject detail operations fail.
class SubjectDetailException implements Exception {
  const SubjectDetailException(this.message);

  final String message;

  @override
  String toString() => 'SubjectDetailException: $message';
}

/// Supabase implementation of [SubjectDetailRepository].
///
/// Queries real data from Supabase database including:
/// - Subject details from the `subjects` table
/// - Assignments from the `assignments` table
/// - Course materials from the `materials` table
/// - Teacher information from the `profiles` table
///
/// Also supports file uploads for assignment submissions using Supabase Storage.
class SupabaseSubjectDetailRepository implements SubjectDetailRepository {
  /// Creates a [SupabaseSubjectDetailRepository] instance.
  ///
  /// Optionally accepts a [SupabaseClient] for testing purposes.
  SupabaseSubjectDetailRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  /// The storage bucket name for course materials and submissions.
  static const String _storageBucket = 'classio-materials';

  /// Default subject color when none is specified.
  static const Color _defaultSubjectColor = Colors.blue;

  /// Map of subject names to their theme colors.
  /// This provides consistent colors for subjects across the app.
  static final Map<String, Color> _subjectColorMap = {
    'mathematics': Colors.blue,
    'math': Colors.blue,
    'physics': Colors.purple,
    'chemistry': Colors.green,
    'biology': Colors.teal,
    'english': Colors.orange,
    'history': Colors.brown,
    'geography': Colors.indigo,
    'art': Colors.pink,
    'music': Colors.amber,
    'science': Colors.cyan,
    'computer science': Colors.blueGrey,
    'programming': Colors.blueGrey,
  };

  @override
  Future<SubjectDetail> getSubjectDetail(String subjectId) async {
    try {
      // Fetch subject with teacher information
      final subjectResponse = await _supabase
          .from('subjects')
          .select('''
            id,
            name,
            description,
            teacher_id,
            created_at,
            profiles:teacher_id (
              id,
              first_name,
              last_name,
              avatar_url
            )
          ''')
          .eq('id', subjectId)
          .single();

      // Parse subject data
      final subjectName = subjectResponse['name'] as String? ?? 'Unknown Subject';
      final teacherProfile = subjectResponse['profiles'] as Map<String, dynamic>?;
      final teacherName = _formatTeacherName(teacherProfile);
      final subjectColor = _getSubjectColor(subjectName);

      // Fetch assignments, materials, and posts in parallel
      final results = await Future.wait([
        getAssignments(subjectId),
        getMaterials(subjectId),
        _getPosts(subjectId, teacherName, teacherProfile?['avatar_url'] as String?),
      ]);

      final assignments = results[0] as List<Assignment>;
      final materials = results[1] as List<CourseMaterial>;
      final posts = results[2] as List<CoursePost>;

      return SubjectDetail(
        subjectId: subjectId,
        subjectName: subjectName,
        subjectColor: subjectColor,
        teacherName: teacherName,
        posts: posts,
        materials: materials,
        assignments: assignments,
      );
    } on PostgrestException catch (e) {
      throw SubjectDetailException('Failed to fetch subject detail: ${e.message}');
    } catch (e) {
      if (e is SubjectDetailException) rethrow;
      throw SubjectDetailException('Failed to fetch subject detail: ${e.toString()}');
    }
  }

  /// Fetches assignments for a specific subject.
  ///
  /// Returns a list of [Assignment] objects filtered by the given [subjectId].
  /// Assignments are ordered by due date in ascending order.
  Future<List<Assignment>> getAssignments(String subjectId) async {
    try {
      // First, get the subject data for creating Subject entity
      final subjectResponse = await _supabase
          .from('subjects')
          .select('id, name, teacher_id, profiles:teacher_id(first_name, last_name)')
          .eq('id', subjectId)
          .single();

      final subjectName = subjectResponse['name'] as String? ?? 'Unknown Subject';
      final teacherProfile = subjectResponse['profiles'] as Map<String, dynamic>?;
      final teacherName = _formatTeacherName(teacherProfile);

      final subject = Subject(
        id: subjectId,
        name: subjectName,
        color: _getSubjectColor(subjectName).toARGB32(),
        teacherName: teacherName,
      );

      // Fetch assignments for this subject
      final assignmentsResponse = await _supabase
          .from('assignments')
          .select('id, title, description, due_date, max_score, created_at')
          .eq('subject_id', subjectId)
          .order('due_date', ascending: true);

      final assignments = <Assignment>[];

      for (final assignmentData in assignmentsResponse as List<dynamic>) {
        final data = assignmentData as Map<String, dynamic>;

        // Check if current user has submitted this assignment
        final isCompleted = await _checkAssignmentCompletion(data['id'] as String);

        assignments.add(Assignment(
          id: data['id'] as String,
          subject: subject,
          title: data['title'] as String? ?? 'Untitled Assignment',
          description: data['description'] as String?,
          dueDate: data['due_date'] != null
              ? DateTime.parse(data['due_date'] as String)
              : DateTime.now().add(const Duration(days: 7)),
          isCompleted: isCompleted,
        ));
      }

      return assignments;
    } on PostgrestException catch (e) {
      throw SubjectDetailException('Failed to fetch assignments: ${e.message}');
    } catch (e) {
      if (e is SubjectDetailException) rethrow;
      throw SubjectDetailException('Failed to fetch assignments: ${e.toString()}');
    }
  }

  /// Fetches course materials for a specific subject.
  ///
  /// Returns a list of [CourseMaterial] objects filtered by the given [subjectId].
  /// Materials are ordered by creation date in descending order (newest first).
  Future<List<CourseMaterial>> getMaterials(String subjectId) async {
    try {
      final materialsResponse = await _supabase
          .from('materials')
          .select('id, title, description, file_url, material_type, created_at')
          .eq('subject_id', subjectId)
          .order('created_at', ascending: false);

      final materials = <CourseMaterial>[];

      for (final materialData in materialsResponse as List<dynamic>) {
        final data = materialData as Map<String, dynamic>;

        materials.add(CourseMaterial(
          id: data['id'] as String,
          title: data['title'] as String? ?? 'Untitled Material',
          type: _parseMaterialType(data['material_type'] as String?),
          url: data['file_url'] as String? ?? '',
          dateAdded: data['created_at'] != null
              ? DateTime.parse(data['created_at'] as String)
              : DateTime.now(),
        ));
      }

      return materials;
    } on PostgrestException catch (e) {
      throw SubjectDetailException('Failed to fetch materials: ${e.message}');
    } catch (e) {
      if (e is SubjectDetailException) rethrow;
      throw SubjectDetailException('Failed to fetch materials: ${e.toString()}');
    }
  }

  /// Submits an assignment with a file upload.
  ///
  /// Uploads the file to Supabase Storage and creates a submission record
  /// in the `assignment_submissions` table.
  ///
  /// Parameters:
  /// - [assignmentId]: The ID of the assignment to submit to
  /// - [filePath]: The local file path of the file to upload
  /// - [fileName]: The name to use for the uploaded file
  ///
  /// Returns `true` if the submission was successful, `false` otherwise.
  ///
  /// Throws [SubjectDetailException] if:
  /// - The user is not authenticated
  /// - The file upload fails
  /// - The database insert fails
  Future<bool> submitAssignment({
    required String assignmentId,
    required String filePath,
    required String fileName,
  }) async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw const SubjectDetailException('User must be authenticated to submit assignments');
      }

      // Generate unique file path in storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'submissions/${user.id}/$assignmentId/${timestamp}_$fileName';

      // Upload file to Supabase Storage
      final file = File(filePath);
      if (!await file.exists()) {
        throw const SubjectDetailException('File not found');
      }

      final fileBytes = await file.readAsBytes();
      await _supabase.storage
          .from(_storageBucket)
          .uploadBinary(storagePath, fileBytes);

      // Get the public URL for the uploaded file
      final fileUrl = _supabase.storage
          .from(_storageBucket)
          .getPublicUrl(storagePath);

      // Create submission record in database
      await _supabase.from('assignment_submissions').insert({
        'assignment_id': assignmentId,
        'student_id': user.id,
        'file_url': fileUrl,
        'content': 'File submission: $fileName',
        'submitted_at': DateTime.now().toIso8601String(),
      });

      return true;
    } on StorageException catch (e) {
      throw SubjectDetailException('Failed to upload file: ${e.message}');
    } on PostgrestException catch (e) {
      throw SubjectDetailException('Failed to create submission: ${e.message}');
    } catch (e) {
      if (e is SubjectDetailException) rethrow;
      throw SubjectDetailException('Failed to submit assignment: ${e.toString()}');
    }
  }

  /// Fetches posts (announcements and assignment notifications) for a subject.
  ///
  /// This creates posts from assignments and could be extended to include
  /// actual announcements table if one exists.
  Future<List<CoursePost>> _getPosts(
    String subjectId,
    String teacherName,
    String? teacherAvatarUrl,
  ) async {
    try {
      // Fetch assignments to create assignment posts
      final assignmentsResponse = await _supabase
          .from('assignments')
          .select('id, title, description, created_at')
          .eq('subject_id', subjectId)
          .order('created_at', ascending: false)
          .limit(10);

      final posts = <CoursePost>[];

      for (final assignmentData in assignmentsResponse as List<dynamic>) {
        final data = assignmentData as Map<String, dynamic>;

        posts.add(CoursePost(
          id: 'assignment-${data['id']}',
          authorName: teacherName,
          authorAvatarUrl: teacherAvatarUrl,
          content: data['description'] as String? ??
              'New assignment: ${data['title']}',
          date: data['created_at'] != null
              ? DateTime.parse(data['created_at'] as String)
              : DateTime.now(),
          type: CoursePostType.assignment,
        ));
      }

      // Sort posts by date (newest first)
      posts.sort((a, b) => b.date.compareTo(a.date));

      return posts;
    } catch (e) {
      // Return empty list if posts cannot be fetched
      return [];
    }
  }

  /// Checks if the current user has completed (submitted) an assignment.
  Future<bool> _checkAssignmentCompletion(String assignmentId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('assignment_submissions')
          .select('id')
          .eq('assignment_id', assignmentId)
          .eq('student_id', user.id)
          .limit(1);

      return (response as List<dynamic>).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Formats teacher name from profile data.
  String _formatTeacherName(Map<String, dynamic>? profile) {
    if (profile == null) return 'Unknown Teacher';

    final firstName = profile['first_name'] as String?;
    final lastName = profile['last_name'] as String?;

    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName;
    } else if (lastName != null) {
      return lastName;
    }

    return 'Unknown Teacher';
  }

  /// Gets the theme color for a subject based on its name.
  Color _getSubjectColor(String subjectName) {
    final normalizedName = subjectName.toLowerCase().trim();

    // Check for exact match
    if (_subjectColorMap.containsKey(normalizedName)) {
      return _subjectColorMap[normalizedName]!;
    }

    // Check for partial match
    for (final entry in _subjectColorMap.entries) {
      if (normalizedName.contains(entry.key) ||
          entry.key.contains(normalizedName)) {
        return entry.value;
      }
    }

    return _defaultSubjectColor;
  }

  /// Parses material type string to [CourseMaterialType] enum.
  CourseMaterialType _parseMaterialType(String? typeString) {
    if (typeString == null) return CourseMaterialType.pdf;

    final normalizedType = typeString.toLowerCase().trim();

    switch (normalizedType) {
      case 'pdf':
      case 'document':
      case 'file':
        return CourseMaterialType.pdf;
      case 'link':
      case 'url':
      case 'website':
        return CourseMaterialType.link;
      case 'video':
      case 'youtube':
      case 'vimeo':
        return CourseMaterialType.video;
      default:
        // Try to guess from file extension in the type string
        if (normalizedType.endsWith('.pdf')) {
          return CourseMaterialType.pdf;
        } else if (normalizedType.contains('video') ||
            normalizedType.contains('mp4') ||
            normalizedType.contains('youtube')) {
          return CourseMaterialType.video;
        } else if (normalizedType.startsWith('http')) {
          return CourseMaterialType.link;
        }
        return CourseMaterialType.pdf;
    }
  }
}
