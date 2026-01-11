import 'dart:math';

import 'package:flutter/material.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../dashboard/domain/entities/subject.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/admin_repository.dart';

/// Mock implementation of [AdminRepository] for testing and development.
///
/// Provides realistic fake data for admin panel functionality including
/// schools, users, classes, subjects, and invite codes.
class MockAdminRepository implements AdminRepository {
  /// Creates a [MockAdminRepository] instance.
  MockAdminRepository() {
    _initializeMockData();
  }

  // Mock data storage
  late final List<School> _schools;
  late final List<AppUser> _users;
  late final List<ClassInfo> _classes;
  late final List<Subject> _subjects;
  late final List<InviteCode> _inviteCodes;

  /// Initializes all mock data.
  void _initializeMockData() {
    final now = DateTime.now();

    // Initialize schools
    _schools = [
      School(
        id: 'school-1',
        name: 'Springfield High School',
        createdAt: now.subtract(const Duration(days: 365)),
      ),
      School(
        id: 'school-2',
        name: 'Riverside Academy',
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      School(
        id: 'school-3',
        name: 'Oak Valley Elementary',
        createdAt: now.subtract(const Duration(days: 100)),
      ),
    ];

    // Initialize users
    _users = [
      AppUser(
        id: 'user-1',
        email: 'admin@springfield.edu',
        role: UserRole.admin,
        firstName: 'John',
        lastName: 'Smith',
        schoolId: 'school-1',
        createdAt: now.subtract(const Duration(days: 300)),
      ),
      AppUser(
        id: 'user-2',
        email: 'teacher1@springfield.edu',
        role: UserRole.teacher,
        firstName: 'Emily',
        lastName: 'Johnson',
        schoolId: 'school-1',
        createdAt: now.subtract(const Duration(days: 250)),
      ),
      AppUser(
        id: 'user-3',
        email: 'teacher2@springfield.edu',
        role: UserRole.teacher,
        firstName: 'Michael',
        lastName: 'Brown',
        schoolId: 'school-1',
        createdAt: now.subtract(const Duration(days: 200)),
      ),
      AppUser(
        id: 'user-4',
        email: 'student1@springfield.edu',
        role: UserRole.student,
        firstName: 'Alice',
        lastName: 'Williams',
        schoolId: 'school-1',
        createdAt: now.subtract(const Duration(days: 150)),
      ),
      AppUser(
        id: 'user-5',
        email: 'student2@springfield.edu',
        role: UserRole.student,
        firstName: 'Bob',
        lastName: 'Davis',
        schoolId: 'school-1',
        createdAt: now.subtract(const Duration(days: 100)),
      ),
      AppUser(
        id: 'user-6',
        email: 'parent1@gmail.com',
        role: UserRole.parent,
        firstName: 'Sarah',
        lastName: 'Williams',
        schoolId: 'school-1',
        createdAt: now.subtract(const Duration(days: 140)),
      ),
      // Riverside Academy users
      AppUser(
        id: 'user-7',
        email: 'admin@riverside.edu',
        role: UserRole.admin,
        firstName: 'Robert',
        lastName: 'Miller',
        schoolId: 'school-2',
        createdAt: now.subtract(const Duration(days: 180)),
      ),
      AppUser(
        id: 'user-8',
        email: 'teacher@riverside.edu',
        role: UserRole.teacher,
        firstName: 'Jennifer',
        lastName: 'Wilson',
        schoolId: 'school-2',
        createdAt: now.subtract(const Duration(days: 160)),
      ),
    ];

    // Initialize classes
    _classes = [
      ClassInfo(
        id: 'class-1',
        schoolId: 'school-1',
        name: 'Class 1A',
        gradeLevel: 1,
        academicYear: '2024-2025',
        createdAt: now.subtract(const Duration(days: 300)),
      ),
      ClassInfo(
        id: 'class-2',
        schoolId: 'school-1',
        name: 'Class 1B',
        gradeLevel: 1,
        academicYear: '2024-2025',
        createdAt: now.subtract(const Duration(days: 300)),
      ),
      ClassInfo(
        id: 'class-3',
        schoolId: 'school-1',
        name: 'Class 2A',
        gradeLevel: 2,
        academicYear: '2024-2025',
        createdAt: now.subtract(const Duration(days: 280)),
      ),
      ClassInfo(
        id: 'class-4',
        schoolId: 'school-1',
        name: 'Class 3A',
        gradeLevel: 3,
        academicYear: '2024-2025',
        createdAt: now.subtract(const Duration(days: 260)),
      ),
      ClassInfo(
        id: 'class-5',
        schoolId: 'school-2',
        name: 'Grade 9A',
        gradeLevel: 9,
        academicYear: '2024-2025',
        createdAt: now.subtract(const Duration(days: 180)),
      ),
      ClassInfo(
        id: 'class-6',
        schoolId: 'school-2',
        name: 'Grade 10A',
        gradeLevel: 10,
        academicYear: '2024-2025',
        createdAt: now.subtract(const Duration(days: 180)),
      ),
    ];

    // Initialize subjects
    _subjects = [
      const Subject(
        id: 'subject-1',
        name: 'Mathematics',
        color: Colors.blue,
        teacherName: 'Emily Johnson',
      ),
      const Subject(
        id: 'subject-2',
        name: 'Physics',
        color: Colors.orange,
        teacherName: 'Emily Johnson',
      ),
      const Subject(
        id: 'subject-3',
        name: 'Chemistry',
        color: Colors.green,
        teacherName: 'Michael Brown',
      ),
      const Subject(
        id: 'subject-4',
        name: 'Biology',
        color: Colors.teal,
        teacherName: 'Michael Brown',
      ),
      const Subject(
        id: 'subject-5',
        name: 'English Literature',
        color: Colors.purple,
        teacherName: 'Jennifer Wilson',
      ),
    ];

    // Initialize invite codes
    _inviteCodes = [
      InviteCode(
        id: 'invite-1',
        code: 'TEACHER24',
        role: UserRole.teacher,
        schoolId: 'school-1',
        usageLimit: 5,
        timesUsed: 2,
        isActive: true,
        expiresAt: now.add(const Duration(days: 30)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      InviteCode(
        id: 'invite-2',
        code: 'STUDENT24',
        role: UserRole.student,
        schoolId: 'school-1',
        classId: 'class-1',
        usageLimit: 30,
        timesUsed: 15,
        isActive: true,
        expiresAt: now.add(const Duration(days: 60)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      InviteCode(
        id: 'invite-3',
        code: 'PARENT24',
        role: UserRole.parent,
        schoolId: 'school-1',
        usageLimit: 50,
        timesUsed: 20,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      InviteCode(
        id: 'invite-4',
        code: 'EXPIRED01',
        role: UserRole.student,
        schoolId: 'school-1',
        usageLimit: 10,
        timesUsed: 10,
        isActive: false,
        expiresAt: now.subtract(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 45)),
      ),
    ];
  }

  @override
  Future<List<School>> getSchools() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_schools);
  }

  @override
  Future<School> createSchool(String name) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newSchool = School(
      id: 'school-${_schools.length + 1}',
      name: name,
      createdAt: DateTime.now(),
    );

    _schools.add(newSchool);
    return newSchool;
  }

  @override
  Future<List<AppUser>> getSchoolUsers(String schoolId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _users.where((user) => user.schoolId == schoolId).toList();
  }

  @override
  Future<List<ClassInfo>> getSchoolClasses(String schoolId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _classes.where((cls) => cls.schoolId == schoolId).toList();
  }

  @override
  Future<ClassInfo> createClass({
    required String schoolId,
    required String name,
    required int gradeLevel,
    required String academicYear,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final newClass = ClassInfo(
      id: 'class-${_classes.length + 1}',
      schoolId: schoolId,
      name: name,
      gradeLevel: gradeLevel,
      academicYear: academicYear,
      createdAt: DateTime.now(),
    );

    _classes.add(newClass);
    return newClass;
  }

  @override
  Future<InviteCode> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final code = _generateRandomCode(8);
    final newInviteCode = InviteCode(
      id: 'invite-${_inviteCodes.length + 1}',
      code: code,
      role: role,
      schoolId: schoolId,
      classId: classId,
      usageLimit: usageLimit,
      timesUsed: 0,
      isActive: true,
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
    );

    _inviteCodes.add(newInviteCode);
    return newInviteCode;
  }

  @override
  Future<List<Subject>> getTeacherSubjects(String teacherId) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // For mock data, return subjects based on teacher
    if (teacherId == 'user-2') {
      // Emily Johnson
      return _subjects.where((s) => s.teacherName == 'Emily Johnson').toList();
    } else if (teacherId == 'user-3') {
      // Michael Brown
      return _subjects.where((s) => s.teacherName == 'Michael Brown').toList();
    } else if (teacherId == 'user-8') {
      // Jennifer Wilson
      return _subjects
          .where((s) => s.teacherName == 'Jennifer Wilson')
          .toList();
    }

    return [];
  }

  @override
  Future<List<InviteCode>> getSchoolInviteCodes(String schoolId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _inviteCodes.where((code) => code.schoolId == schoolId).toList();
  }

  @override
  Future<InviteCode> deactivateInviteCode(String codeId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _inviteCodes.indexWhere((code) => code.id == codeId);
    if (index == -1) {
      throw Exception('Invite code not found');
    }

    final updatedCode = _inviteCodes[index].copyWith(isActive: false);
    _inviteCodes[index] = updatedCode;
    return updatedCode;
  }

  @override
  Future<bool> deleteClass(String classId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _classes.indexWhere((cls) => cls.id == classId);
    if (index == -1) {
      return false;
    }

    _classes.removeAt(index);
    return true;
  }

  @override
  Future<AppUser> updateUserRole(String userId, UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _users.indexWhere((user) => user.id == userId);
    if (index == -1) {
      throw Exception('User not found');
    }

    final updatedUser = _users[index].copyWith(role: newRole);
    _users[index] = updatedUser;
    return updatedUser;
  }

  /// Generates a random alphanumeric code of the specified length.
  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }
}
