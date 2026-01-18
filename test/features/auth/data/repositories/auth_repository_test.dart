import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    group('UserRole', () {
      test('should have correct role names', () {
        expect(UserRole.superadmin.name, 'superadmin');
        expect(UserRole.bigadmin.name, 'bigadmin');
        expect(UserRole.admin.name, 'admin');
        expect(UserRole.teacher.name, 'teacher');
        expect(UserRole.student.name, 'student');
        expect(UserRole.parent.name, 'parent');
      });

      test('fromString should parse valid role strings', () {
        expect(UserRole.fromString('superadmin'), UserRole.superadmin);
        expect(UserRole.fromString('teacher'), UserRole.teacher);
        expect(UserRole.fromString('student'), UserRole.student);
        expect(UserRole.fromString('parent'), UserRole.parent);
      });

      test('fromString should be case insensitive', () {
        expect(UserRole.fromString('TEACHER'), UserRole.teacher);
        expect(UserRole.fromString('Student'), UserRole.student);
        expect(UserRole.fromString('SUPERADMIN'), UserRole.superadmin);
      });

      test('fromString should return null for invalid strings', () {
        expect(UserRole.fromString('invalid'), isNull);
        expect(UserRole.fromString(''), isNull);
        expect(UserRole.fromString(null), isNull);
      });

      test('toJson should return role name', () {
        expect(UserRole.teacher.toJson(), 'teacher');
        expect(UserRole.student.toJson(), 'student');
        expect(UserRole.superadmin.toJson(), 'superadmin');
      });
    });

    group('AppUser entity', () {
      test('should create user with required fields', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
        );

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.role, UserRole.student);
      });

      test('should handle nullable fields', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
          lastName: 'Doe',
          schoolId: null,
          avatarUrl: null,
          createdAt: null,
        );

        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.schoolId, isNull);
        expect(user.avatarUrl, isNull);
        expect(user.createdAt, isNull);
      });

      test('should create user with all fields populated', () {
        final now = DateTime.now();
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
          lastName: 'Doe',
          schoolId: 'school-123',
          avatarUrl: 'https://example.com/avatar.jpg',
          createdAt: now,
        );

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.role, UserRole.teacher);
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.schoolId, 'school-123');
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.createdAt, now);
      });

      test('fullName should return formatted name with first and last name', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
          lastName: 'Doe',
        );

        expect(user.fullName, 'John Doe');
      });

      test('fullName should return first name only when last name is null', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
        );

        expect(user.fullName, 'John');
      });

      test('fullName should return last name only when first name is null', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          lastName: 'Doe',
        );

        expect(user.fullName, 'Doe');
      });

      test('fullName should return email when no names are provided', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );

        expect(user.fullName, 'test@example.com');
      });

      test('copyWith should create new instance with updated fields', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
          firstName: 'John',
        );

        final updated = user.copyWith(firstName: 'Jane');

        expect(updated.firstName, 'Jane');
        expect(updated.id, user.id);
        expect(updated.email, user.email);
        expect(updated.role, user.role);
      });

      test('copyWith should update multiple fields', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
          firstName: 'John',
        );

        final updated = user.copyWith(
          firstName: 'Jane',
          lastName: 'Smith',
          role: UserRole.teacher,
        );

        expect(updated.firstName, 'Jane');
        expect(updated.lastName, 'Smith');
        expect(updated.role, UserRole.teacher);
        expect(updated.id, user.id);
        expect(updated.email, user.email);
      });

      test('fromJson should parse valid JSON with all fields', () {
        final now = DateTime.now();
        final json = {
          'id': 'test-id',
          'email': 'test@example.com',
          'role': 'teacher',
          'first_name': 'John',
          'last_name': 'Doe',
          'school_id': 'school-123',
          'avatar_url': 'https://example.com/avatar.jpg',
          'created_at': now.toIso8601String(),
        };

        final user = AppUser.fromJson(json);

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.role, UserRole.teacher);
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.schoolId, 'school-123');
        expect(user.avatarUrl, 'https://example.com/avatar.jpg');
        expect(user.createdAt, isNotNull);
      });

      test('fromJson should parse JSON with only required fields', () {
        final json = {
          'id': 'test-id',
          'email': 'test@example.com',
          'role': 'student',
        };

        final user = AppUser.fromJson(json);

        expect(user.id, 'test-id');
        expect(user.email, 'test@example.com');
        expect(user.role, UserRole.student);
        expect(user.firstName, isNull);
        expect(user.lastName, isNull);
        expect(user.schoolId, isNull);
      });

      test('fromJson should throw on missing required fields', () {
        expect(
          () => AppUser.fromJson({'email': 'test@example.com'}),
          throwsArgumentError,
        );

        expect(
          () => AppUser.fromJson({'id': 'test-id'}),
          throwsArgumentError,
        );

        expect(
          () => AppUser.fromJson({'id': 'test-id', 'email': 'test@example.com'}),
          throwsArgumentError,
        );
      });

      test('fromJson should handle invalid createdAt gracefully', () {
        final json = {
          'id': 'test-id',
          'email': 'test@example.com',
          'role': 'teacher',
          'created_at': 'invalid-date',
        };

        final user = AppUser.fromJson(json);

        expect(user.id, 'test-id');
        expect(user.createdAt, isNull);
      });

      test('toJson should serialize to valid JSON with all fields', () {
        final now = DateTime.now();
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.admin,
          firstName: 'Jane',
          lastName: 'Smith',
          schoolId: 'school-456',
          avatarUrl: 'https://example.com/jane.jpg',
          createdAt: now,
        );

        final json = user.toJson();

        expect(json['id'], 'test-id');
        expect(json['email'], 'test@example.com');
        expect(json['role'], 'admin');
        expect(json['first_name'], 'Jane');
        expect(json['last_name'], 'Smith');
        expect(json['school_id'], 'school-456');
        expect(json['avatar_url'], 'https://example.com/jane.jpg');
        expect(json['created_at'], now.toIso8601String());
      });

      test('toJson should handle null fields', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
        );

        final json = user.toJson();

        expect(json['id'], 'test-id');
        expect(json['email'], 'test@example.com');
        expect(json['role'], 'student');
        expect(json['first_name'], isNull);
        expect(json['last_name'], isNull);
        expect(json['school_id'], isNull);
        expect(json['avatar_url'], isNull);
        expect(json['created_at'], isNull);
      });

      test('equality operator should work correctly', () {
        final user1 = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
        );

        final user2 = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
        );

        final user3 = AppUser(
          id: 'different-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
        );

        expect(user1, equals(user2));
        expect(user1, isNot(equals(user3)));
      });

      test('hashCode should be consistent', () {
        final user1 = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );

        final user2 = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );

        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('toString should return formatted string', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          firstName: 'John',
          lastName: 'Doe',
          schoolId: 'school-123',
        );

        final str = user.toString();

        expect(str, contains('test-id'));
        expect(str, contains('test@example.com'));
        expect(str, contains('teacher'));
        expect(str, contains('John'));
        expect(str, contains('Doe'));
        expect(str, contains('school-123'));
      });
    });

    group('Role permissions', () {
      test('isSuperAdmin should return true for superadmin', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );

        expect(user.isSuperAdmin, isTrue);
        expect(user.isBigAdmin, isFalse);
        expect(user.isAdmin, isFalse);
      });

      test('isBigAdmin should return true for bigadmin', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.bigadmin,
        );

        expect(user.isSuperAdmin, isFalse);
        expect(user.isBigAdmin, isTrue);
        expect(user.isAdmin, isFalse);
      });

      test('isAdmin should return true for admin', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.admin,
        );

        expect(user.isSuperAdmin, isFalse);
        expect(user.isBigAdmin, isFalse);
        expect(user.isAdmin, isTrue);
      });

      test('isTeacher should return true for teacher', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );

        expect(user.isTeacher, isTrue);
        expect(user.isStudent, isFalse);
        expect(user.isParent, isFalse);
      });

      test('isStudent should return true for student', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
        );

        expect(user.isStudent, isTrue);
        expect(user.isTeacher, isFalse);
        expect(user.isParent, isFalse);
      });

      test('isParent should return true for parent', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.parent,
        );

        expect(user.isParent, isTrue);
        expect(user.isStudent, isFalse);
        expect(user.isTeacher, isFalse);
      });

      test('hasAdminPrivileges should return true for admin roles', () {
        final superadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );
        final bigadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.bigadmin,
        );
        final admin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.admin,
        );
        final teacher = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );

        expect(superadmin.hasAdminPrivileges, isTrue);
        expect(bigadmin.hasAdminPrivileges, isTrue);
        expect(admin.hasAdminPrivileges, isTrue);
        expect(teacher.hasAdminPrivileges, isFalse);
      });

      test('canManageUsers should return true for admin roles', () {
        final superadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );
        final teacher = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );

        expect(superadmin.canManageUsers, isTrue);
        expect(teacher.canManageUsers, isFalse);
      });

      test('canManageClasses should include teachers', () {
        final teacher = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );
        final student = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
        );

        expect(teacher.canManageClasses, isTrue);
        expect(student.canManageClasses, isFalse);
      });

      test('canManageSchoolStaff should only return true for superadmin and bigadmin', () {
        final superadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );
        final bigadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.bigadmin,
        );
        final admin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.admin,
        );

        expect(superadmin.canManageSchoolStaff, isTrue);
        expect(bigadmin.canManageSchoolStaff, isTrue);
        expect(admin.canManageSchoolStaff, isFalse);
      });

      test('canAccessAllSchools should only return true for superadmin', () {
        final superadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );
        final bigadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.bigadmin,
        );

        expect(superadmin.canAccessAllSchools, isTrue);
        expect(bigadmin.canAccessAllSchools, isFalse);
      });

      test('belongsToSchool should return true for matching school ID', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
          schoolId: 'school-123',
        );

        expect(user.belongsToSchool('school-123'), isTrue);
        expect(user.belongsToSchool('school-456'), isFalse);
        expect(user.belongsToSchool(null), isFalse);
      });

      test('belongsToSchool should return true for superadmin regardless of school', () {
        final user = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );

        expect(user.belongsToSchool('school-123'), isTrue);
        expect(user.belongsToSchool('school-456'), isTrue);
      });

      test('hasRoleOrHigher should respect role hierarchy', () {
        final superadmin = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.superadmin,
        );
        final teacher = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.teacher,
        );
        final student = AppUser(
          id: 'test-id',
          email: 'test@example.com',
          role: UserRole.student,
        );

        // Superadmin has all roles
        expect(superadmin.hasRoleOrHigher(UserRole.superadmin), isTrue);
        expect(superadmin.hasRoleOrHigher(UserRole.bigadmin), isTrue);
        expect(superadmin.hasRoleOrHigher(UserRole.admin), isTrue);
        expect(superadmin.hasRoleOrHigher(UserRole.teacher), isTrue);
        expect(superadmin.hasRoleOrHigher(UserRole.student), isTrue);

        // Teacher has teacher and below
        expect(teacher.hasRoleOrHigher(UserRole.superadmin), isFalse);
        expect(teacher.hasRoleOrHigher(UserRole.bigadmin), isFalse);
        expect(teacher.hasRoleOrHigher(UserRole.admin), isFalse);
        expect(teacher.hasRoleOrHigher(UserRole.teacher), isTrue);
        expect(teacher.hasRoleOrHigher(UserRole.student), isTrue);

        // Student only has student level
        expect(student.hasRoleOrHigher(UserRole.teacher), isFalse);
        expect(student.hasRoleOrHigher(UserRole.student), isTrue);
        expect(student.hasRoleOrHigher(UserRole.parent), isTrue);
      });
    });
  });
}
