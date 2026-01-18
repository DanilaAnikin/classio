import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classio/core/localization/generated/app_localizations.dart';
import 'package:classio/core/providers/providers.dart';
import 'package:classio/features/auth/presentation/pages/login_page.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';

/// Mock AuthNotifier for testing that provides an unauthenticated state
/// This completely bypasses the SupabaseAuthRepository to avoid Supabase initialization
class MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
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

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authNotifierProvider.overrideWith(() => MockAuthNotifier()),
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

  group('LoginPage Localization', () {
    testWidgets('displays email label from localization', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find email text field with localized label - 'Email' in English
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('displays password label from localization', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find password text field with localized label - 'Password' in English
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays sign in button from localization', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find sign in button with localized text - 'Sign In' in English
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('displays welcome message from localization', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find welcome message - 'Welcome to Classio' in English
      expect(find.text('Welcome to Classio'), findsOneWidget);
    });

    testWidgets('displays sign in to continue subtitle from localization',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find subtitle - 'Sign in to continue' in English
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('displays forgot password link from localization',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find forgot password link - 'Forgot Password?' in English
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('displays no account prompt from localization', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find "I don't have an account" link - localized text
      expect(find.text("I don't have an account"), findsOneWidget);
    });

    testWidgets('shows validation error for empty email when form submitted',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap sign in without entering email
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show localized error - 'Email is required' in English
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('shows validation error for empty password when form submitted',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find the email TextFormField by its label and enter text
      final emailField = find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(emailField, 'test@example.com');

      // Tap sign in without entering password
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show localized error - 'Password is required' in English
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find the email TextFormField by its label and enter invalid email
      final emailField = find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(emailField, 'invalid-email');

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show localized error - 'Please enter a valid email' in English
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('shows validation error for short password', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find the email TextFormField by its label
      final emailField = find.ancestor(
        of: find.text('Email'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(emailField, 'test@example.com');

      // Find the password TextFormField by its label and enter short password
      final passwordField = find.ancestor(
        of: find.text('Password'),
        matching: find.byType(TextFormField),
      );
      await tester.enterText(passwordField, '123');

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Should show localized error - 'Password must be at least 6 characters'
      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('displays email hint text from localization', (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find email hint text - 'Enter your email address' in English
      expect(find.text('Enter your email address'), findsOneWidget);
    });

    testWidgets('displays password hint text from localization',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Find password hint text - 'Enter your password' in English
      expect(find.text('Enter your password'), findsOneWidget);
    });
  });

  group('LoginPage Registration Mode Localization', () {
    testWidgets('displays join classio message when toggling to register mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap "I don't have an account" to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show registration welcome message - 'Join Classio' in English
      expect(find.text('Join Classio'), findsOneWidget);
    });

    testWidgets('displays create account subtitle when in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show registration subtitle
      expect(find.text('Create your account to get started'), findsOneWidget);
    });

    testWidgets('displays register button when in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show Register button instead of Sign In
      expect(find.text('Register'), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);
    });

    testWidgets('displays invite code field when in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show Invite Code label
      expect(find.text('Invite Code'), findsOneWidget);
    });

    testWidgets('displays first name field when in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show First Name label
      expect(find.text('First Name'), findsOneWidget);
    });

    testWidgets('displays last name field when in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show Last Name label
      expect(find.text('Last Name'), findsOneWidget);
    });

    testWidgets('displays confirm password field when in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show Confirm Password label
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('displays already have account link in registration mode',
        (tester) async {
      await tester.pumpWidget(createTestWidget(const LoginPage()));
      await tester.pumpAndSettle();

      // Tap to switch to registration mode
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();

      // Should show "Already have an account?" link
      expect(find.text('Already have an account?'), findsOneWidget);
    });
  });
}
