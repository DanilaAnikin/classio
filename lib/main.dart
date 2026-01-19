import 'package:flutter/foundation.dart';
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
/// 2. Loads environment variables from .env file (dev) or --dart-define (prod)
/// 3. Initializes Supabase with URL and anon key from environment
/// 4. Loads SharedPreferences instance
/// 5. Runs the app with ProviderScope and SharedPreferences override
///
/// SECURITY: For production builds, use --dart-define instead of .env file:
/// flutter build apk --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Add custom error handler to log overflow errors with detailed context
  // Only run extensive debug output in debug mode
  if (kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      final exceptionStr = details.exception.toString();
      final isOverflow = exceptionStr.contains('OVERFLOWED') ||
          exceptionStr.contains('overflowed') ||
          exceptionStr.contains('A RenderFlex overflowed') ||
          exceptionStr.contains('RenderBox was not laid out');

      if (isOverflow) {
        debugPrint('');
        debugPrint('╔════════════════════════════════════════════════════════════');
        debugPrint('║ OVERFLOWED ERROR DETECTED');
        debugPrint('╠════════════════════════════════════════════════════════════');
        debugPrint('║ Error: $exceptionStr');
        debugPrint('╠════════════════════════════════════════════════════════════');
        debugPrint('║ Context: ${details.context?.toString() ?? 'No context available'}');
        debugPrint('║ Library: ${details.library ?? 'Unknown'}');
        debugPrint('╠════════════════════════════════════════════════════════════');

        // Try to get widget info from informationCollector
        debugPrint('║ Widget Info:');
        try {
          if (details.informationCollector != null) {
            final infos = details.informationCollector!();
            for (final info in infos) {
              final lines = info.toString().split('\n');
              for (final line in lines) {
                if (line.trim().isNotEmpty) {
                  debugPrint('║   $line');
                }
              }
            }
          } else {
            debugPrint('║   No widget info available from informationCollector');
          }
        } catch (e) {
          debugPrint('║   Error getting widget info: $e');
        }

        debugPrint('╠════════════════════════════════════════════════════════════');

        // Print stack trace
        debugPrint('║ Stack Trace:');
        try {
          if (details.stack != null) {
            final stackStr = details.stack.toString();
            final lines = stackStr.split('\n');
            int printed = 0;

            // First, try to find app-specific frames
            for (final line in lines) {
              if (line.contains('package:classio') && printed < 15) {
                debugPrint('║   $line');
                printed++;
              }
            }

            // If no app frames found, print first 10 lines
            if (printed == 0) {
              for (int i = 0; i < lines.length && i < 10; i++) {
                debugPrint('║   ${lines[i]}');
              }
            }
          } else {
            debugPrint('║   No stack trace available');
          }
        } catch (e) {
          debugPrint('║   Error getting stack trace: $e');
        }

        debugPrint('╠════════════════════════════════════════════════════════════');

        // Also print the full summary for maximum info
        debugPrint('║ Full Error Summary:');
        try {
          final summary = details.toString();
          final summaryLines = summary.split('\n');
          for (int i = 0; i < summaryLines.length && i < 30; i++) {
            debugPrint('║   ${summaryLines[i]}');
          }
        } catch (e) {
          debugPrint('║   Error getting summary: $e');
        }

        debugPrint('╚════════════════════════════════════════════════════════════');
        debugPrint('');
      }

      // Call the default handler
      FlutterError.presentError(details);
    };
  }

  // Get environment variables from dart-define (production) or .env (development)
  // dart-define values are compile-time constants, more secure for production
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // Determine which source to use for credentials
  String finalSupabaseUrl;
  String finalSupabaseAnonKey;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    // Production mode: using --dart-define values
    finalSupabaseUrl = supabaseUrl;
    finalSupabaseAnonKey = supabaseAnonKey;
  } else {
    // Development mode: load from assets/.env file
    // For Flutter Web, the .env must be in assets/ directory and registered in pubspec.yaml
    try {
      await dotenv.load(fileName: 'assets/.env');
      finalSupabaseUrl = dotenv.env['SUPABASE_URL']!;
      finalSupabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']!;
    } catch (e) {
      throw Exception(
        'Failed to load environment variables. '
        'For development, create assets/.env file (copy from .env.example). '
        'For production, use --dart-define=SUPABASE_URL and --dart-define=SUPABASE_ANON_KEY',
      );
    }
  }

  // Initialize Supabase with URL and anon key from environment variables
  await Supabase.initialize(
    url: finalSupabaseUrl,
    anonKey: finalSupabaseAnonKey,
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
