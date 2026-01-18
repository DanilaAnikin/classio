# Classio

School Management System (LMS + Administration)

## Platforms Supported

- iOS
- Android
- Web
- Windows
- Linux

## How to Run

```bash
flutter run
```

## Features Implemented

- **Dual theme system (Clean/Playful)** - Switch between professional and playful visual styles
- **Multi-language support (8 languages)** - English, Czech, German, French, Russian, Polish, Spanish, Italian
- **Persistent settings** - User preferences are saved locally
- **Clean Architecture with feature-based structure** - Organized codebase following best practices

## Getting Started

1. Ensure Flutter is installed on your system
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter gen-l10n` to generate localization files
5. Create a `.env` file in the root directory with your Supabase credentials:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```
6. Run `flutter run` to start the application

## Building for Production

For production builds, use `--dart-define` to pass environment variables securely without bundling the .env file:

### Android
```bash
flutter build apk --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### iOS
```bash
flutter build ios --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### Web
```bash
flutter build web --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

**IMPORTANT**: Never commit the `.env` file to version control. It's already in `.gitignore`.

## Project Structure

```
lib/
  core/           # Core functionality (themes, localization, etc.)
  features/       # Feature modules (dashboard, settings, etc.)
  shared/         # Shared widgets and utilities
  main.dart       # Application entry point
```
# classio
