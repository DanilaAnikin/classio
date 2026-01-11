// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currentLanguageCodeHash() =>
    r'efe28d2344b830b0ef5f33506cedb89a4f3c878e';

/// Provider that exposes the current language code as a String.
///
/// Copied from [currentLanguageCode].
@ProviderFor(currentLanguageCode)
final currentLanguageCodeProvider = AutoDisposeProvider<String>.internal(
  currentLanguageCode,
  name: r'currentLanguageCodeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentLanguageCodeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentLanguageCodeRef = AutoDisposeProviderRef<String>;
String _$isCurrentLocaleHash() => r'80b400f65daf1338bcab482d84d5635659534e3c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider that checks if a specific language code is the current locale.
///
/// Copied from [isCurrentLocale].
@ProviderFor(isCurrentLocale)
const isCurrentLocaleProvider = IsCurrentLocaleFamily();

/// Provider that checks if a specific language code is the current locale.
///
/// Copied from [isCurrentLocale].
class IsCurrentLocaleFamily extends Family<bool> {
  /// Provider that checks if a specific language code is the current locale.
  ///
  /// Copied from [isCurrentLocale].
  const IsCurrentLocaleFamily();

  /// Provider that checks if a specific language code is the current locale.
  ///
  /// Copied from [isCurrentLocale].
  IsCurrentLocaleProvider call(String languageCode) {
    return IsCurrentLocaleProvider(languageCode);
  }

  @override
  IsCurrentLocaleProvider getProviderOverride(
    covariant IsCurrentLocaleProvider provider,
  ) {
    return call(provider.languageCode);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isCurrentLocaleProvider';
}

/// Provider that checks if a specific language code is the current locale.
///
/// Copied from [isCurrentLocale].
class IsCurrentLocaleProvider extends AutoDisposeProvider<bool> {
  /// Provider that checks if a specific language code is the current locale.
  ///
  /// Copied from [isCurrentLocale].
  IsCurrentLocaleProvider(String languageCode)
    : this._internal(
        (ref) => isCurrentLocale(ref as IsCurrentLocaleRef, languageCode),
        from: isCurrentLocaleProvider,
        name: r'isCurrentLocaleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isCurrentLocaleHash,
        dependencies: IsCurrentLocaleFamily._dependencies,
        allTransitiveDependencies:
            IsCurrentLocaleFamily._allTransitiveDependencies,
        languageCode: languageCode,
      );

  IsCurrentLocaleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.languageCode,
  }) : super.internal();

  final String languageCode;

  @override
  Override overrideWith(bool Function(IsCurrentLocaleRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsCurrentLocaleProvider._internal(
        (ref) => create(ref as IsCurrentLocaleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        languageCode: languageCode,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsCurrentLocaleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsCurrentLocaleProvider &&
        other.languageCode == languageCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, languageCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin IsCurrentLocaleRef on AutoDisposeProviderRef<bool> {
  /// The parameter `languageCode` of this provider.
  String get languageCode;
}

class _IsCurrentLocaleProviderElement extends AutoDisposeProviderElement<bool>
    with IsCurrentLocaleRef {
  _IsCurrentLocaleProviderElement(super.provider);

  @override
  String get languageCode => (origin as IsCurrentLocaleProvider).languageCode;
}

String _$supportedLocalesListHash() =>
    r'30812f98a85510be6b676f877c0398e8db41fe80';

/// Provider that returns the list of supported locales.
///
/// Copied from [supportedLocalesList].
@ProviderFor(supportedLocalesList)
final supportedLocalesListProvider = AutoDisposeProvider<List<Locale>>.internal(
  supportedLocalesList,
  name: r'supportedLocalesListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$supportedLocalesListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SupportedLocalesListRef = AutoDisposeProviderRef<List<Locale>>;
String _$localeNotifierHash() => r'dcde4e4d510559632d82c8e27c1f3f5fe007edeb';

/// Notifier for managing the application locale/language state.
///
/// This notifier handles:
/// - Loading the saved locale preference from SharedPreferences
/// - Persisting locale changes to SharedPreferences
/// - Validating that the locale is in the supported locales list
///
/// Copied from [LocaleNotifier].
@ProviderFor(LocaleNotifier)
final localeNotifierProvider =
    NotifierProvider<LocaleNotifier, Locale>.internal(
      LocaleNotifier.new,
      name: r'localeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LocaleNotifier = Notifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
