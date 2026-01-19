<div align="center">

# Classio

**A Comprehensive School Management System**

[![Flutter](https://img.shields.io/badge/Flutter-3.10.3+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase&logoColor=white)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.4.9-00D1B2)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

*Learning Management System + School Administration in one unified platform*

[Features](#features) • [Tech Stack](#tech-stack) • [Installation](#installation) • [Documentation](#project-structure)

</div>

---

## Overview

Classio is a modern, feature-rich School Management System that combines Learning Management System (LMS) capabilities with comprehensive administrative tools. Built with Flutter for cross-platform deployment, it serves educational institutions with role-based access control, real-time communication, and intuitive interfaces.

### Platforms Supported

| Platform | Status |
|----------|--------|
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| Web      | ✅ Supported |
| Windows  | ✅ Supported |
| Linux    | ✅ Supported |

### Localization

Available in **8 languages**: English, Czech, German, French, Russian, Polish, Spanish, and Italian.

### Themes

- **Clean Theme** - Professional, minimalist design for formal environments
- **Playful Theme** - Colorful, engaging design for a more casual experience

---

## Features

### Authentication & Security
- Secure authentication powered by Supabase Auth
- Invite code system for role-specific registration
- Role-Based Access Control (RBAC) with granular permissions

### Dashboard
- Role-specific dashboard views tailored to each user type
- Quick access to relevant features and statistics
- Real-time updates and notifications

### Schedule Management
- Comprehensive timetable system
- Class scheduling and room assignments
- Visual calendar views

### Grades System
- Weighted grade calculations
- Grade entry and management for teachers
- Academic performance tracking for students and parents

### Attendance Tracking
- Daily attendance recording
- Excuse submission and approval workflow
- Attendance reports and statistics

### Messaging System
- Direct messaging between users
- Group conversations
- School-wide announcements
- Real-time chat powered by Supabase Realtime

### Administration
- School management and configuration
- Staff administration
- Class and section management
- Student enrollment

### Settings & Personalization
- Theme switching (Clean/Playful)
- Language selection (8 languages)
- Persistent user preferences

---

## User Roles

Classio implements a comprehensive role-based system with 6 distinct user types:

| Role | Description | Key Capabilities |
|------|-------------|------------------|
| **SuperAdmin** | System administrator | Full access across all schools, system configuration |
| **BigAdmin** | Multi-school administrator | Elevated privileges across multiple schools |
| **Admin** | School administrator | Full access to school-specific features |
| **Teacher** | Instructor | Class management, grade entry, attendance tracking |
| **Student** | Learner | View grades, attendance, schedule, academic tracking |
| **Parent** | Guardian | Child monitoring, grade viewing, excuse submission |

---

## Tech Stack

### Frontend
- **Flutter** 3.10.3+ - Cross-platform UI framework
- **Riverpod** 2.4.9 - State management
- **GoRouter** 13.2.0 - Declarative routing (90+ routes)
- **Google Fonts** - Typography

### Backend
- **Supabase** - Backend as a Service
  - PostgreSQL database
  - Authentication
  - Realtime subscriptions
  - Row Level Security (RLS)

### Utilities
- **flutter_dotenv** - Environment variable management
- **SharedPreferences** - Local storage
- **build_runner** - Code generation

---

## Project Structure

```
lib/
├── core/                      # Core functionality
│   ├── constants/             # App-wide constants
│   ├── exceptions/            # Custom exception classes
│   ├── localization/          # i18n configuration (8 languages)
│   ├── providers/             # Global Riverpod providers
│   ├── router/                # GoRouter configuration
│   ├── theme/                 # Theme definitions (Clean/Playful)
│   └── utils/                 # Utility functions and helpers
│
├── features/                  # Feature modules (Clean Architecture)
│   ├── auth/                  # Authentication & registration
│   ├── admin_panel/           # Admin dashboard & tools
│   ├── superadmin/            # Super admin features
│   ├── principal/             # Principal dashboard
│   ├── deputy/                # Deputy admin panel
│   ├── teacher/               # Teacher-specific features
│   ├── student/               # Student-specific features
│   ├── parent/                # Parent-specific features
│   ├── dashboard/             # Main dashboard
│   ├── schedule/              # Timetable management
│   ├── grades/                # Grade management
│   ├── attendance/            # Attendance tracking
│   ├── chat/                  # Messaging system
│   ├── profile/               # User profiles
│   ├── settings/              # App settings
│   └── invite/                # Invite code management
│
└── shared/                    # Shared resources
    └── widgets/               # Reusable UI components
```

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** 3.10.3 or higher
- **Dart SDK** 3.0 or higher
- **Git** for version control
- A **Supabase** project (free tier available at [supabase.com](https://supabase.com))

### Verify Installation

```bash
flutter doctor
```

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/your-username/classio.git
cd classio
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Localization Files

```bash
flutter gen-l10n
```

### 4. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Configure Environment Variables

Create a `.env` file in the project root directory:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

> **Security Note**: The `.env` file is included in `.gitignore`. Never commit sensitive credentials to version control.

### 6. Run the Application

```bash
flutter run
```

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous/public key | Yes |

### Getting Supabase Credentials

1. Create a project at [supabase.com](https://supabase.com)
2. Navigate to **Settings** > **API**
3. Copy the **Project URL** and **anon/public** key

---

## Running the App

### Development Mode

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d linux       # Linux
flutter run -d <device_id> # Specific device
```

### List Available Devices

```bash
flutter devices
```

---

## Building for Production

For production builds, use `--dart-define` to pass environment variables securely:

### Android (APK)

```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Android (App Bundle)

```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### iOS

```bash
flutter build ios --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Web

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Windows

```bash
flutter build windows --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### Linux

```bash
flutter build linux --release \
  --dart-define=SUPABASE_URL=your_url \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

> **Important**: Never commit environment variables or the `.env` file to version control.

---

## Contributing

We welcome contributions to Classio! Here's how you can help:

### Getting Started

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
4. **Commit** your changes (`git commit -m 'Add amazing feature'`)
5. **Push** to the branch (`git push origin feature/amazing-feature`)
6. **Open** a Pull Request

### Guidelines

- Follow the existing code style and architecture patterns
- Write meaningful commit messages
- Update documentation for any new features
- Ensure all tests pass before submitting
- Add tests for new functionality

### Code Style

- Use the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Run `flutter analyze` before committing
- Format code with `dart format .`

### Reporting Issues

When reporting issues, please include:
- A clear description of the problem
- Steps to reproduce the issue
- Expected vs actual behavior
- Flutter version (`flutter --version`)
- Platform and OS version

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with Flutter and Supabase**

</div>
