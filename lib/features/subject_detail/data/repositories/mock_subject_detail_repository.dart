import 'package:flutter/material.dart';

import 'package:classio/features/dashboard/domain/entities/assignment.dart';
import 'package:classio/features/dashboard/domain/entities/subject.dart';
import '../../domain/domain.dart';

/// Mock implementation of [SubjectDetailRepository] for testing and development.
///
/// Provides realistic fake data for a subject's detail view including:
/// - Subject information (name, teacher, color)
/// - Course posts (announcements and assignments)
/// - Course materials (PDFs, links, videos)
/// - Assignments for the subject
class MockSubjectDetailRepository implements SubjectDetailRepository {
  /// Creates a [MockSubjectDetailRepository] instance.
  MockSubjectDetailRepository();

  @override
  Future<SubjectDetail> getSubjectDetail(String subjectId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data based on subject ID
    return _getMockSubjectDetail(subjectId);
  }

  /// Generates mock subject detail data based on the subject ID.
  SubjectDetail _getMockSubjectDetail(String subjectId) {
    final now = DateTime.now();

    // Get subject-specific data or use default
    final subjectData = _subjectDataMap[subjectId] ?? _defaultSubjectData;

    // Create Subject entity for assignments
    final subject = Subject(
      id: subjectId,
      name: subjectData['name'] as String,
      color: (subjectData['color'] as Color).toARGB32(),
      teacherName: subjectData['teacherName'] as String,
    );

    return SubjectDetail(
      subjectId: subjectId,
      subjectName: subject.name,
      subjectColor: Color(subject.color),
      teacherName: subject.teacherName!,
      posts: _getPostsForSubject(subjectId, now),
      materials: _getMaterialsForSubject(subjectId, now),
      assignments: _getAssignmentsForSubject(subject, now),
    );
  }

  /// Map of subject IDs to their configuration data.
  static final Map<String, Map<String, dynamic>> _subjectDataMap = {
    'math': {
      'name': 'Mathematics',
      'color': Colors.blue,
      'teacherName': 'Dr. Sarah Johnson',
    },
    'physics': {
      'name': 'Physics',
      'color': Colors.purple,
      'teacherName': 'Prof. Michael Chen',
    },
    'chemistry': {
      'name': 'Chemistry',
      'color': Colors.green,
      'teacherName': 'Dr. Emily Rodriguez',
    },
    'biology': {
      'name': 'Biology',
      'color': Colors.teal,
      'teacherName': 'Dr. James Wilson',
    },
    'english': {
      'name': 'English Literature',
      'color': Colors.orange,
      'teacherName': 'Ms. Rebecca Thompson',
    },
    'history': {
      'name': 'World History',
      'color': Colors.brown,
      'teacherName': 'Mr. David Martinez',
    },
  };

  /// Default subject data for unknown subject IDs.
  static final Map<String, dynamic> _defaultSubjectData = {
    'name': 'General Course',
    'color': Colors.grey,
    'teacherName': 'Staff Teacher',
  };

  /// Returns mock posts for a subject.
  List<CoursePost> _getPostsForSubject(String subjectId, DateTime now) {
    // Return subject-specific posts
    if (subjectId == 'math') {
      return [
        CoursePost(
          id: 'post-1',
          authorName: 'Dr. Sarah Johnson',
          content: 'Welcome to the new semester! Looking forward to exploring '
              'advanced mathematics with you all. We will cover calculus, '
              'linear algebra, and differential equations.',
          date: now.subtract(const Duration(days: 14)),
          type: CoursePostType.announcement,
        ),
        CoursePost(
          id: 'post-2',
          authorName: 'Dr. Sarah Johnson',
          content: 'Homework #3 - Due Friday: Complete problems 1-15 from '
              'Chapter 4 on integration techniques. Show all your work and '
              'include step-by-step solutions.',
          date: now.subtract(const Duration(days: 3)),
          type: CoursePostType.assignment,
        ),
        CoursePost(
          id: 'post-3',
          authorName: 'Dr. Sarah Johnson',
          content: 'Lab session rescheduled to Room 204 this Thursday at 2 PM. '
              'Please bring your graphing calculators and notebooks.',
          date: now.subtract(const Duration(days: 2)),
          type: CoursePostType.announcement,
        ),
        CoursePost(
          id: 'post-4',
          authorName: 'Dr. Sarah Johnson',
          content: 'Midterm exam next week on Tuesday at 10 AM. The exam will '
              'cover chapters 1-5. Review sessions scheduled for Monday '
              'afternoon at 3 PM in the main lecture hall.',
          date: now.subtract(const Duration(days: 1)),
          type: CoursePostType.announcement,
        ),
        CoursePost(
          id: 'post-5',
          authorName: 'Dr. Sarah Johnson',
          content: 'Project proposal deadline extended to next Friday due to '
              'popular request. Make sure to include all required sections: '
              'introduction, methodology, and expected results.',
          date: now.subtract(const Duration(hours: 12)),
          type: CoursePostType.assignment,
        ),
      ];
    } else if (subjectId == 'physics') {
      return [
        CoursePost(
          id: 'post-1',
          authorName: 'Prof. Michael Chen',
          content: 'Welcome to the new semester! This term we will explore '
              'classical mechanics, thermodynamics, and electromagnetism. '
              'Excited to have you all in class!',
          date: now.subtract(const Duration(days: 15)),
          type: CoursePostType.announcement,
        ),
        CoursePost(
          id: 'post-2',
          authorName: 'Prof. Michael Chen',
          content: 'Homework #3 - Due Friday: Solve problems 10-25 from the '
              'dynamics chapter. Remember to include free body diagrams and '
              'show all calculations.',
          date: now.subtract(const Duration(days: 4)),
          type: CoursePostType.assignment,
        ),
        CoursePost(
          id: 'post-3',
          authorName: 'Prof. Michael Chen',
          content: 'Lab session rescheduled to Room 204 next Tuesday. We will '
              'be conducting the pendulum experiment. Please review the lab '
              'manual before class.',
          date: now.subtract(const Duration(days: 3)),
          type: CoursePostType.announcement,
        ),
        CoursePost(
          id: 'post-4',
          authorName: 'Prof. Michael Chen',
          content: 'Midterm exam next week! The test will cover mechanics and '
              'energy conservation. Practice problems are available on the '
              'course website.',
          date: now.subtract(const Duration(days: 2)),
          type: CoursePostType.announcement,
        ),
        CoursePost(
          id: 'post-5',
          authorName: 'Prof. Michael Chen',
          content: 'Project proposal deadline extended to accommodate your '
              'requests. New deadline is next Monday. Include experimental '
              'design and expected outcomes.',
          date: now.subtract(const Duration(days: 1)),
          type: CoursePostType.assignment,
        ),
        CoursePost(
          id: 'post-6',
          authorName: 'Prof. Michael Chen',
          content: 'Great work on the recent lab reports! Keep up the '
              'excellent effort. Remember to cite all sources properly.',
          date: now.subtract(const Duration(hours: 6)),
          type: CoursePostType.announcement,
        ),
      ];
    }

    // Default posts for other subjects
    return [
      CoursePost(
        id: 'post-1',
        authorName: _subjectDataMap[subjectId]?['teacherName'] as String? ??
            'Teacher',
        content: 'Welcome to the new semester! Looking forward to a great '
            'academic year together.',
        date: now.subtract(const Duration(days: 14)),
        type: CoursePostType.announcement,
      ),
      CoursePost(
        id: 'post-2',
        authorName: _subjectDataMap[subjectId]?['teacherName'] as String? ??
            'Teacher',
        content: 'Homework #3 - Due Friday: Complete the assigned readings '
            'and prepare for class discussion.',
        date: now.subtract(const Duration(days: 3)),
        type: CoursePostType.assignment,
      ),
      CoursePost(
        id: 'post-3',
        authorName: _subjectDataMap[subjectId]?['teacherName'] as String? ??
            'Teacher',
        content: 'Lab session rescheduled to Room 204 next week. Please check '
            'the updated schedule on the course portal.',
        date: now.subtract(const Duration(days: 2)),
        type: CoursePostType.announcement,
      ),
      CoursePost(
        id: 'post-4',
        authorName: _subjectDataMap[subjectId]?['teacherName'] as String? ??
            'Teacher',
        content: 'Midterm exam next week. Review sessions will be held on '
            'Monday and Wednesday afternoons.',
        date: now.subtract(const Duration(days: 1)),
        type: CoursePostType.announcement,
      ),
      CoursePost(
        id: 'post-5',
        authorName: _subjectDataMap[subjectId]?['teacherName'] as String? ??
            'Teacher',
        content: 'Project proposal deadline extended by one week. Make sure '
            'to submit through the online portal.',
        date: now.subtract(const Duration(hours: 12)),
        type: CoursePostType.assignment,
      ),
    ];
  }

  /// Returns mock materials for a subject.
  List<CourseMaterial> _getMaterialsForSubject(String subjectId, DateTime now) {
    if (subjectId == 'math') {
      return [
        CourseMaterial(
          id: 'mat-1',
          title: 'Course Syllabus 2024.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/math/syllabus-2024.pdf',
          dateAdded: now.subtract(const Duration(days: 30)),
        ),
        CourseMaterial(
          id: 'mat-2',
          title: 'Lecture 1 - Introduction to Calculus.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/math/lecture-1-calculus.pdf',
          dateAdded: now.subtract(const Duration(days: 25)),
        ),
        CourseMaterial(
          id: 'mat-3',
          title: 'Lecture 2 - Derivatives Fundamentals.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/math/lecture-2-derivatives.pdf',
          dateAdded: now.subtract(const Duration(days: 20)),
        ),
        CourseMaterial(
          id: 'mat-4',
          title: 'Khan Academy - Calculus Resources',
          type: CourseMaterialType.link,
          url: 'https://www.khanacademy.org/math/calculus-1',
          dateAdded: now.subtract(const Duration(days: 15)),
        ),
        CourseMaterial(
          id: 'mat-5',
          title: 'Tutorial Video - Integration Techniques',
          type: CourseMaterialType.video,
          url: 'https://www.youtube.com/watch?v=integration-tutorial',
          dateAdded: now.subtract(const Duration(days: 10)),
        ),
        CourseMaterial(
          id: 'mat-6',
          title: 'Practice Problems Set - Chapter 4.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/math/practice-ch4.pdf',
          dateAdded: now.subtract(const Duration(days: 5)),
        ),
      ];
    } else if (subjectId == 'physics') {
      return [
        CourseMaterial(
          id: 'mat-1',
          title: 'Course Syllabus 2024.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/physics/syllabus-2024.pdf',
          dateAdded: now.subtract(const Duration(days: 30)),
        ),
        CourseMaterial(
          id: 'mat-2',
          title: 'Lecture 1 - Introduction to Mechanics.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/physics/lecture-1-mechanics.pdf',
          dateAdded: now.subtract(const Duration(days: 25)),
        ),
        CourseMaterial(
          id: 'mat-3',
          title: 'Lecture 2 - Newton\'s Laws of Motion.pdf',
          type: CourseMaterialType.pdf,
          url: 'https://example.com/physics/lecture-2-newtons-laws.pdf',
          dateAdded: now.subtract(const Duration(days: 20)),
        ),
        CourseMaterial(
          id: 'mat-4',
          title: 'Khan Academy - Physics Resources',
          type: CourseMaterialType.link,
          url: 'https://www.khanacademy.org/science/physics',
          dateAdded: now.subtract(const Duration(days: 15)),
        ),
        CourseMaterial(
          id: 'mat-5',
          title: 'Tutorial Video - Understanding Forces',
          type: CourseMaterialType.video,
          url: 'https://www.youtube.com/watch?v=forces-tutorial',
          dateAdded: now.subtract(const Duration(days: 10)),
        ),
      ];
    }

    // Default materials for other subjects
    return [
      CourseMaterial(
        id: 'mat-1',
        title: 'Course Syllabus 2024.pdf',
        type: CourseMaterialType.pdf,
        url: 'https://example.com/syllabus-2024.pdf',
        dateAdded: now.subtract(const Duration(days: 30)),
      ),
      CourseMaterial(
        id: 'mat-2',
        title: 'Lecture 1 - Introduction.pdf',
        type: CourseMaterialType.pdf,
        url: 'https://example.com/lecture-1.pdf',
        dateAdded: now.subtract(const Duration(days: 25)),
      ),
      CourseMaterial(
        id: 'mat-3',
        title: 'Lecture 2 - Fundamentals.pdf',
        type: CourseMaterialType.pdf,
        url: 'https://example.com/lecture-2.pdf',
        dateAdded: now.subtract(const Duration(days: 20)),
      ),
      CourseMaterial(
        id: 'mat-4',
        title: 'Khan Academy Resources',
        type: CourseMaterialType.link,
        url: 'https://www.khanacademy.org',
        dateAdded: now.subtract(const Duration(days: 15)),
      ),
      CourseMaterial(
        id: 'mat-5',
        title: 'Tutorial Video - Getting Started',
        type: CourseMaterialType.video,
        url: 'https://www.youtube.com/watch?v=getting-started',
        dateAdded: now.subtract(const Duration(days: 10)),
      ),
    ];
  }

  /// Returns mock assignments for a subject.
  List<Assignment> _getAssignmentsForSubject(Subject subject, DateTime now) {
    if (subject.id == 'math') {
      return [
        Assignment(
          id: 'assign-1',
          subject: subject,
          title: 'Chapter 1 Quiz',
          description: 'Complete the online quiz on derivatives and limits. '
              'Time limit: 45 minutes. Make sure you understand the concepts '
              'before starting.',
          dueDate: now.add(const Duration(days: 2)),
          isCompleted: false,
        ),
        Assignment(
          id: 'assign-2',
          subject: subject,
          title: 'Lab Report #1',
          description: 'Write a detailed lab report on the integration '
              'techniques experiment. Include all calculations, graphs, '
              'and a discussion of results.',
          dueDate: now.add(const Duration(days: 5)),
          isCompleted: false,
        ),
        Assignment(
          id: 'assign-3',
          subject: subject,
          title: 'Midterm Project',
          description: 'Research and present a real-world application of '
              'calculus in engineering or science. Minimum 5 pages, '
              'include references and examples.',
          dueDate: now.add(const Duration(days: 10)),
          isCompleted: false,
        ),
      ];
    } else if (subject.id == 'physics') {
      return [
        Assignment(
          id: 'assign-1',
          subject: subject,
          title: 'Chapter 1 Quiz',
          description: 'Online quiz covering mechanics fundamentals and '
              'Newton\'s laws. 30 questions, 60 minute time limit.',
          dueDate: now.add(const Duration(days: 2)),
          isCompleted: false,
        ),
        Assignment(
          id: 'assign-2',
          subject: subject,
          title: 'Lab Report #1',
          description: 'Complete lab report on the pendulum motion experiment. '
              'Include error analysis, graphs, and discussion of results. '
              'Minimum 3 pages.',
          dueDate: now.add(const Duration(days: 5)),
          isCompleted: false,
        ),
        Assignment(
          id: 'assign-3',
          subject: subject,
          title: 'Midterm Project',
          description: 'Design an experiment demonstrating conservation of '
              'energy. Submit proposal including materials needed, procedure, '
              'and expected results.',
          dueDate: now.add(const Duration(days: 10)),
          isCompleted: false,
        ),
        Assignment(
          id: 'assign-4',
          subject: subject,
          title: 'Problem Set #3',
          description: 'Solve all problems from chapter 5 on dynamics and '
              'circular motion. Show all work including free body diagrams.',
          dueDate: now.add(const Duration(days: 14)),
          isCompleted: false,
        ),
      ];
    }

    // Default assignments for other subjects
    return [
      Assignment(
        id: 'assign-1',
        subject: subject,
        title: 'Chapter 1 Quiz',
        description: 'Complete the quiz on the first chapter. Review your '
            'notes before starting.',
        dueDate: now.add(const Duration(days: 2)),
        isCompleted: false,
      ),
      Assignment(
        id: 'assign-2',
        subject: subject,
        title: 'Lab Report #1',
        description: 'Write up your findings from the first laboratory '
            'session. Include observations and conclusions.',
        dueDate: now.add(const Duration(days: 5)),
        isCompleted: false,
      ),
      Assignment(
        id: 'assign-3',
        subject: subject,
        title: 'Midterm Project',
        description: 'Complete the midterm project as described in class. '
            'Follow the rubric provided in the course materials.',
        dueDate: now.add(const Duration(days: 10)),
        isCompleted: false,
      ),
    ];
  }
}
