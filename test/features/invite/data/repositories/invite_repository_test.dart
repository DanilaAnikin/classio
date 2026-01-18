import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/invite/domain/entities/invite_token.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';

void main() {
  group('Token Generation', () {
    // This is a helper function that mimics the repository's token generation
    String generateTokenString() {
      const chars =
          'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
      final random = Random.secure();
      return List.generate(16, (_) => chars[random.nextInt(chars.length)])
          .join();
    }

    test('generates token of correct length (16 characters)', () {
      final token = generateTokenString();

      expect(token.length, 16);
    });

    test('generates unique tokens on each call', () {
      final tokens = <String>{};

      // Generate 100 tokens and verify all are unique
      for (var i = 0; i < 100; i++) {
        tokens.add(generateTokenString());
      }

      expect(tokens.length, 100);
    });

    test('token contains only alphanumeric characters', () {
      final token = generateTokenString();

      final alphanumericPattern = RegExp(r'^[A-Za-z0-9]+$');
      expect(alphanumericPattern.hasMatch(token), isTrue);
    });

    test('token distribution includes uppercase, lowercase, and digits', () {
      // Generate many tokens and check character distribution
      final allChars = StringBuffer();
      for (var i = 0; i < 50; i++) {
        allChars.write(generateTokenString());
      }
      final combined = allChars.toString();

      // Check presence of each character class
      expect(combined.contains(RegExp(r'[A-Z]')), isTrue);
      expect(combined.contains(RegExp(r'[a-z]')), isTrue);
      expect(combined.contains(RegExp(r'[0-9]')), isTrue);
    });
  });

  group('InviteToken Entity', () {
    test('creates with all required fields', () {
      final token = InviteToken(
        token: 'ABC123DEF456GHI7',
        role: UserRole.teacher,
        schoolId: 'school-1',
        createdByUserId: 'user-1',
        timesUsed: 0,
        usageLimit: 1,
        createdAt: DateTime.now(),
      );

      expect(token.token, 'ABC123DEF456GHI7');
      expect(token.role, UserRole.teacher);
      expect(token.schoolId, 'school-1');
      expect(token.isUsed, isFalse);
      expect(token.isActive, isTrue);
    });

    test('correctly identifies expired token', () {
      final expiredToken = InviteToken(
        token: 'EXPIRED123456789',
        role: UserRole.student,
        schoolId: 'school-1',
        createdByUserId: 'user-1',
        timesUsed: 0,
        usageLimit: 1,
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      );

      expect(expiredToken.isExpired, isTrue);
      expect(expiredToken.isValid, isFalse);
    });

    test('correctly identifies valid token', () {
      final validToken = InviteToken(
        token: 'VALID1234567890A',
        role: UserRole.student,
        schoolId: 'school-1',
        createdByUserId: 'user-1',
        timesUsed: 0,
        usageLimit: 1,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );

      expect(validToken.isExpired, isFalse);
      expect(validToken.isValid, isTrue);
    });

    test('token without expiration is not expired', () {
      final tokenWithoutExpiry = InviteToken(
        token: 'NOEXPIRY12345678',
        role: UserRole.teacher,
        schoolId: 'school-1',
        createdByUserId: 'user-1',
        timesUsed: 0,
        usageLimit: 1,
        expiresAt: null,
        createdAt: DateTime.now(),
      );

      expect(tokenWithoutExpiry.isExpired, isFalse);
      expect(tokenWithoutExpiry.isValid, isTrue);
    });

    test('used token is not valid even if not expired', () {
      final usedToken = InviteToken(
        token: 'USED123456789012',
        role: UserRole.student,
        schoolId: 'school-1',
        createdByUserId: 'user-1',
        timesUsed: 1,
        usageLimit: 1,
        expiresAt: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
      );

      expect(usedToken.isExpired, isFalse);
      expect(usedToken.isUsed, isTrue);
      expect(usedToken.isActive, isFalse);
      expect(usedToken.isValid, isFalse);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'token': 'TEST123456789012',
        'role': 'teacher',
        'school_id': 'school-123',
        'created_by_user_id': 'user-456',
        'specific_class_id': 'class-789',
        'times_used': 0,
        'usage_limit': 1,
        'expires_at': '2026-01-20T10:00:00Z',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final token = InviteToken.fromJson(json);

      expect(token.token, 'TEST123456789012');
      expect(token.role, UserRole.teacher);
      expect(token.schoolId, 'school-123');
      expect(token.createdByUserId, 'user-456');
      expect(token.specificClassId, 'class-789');
      expect(token.timesUsed, 0);
      expect(token.usageLimit, 1);
      expect(token.isUsed, isFalse);
      expect(token.isActive, isTrue);
      expect(token.expiresAt, DateTime.utc(2026, 1, 20, 10, 0, 0));
      expect(token.createdAt, DateTime.utc(2026, 1, 13, 10, 0, 0));
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'token': 'TEST123456789012',
        'role': 'student',
        'school_id': null,
        'created_by_user_id': null,
        'times_used': 0,
        'usage_limit': 1,
        'created_at': '2026-01-13T10:00:00Z',
      };

      final token = InviteToken.fromJson(json);

      expect(token.token, 'TEST123456789012');
      expect(token.role, UserRole.student);
      expect(token.schoolId, isNull);
      expect(token.createdByUserId, isNull);
      expect(token.specificClassId, isNull);
      expect(token.expiresAt, isNull);
    });

    test('fromJson throws ArgumentError for missing required fields', () {
      final invalidJson = {
        'token': 'TEST123456789012',
        // missing role, times_used, usage_limit, created_at
      };

      expect(
        () => InviteToken.fromJson(invalidJson),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromJson throws ArgumentError for missing token', () {
      final invalidJson = {
        'role': 'teacher',
        'times_used': 0,
        'usage_limit': 1,
        'created_at': '2026-01-13T10:00:00Z',
      };

      expect(
        () => InviteToken.fromJson(invalidJson),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromJson throws ArgumentError for invalid created_at format', () {
      final invalidJson = {
        'token': 'TEST123456789012',
        'role': 'teacher',
        'times_used': 0,
        'usage_limit': 1,
        'created_at': 'not-a-valid-date',
      };

      expect(
        () => InviteToken.fromJson(invalidJson),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('fromJson handles invalid expires_at format gracefully', () {
      final json = {
        'token': 'TEST123456789012',
        'role': 'teacher',
        'school_id': 'school-1',
        'times_used': 0,
        'usage_limit': 1,
        'expires_at': 'not-a-valid-date',
        'created_at': '2026-01-13T10:00:00Z',
      };

      final token = InviteToken.fromJson(json);

      expect(token.expiresAt, isNull);
    });

    test('toJson produces valid JSON', () {
      final original = InviteToken(
        token: 'TEST123456789012',
        role: UserRole.teacher,
        schoolId: 'school-123',
        createdByUserId: 'user-456',
        specificClassId: 'class-789',
        timesUsed: 0,
        usageLimit: 1,
        expiresAt: DateTime.utc(2026, 1, 20, 10, 0, 0),
        createdAt: DateTime.utc(2026, 1, 13, 10, 0, 0),
      );

      final json = original.toJson();

      expect(json['token'], 'TEST123456789012');
      expect(json['role'], 'teacher');
      expect(json['school_id'], 'school-123');
      expect(json['created_by_user_id'], 'user-456');
      expect(json['specific_class_id'], 'class-789');
      expect(json['times_used'], 0);
      expect(json['usage_limit'], 1);
      expect(json['expires_at'], '2026-01-20T10:00:00.000Z');
      expect(json['created_at'], '2026-01-13T10:00:00.000Z');
    });

    test('toJson handles null optional fields', () {
      final token = InviteToken(
        token: 'TEST123456789012',
        role: UserRole.superadmin,
        schoolId: null,
        createdByUserId: null,
        timesUsed: 0,
        usageLimit: 1,
        createdAt: DateTime.utc(2026, 1, 13, 10, 0, 0),
      );

      final json = token.toJson();

      expect(json['school_id'], isNull);
      expect(json['created_by_user_id'], isNull);
      expect(json['specific_class_id'], isNull);
      expect(json['expires_at'], isNull);
    });

    test('copyWith creates a new instance with updated fields', () {
      final original = InviteToken(
        token: 'TEST123456789012',
        role: UserRole.teacher,
        schoolId: 'school-123',
        createdByUserId: 'user-456',
        timesUsed: 0,
        usageLimit: 1,
        createdAt: DateTime.utc(2026, 1, 13, 10, 0, 0),
      );

      final updated = original.copyWith(timesUsed: 1);

      expect(updated.token, original.token);
      expect(updated.role, original.role);
      expect(updated.timesUsed, 1);
      expect(updated.isUsed, isTrue);
      expect(original.timesUsed, 0);
      expect(original.isUsed, isFalse); // Original unchanged
    });

    test('equality compares all fields', () {
      final createdAt = DateTime.utc(2026, 1, 13, 10, 0, 0);

      final token1 = InviteToken(
        token: 'TEST123456789012',
        role: UserRole.teacher,
        schoolId: 'school-123',
        createdByUserId: 'user-456',
        timesUsed: 0,
        usageLimit: 1,
        createdAt: createdAt,
      );

      final token2 = InviteToken(
        token: 'TEST123456789012',
        role: UserRole.teacher,
        schoolId: 'school-123',
        createdByUserId: 'user-456',
        timesUsed: 0,
        usageLimit: 1,
        createdAt: createdAt,
      );

      final token3 = InviteToken(
        token: 'DIFFERENT1234567',
        role: UserRole.teacher,
        schoolId: 'school-123',
        createdByUserId: 'user-456',
        timesUsed: 0,
        usageLimit: 1,
        createdAt: createdAt,
      );

      expect(token1, equals(token2));
      expect(token1, isNot(equals(token3)));
    });
  });

  group('Invite Permission Logic', () {
    // Test the hierarchical permission logic that would be in the repository
    bool canGenerateInviteFor(UserRole creatorRole, UserRole targetRole) {
      switch (creatorRole) {
        case UserRole.superadmin:
          return targetRole == UserRole.bigadmin;
        case UserRole.bigadmin:
          return [UserRole.admin, UserRole.teacher].contains(targetRole);
        case UserRole.admin:
          return [UserRole.teacher, UserRole.parent].contains(targetRole);
        case UserRole.teacher:
          return targetRole == UserRole.student;
        case UserRole.student:
        case UserRole.parent:
          return false;
      }
    }

    List<UserRole> getInvitableRoles(UserRole creatorRole) {
      switch (creatorRole) {
        case UserRole.superadmin:
          return [UserRole.bigadmin];
        case UserRole.bigadmin:
          return [UserRole.admin, UserRole.teacher];
        case UserRole.admin:
          return [UserRole.teacher, UserRole.parent];
        case UserRole.teacher:
          return [UserRole.student];
        case UserRole.student:
        case UserRole.parent:
          return [];
      }
    }

    test('superadmin can only invite bigadmin', () {
      expect(canGenerateInviteFor(UserRole.superadmin, UserRole.bigadmin), isTrue);
      expect(canGenerateInviteFor(UserRole.superadmin, UserRole.admin), isFalse);
      expect(canGenerateInviteFor(UserRole.superadmin, UserRole.teacher), isFalse);
      expect(canGenerateInviteFor(UserRole.superadmin, UserRole.student), isFalse);
      expect(canGenerateInviteFor(UserRole.superadmin, UserRole.parent), isFalse);
    });

    test('bigadmin can invite admin and teacher', () {
      expect(canGenerateInviteFor(UserRole.bigadmin, UserRole.admin), isTrue);
      expect(canGenerateInviteFor(UserRole.bigadmin, UserRole.teacher), isTrue);
      expect(canGenerateInviteFor(UserRole.bigadmin, UserRole.bigadmin), isFalse);
      expect(canGenerateInviteFor(UserRole.bigadmin, UserRole.student), isFalse);
      expect(canGenerateInviteFor(UserRole.bigadmin, UserRole.parent), isFalse);
    });

    test('admin can invite teacher and parent', () {
      expect(canGenerateInviteFor(UserRole.admin, UserRole.teacher), isTrue);
      expect(canGenerateInviteFor(UserRole.admin, UserRole.parent), isTrue);
      expect(canGenerateInviteFor(UserRole.admin, UserRole.admin), isFalse);
      expect(canGenerateInviteFor(UserRole.admin, UserRole.student), isFalse);
      expect(canGenerateInviteFor(UserRole.admin, UserRole.bigadmin), isFalse);
    });

    test('teacher can only invite student', () {
      expect(canGenerateInviteFor(UserRole.teacher, UserRole.student), isTrue);
      expect(canGenerateInviteFor(UserRole.teacher, UserRole.teacher), isFalse);
      expect(canGenerateInviteFor(UserRole.teacher, UserRole.parent), isFalse);
      expect(canGenerateInviteFor(UserRole.teacher, UserRole.admin), isFalse);
    });

    test('student cannot invite anyone', () {
      expect(canGenerateInviteFor(UserRole.student, UserRole.student), isFalse);
      expect(canGenerateInviteFor(UserRole.student, UserRole.teacher), isFalse);
      expect(canGenerateInviteFor(UserRole.student, UserRole.parent), isFalse);
    });

    test('parent cannot invite anyone', () {
      expect(canGenerateInviteFor(UserRole.parent, UserRole.student), isFalse);
      expect(canGenerateInviteFor(UserRole.parent, UserRole.teacher), isFalse);
      expect(canGenerateInviteFor(UserRole.parent, UserRole.parent), isFalse);
    });

    test('getInvitableRoles returns correct roles for each creator', () {
      expect(getInvitableRoles(UserRole.superadmin), [UserRole.bigadmin]);
      expect(getInvitableRoles(UserRole.bigadmin), [UserRole.admin, UserRole.teacher]);
      expect(getInvitableRoles(UserRole.admin), [UserRole.teacher, UserRole.parent]);
      expect(getInvitableRoles(UserRole.teacher), [UserRole.student]);
      expect(getInvitableRoles(UserRole.student), isEmpty);
      expect(getInvitableRoles(UserRole.parent), isEmpty);
    });
  });

  group('UserRole parsing', () {
    test('fromString parses all valid roles', () {
      expect(UserRole.fromString('superadmin'), UserRole.superadmin);
      expect(UserRole.fromString('bigadmin'), UserRole.bigadmin);
      expect(UserRole.fromString('admin'), UserRole.admin);
      expect(UserRole.fromString('teacher'), UserRole.teacher);
      expect(UserRole.fromString('student'), UserRole.student);
      expect(UserRole.fromString('parent'), UserRole.parent);
    });

    test('fromString is case insensitive', () {
      expect(UserRole.fromString('SUPERADMIN'), UserRole.superadmin);
      expect(UserRole.fromString('Teacher'), UserRole.teacher);
      expect(UserRole.fromString('STUDENT'), UserRole.student);
    });

    test('fromString returns null for invalid role', () {
      expect(UserRole.fromString('invalid'), isNull);
      expect(UserRole.fromString(''), isNull);
      expect(UserRole.fromString(null), isNull);
    });

    test('toJson returns correct string', () {
      expect(UserRole.superadmin.toJson(), 'superadmin');
      expect(UserRole.bigadmin.toJson(), 'bigadmin');
      expect(UserRole.admin.toJson(), 'admin');
      expect(UserRole.teacher.toJson(), 'teacher');
      expect(UserRole.student.toJson(), 'student');
      expect(UserRole.parent.toJson(), 'parent');
    });
  });
}
