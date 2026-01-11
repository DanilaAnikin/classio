// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedPreferencesHash() => r'4e865e1c946c70f34f29002ebb2c0abdec66ecc3';

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
///
/// Copied from [sharedPreferences].
@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = Provider<SharedPreferences>.internal(
  sharedPreferences,
  name: r'sharedPreferencesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedPreferencesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesRef = ProviderRef<SharedPreferences>;
String _$sharedPreferencesAsyncHash() =>
    r'28c4549ac5782c3cf98204154f16d2b3fca677fa';

/// Alternative async provider for SharedPreferences.
///
/// Use this if you prefer to handle the async initialization within
/// the provider system rather than before app startup.
///
/// Note: This approach requires handling the AsyncValue loading state
/// in widgets that depend on this provider.
///
/// Copied from [sharedPreferencesAsync].
@ProviderFor(sharedPreferencesAsync)
final sharedPreferencesAsyncProvider =
    FutureProvider<SharedPreferences>.internal(
      sharedPreferencesAsync,
      name: r'sharedPreferencesAsyncProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sharedPreferencesAsyncHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SharedPreferencesAsyncRef = FutureProviderRef<SharedPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
