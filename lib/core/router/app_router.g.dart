// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$goRouterHash() => r'd4ecd7f67edf55c985d4fdb1001f41293caac5ad';

/// Provides the [GoRouter] instance for the application.
///
/// This provider creates and configures the router with all routes,
/// transitions, and error handling. It can access other providers
/// if needed (e.g., for auth state-based redirects).
///
/// Usage in MaterialApp:
/// ```dart
/// MaterialApp.router(
///   routerConfig: ref.watch(goRouterProvider),
/// )
/// ```
///
/// Copied from [goRouter].
@ProviderFor(goRouter)
final goRouterProvider = AutoDisposeProvider<GoRouter>.internal(
  goRouter,
  name: r'goRouterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$goRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GoRouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
