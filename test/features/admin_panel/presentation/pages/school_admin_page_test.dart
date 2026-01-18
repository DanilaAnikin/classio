import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classio/core/localization/generated/app_localizations.dart';
import 'package:classio/core/providers/providers.dart';
import 'package:classio/features/admin_panel/presentation/pages/school_admin_page.dart';
import 'package:classio/features/admin_panel/presentation/providers/admin_providers.dart';
import 'package:classio/features/admin_panel/domain/repositories/admin_repository.dart';
import 'package:classio/features/admin_panel/domain/entities/entities.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/features/auth/domain/entities/app_user.dart';
import 'package:classio/features/dashboard/domain/entities/subject.dart';

/// Mock AdminRepository for testing
class MockAdminRepository implements AdminRepository {
  @override
  Future<List<School>> getSchools() async => [];

  @override
  Future<List<AppUser>> getSchoolUsers(String schoolId) async => [];

  @override
  Future<List<ClassInfo>> getSchoolClasses(String schoolId) async => [];

  @override
  Future<List<Subject>> getTeacherSubjects(String teacherId) async => [];

  @override
  Future<List<InviteCode>> getSchoolInviteCodes(String schoolId) async => [];

  @override
  Future<School> createSchool(String name) async {
    throw UnimplementedError();
  }

  @override
  Future<ClassInfo> createClass({
    required String schoolId,
    required String name,
    required int gradeLevel,
    required String academicYear,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<InviteCode> generateInviteCode({
    required String schoolId,
    required UserRole role,
    String? classId,
    required int usageLimit,
    DateTime? expiresAt,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<InviteCode> deactivateInviteCode(String codeId) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteClass(String classId) async {
    throw UnimplementedError();
  }

  @override
  Future<AppUser> updateUserRole(String userId, UserRole newRole) async {
    throw UnimplementedError();
  }
}

/// Mock AuthNotifier for testing that provides a pre-set user state
/// This completely bypasses the SupabaseAuthRepository to avoid Supabase initialization
class MockAuthNotifier extends AuthNotifier {
  final AppUser? _mockUser;

  MockAuthNotifier(this._mockUser);

  @override
  AuthState build() {
    if (_mockUser != null) {
      return AuthState.authenticated(_mockUser);
    }
    return AuthState.unauthenticated();
  }

  @override
  Future<void> signIn(String email, String password) async {
    // Do nothing in tests
  }

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String inviteCode,
    String? firstName,
    String? lastName,
  }) async {
    // Do nothing in tests
  }

  @override
  Future<void> checkAuthStatus() async {
    // Do nothing in tests
  }

  @override
  Future<void> signOut() async {
    // Do nothing in tests
  }

  @override
  void clearError() {
    // Do nothing in tests
  }
}

void main() {
  late SharedPreferences prefs;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  /// Creates a test widget with an admin user that has access to SchoolAdminPage
  Widget createTestWidgetWithAdminUser(Widget child) {
    final mockAdminUser = AppUser(
      id: 'test-admin-id',
      email: 'admin@test.com',
      role: UserRole.admin,
      firstName: 'Test',
      lastName: 'Admin',
      schoolId: 'test-school-id',
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        adminRepositoryProvider.overrideWithValue(MockAdminRepository()),
        authNotifierProvider.overrideWith(() => MockAuthNotifier(mockAdminUser)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      ),
    );
  }

  /// Creates a test widget with a user that has no admin privileges
  Widget createTestWidgetWithNonAdminUser(Widget child) {
    final mockStudentUser = AppUser(
      id: 'test-student-id',
      email: 'student@test.com',
      role: UserRole.student,
      firstName: 'Test',
      lastName: 'Student',
      schoolId: 'test-school-id',
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        adminRepositoryProvider.overrideWithValue(MockAdminRepository()),
        authNotifierProvider
            .overrideWith(() => MockAuthNotifier(mockStudentUser)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      ),
    );
  }

  /// Creates a test widget with an admin user that has no school assigned
  Widget createTestWidgetWithAdminNoSchool(Widget child) {
    final mockAdminUser = AppUser(
      id: 'test-admin-id',
      email: 'admin@test.com',
      role: UserRole.admin,
      firstName: 'Test',
      lastName: 'Admin',
      schoolId: null, // No school assigned
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        adminRepositoryProvider.overrideWithValue(MockAdminRepository()),
        authNotifierProvider.overrideWith(() => MockAuthNotifier(mockAdminUser)),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      ),
    );
  }

  group('SchoolAdminPage Localization', () {
    testWidgets('displays localized app bar title', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Find app bar title - 'School Admin' in English
      expect(find.text('School Admin'), findsOneWidget);
    });

    testWidgets('displays localized Users tab label', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Find Users tab label - 'Users' in English
      expect(find.text('Users'), findsOneWidget);
    });

    testWidgets('displays localized Classes tab label', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Find Classes tab label - 'Classes' in English
      expect(find.text('Classes'), findsOneWidget);
    });

    testWidgets('displays localized Generate Invite button', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // On Users tab, should show Generate Invite FAB - 'Generate Invite' in English
      expect(find.text('Generate Invite'), findsOneWidget);
    });

    testWidgets('displays localized Create Class button when on Classes tab',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Tap on Classes tab
      await tester.tap(find.text('Classes'));
      await tester.pumpAndSettle();

      // Should show Create Class FAB - 'Create Class' in English
      expect(find.text('Create Class'), findsOneWidget);
    });
  });

  group('SchoolAdminPage Access Denied Localization', () {
    testWidgets('displays localized Access Denied message for non-admin user',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithNonAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Should show Access Denied - localized text
      expect(find.text('Access Denied'), findsOneWidget);
    });

    testWidgets('displays localized no permission message for non-admin user',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithNonAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Should show no permission message - localized text
      expect(find.text('You do not have permission to access this page.'),
          findsOneWidget);
    });

    testWidgets('displays localized app bar title on access denied page',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithNonAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Should still show School Admin title in app bar
      expect(find.text('School Admin'), findsOneWidget);
    });
  });

  group('SchoolAdminPage No School Assigned Localization', () {
    testWidgets('displays localized No School Assigned message',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminNoSchool(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Should show No School Assigned - localized text
      expect(find.text('No School Assigned'), findsOneWidget);
    });

    testWidgets('displays localized not assigned to school message',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminNoSchool(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Should show not assigned message - localized text
      expect(find.text('You are not assigned to any school.'), findsOneWidget);
    });

    testWidgets('displays localized app bar title on no school page',
        (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminNoSchool(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Should still show School Admin title in app bar
      expect(find.text('School Admin'), findsOneWidget);
    });
  });

  group('SchoolAdminPage TabBar Localization', () {
    testWidgets('both tabs display localized labels', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Both tabs should be visible with localized labels
      expect(find.text('Users'), findsOneWidget);
      expect(find.text('Classes'), findsOneWidget);
    });

    testWidgets('TabBar icons are present', (tester) async {
      await tester.pumpWidget(
          createTestWidgetWithAdminUser(const SchoolAdminPage()));
      await tester.pumpAndSettle();

      // Check that tab icons are present (use findsAtLeast in case icons appear multiple times)
      expect(find.byIcon(Icons.people_outline_rounded), findsAtLeast(1));
      expect(find.byIcon(Icons.class_outlined), findsAtLeast(1));
    });
  });
}
