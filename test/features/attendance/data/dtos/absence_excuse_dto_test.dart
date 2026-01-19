import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/attendance/data/dtos/absence_excuse_dto.dart';
import 'package:classio/features/attendance/domain/entities/absence_excuse.dart';

void main() {
  final now = DateTime.now();

  Map<String, dynamic> createValidJson({
    String id = 'excuse-123',
    String attendanceId = 'att-456',
    String studentId = 'student-789',
    String parentId = 'parent-012',
    String reason = 'Doctor appointment',
    String status = 'pending',
    String? teacherResponse,
    String? teacherId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return {
      'id': id,
      'attendance_id': attendanceId,
      'student_id': studentId,
      'parent_id': parentId,
      'reason': reason,
      'status': status,
      'teacher_response': teacherResponse,
      'teacher_id': teacherId,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': (updatedAt ?? now).toIso8601String(),
    };
  }

  group('AbsenceExcuseDTO', () {
    group('fromJson', () {
      test('parses valid JSON correctly', () {
        final json = createValidJson();
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.id, equals('excuse-123'));
        expect(dto.attendanceId, equals('att-456'));
        expect(dto.studentId, equals('student-789'));
        expect(dto.parentId, equals('parent-012'));
        expect(dto.reason, equals('Doctor appointment'));
        expect(dto.status, equals(AbsenceExcuseStatus.pending));
      });

      test('parses teacher response and id', () {
        final json = createValidJson(
          status: 'declined',
          teacherResponse: 'Need documentation',
          teacherId: 'teacher-123',
        );
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.teacherResponse, equals('Need documentation'));
        expect(dto.teacherId, equals('teacher-123'));
        expect(dto.status, equals(AbsenceExcuseStatus.declined));
      });

      test('parses nested student profile', () {
        final json = {
          ...createValidJson(),
          'student': {
            'first_name': 'John',
            'last_name': 'Doe',
          },
        };
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.studentName, equals('John Doe'));
      });

      test('parses nested parent profile', () {
        final json = {
          ...createValidJson(),
          'parent': {
            'first_name': 'Jane',
            'last_name': 'Doe',
          },
        };
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.parentName, equals('Jane Doe'));
      });

      test('parses nested teacher profile', () {
        final json = {
          ...createValidJson(),
          'teacher': {
            'first_name': 'Mr',
            'last_name': 'Smith',
          },
        };
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.teacherName, equals('Mr Smith'));
      });

      test('parses nested attendance and lesson data', () {
        final json = {
          ...createValidJson(),
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
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.attendanceDate, isNotNull);
        expect(dto.attendanceDate!.year, equals(2025));
        expect(dto.attendanceDate!.month, equals(1));
        expect(dto.attendanceDate!.day, equals(15));
        expect(dto.subjectName, equals('Mathematics'));
        expect(dto.lessonStartTime!.hour, equals(9));
        expect(dto.lessonStartTime!.minute, equals(0));
        expect(dto.lessonEndTime!.hour, equals(10));
        expect(dto.lessonEndTime!.minute, equals(0));
      });

      test('handles null profile data gracefully', () {
        final json = {
          ...createValidJson(),
          'student': null,
          'parent': null,
          'teacher': null,
        };
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.studentName, isNull);
        expect(dto.parentName, isNull);
        expect(dto.teacherName, isNull);
        expect(dto.isValid, isTrue);
      });

      test('handles null attendance data gracefully', () {
        final json = {
          ...createValidJson(),
          'attendance': null,
        };
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.attendanceDate, isNull);
        expect(dto.subjectName, isNull);
        expect(dto.lessonStartTime, isNull);
        expect(dto.lessonEndTime, isNull);
        expect(dto.isValid, isTrue);
      });

      test('defaults status to pending for unknown values', () {
        final json = {...createValidJson(), 'status': 'unknown'};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.status, equals(AbsenceExcuseStatus.pending));
      });
    });

    group('isValid', () {
      test('returns true for valid complete DTO', () {
        final json = createValidJson();
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isTrue);
        expect(dto.validationErrors, isEmpty);
      });

      test('returns false when id is null', () {
        final json = {...createValidJson(), 'id': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('id is required'));
      });

      test('returns false when id is empty', () {
        final json = {...createValidJson(), 'id': ''};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('id is required'));
      });

      test('returns false when attendance_id is null', () {
        final json = {...createValidJson(), 'attendance_id': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('attendance_id is required'));
      });

      test('returns false when attendance_id is empty', () {
        final json = {...createValidJson(), 'attendance_id': ''};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('attendance_id is required'));
      });

      test('returns false when student_id is null', () {
        final json = {...createValidJson(), 'student_id': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('student_id is required'));
      });

      test('returns false when student_id is empty', () {
        final json = {...createValidJson(), 'student_id': ''};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('student_id is required'));
      });

      test('returns false when parent_id is null', () {
        final json = {...createValidJson(), 'parent_id': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('parent_id is required'));
      });

      test('returns false when parent_id is empty', () {
        final json = {...createValidJson(), 'parent_id': ''};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('parent_id is required'));
      });

      test('returns false when reason is null', () {
        final json = {...createValidJson(), 'reason': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('reason is required'));
      });

      test('returns false when reason is empty', () {
        final json = {...createValidJson(), 'reason': ''};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('reason is required'));
      });

      test('returns false when created_at is null', () {
        final json = {...createValidJson(), 'created_at': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('created_at is required'));
      });

      test('returns false when updated_at is null', () {
        final json = {...createValidJson(), 'updated_at': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors, contains('updated_at is required'));
      });

      test('collects multiple validation errors', () {
        final json = {
          'id': null,
          'attendance_id': '',
          'student_id': null,
          'parent_id': '',
          'reason': null,
          'status': 'pending',
          'created_at': null,
          'updated_at': null,
        };
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(dto.isValid, isFalse);
        expect(dto.validationErrors.length, greaterThanOrEqualTo(6));
        expect(dto.validationErrors, contains('id is required'));
        expect(dto.validationErrors, contains('attendance_id is required'));
        expect(dto.validationErrors, contains('student_id is required'));
        expect(dto.validationErrors, contains('parent_id is required'));
        expect(dto.validationErrors, contains('reason is required'));
      });
    });

    group('toEntity', () {
      test('converts valid DTO to entity', () {
        final json = createValidJson();
        final dto = AbsenceExcuseDTO.fromJson(json);
        final entity = dto.toEntity();

        expect(entity.id, equals('excuse-123'));
        expect(entity.attendanceId, equals('att-456'));
        expect(entity.studentId, equals('student-789'));
        expect(entity.parentId, equals('parent-012'));
        expect(entity.reason, equals('Doctor appointment'));
        expect(entity.status, equals(AbsenceExcuseStatus.pending));
      });

      test('throws StateError for invalid DTO', () {
        final json = {...createValidJson(), 'id': null};
        final dto = AbsenceExcuseDTO.fromJson(json);

        expect(
          () => dto.toEntity(),
          throwsA(isA<StateError>()),
        );
      });

      test('includes optional fields in entity', () {
        final json = {
          ...createValidJson(
            status: 'declined',
            teacherResponse: 'Need documentation',
            teacherId: 'teacher-123',
          ),
          'student': {'first_name': 'John', 'last_name': 'Doe'},
          'parent': {'first_name': 'Jane', 'last_name': 'Doe'},
        };
        final dto = AbsenceExcuseDTO.fromJson(json);
        final entity = dto.toEntity();

        expect(entity.teacherResponse, equals('Need documentation'));
        expect(entity.teacherId, equals('teacher-123'));
        expect(entity.studentName, equals('John Doe'));
        expect(entity.parentName, equals('Jane Doe'));
      });
    });

    group('toEntityOrNull', () {
      test('returns entity for valid DTO', () {
        final json = createValidJson();
        final dto = AbsenceExcuseDTO.fromJson(json);
        final entity = dto.toEntityOrNull(logErrors: false);

        expect(entity, isNotNull);
        expect(entity!.id, equals('excuse-123'));
      });

      test('returns null for invalid DTO', () {
        final json = {...createValidJson(), 'id': null};
        final dto = AbsenceExcuseDTO.fromJson(json);
        final entity = dto.toEntityOrNull(logErrors: false);

        expect(entity, isNull);
      });
    });

    group('toJson', () {
      test('converts DTO back to JSON', () {
        final json = createValidJson(
          status: 'approved',
          teacherResponse: 'Approved',
          teacherId: 'teacher-123',
        );
        final dto = AbsenceExcuseDTO.fromJson(json);
        final output = dto.toJson();

        expect(output['id'], equals('excuse-123'));
        expect(output['attendance_id'], equals('att-456'));
        expect(output['student_id'], equals('student-789'));
        expect(output['parent_id'], equals('parent-012'));
        expect(output['reason'], equals('Doctor appointment'));
        expect(output['status'], equals('approved'));
        expect(output['teacher_response'], equals('Approved'));
        expect(output['teacher_id'], equals('teacher-123'));
      });
    });

    group('toString', () {
      test('returns readable representation', () {
        final json = createValidJson();
        final dto = AbsenceExcuseDTO.fromJson(json);

        final str = dto.toString();
        expect(str, contains('AbsenceExcuseDTO'));
        expect(str, contains('excuse-123'));
        expect(str, contains('student-789'));
        expect(str, contains('pending'));
        expect(str, contains('isValid: true'));
      });
    });
  });

  group('AbsenceExcuseDTOListParser', () {
    test('parses list of JSON maps to DTOs', () {
      final jsonList = [
        createValidJson(id: 'excuse-1'),
        createValidJson(id: 'excuse-2'),
        createValidJson(id: 'excuse-3'),
      ];

      final dtos = jsonList.toAbsenceExcuseDTOs();

      expect(dtos.length, equals(3));
      expect(dtos[0].id, equals('excuse-1'));
      expect(dtos[1].id, equals('excuse-2'));
      expect(dtos[2].id, equals('excuse-3'));
    });

    test('parses and converts to entities, filtering invalid', () {
      final jsonList = [
        createValidJson(id: 'excuse-1'),
        {...createValidJson(id: 'excuse-2'), 'id': null}, // Invalid
        createValidJson(id: 'excuse-3'),
      ];

      final entities = jsonList.toAbsenceExcuses(logErrors: false);

      expect(entities.length, equals(2));
      expect(entities[0].id, equals('excuse-1'));
      expect(entities[1].id, equals('excuse-3'));
    });

    test('returns empty list for empty input', () {
      final jsonList = <Map<String, dynamic>>[];

      final dtos = jsonList.toAbsenceExcuseDTOs();
      final entities = jsonList.toAbsenceExcuses(logErrors: false);

      expect(dtos, isEmpty);
      expect(entities, isEmpty);
    });
  });

  group('Nested Data Parsing Edge Cases', () {
    test('handles profile with only first_name', () {
      final json = {
        ...createValidJson(),
        'student': {'first_name': 'John'},
      };
      final dto = AbsenceExcuseDTO.fromJson(json);

      expect(dto.studentName, equals('John'));
    });

    test('handles profile with only last_name', () {
      final json = {
        ...createValidJson(),
        'student': {'last_name': 'Doe'},
      };
      final dto = AbsenceExcuseDTO.fromJson(json);

      expect(dto.studentName, equals('Doe'));
    });

    test('handles attendance without lessons', () {
      final json = {
        ...createValidJson(),
        'attendance': {
          'date': '2025-01-15',
        },
      };
      final dto = AbsenceExcuseDTO.fromJson(json);

      expect(dto.attendanceDate, isNotNull);
      expect(dto.lessonStartTime, isNull);
      expect(dto.lessonEndTime, isNull);
      expect(dto.subjectName, isNull);
    });

    test('handles lessons without subjects', () {
      final json = {
        ...createValidJson(),
        'attendance': {
          'date': '2025-01-15',
          'lessons': {
            'start_time': '09:00',
            'end_time': '10:00',
          },
        },
      };
      final dto = AbsenceExcuseDTO.fromJson(json);

      expect(dto.lessonStartTime, isNotNull);
      expect(dto.lessonEndTime, isNotNull);
      expect(dto.subjectName, isNull);
    });

    test('handles invalid date format gracefully', () {
      final json = {
        ...createValidJson(),
        'attendance': {
          'date': 'invalid-date',
        },
      };
      final dto = AbsenceExcuseDTO.fromJson(json);

      expect(dto.attendanceDate, isNull);
      expect(dto.isValid, isTrue); // attendanceDate is optional
    });

    test('handles invalid time format gracefully', () {
      final json = {
        ...createValidJson(),
        'attendance': {
          'date': '2025-01-15',
          'lessons': {
            'start_time': 'invalid',
            'end_time': 'also-invalid',
          },
        },
      };
      final dto = AbsenceExcuseDTO.fromJson(json);

      expect(dto.lessonStartTime, isNull);
      expect(dto.lessonEndTime, isNull);
      expect(dto.isValid, isTrue); // lesson times are optional
    });
  });
}
