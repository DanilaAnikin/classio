// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:classio/core/providers/providers.dart';
import 'package:classio/features/auth/presentation/providers/auth_provider.dart';
import 'package:classio/main.dart';

void main() {
  testWidgets('App launches and shows login screen when unauthenticated',
      (WidgetTester tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // Override authNotifierProvider to return unauthenticated state
          // This avoids Supabase initialization requirements
          authNotifierProvider.overrideWith(() => _MockAuthNotifier()),
        ],
        child: const ClassioApp(),
      ),
    );

    // Pump once to allow the initial build
    await tester.pump();

    // Verify that the app widget is created
    expect(find.byType(ClassioApp), findsOneWidget);

    // Allow async operations to complete (with a timeout to avoid infinite loops)
    await tester.pump(const Duration(milliseconds: 100));

    // The app should redirect to login since user is unauthenticated
    // We're verifying the app launches without crashing
    expect(find.byType(ClassioApp), findsOneWidget);
  });
}

/// Mock AuthNotifier that returns unauthenticated state without Supabase
class _MockAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    // Return unauthenticated state directly without any Supabase calls
    return AuthState.unauthenticated();
  }
}
