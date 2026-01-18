/// Teacher feature exports.
///
/// This barrel file exports all components of the teacher feature including
/// domain entities, repository interfaces, data implementations, and
/// presentation components (providers, pages, tabs, widgets, and dialogs).
///
/// ## Usage
///
/// Import this file to access all teacher-related functionality:
/// ```dart
/// import 'package:classio/features/teacher/teacher.dart';
/// ```
///
/// ## Architecture
///
/// The teacher feature follows Clean Architecture with three layers:
/// - **Domain**: Entities and repository interface ([TeacherRepository])
/// - **Data**: Supabase implementation ([SupabaseTeacherRepository])
/// - **Presentation**: Riverpod providers, pages, tabs, widgets, and dialogs
///
/// ## Features
///
/// The teacher dashboard provides:
/// - **Overview**: Quick stats, today's lessons, pending excuses
/// - **Gradebook**: Grade grid with students vs assignments
/// - **Attendance**: Mark attendance for lessons with Present/Absent/Late toggles
/// - **My Students**: View and manage students by class
/// - **Assignments**: Create and manage assignments
library;

export 'domain/domain.dart';
export 'data/data.dart';
export 'presentation/presentation.dart';
