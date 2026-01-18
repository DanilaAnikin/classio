/// Domain entities for the Parent feature.
///
/// This barrel file exports all entity classes used in the parent domain.
/// The parent feature reuses entities from the student feature for attendance.
library;

export 'child_info.dart';

// Re-export attendance entities from student feature
export '../../../student/domain/entities/attendance.dart';
