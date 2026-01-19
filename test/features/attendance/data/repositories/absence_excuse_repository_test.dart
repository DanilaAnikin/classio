import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/attendance/domain/entities/absence_excuse.dart';
import 'package:classio/features/attendance/domain/repositories/absence_excuse_repository.dart';
import 'package:classio/features/student/domain/entities/attendance.dart';

/// A mock implementation of AbsenceExcuseRepository for testing.
///
/// This allows testing the repository interface contract and
/// simulating various scenarios without requiring Supabase.
class MockAbsenceExcuseRepository implements AbsenceExcuseRepository {
  final Map<String, AbsenceExcuse> _excuses = {};
  final Map<String, AttendanceEntity> _attendanceRecords = {};
  String? currentUserId;
  String? currentUserRole;
  List<String> teacherSubjectIds = [];
  bool shouldThrowError = false;
  String errorMessage = 'Mock error';

  void reset() {
    _excuses.clear();
    _attendanceRecords.clear();
    currentUserId = null;
    currentUserRole = null;
    teacherSubjectIds = [];
    shouldThrowError = false;
    errorMessage = 'Mock error';
  }

  void setCurrentUser(String userId, String role) {
    currentUserId = userId;
    currentUserRole = role;
  }

  void addAttendance(AttendanceEntity attendance) {
    _attendanceRecords[attendance.id] = attendance;
  }

  void addExcuse(AbsenceExcuse excuse) {
    _excuses[excuse.id] = excuse;
  }

  @override
  Future<AbsenceExcuse> submitExcuse({
    required String attendanceId,
    required String studentId,
    required String reason,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Check if excuse already exists for this attendance
    final existing = _excuses.values.where(
      (e) => e.attendanceId == attendanceId,
    );
    if (existing.isNotEmpty) {
      throw Exception('An excuse for this attendance record already exists');
    }

    // Check if attendance exists and is excusable
    final attendance = _attendanceRecords[attendanceId];
    if (attendance != null) {
      if (attendance.status == AttendanceStatus.present) {
        throw Exception('Cannot submit excuse for present attendance');
      }
    }

    final now = DateTime.now();
    final excuse = AbsenceExcuse(
      id: 'excuse-${_excuses.length + 1}',
      attendanceId: attendanceId,
      studentId: studentId,
      parentId: currentUserId!,
      reason: reason,
      status: AbsenceExcuseStatus.pending,
      createdAt: now,
      updatedAt: now,
    );

    _excuses[excuse.id] = excuse;
    return excuse;
  }

  @override
  Future<List<AbsenceExcuse>> getExcusesForChild(String childId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _excuses.values
        .where((e) => e.studentId == childId && e.parentId == currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<AbsenceExcuse>> getAllParentExcuses() async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _excuses.values
        .where((e) => e.parentId == currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<AbsenceExcuse>> getPendingExcusesForChild(String childId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _excuses.values
        .where(
          (e) =>
              e.studentId == childId &&
              e.parentId == currentUserId &&
              e.status == AbsenceExcuseStatus.pending,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AbsenceExcuse?> getExcuseByAttendanceId(String attendanceId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    try {
      return _excuses.values.firstWhere((e) => e.attendanceId == attendanceId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AbsenceExcuse>> getPendingExcusesForTeacher() async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    // Return all pending excuses (simplified for testing)
    return _excuses.values
        .where((e) => e.status == AbsenceExcuseStatus.pending)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<AbsenceExcuse>> getAllExcusesForTeacher() async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _excuses.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AbsenceExcuse> approveExcuse(String excuseId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final excuse = _excuses[excuseId];
    if (excuse == null) {
      throw Exception('Excuse not found: $excuseId');
    }

    final updated = excuse.copyWith(
      status: AbsenceExcuseStatus.approved,
      teacherId: currentUserId,
      updatedAt: DateTime.now(),
    );

    _excuses[excuseId] = updated;

    // Update attendance record if exists
    final attendance = _attendanceRecords[excuse.attendanceId];
    if (attendance != null) {
      _attendanceRecords[excuse.attendanceId] = attendance.copyWith(
        status: AttendanceStatus.excused,
        excuseStatus: ExcuseStatus.approved,
      );
    }

    return updated;
  }

  @override
  Future<AbsenceExcuse> declineExcuse(String excuseId, {String? response}) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final excuse = _excuses[excuseId];
    if (excuse == null) {
      throw Exception('Excuse not found: $excuseId');
    }

    final updated = excuse.copyWith(
      status: AbsenceExcuseStatus.declined,
      teacherId: currentUserId,
      teacherResponse: response,
      updatedAt: DateTime.now(),
    );

    _excuses[excuseId] = updated;

    // Update attendance record if exists
    final attendance = _attendanceRecords[excuse.attendanceId];
    if (attendance != null) {
      _attendanceRecords[excuse.attendanceId] = attendance.copyWith(
        excuseStatus: ExcuseStatus.rejected,
      );
    }

    return updated;
  }

  @override
  Future<List<AbsenceExcuse>> getStudentExcuses() async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    if (currentUserId == null) {
      throw Exception('User not authenticated');
    }

    return _excuses.values
        .where((e) => e.studentId == currentUserId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<AbsenceExcuse?> getExcuseById(String excuseId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }

    return _excuses[excuseId];
  }

  @override
  Future<void> refresh() async {
    // No-op for mock
  }
}

void main() {
  late MockAbsenceExcuseRepository repository;

  setUp(() {
    repository = MockAbsenceExcuseRepository();
  });

  tearDown(() {
    repository.reset();
  });

  group('AbsenceExcuseRepository', () {
    group('submitExcuse', () {
      test('creates new excuse with pending status', () async {
        repository.setCurrentUser('parent-123', 'parent');

        final excuse = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Doctor appointment',
        );

        expect(excuse.attendanceId, equals('att-456'));
        expect(excuse.studentId, equals('student-789'));
        expect(excuse.parentId, equals('parent-123'));
        expect(excuse.reason, equals('Doctor appointment'));
        expect(excuse.status, equals(AbsenceExcuseStatus.pending));
        expect(excuse.isPending, isTrue);
      });

      test('throws when user not authenticated', () async {
        expect(
          () => repository.submitExcuse(
            attendanceId: 'att-456',
            studentId: 'student-789',
            reason: 'Doctor appointment',
          ),
          throwsException,
        );
      });

      test('throws when excuse already exists for attendance', () async {
        repository.setCurrentUser('parent-123', 'parent');

        await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Doctor appointment',
        );

        expect(
          () => repository.submitExcuse(
            attendanceId: 'att-456',
            studentId: 'student-789',
            reason: 'Another reason',
          ),
          throwsException,
        );
      });

      test('throws when submitting excuse for present attendance', () async {
        repository.setCurrentUser('parent-123', 'parent');

        final attendance = AttendanceEntity(
          id: 'att-456',
          studentId: 'student-789',
          lessonId: 'lesson-1',
          date: DateTime.now(),
          status: AttendanceStatus.present,
        );
        repository.addAttendance(attendance);

        expect(
          () => repository.submitExcuse(
            attendanceId: 'att-456',
            studentId: 'student-789',
            reason: 'Doctor appointment',
          ),
          throwsException,
        );
      });
    });

    group('getExcusesForChild', () {
      test('returns excuses for specific child', () async {
        repository.setCurrentUser('parent-123', 'parent');

        await repository.submitExcuse(
          attendanceId: 'att-1',
          studentId: 'child-1',
          reason: 'Sick',
        );
        await repository.submitExcuse(
          attendanceId: 'att-2',
          studentId: 'child-2',
          reason: 'Dentist',
        );
        await repository.submitExcuse(
          attendanceId: 'att-3',
          studentId: 'child-1',
          reason: 'Doctor',
        );

        final excuses = await repository.getExcusesForChild('child-1');

        expect(excuses.length, equals(2));
        expect(excuses.every((e) => e.studentId == 'child-1'), isTrue);
      });

      test('returns empty list when no excuses exist', () async {
        repository.setCurrentUser('parent-123', 'parent');

        final excuses = await repository.getExcusesForChild('child-1');

        expect(excuses, isEmpty);
      });

      test('throws when user not authenticated', () async {
        expect(
          () => repository.getExcusesForChild('child-1'),
          throwsException,
        );
      });
    });

    group('getPendingExcusesForChild', () {
      test('returns only pending excuses', () async {
        repository.setCurrentUser('parent-123', 'parent');

        final excuse1 = await repository.submitExcuse(
          attendanceId: 'att-1',
          studentId: 'child-1',
          reason: 'Sick',
        );
        await repository.submitExcuse(
          attendanceId: 'att-2',
          studentId: 'child-1',
          reason: 'Doctor',
        );

        // Approve one excuse
        repository.setCurrentUser('teacher-123', 'teacher');
        await repository.approveExcuse(excuse1.id);

        repository.setCurrentUser('parent-123', 'parent');
        final pending = await repository.getPendingExcusesForChild('child-1');

        expect(pending.length, equals(1));
        expect(pending.first.status, equals(AbsenceExcuseStatus.pending));
      });
    });

    group('getExcuseByAttendanceId', () {
      test('returns excuse when exists', () async {
        repository.setCurrentUser('parent-123', 'parent');

        await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Doctor appointment',
        );

        final excuse = await repository.getExcuseByAttendanceId('att-456');

        expect(excuse, isNotNull);
        expect(excuse!.attendanceId, equals('att-456'));
      });

      test('returns null when excuse does not exist', () async {
        final excuse = await repository.getExcuseByAttendanceId('non-existent');

        expect(excuse, isNull);
      });
    });

    group('getPendingExcusesForTeacher', () {
      test('returns pending excuses for teacher review', () async {
        repository.setCurrentUser('parent-123', 'parent');

        await repository.submitExcuse(
          attendanceId: 'att-1',
          studentId: 'student-1',
          reason: 'Sick',
        );
        await repository.submitExcuse(
          attendanceId: 'att-2',
          studentId: 'student-2',
          reason: 'Doctor',
        );

        repository.setCurrentUser('teacher-123', 'teacher');
        final pending = await repository.getPendingExcusesForTeacher();

        expect(pending.length, equals(2));
        expect(
          pending.every((e) => e.status == AbsenceExcuseStatus.pending),
          isTrue,
        );
      });

      test('throws when teacher not authenticated', () async {
        expect(
          () => repository.getPendingExcusesForTeacher(),
          throwsException,
        );
      });
    });

    group('approveExcuse', () {
      test('changes status to approved', () async {
        repository.setCurrentUser('parent-123', 'parent');
        final excuse = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Doctor appointment',
        );

        repository.setCurrentUser('teacher-123', 'teacher');
        final approved = await repository.approveExcuse(excuse.id);

        expect(approved.status, equals(AbsenceExcuseStatus.approved));
        expect(approved.isApproved, isTrue);
        expect(approved.teacherId, equals('teacher-123'));
      });

      test('updates related attendance record to excused', () async {
        repository.setCurrentUser('parent-123', 'parent');

        final attendance = AttendanceEntity(
          id: 'att-456',
          studentId: 'student-789',
          lessonId: 'lesson-1',
          date: DateTime.now(),
          status: AttendanceStatus.absent,
        );
        repository.addAttendance(attendance);

        final excuse = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Doctor appointment',
        );

        repository.setCurrentUser('teacher-123', 'teacher');
        await repository.approveExcuse(excuse.id);

        // Verify the attendance record was updated
        final updatedAttendance = repository._attendanceRecords['att-456'];
        expect(updatedAttendance!.status, equals(AttendanceStatus.excused));
        expect(updatedAttendance.excuseStatus, equals(ExcuseStatus.approved));
      });

      test('throws when excuse not found', () async {
        repository.setCurrentUser('teacher-123', 'teacher');

        expect(
          () => repository.approveExcuse('non-existent'),
          throwsException,
        );
      });

      test('throws when teacher not authenticated', () async {
        expect(
          () => repository.approveExcuse('excuse-1'),
          throwsException,
        );
      });
    });

    group('declineExcuse', () {
      test('changes status to declined', () async {
        repository.setCurrentUser('parent-123', 'parent');
        final excuse = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Not feeling well',
        );

        repository.setCurrentUser('teacher-123', 'teacher');
        final declined = await repository.declineExcuse(excuse.id);

        expect(declined.status, equals(AbsenceExcuseStatus.declined));
        expect(declined.isDeclined, isTrue);
        expect(declined.teacherId, equals('teacher-123'));
      });

      test('includes teacher response when provided', () async {
        repository.setCurrentUser('parent-123', 'parent');
        final excuse = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Not feeling well',
        );

        repository.setCurrentUser('teacher-123', 'teacher');
        final declined = await repository.declineExcuse(
          excuse.id,
          response: 'Please provide documentation',
        );

        expect(declined.teacherResponse, equals('Please provide documentation'));
      });

      test('updates related attendance record excuse status', () async {
        repository.setCurrentUser('parent-123', 'parent');

        final attendance = AttendanceEntity(
          id: 'att-456',
          studentId: 'student-789',
          lessonId: 'lesson-1',
          date: DateTime.now(),
          status: AttendanceStatus.absent,
        );
        repository.addAttendance(attendance);

        final excuse = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Not feeling well',
        );

        repository.setCurrentUser('teacher-123', 'teacher');
        await repository.declineExcuse(excuse.id);

        final updatedAttendance = repository._attendanceRecords['att-456'];
        expect(updatedAttendance!.excuseStatus, equals(ExcuseStatus.rejected));
      });

      test('throws when excuse not found', () async {
        repository.setCurrentUser('teacher-123', 'teacher');

        expect(
          () => repository.declineExcuse('non-existent'),
          throwsException,
        );
      });
    });

    group('getStudentExcuses', () {
      test('returns excuses for current student', () async {
        repository.setCurrentUser('parent-123', 'parent');

        await repository.submitExcuse(
          attendanceId: 'att-1',
          studentId: 'student-1',
          reason: 'Sick',
        );
        await repository.submitExcuse(
          attendanceId: 'att-2',
          studentId: 'student-2',
          reason: 'Doctor',
        );

        repository.setCurrentUser('student-1', 'student');
        final excuses = await repository.getStudentExcuses();

        expect(excuses.length, equals(1));
        expect(excuses.first.studentId, equals('student-1'));
      });
    });

    group('getExcuseById', () {
      test('returns excuse when exists', () async {
        repository.setCurrentUser('parent-123', 'parent');
        final created = await repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Doctor appointment',
        );

        final excuse = await repository.getExcuseById(created.id);

        expect(excuse, isNotNull);
        expect(excuse!.id, equals(created.id));
      });

      test('returns null when excuse does not exist', () async {
        final excuse = await repository.getExcuseById('non-existent');

        expect(excuse, isNull);
      });
    });

    group('error handling', () {
      test('throws exception when error flag is set', () async {
        repository.setCurrentUser('parent-123', 'parent');
        repository.shouldThrowError = true;
        repository.errorMessage = 'Database connection failed';

        expect(
          () => repository.submitExcuse(
            attendanceId: 'att-456',
            studentId: 'student-789',
            reason: 'Sick',
          ),
          throwsException,
        );
      });
    });
  });

  group('Absence Excuse Workflow', () {
    test('parent submits excuse -> teacher approves -> status updated', () async {
      // Step 1: Parent submits excuse
      repository.setCurrentUser('parent-123', 'parent');

      final attendance = AttendanceEntity(
        id: 'att-456',
        studentId: 'student-789',
        lessonId: 'lesson-1',
        date: DateTime.now(),
        status: AttendanceStatus.absent,
      );
      repository.addAttendance(attendance);

      final excuse = await repository.submitExcuse(
        attendanceId: 'att-456',
        studentId: 'student-789',
        reason: 'Doctor appointment with documentation',
      );

      expect(excuse.isPending, isTrue);

      // Step 2: Teacher reviews and approves
      repository.setCurrentUser('teacher-123', 'teacher');
      final pendingExcuses = await repository.getPendingExcusesForTeacher();
      expect(pendingExcuses.length, equals(1));

      final approved = await repository.approveExcuse(excuse.id);

      // Step 3: Verify status updated
      expect(approved.isApproved, isTrue);
      expect(approved.teacherId, equals('teacher-123'));

      // Step 4: Verify attendance record updated
      final updatedAttendance = repository._attendanceRecords['att-456'];
      expect(updatedAttendance!.status, equals(AttendanceStatus.excused));
      expect(updatedAttendance.excuseStatus, equals(ExcuseStatus.approved));
    });

    test('parent submits excuse -> teacher declines -> status updated', () async {
      // Step 1: Parent submits excuse
      repository.setCurrentUser('parent-123', 'parent');

      final attendance = AttendanceEntity(
        id: 'att-456',
        studentId: 'student-789',
        lessonId: 'lesson-1',
        date: DateTime.now(),
        status: AttendanceStatus.absent,
      );
      repository.addAttendance(attendance);

      final excuse = await repository.submitExcuse(
        attendanceId: 'att-456',
        studentId: 'student-789',
        reason: 'Not feeling well',
      );

      expect(excuse.isPending, isTrue);

      // Step 2: Teacher reviews and declines
      repository.setCurrentUser('teacher-123', 'teacher');
      final declined = await repository.declineExcuse(
        excuse.id,
        response: 'Please provide a doctors note',
      );

      // Step 3: Verify status updated
      expect(declined.isDeclined, isTrue);
      expect(declined.teacherResponse, equals('Please provide a doctors note'));

      // Step 4: Verify attendance record updated
      final updatedAttendance = repository._attendanceRecords['att-456'];
      expect(updatedAttendance!.excuseStatus, equals(ExcuseStatus.rejected));
    });

    test('cannot submit excuse for present attendance', () async {
      repository.setCurrentUser('parent-123', 'parent');

      final attendance = AttendanceEntity(
        id: 'att-456',
        studentId: 'student-789',
        lessonId: 'lesson-1',
        date: DateTime.now(),
        status: AttendanceStatus.present,
      );
      repository.addAttendance(attendance);

      expect(
        () => repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'I was actually absent',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('present'),
          ),
        ),
      );
    });

    test('cannot submit multiple excuses for same attendance', () async {
      repository.setCurrentUser('parent-123', 'parent');

      final attendance = AttendanceEntity(
        id: 'att-456',
        studentId: 'student-789',
        lessonId: 'lesson-1',
        date: DateTime.now(),
        status: AttendanceStatus.absent,
      );
      repository.addAttendance(attendance);

      // First excuse succeeds
      await repository.submitExcuse(
        attendanceId: 'att-456',
        studentId: 'student-789',
        reason: 'Doctor appointment',
      );

      // Second excuse fails
      expect(
        () => repository.submitExcuse(
          attendanceId: 'att-456',
          studentId: 'student-789',
          reason: 'Different reason',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('already exists'),
          ),
        ),
      );
    });

    test('full workflow: absence -> excuse submitted -> approved -> marked excused', () async {
      // Initial state: student is marked absent
      final attendance = AttendanceEntity(
        id: 'att-456',
        studentId: 'student-789',
        lessonId: 'lesson-1',
        date: DateTime.now(),
        status: AttendanceStatus.absent,
        excuseStatus: ExcuseStatus.none,
      );
      repository.addAttendance(attendance);

      // Parent submits excuse
      repository.setCurrentUser('parent-123', 'parent');
      final excuse = await repository.submitExcuse(
        attendanceId: 'att-456',
        studentId: 'student-789',
        reason: 'Hospital visit - documentation attached',
      );

      // Verify excuse created with pending status
      expect(excuse.status, equals(AbsenceExcuseStatus.pending));

      // Parent can see their pending excuses
      final parentExcuses = await repository.getExcusesForChild('student-789');
      expect(parentExcuses.length, equals(1));

      // Teacher sees pending excuses
      repository.setCurrentUser('teacher-123', 'teacher');
      final teacherPending = await repository.getPendingExcusesForTeacher();
      expect(teacherPending.length, equals(1));

      // Teacher approves
      final approved = await repository.approveExcuse(excuse.id);
      expect(approved.status, equals(AbsenceExcuseStatus.approved));

      // Pending list is now empty
      final teacherPendingAfter = await repository.getPendingExcusesForTeacher();
      expect(teacherPendingAfter, isEmpty);

      // Attendance is marked as excused
      final finalAttendance = repository._attendanceRecords['att-456'];
      expect(finalAttendance!.status, equals(AttendanceStatus.excused));
      expect(finalAttendance.excuseStatus, equals(ExcuseStatus.approved));

      // Student can see their excuse was approved
      repository.setCurrentUser('student-789', 'student');
      final studentExcuses = await repository.getStudentExcuses();
      expect(studentExcuses.length, equals(1));
      expect(studentExcuses.first.isApproved, isTrue);
    });
  });
}
