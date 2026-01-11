// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isCleanThemeHash() => r'025ab83f3c6b48126b4d81d41dfa0d479af7b4e5';

/// Convenience provider to check if the current theme is clean.
///
/// Copied from [isCleanTheme].
@ProviderFor(isCleanTheme)
final isCleanThemeProvider = AutoDisposeProvider<bool>.internal(
  isCleanTheme,
  name: r'isCleanThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isCleanThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsCleanThemeRef = AutoDisposeProviderRef<bool>;
String _$isPlayfulThemeHash() => r'd7d9f559449922b1f276789d60d96dd1b0fa4b7b';

/// Convenience provider to check if the current theme is playful.
///
/// Copied from [isPlayfulTheme].
@ProviderFor(isPlayfulTheme)
final isPlayfulThemeProvider = AutoDisposeProvider<bool>.internal(
  isPlayfulTheme,
  name: r'isPlayfulThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPlayfulThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPlayfulThemeRef = AutoDisposeProviderRef<bool>;
String _$themeNotifierHash() => r'b090ac5e3c34e3c16eccec6d7fe201f5f407d877';

/// Notifier for managing the application theme state.
///
/// This notifier handles:
/// - Loading the saved theme preference from SharedPreferences
/// - Persisting theme changes to SharedPreferences
/// - Providing methods to change or toggle the theme
///
/// Copied from [ThemeNotifier].
@ProviderFor(ThemeNotifier)
final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeType>.internal(
      ThemeNotifier.new,
      name: r'themeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeNotifier = Notifier<ThemeType>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
