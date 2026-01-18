import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';

/// Tests for SupabaseAuthRepository validation logic and AppUser entity.
///
/// Since the validation methods (_validatePasswordStrength, _isValidEmail)
/// are private in SupabaseAuthRepository, we test the validation logic
/// by replicating it here for unit testing purposes.
///
/// Additionally, we test the AppUser entity's handling of optional email.
void main() {
  // Replicated validation functions for testing
  // These mirror the private methods in SupabaseAuthRepository

  /// Validates email format using the same regex as SupabaseAuthRepository.
  bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates password strength using the same logic as SupabaseAuthRepository.
  ///
  /// Password requirements:
  /// - Minimum 12 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  /// - At least one special character (!@#$%^&*(),.?":{}|<>)
  ///
  /// Returns null if password is valid, otherwise returns an error message.
  String? validatePasswordStrength(String password) {
    if (password.isEmpty) {
      return 'Password cannot be empty';
    }
    if (password.length < 12) {
      return 'Password must be at least 12 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character (!@#\$%^&*(),.?":{}|<>)';
    }
    return null; // Password is valid
  }

  group('Password Validation', () {
    test('rejects empty password', () {
      final result = validatePasswordStrength('');
      expect(result, isNotNull);
      expect(result, 'Password cannot be empty');
    });

    test('rejects password shorter than 12 characters', () {
      // Password: "Short1!" (7 chars) should fail
      final result = validatePasswordStrength('Short1!');
      expect(result, isNotNull);
      expect(result, 'Password must be at least 12 characters');
    });

    test('rejects password with exactly 11 characters', () {
      // Password: "Abcdefgh1!" (10 chars) should fail
      final result = validatePasswordStrength('Abcdefgh1!A');
      expect(result, isNotNull);
      expect(result, 'Password must be at least 12 characters');
    });

    test('rejects password without uppercase letter', () {
      // Password: "alllowercase123!" should fail
      final result = validatePasswordStrength('alllowercase123!');
      expect(result, isNotNull);
      expect(result, 'Password must contain at least one uppercase letter');
    });

    test('rejects password without lowercase letter', () {
      // Password: "ALLUPPERCASE123!" should fail
      final result = validatePasswordStrength('ALLUPPERCASE123!');
      expect(result, isNotNull);
      expect(result, 'Password must contain at least one lowercase letter');
    });

    test('rejects password without number', () {
      // Password: "NoNumbersHere!" should fail
      final result = validatePasswordStrength('NoNumbersHere!!');
      expect(result, isNotNull);
      expect(result, 'Password must contain at least one number');
    });

    test('rejects password without special character', () {
      // Password: "NoSpecialChar123" should fail
      final result = validatePasswordStrength('NoSpecialChar123');
      expect(result, isNotNull);
      expect(result, contains('special character'));
    });

    test('accepts valid strong password', () {
      // Password: "ValidP@ssw0rd123" should pass validation
      final result = validatePasswordStrength('ValidP@ssw0rd123');
      expect(result, isNull);
    });

    test('accepts password with exactly 12 characters', () {
      // Password: "Abcdefgh1!Ab" (12 chars) should pass
      final result = validatePasswordStrength('Abcdefgh1!Ab');
      expect(result, isNull);
    });

    test('accepts password with various special characters', () {
      expect(validatePasswordStrength('ValidP@ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP#ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP\$ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP%ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP^ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP&ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP*ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP(ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP)ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP,ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP.ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP?ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP"ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP:ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP{ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP}ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP|ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP<ssw0rd'), isNull);
      expect(validatePasswordStrength('ValidP>ssw0rd'), isNull);
    });

    test('rejects password with only whitespace', () {
      final result = validatePasswordStrength('            ');
      expect(result, isNotNull);
      // Will fail on uppercase requirement since whitespace has none
      expect(result, 'Password must contain at least one uppercase letter');
    });

    test('rejects password with unrecognized special characters', () {
      // Using backtick, tilde, and other characters not in the allowed set
      final result = validatePasswordStrength('ValidPassword1~');
      expect(result, isNotNull);
      expect(result, contains('special character'));
    });
  });

  group('Email Validation', () {
    test('rejects empty email', () {
      final result = isValidEmail('');
      expect(result, isFalse);
    });

    test('rejects invalid email format - missing @', () {
      final result = isValidEmail('invalidemail.com');
      expect(result, isFalse);
    });

    test('rejects invalid email format - missing domain', () {
      final result = isValidEmail('test@');
      expect(result, isFalse);
    });

    test('rejects invalid email format - missing local part', () {
      final result = isValidEmail('@domain.com');
      expect(result, isFalse);
    });

    test('rejects invalid email format - multiple @', () {
      final result = isValidEmail('test@@domain.com');
      expect(result, isFalse);
    });

    test('rejects invalid email format - spaces', () {
      final result = isValidEmail('test @domain.com');
      expect(result, isFalse);
    });

    test('accepts valid email format - standard', () {
      final result = isValidEmail('test@example.com');
      expect(result, isTrue);
    });

    test('accepts valid email format - with subdomain', () {
      final result = isValidEmail('test@mail.example.com');
      expect(result, isTrue);
    });

    test('accepts valid email format - with plus sign', () {
      final result = isValidEmail('test+tag@example.com');
      expect(result, isTrue);
    });

    test('accepts valid email format - with dots in local part', () {
      final result = isValidEmail('first.last@example.com');
      expect(result, isTrue);
    });

    test('accepts valid email format - with numbers', () {
      final result = isValidEmail('test123@example123.com');
      expect(result, isTrue);
    });

    test('accepts valid email format - with hyphen in domain', () {
      final result = isValidEmail('test@my-domain.com');
      expect(result, isTrue);
    });

    test('accepts valid email format - minimal', () {
      final result = isValidEmail('a@b.co');
      expect(result, isTrue);
    });
  });

  group('AppUser Email Handling', () {
    test('AppUser can be created with null email', () {
      final user = AppUser(
        id: 'test-id',
        email: null, // Optional now
        role: UserRole.student,
        firstName: 'Test',
        lastName: 'User',
      );
      expect(user.email, isNull);
      expect(user.id, equals('test-id'));
      expect(user.role, equals(UserRole.student));
    });

    test('AppUser can be created with valid email', () {
      final user = AppUser(
        id: 'test-id',
        email: 'test@example.com',
        role: UserRole.student,
        firstName: 'Test',
        lastName: 'User',
      );
      expect(user.email, equals('test@example.com'));
    });

    test('AppUser fullName returns full name when both names present', () {
      final user = AppUser(
        id: 'id',
        email: null,
        role: UserRole.student,
        firstName: 'John',
        lastName: 'Doe',
      );
      expect(user.fullName, equals('John Doe'));
    });

    test('AppUser fullName returns firstName when only firstName present', () {
      final user = AppUser(
        id: 'id',
        email: null,
        role: UserRole.student,
        firstName: 'John',
        lastName: null,
      );
      expect(user.fullName, equals('John'));
    });

    test('AppUser fullName returns lastName when only lastName present', () {
      final user = AppUser(
        id: 'id',
        email: null,
        role: UserRole.student,
        firstName: null,
        lastName: 'Doe',
      );
      expect(user.fullName, equals('Doe'));
    });

    test('AppUser fullName falls back to email when no names present', () {
      final user = AppUser(
        id: 'id',
        email: 'test@example.com',
        role: UserRole.student,
        firstName: null,
        lastName: null,
      );
      expect(user.fullName, equals('test@example.com'));
    });

    test('AppUser fullName returns Unknown User when all null', () {
      final user = AppUser(
        id: 'id',
        email: null,
        role: UserRole.student,
        firstName: null,
        lastName: null,
      );
      expect(user.fullName, equals('Unknown User'));
      expect(user.fullName, isNotEmpty);
    });

    test('AppUser toJson handles null email correctly', () {
      final user = AppUser(
        id: 'test-id',
        email: null,
        role: UserRole.student,
      );
      final json = user.toJson();
      expect(json['email'], isNull);
      expect(json['id'], equals('test-id'));
      expect(json['role'], equals('student'));
    });

    test('AppUser fromJson handles missing email correctly', () {
      final json = {
        'id': 'test-id',
        'role': 'student',
        // email is not present
      };
      final user = AppUser.fromJson(json);
      expect(user.email, isNull);
      expect(user.id, equals('test-id'));
    });

    test('AppUser fromJson handles null email correctly', () {
      final json = {
        'id': 'test-id',
        'email': null,
        'role': 'teacher',
      };
      final user = AppUser.fromJson(json);
      expect(user.email, isNull);
      expect(user.role, equals(UserRole.teacher));
    });

    test('AppUser equality works with null emails', () {
      final user1 = AppUser(id: 'id', email: null, role: UserRole.student);
      final user2 = AppUser(id: 'id', email: null, role: UserRole.student);
      final user3 = AppUser(id: 'id', email: 'test@test.com', role: UserRole.student);

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });

    test('AppUser copyWith preserves null email when not specified', () {
      final user = AppUser(id: 'id', email: null, role: UserRole.student);
      final copied = user.copyWith(firstName: 'NewName');
      expect(copied.email, isNull);
      expect(copied.firstName, equals('NewName'));
    });

    test('AppUser copyWith can set email from null to value', () {
      final user = AppUser(id: 'id', email: null, role: UserRole.student);
      final copied = user.copyWith(email: 'new@email.com');
      expect(copied.email, equals('new@email.com'));
    });
  });

  group('UserRole', () {
    test('UserRole.fromString parses valid roles correctly', () {
      expect(UserRole.fromString('student'), equals(UserRole.student));
      expect(UserRole.fromString('teacher'), equals(UserRole.teacher));
      expect(UserRole.fromString('admin'), equals(UserRole.admin));
      expect(UserRole.fromString('bigadmin'), equals(UserRole.bigadmin));
      expect(UserRole.fromString('superadmin'), equals(UserRole.superadmin));
      expect(UserRole.fromString('parent'), equals(UserRole.parent));
    });

    test('UserRole.fromString is case insensitive', () {
      expect(UserRole.fromString('STUDENT'), equals(UserRole.student));
      expect(UserRole.fromString('Teacher'), equals(UserRole.teacher));
      expect(UserRole.fromString('ADMIN'), equals(UserRole.admin));
    });

    test('UserRole.fromString returns null for invalid role', () {
      expect(UserRole.fromString('invalid'), isNull);
      expect(UserRole.fromString(''), isNull);
      expect(UserRole.fromString('unknown'), isNull);
    });

    test('UserRole.fromString returns null for null input', () {
      expect(UserRole.fromString(null), isNull);
    });

    test('UserRole.toJson returns role name as string', () {
      expect(UserRole.student.toJson(), equals('student'));
      expect(UserRole.teacher.toJson(), equals('teacher'));
      expect(UserRole.admin.toJson(), equals('admin'));
    });
  });

  group('AppUser RBAC Helpers', () {
    test('isSuperAdmin returns true only for superadmin role', () {
      expect(
        AppUser(id: 'id', role: UserRole.superadmin).isSuperAdmin,
        isTrue,
      );
      expect(
        AppUser(id: 'id', role: UserRole.admin).isSuperAdmin,
        isFalse,
      );
    });

    test('hasAdminPrivileges returns true for superadmin, bigadmin, admin', () {
      expect(
        AppUser(id: 'id', role: UserRole.superadmin).hasAdminPrivileges,
        isTrue,
      );
      expect(
        AppUser(id: 'id', role: UserRole.bigadmin).hasAdminPrivileges,
        isTrue,
      );
      expect(
        AppUser(id: 'id', role: UserRole.admin).hasAdminPrivileges,
        isTrue,
      );
      expect(
        AppUser(id: 'id', role: UserRole.teacher).hasAdminPrivileges,
        isFalse,
      );
      expect(
        AppUser(id: 'id', role: UserRole.student).hasAdminPrivileges,
        isFalse,
      );
    });

    test('belongsToSchool returns true for superadmin regardless of school', () {
      final superadmin = AppUser(
        id: 'id',
        role: UserRole.superadmin,
        schoolId: null,
      );
      expect(superadmin.belongsToSchool('any-school-id'), isTrue);
    });

    test('belongsToSchool returns false for null schoolId check', () {
      final user = AppUser(id: 'id', role: UserRole.student, schoolId: 'school1');
      expect(user.belongsToSchool(null), isFalse);
    });

    test('hasRoleOrHigher correctly compares role hierarchy', () {
      final superadmin = AppUser(id: 'id', role: UserRole.superadmin);
      final student = AppUser(id: 'id', role: UserRole.student);
      final teacher = AppUser(id: 'id', role: UserRole.teacher);

      expect(superadmin.hasRoleOrHigher(UserRole.student), isTrue);
      expect(superadmin.hasRoleOrHigher(UserRole.superadmin), isTrue);
      expect(student.hasRoleOrHigher(UserRole.superadmin), isFalse);
      expect(teacher.hasRoleOrHigher(UserRole.student), isTrue);
      expect(student.hasRoleOrHigher(UserRole.teacher), isFalse);
    });
  });
}
