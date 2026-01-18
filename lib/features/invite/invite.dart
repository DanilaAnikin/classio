/// Invite feature exports.
///
/// This barrel file exports all components of the invite feature including
/// domain entities, repository interfaces, data implementations, and
/// presentation components (providers and widgets).
///
/// ## Usage
///
/// Import this file to access all invite-related functionality:
/// ```dart
/// import 'package:classio/features/invite/invite.dart';
/// ```
///
/// ## Architecture
///
/// The invite feature follows Clean Architecture with three layers:
/// - **Domain**: Entity ([InviteToken]) and repository interface ([InviteRepository])
/// - **Data**: Supabase implementation ([SupabaseInviteRepository])
/// - **Presentation**: Riverpod providers and UI widgets
///
/// ## Hierarchical Permissions
///
/// The invite system enforces strict hierarchical permission rules:
/// - SuperAdmin can invite: BigAdmin
/// - BigAdmin can invite: Admin, Teacher
/// - Admin can invite: Teacher, Parent
/// - Teacher can invite: Student (with specific class assignment)
/// - Student/Parent: Cannot invite anyone
library;

export 'domain/domain.dart';
export 'data/data.dart';
export 'presentation/presentation.dart';
