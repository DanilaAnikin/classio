import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Provider for the SharedPreferences instance.
///
/// This provider must be overridden in the ProviderScope with the actual
/// SharedPreferences instance that is initialized before the app starts.
///
/// Example usage in main.dart:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final prefs = await SharedPreferences.getInstance();
///
///   runApp(
///     ProviderScope(
///       overrides: [
///         sharedPreferencesProvider.overrideWithValue(prefs),
///       ],
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  // This will throw if not overridden. The provider must be overridden
  // with the actual SharedPreferences instance in ProviderScope.
  throw UnimplementedError(
    'SharedPreferences must be initialized before use. '
    'Override this provider in ProviderScope with the SharedPreferences instance.',
  );
}

/// Alternative async provider for SharedPreferences.
///
/// Use this if you prefer to handle the async initialization within
/// the provider system rather than before app startup.
///
/// Note: This approach requires handling the AsyncValue loading state
/// in widgets that depend on this provider.
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferencesAsync(Ref ref) async {
  return SharedPreferences.getInstance();
}
