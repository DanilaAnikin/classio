import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/theme.dart';
import '../../../auth/domain/entities/app_user.dart';

/// Provider that fetches students for a specific class.
final principalClassStudentsProvider =
    FutureProvider.family<List<AppUser>, String>((ref, classId) async {
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('class_students')
      .select('student:profiles!class_students_student_id_fkey(*)')
      .eq('class_id', classId);

  return (response as List)
      .map((r) => AppUser.fromJson(r['student'] as Map<String, dynamic>))
      .toList();
});

/// A dialog that displays all students enrolled in a class.
class ViewClassStudentsDialog extends ConsumerWidget {
  /// Creates a [ViewClassStudentsDialog].
  const ViewClassStudentsDialog({
    super.key,
    required this.classId,
    required this.className,
  });

  /// The ID of the class to view students for.
  final String classId;

  /// The name of the class (for display purposes).
  final String className;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(principalClassStudentsProvider(classId));
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text('Students in $className'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: studentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (students) {
            if (students.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No students enrolled in this class',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final avatarUrl = student.avatarUrl;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                    backgroundImage: avatarUrl != null
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null
                        ? Text(
                            student.displayName.isNotEmpty
                                ? student.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(color: theme.colorScheme.primary),
                          )
                        : null,
                  ),
                  title: Text(student.displayName),
                  subtitle: Text(student.email ?? ''),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
