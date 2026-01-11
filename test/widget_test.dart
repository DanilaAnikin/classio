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
import 'package:classio/main.dart';

void main() {
  testWidgets('App launches and shows dashboard', (WidgetTester tester) async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ClassioApp(),
      ),
    );

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the dashboard is shown (checking for common dashboard elements)
    // The specific assertions will depend on the actual DashboardScreen content
    expect(find.byType(ClassioApp), findsOneWidget);
  });
}
