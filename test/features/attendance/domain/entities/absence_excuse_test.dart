import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/attendance/domain/entities/absence_excuse.dart';

void main() {
  group('AbsenceExcuseStatus', () {
    group('fromString', () {
      test('parses all valid status strings correctly', () {
        expect(
          AbsenceExcuseStatus.fromString('pending'),
          equals(AbsenceExcuseStatus.pending),
        );
        expect(
          AbsenceExcuseStatus.fromString('approved'),
          equals(AbsenceExcuseStatus.approved),
        );
        expect(
          AbsenceExcuseStatus.fromString('declined'),
          equals(AbsenceExcuseStatus.declined),
        );
      });

      test('is case insensitive', () {
        expect(
          AbsenceExcuseStatus.fromString('PENDING'),
          equals(AbsenceExcuseStatus.pending),
        );
        expect(
          AbsenceExcuseStatus.fromString('Approved'),
          equals(AbsenceExcuseStatus.approved),
        );
        expect(
          AbsenceExcuseStatus.fromString('DECLINED'),
          equals(AbsenceExcuseStatus.declined),
        );
      });

      test('returns pending for null input', () {
        expect(
          AbsenceExcuseStatus.fromString(null),
          equals(AbsenceExcuseStatus.pending),
        );
      });

      test('returns pending for unknown status', () {
        expect(
          AbsenceExcuseStatus.fromString('unknown'),
          equals(AbsenceExcuseStatus.pending),
        );
        expect(
          AbsenceExcuseStatus.fromString('invalid'),
          equals(AbsenceExcuseStatus.pending),
        );
      });
    });

    group('label', () {
      test('returns correct labels for all statuses', () {
        expect(AbsenceExcuseStatus.pending.label, equals('Pending'));
        expect(AbsenceExcuseStatus.approved.label, equals('Approved'));
        expect(AbsenceExcuseStatus.declined.label, equals('Declined'));
      });
    });
  });

  group('AbsenceExcuse', () {
    final now = DateTime.now();
    final baseJson = {
      'id': 'excuse-123',
      'attendance_id': 'att-456',
      'student_id': 'student-789',
      'parent_id': 'parent-012',
      'reason': 'Doctor appointment',
      'status': 'pending',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    group('creation', () {
      test('creates entity with required fields', () {
        final excuse = AbsenceExcuse(
          id: 'excuse-123',
          attendanceId: 'att-456',
          studentId: 'student-789',
          parentId: 'parent-012',
          reason: 'Doctor appointment',
          status: AbsenceExcuseStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        expect(excuse.id, equals('excuse-123'));
        expect(excuse.attendanceId, equals('att-456'));
        expect(excuse.studentId, equals('student-789'));
        expect(excuse.parentId, equals('parent-012'));
        expect(excuse.reason, equals('Doctor appointment'));
        expect(excuse.status, equals(AbsenceExcuseStatus.pending));
        expect(excuse.createdAt, equals(now));
        expect(excuse.updatedAt, equals(now));
      });

      test('creates entity with optional fields', () {
        final excuse = AbsenceExcuse(
          id: 'excuse-123',
          attendanceId: 'att-456',
          studentId: 'student-789',
          parentId: 'parent-012',
          reason: 'Doctor appointment',
          status: AbsenceExcuseStatus.declined,
          createdAt: now,
          updatedAt: now,
          teacherResponse: 'Please provide documentation',
          teacherId: 'teacher-456',
          studentName: 'John Doe',
          parentName: 'Jane Doe',
          teacherName: 'Mr. Smith',
          subjectName: 'Mathematics',
          attendanceDate: now,
          lessonStartTime: now,
          lessonEndTime: now.add(const Duration(hours: 1)),
        );

        expect(excuse.teacherResponse, equals('Please provide documentation'));
        expect(excuse.teacherId, equals('teacher-456'));
        expect(excuse.studentName, equals('John Doe'));
        expect(excuse.parentName, equals('Jane Doe'));
        expect(excuse.teacherName, equals('Mr. Smith'));
        expect(excuse.subjectName, equals('Mathematics'));
      });
    });

    group('fromJson', () {
      test('parses basic JSON correctly', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);

        expect(excuse.id, equals('excuse-123'));
        expect(excuse.attendanceId, equals('att-456'));
        expect(excuse.studentId, equals('student-789'));
        expect(excuse.parentId, equals('parent-012'));
        expect(excuse.reason, equals('Doctor appointment'));
        expect(excuse.status, equals(AbsenceExcuseStatus.pending));
      });

      test('parses JSON with teacher response', () {
        final json = {
          ...baseJson,
          'status': 'declined',
          'teacher_response': 'Need more details',
          'teacher_id': 'teacher-123',
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.status, equals(AbsenceExcuseStatus.declined));
        expect(excuse.teacherResponse, equals('Need more details'));
        expect(excuse.teacherId, equals('teacher-123'));
      });

      test('parses JSON with nested student profile', () {
        final json = {
          ...baseJson,
          'student': {
            'first_name': 'John',
            'last_name': 'Doe',
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.studentName, equals('John Doe'));
      });

      test('parses JSON with nested parent profile', () {
        final json = {
          ...baseJson,
          'parent': {
            'first_name': 'Jane',
            'last_name': 'Doe',
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.parentName, equals('Jane Doe'));
      });

      test('parses JSON with nested teacher profile', () {
        final json = {
          ...baseJson,
          'teacher': {
            'first_name': 'Mr',
            'last_name': 'Smith',
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.teacherName, equals('Mr Smith'));
      });

      test('parses JSON with nested attendance and lesson data', () {
        final json = {
          ...baseJson,
          'attendance': {
            'date': '2025-01-15',
            'lessons': {
              'start_time': '09:00',
              'end_time': '10:00',
              'subjects': {
                'name': 'Mathematics',
              },
            },
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.attendanceDate, isNotNull);
        expect(excuse.attendanceDate!.year, equals(2025));
        expect(excuse.attendanceDate!.month, equals(1));
        expect(excuse.attendanceDate!.day, equals(15));
        expect(excuse.subjectName, equals('Mathematics'));
        expect(excuse.lessonStartTime!.hour, equals(9));
        expect(excuse.lessonStartTime!.minute, equals(0));
        expect(excuse.lessonEndTime!.hour, equals(10));
        expect(excuse.lessonEndTime!.minute, equals(0));
      });

      test('handles first name only in profile', () {
        final json = {
          ...baseJson,
          'student': {
            'first_name': 'John',
            'last_name': null,
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.studentName, equals('John'));
      });

      test('handles last name only in profile', () {
        final json = {
          ...baseJson,
          'student': {
            'first_name': null,
            'last_name': 'Doe',
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.studentName, equals('Doe'));
      });

      test('handles empty strings in profile names', () {
        final json = {
          ...baseJson,
          'student': {
            'first_name': '',
            'last_name': 'Doe',
          },
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.studentName, equals('Doe'));
      });

      test('handles null profile', () {
        final json = {
          ...baseJson,
          'student': null,
        };

        final excuse = AbsenceExcuse.fromJson(json);

        expect(excuse.studentName, isNull);
      });
    });

    group('status helpers', () {
      test('isPending returns true only for pending status', () {
        final pending = AbsenceExcuse.fromJson({...baseJson, 'status': 'pending'});
        final approved = AbsenceExcuse.fromJson({...baseJson, 'status': 'approved'});
        final declined = AbsenceExcuse.fromJson({...baseJson, 'status': 'declined'});

        expect(pending.isPending, isTrue);
        expect(approved.isPending, isFalse);
        expect(declined.isPending, isFalse);
      });

      test('isApproved returns true only for approved status', () {
        final pending = AbsenceExcuse.fromJson({...baseJson, 'status': 'pending'});
        final approved = AbsenceExcuse.fromJson({...baseJson, 'status': 'approved'});
        final declined = AbsenceExcuse.fromJson({...baseJson, 'status': 'declined'});

        expect(pending.isApproved, isFalse);
        expect(approved.isApproved, isTrue);
        expect(declined.isApproved, isFalse);
      });

      test('isDeclined returns true only for declined status', () {
        final pending = AbsenceExcuse.fromJson({...baseJson, 'status': 'pending'});
        final approved = AbsenceExcuse.fromJson({...baseJson, 'status': 'approved'});
        final declined = AbsenceExcuse.fromJson({...baseJson, 'status': 'declined'});

        expect(pending.isDeclined, isFalse);
        expect(approved.isDeclined, isFalse);
        expect(declined.isDeclined, isTrue);
      });
    });

    group('status transitions', () {
      test('excuse starts as pending', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);
        expect(excuse.status, equals(AbsenceExcuseStatus.pending));
        expect(excuse.isPending, isTrue);
      });

      test('can be approved via copyWith', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);
        final approved = excuse.copyWith(
          status: AbsenceExcuseStatus.approved,
          teacherId: 'teacher-123',
        );

        expect(approved.status, equals(AbsenceExcuseStatus.approved));
        expect(approved.teacherId, equals('teacher-123'));
        expect(approved.isApproved, isTrue);
      });

      test('can be declined via copyWith with response', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);
        final declined = excuse.copyWith(
          status: AbsenceExcuseStatus.declined,
          teacherId: 'teacher-123',
          teacherResponse: 'Not a valid excuse',
        );

        expect(declined.status, equals(AbsenceExcuseStatus.declined));
        expect(declined.teacherResponse, equals('Not a valid excuse'));
        expect(declined.isDeclined, isTrue);
      });
    });

    group('toJson', () {
      test('converts entity to JSON correctly', () {
        final excuse = AbsenceExcuse(
          id: 'excuse-123',
          attendanceId: 'att-456',
          studentId: 'student-789',
          parentId: 'parent-012',
          reason: 'Doctor appointment',
          status: AbsenceExcuseStatus.pending,
          createdAt: now,
          updatedAt: now,
        );

        final json = excuse.toJson();

        expect(json['id'], equals('excuse-123'));
        expect(json['attendance_id'], equals('att-456'));
        expect(json['student_id'], equals('student-789'));
        expect(json['parent_id'], equals('parent-012'));
        expect(json['reason'], equals('Doctor appointment'));
        expect(json['status'], equals('pending'));
        expect(json['created_at'], isNotNull);
        expect(json['updated_at'], isNotNull);
      });

      test('includes optional fields in JSON', () {
        final excuse = AbsenceExcuse(
          id: 'excuse-123',
          attendanceId: 'att-456',
          studentId: 'student-789',
          parentId: 'parent-012',
          reason: 'Doctor appointment',
          status: AbsenceExcuseStatus.declined,
          teacherResponse: 'Need documentation',
          teacherId: 'teacher-123',
          createdAt: now,
          updatedAt: now,
        );

        final json = excuse.toJson();

        expect(json['teacher_response'], equals('Need documentation'));
        expect(json['teacher_id'], equals('teacher-123'));
        expect(json['status'], equals('declined'));
      });
    });

    group('copyWith', () {
      test('creates copy with changed status', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);
        final copy = excuse.copyWith(status: AbsenceExcuseStatus.approved);

        expect(copy.status, equals(AbsenceExcuseStatus.approved));
        expect(copy.id, equals(excuse.id));
        expect(copy.reason, equals(excuse.reason));
      });

      test('creates copy with teacher response', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);
        final copy = excuse.copyWith(
          status: AbsenceExcuseStatus.declined,
          teacherResponse: 'Invalid excuse',
        );

        expect(copy.teacherResponse, equals('Invalid excuse'));
      });

      test('preserves all fields when no changes specified', () {
        final excuse = AbsenceExcuse(
          id: 'excuse-123',
          attendanceId: 'att-456',
          studentId: 'student-789',
          parentId: 'parent-012',
          reason: 'Doctor appointment',
          status: AbsenceExcuseStatus.pending,
          createdAt: now,
          updatedAt: now,
          studentName: 'John Doe',
          subjectName: 'Math',
        );

        final copy = excuse.copyWith();

        expect(copy.id, equals(excuse.id));
        expect(copy.attendanceId, equals(excuse.attendanceId));
        expect(copy.studentId, equals(excuse.studentId));
        expect(copy.parentId, equals(excuse.parentId));
        expect(copy.reason, equals(excuse.reason));
        expect(copy.status, equals(excuse.status));
        expect(copy.studentName, equals(excuse.studentName));
        expect(copy.subjectName, equals(excuse.subjectName));
      });
    });

    group('equality', () {
      test('excuses with same id are equal', () {
        final excuse1 = AbsenceExcuse.fromJson(baseJson);
        final excuse2 = AbsenceExcuse.fromJson(baseJson);

        expect(excuse1, equals(excuse2));
        expect(excuse1.hashCode, equals(excuse2.hashCode));
      });

      test('excuses with different ids are not equal', () {
        final excuse1 = AbsenceExcuse.fromJson(baseJson);
        final excuse2 = AbsenceExcuse.fromJson({...baseJson, 'id': 'excuse-999'});

        expect(excuse1, isNot(equals(excuse2)));
      });
    });

    group('toString', () {
      test('returns readable representation', () {
        final excuse = AbsenceExcuse.fromJson(baseJson);

        final str = excuse.toString();
        expect(str, contains('AbsenceExcuse'));
        expect(str, contains('excuse-123'));
        expect(str, contains('student-789'));
        expect(str, contains('pending'));
      });
    });
  });
}
