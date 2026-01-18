/// Principal (BigAdmin) Panel feature.
///
/// This feature provides the principal dashboard for school administrators
/// with BigAdmin role. Includes:
///
/// - Domain: Entities (SchoolStats, ClassWithDetails) and repository interface
/// - Data: Supabase repository implementation
/// - Presentation: Dashboard, tabs, providers, and widgets
library;

export 'data/data.dart';
export 'domain/domain.dart';
export 'presentation/presentation.dart';
