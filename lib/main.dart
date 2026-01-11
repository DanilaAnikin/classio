import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/localization/app_localizations.dart';
import 'core/providers/providers.dart';
import 'core/router/router.dart';
import 'core/theme/clean_theme.dart';
import 'core/theme/playful_theme.dart';

/// Entry point of the Classio application.
///
/// Performs async initialization before running the app:
/// 1. Ensures Flutter bindings are initialized
/// 2. Loads environment variables from .env file
/// 3. Initializes Supabase with URL and anon key from environment
/// 4. Loads SharedPreferences instance
/// 5. Runs the app with ProviderScope and SharedPreferences override
void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize Supabase with URL and anon key from environment variables
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize SharedPreferences before the app starts
  // This allows synchronous access to preferences throughout the app
  final sharedPreferences = await SharedPreferences.getInstance();

  // Run the app wrapped in ProviderScope for Riverpod state management
  runApp(
    ProviderScope(
      overrides: [
        // Override the SharedPreferences provider with the initialized instance
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ClassioApp(),
    ),
  );
}

/// The root widget of the Classio application.
///
/// This is a [ConsumerWidget] that watches:
/// - [themeNotifierProvider] for theme changes (Clean/Playful)
/// - [localeNotifierProvider] for language/locale changes
///
/// Uses [MaterialApp.router] with GoRouter for declarative navigation.
class ClassioApp extends ConsumerWidget {
  const ClassioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme type (Clean or Playful)
    final currentTheme = ref.watch(themeNotifierProvider);

    // Watch the current locale for localization
    final currentLocale = ref.watch(localeNotifierProvider);

    // Get the GoRouter instance for navigation
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      // Router configuration using GoRouter
      routerConfig: router,

      // Application title
      title: 'Classio',

      // Apply the correct theme based on the current ThemeType
      theme: _getThemeData(currentTheme),

      // Current locale from the locale notifier
      locale: currentLocale,

      // Localization delegates for internationalization
      localizationsDelegates: AppLocalizations.localizationsDelegates,

      // Supported locales from LocalizationConfig
      supportedLocales: LocalizationConfig.supportedLocales,

      // Locale resolution callback for fallback behavior
      localeResolutionCallback: LocalizationConfig.localeResolutionCallback,

      // Hide the debug banner in release builds
      debugShowCheckedModeBanner: false,
    );
  }

  /// Returns the appropriate [ThemeData] based on the [ThemeType].
  ///
  /// - [ThemeType.clean]: Returns the Clean theme (minimalist, professional)
  /// - [ThemeType.playful]: Returns the Playful theme (fun, colorful)
  ThemeData _getThemeData(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.clean:
        return CleanTheme.themeData;
      case ThemeType.playful:
        return PlayfulTheme.themeData;
    }
  }
}
