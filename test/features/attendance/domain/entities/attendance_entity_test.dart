import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:classio/features/student/domain/entities/attendance.dart';
import 'package:classio/core/theme/app_colors.dart';

void main() {
  group('AttendanceStatus', () {
    group('fromString', () {
      test('parses all valid status strings correctly', () {
        expect(
          AttendanceStatus.fromString('present'),
          equals(AttendanceStatus.present),
        );
        expect(
          AttendanceStatus.fromString('absent'),
          equals(AttendanceStatus.absent),
        );
        expect(
          AttendanceStatus.fromString('late'),
          equals(AttendanceStatus.late),
        );
        expect(
          AttendanceStatus.fromString('leftEarly'),
          equals(AttendanceStatus.leftEarly),
        );
        expect(
          AttendanceStatus.fromString('excused'),
          equals(AttendanceStatus.excused),
        );
      });

      test('is case insensitive', () {
        expect(
          AttendanceStatus.fromString('PRESENT'),
          equals(AttendanceStatus.present),
        );
        expect(
          AttendanceStatus.fromString('Absent'),
          equals(AttendanceStatus.absent),
        );
        expect(
          AttendanceStatus.fromString('LATE'),
          equals(AttendanceStatus.late),
        );
        expect(
          AttendanceStatus.fromString('LEFTEARLY'),
          equals(AttendanceStatus.leftEarly),
        );
      });

      test('returns present as default for unknown status', () {
        expect(
          AttendanceStatus.fromString('unknown'),
          equals(AttendanceStatus.present),
        );
        expect(
          AttendanceStatus.fromString('invalid'),
          equals(AttendanceStatus.present),
        );
      });

      test('returns null for null input', () {
        expect(AttendanceStatus.fromString(null), isNull);
      });
    });

    group('label', () {
      test('returns correct labels for all statuses', () {
        expect(AttendanceStatus.present.label, equals('Present'));
        expect(AttendanceStatus.absent.label, equals('Absent'));
        expect(AttendanceStatus.late.label, equals('Late'));
        expect(AttendanceStatus.leftEarly.label, equals('Left Early'));
        expect(AttendanceStatus.excused.label, equals('Excused'));
      });
    });

    group('color', () {
      test('returns correct colors for all statuses', () {
        expect(AttendanceStatus.present.color, equals(CleanColors.attendancePresent));
        expect(AttendanceStatus.absent.color, equals(CleanColors.attendanceAbsent));
        expect(AttendanceStatus.late.color, equals(CleanColors.attendanceLate));
        expect(AttendanceStatus.leftEarly.color, equals(CleanColors.attendanceExcused));
        expect(AttendanceStatus.excused.color, equals(CleanColors.info));
      });
    });

    group('icon', () {
      test('returns correct icons for all statuses', () {
        expect(AttendanceStatus.present.icon, equals(Icons.check_circle));
        expect(AttendanceStatus.absent.icon, equals(Icons.cancel));
        expect(AttendanceStatus.late.icon, equals(Icons.schedule));
        expect(AttendanceStatus.leftEarly.icon, equals(Icons.exit_to_app));
        expect(AttendanceStatus.excused.icon, equals(Icons.verified));
      });
    });
  });

  group('ExcuseStatus', () {
    group('fromString', () {
      test('parses all valid status strings correctly', () {
        expect(ExcuseStatus.fromString('none'), equals(ExcuseStatus.none));
        expect(ExcuseStatus.fromString('pending'), equals(ExcuseStatus.pending));
        expect(ExcuseStatus.fromString('approved'), equals(ExcuseStatus.approved));
        expect(ExcuseStatus.fromString('rejected'), equals(ExcuseStatus.rejected));
      });

      test('is case insensitive', () {
        expect(ExcuseStatus.fromString('PENDING'), equals(ExcuseStatus.pending));
        expect(ExcuseStatus.fromString('Approved'), equals(ExcuseStatus.approved));
      });

      test('returns none for null input', () {
        expect(ExcuseStatus.fromString(null), equals(ExcuseStatus.none));
      });

      test('returns none for unknown status', () {
        expect(ExcuseStatus.fromString('unknown'), equals(ExcuseStatus.none));
      });
    });

    group('label', () {
      test('returns correct labels for all statuses', () {
        expect(ExcuseStatus.none.label, equals('No Excuse'));
        expect(ExcuseStatus.pending.label, equals('Pending'));
        expect(ExcuseStatus.approved.label, equals('Approved'));
        expect(ExcuseStatus.rejected.label, equals('Rejected'));
      });
    });

    group('color', () {
      test('returns correct colors for all statuses', () {
        expect(ExcuseStatus.none.color, equals(CleanColors.attendanceUnknown));
        expect(ExcuseStatus.pending.color, equals(CleanColors.warning));
        expect(ExcuseStatus.approved.color, equals(CleanColors.success));
        expect(ExcuseStatus.rejected.color, equals(CleanColors.error));
      });
    });
  });

  group('AttendanceEntity', () {
    final now = DateTime.now();

    AttendanceEntity createEntity({
      String id = 'att-123',
      String studentId = 'student-123',
      String lessonId = 'lesson-123',
      DateTime? date,
      AttendanceStatus status = AttendanceStatus.present,
      ExcuseStatus excuseStatus = ExcuseStatus.none,
    }) {
      return AttendanceEntity(
        id: id,
        studentId: studentId,
        lessonId: lessonId,
        date: date ?? now,
        status: status,
        excuseStatus: excuseStatus,
      );
    }

    group('creation', () {
      test('creates entity with all required fields', () {
        final entity = createEntity();

        expect(entity.id, equals('att-123'));
        expect(entity.studentId, equals('student-123'));
        expect(entity.lessonId, equals('lesson-123'));
        expect(entity.date, equals(now));
        expect(entity.status, equals(AttendanceStatus.present));
      });

      test('creates entity with optional fields', () {
        final entity = AttendanceEntity(
          id: 'att-123',
          studentId: 'student-123',
          lessonId: 'lesson-123',
          date: now,
          status: AttendanceStatus.absent,
          subjectId: 'subject-123',
          subjectName: 'Mathematics',
          lessonStartTime: now,
          lessonEndTime: now.add(const Duration(hours: 1)),
          note: 'Teacher note',
          excuseNote: 'Parent excuse note',
          excuseStatus: ExcuseStatus.pending,
          excuseAttachmentUrl: 'https://example.com/doc.pdf',
          recordedBy: 'teacher-123',
          recordedAt: now,
        );

        expect(entity.subjectId, equals('subject-123'));
        expect(entity.subjectName, equals('Mathematics'));
        expect(entity.note, equals('Teacher note'));
        expect(entity.excuseNote, equals('Parent excuse note'));
        expect(entity.excuseStatus, equals(ExcuseStatus.pending));
        expect(entity.excuseAttachmentUrl, equals('https://example.com/doc.pdf'));
        expect(entity.recordedBy, equals('teacher-123'));
      });

      test('excuseStatus defaults to none', () {
        final entity = createEntity();
        expect(entity.excuseStatus, equals(ExcuseStatus.none));
      });
    });

    group('isNegative', () {
      test('returns true for absent status', () {
        final entity = createEntity(status: AttendanceStatus.absent);
        expect(entity.isNegative, isTrue);
      });

      test('returns true for late status', () {
        final entity = createEntity(status: AttendanceStatus.late);
        expect(entity.isNegative, isTrue);
      });

      test('returns false for present status', () {
        final entity = createEntity(status: AttendanceStatus.present);
        expect(entity.isNegative, isFalse);
      });

      test('returns false for excused status', () {
        final entity = createEntity(status: AttendanceStatus.excused);
        expect(entity.isNegative, isFalse);
      });

      test('returns false for leftEarly status', () {
        final entity = createEntity(status: AttendanceStatus.leftEarly);
        expect(entity.isNegative, isFalse);
      });
    });

    group('canSubmitExcuse', () {
      test('returns true for absent status without approved excuse', () {
        final entity = createEntity(
          status: AttendanceStatus.absent,
          excuseStatus: ExcuseStatus.none,
        );
        expect(entity.canSubmitExcuse, isTrue);
      });

      test('returns true for late status without approved excuse', () {
        final entity = createEntity(
          status: AttendanceStatus.late,
          excuseStatus: ExcuseStatus.none,
        );
        expect(entity.canSubmitExcuse, isTrue);
      });

      test('returns true for absent with pending excuse', () {
        final entity = createEntity(
          status: AttendanceStatus.absent,
          excuseStatus: ExcuseStatus.pending,
        );
        expect(entity.canSubmitExcuse, isTrue);
      });

      test('returns true for absent with rejected excuse', () {
        final entity = createEntity(
          status: AttendanceStatus.absent,
          excuseStatus: ExcuseStatus.rejected,
        );
        expect(entity.canSubmitExcuse, isTrue);
      });

      test('returns false for absent with approved excuse', () {
        final entity = createEntity(
          status: AttendanceStatus.absent,
          excuseStatus: ExcuseStatus.approved,
        );
        expect(entity.canSubmitExcuse, isFalse);
      });

      test('returns false for present status', () {
        final entity = createEntity(status: AttendanceStatus.present);
        expect(entity.canSubmitExcuse, isFalse);
      });

      test('returns false for excused status', () {
        final entity = createEntity(status: AttendanceStatus.excused);
        expect(entity.canSubmitExcuse, isFalse);
      });

      test('returns false for leftEarly status', () {
        final entity = createEntity(status: AttendanceStatus.leftEarly);
        expect(entity.canSubmitExcuse, isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with changed status', () {
        final entity = createEntity(status: AttendanceStatus.present);
        final copy = entity.copyWith(status: AttendanceStatus.absent);

        expect(copy.status, equals(AttendanceStatus.absent));
        expect(copy.id, equals(entity.id));
        expect(copy.studentId, equals(entity.studentId));
      });

      test('creates copy with changed excuse status', () {
        final entity = createEntity(excuseStatus: ExcuseStatus.none);
        final copy = entity.copyWith(excuseStatus: ExcuseStatus.approved);

        expect(copy.excuseStatus, equals(ExcuseStatus.approved));
        expect(copy.status, equals(entity.status));
      });

      test('preserves all fields when no changes specified', () {
        final entity = AttendanceEntity(
          id: 'att-123',
          studentId: 'student-123',
          lessonId: 'lesson-123',
          date: now,
          status: AttendanceStatus.absent,
          subjectName: 'Math',
          excuseNote: 'Sick',
          excuseStatus: ExcuseStatus.pending,
        );

        final copy = entity.copyWith();

        expect(copy.id, equals(entity.id));
        expect(copy.studentId, equals(entity.studentId));
        expect(copy.lessonId, equals(entity.lessonId));
        expect(copy.date, equals(entity.date));
        expect(copy.status, equals(entity.status));
        expect(copy.subjectName, equals(entity.subjectName));
        expect(copy.excuseNote, equals(entity.excuseNote));
        expect(copy.excuseStatus, equals(entity.excuseStatus));
      });
    });

    group('equality', () {
      test('entities with same id are equal', () {
        final entity1 = createEntity(id: 'att-123');
        final entity2 = createEntity(id: 'att-123');

        expect(entity1, equals(entity2));
        expect(entity1.hashCode, equals(entity2.hashCode));
      });

      test('entities with different ids are not equal', () {
        final entity1 = createEntity(id: 'att-123');
        final entity2 = createEntity(id: 'att-456');

        expect(entity1, isNot(equals(entity2)));
      });
    });

    group('toString', () {
      test('returns readable representation', () {
        final entity = createEntity(
          id: 'att-123',
          studentId: 'student-123',
          status: AttendanceStatus.absent,
        );

        final str = entity.toString();
        expect(str, contains('AttendanceEntity'));
        expect(str, contains('att-123'));
        expect(str, contains('student-123'));
        expect(str, contains('absent'));
      });
    });
  });

  group('AttendanceStats', () {
    group('creation', () {
      test('creates stats with all fields', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 10,
          lateDays: 5,
          excusedDays: 5,
        );

        expect(stats.totalDays, equals(100));
        expect(stats.presentDays, equals(80));
        expect(stats.absentDays, equals(10));
        expect(stats.lateDays, equals(5));
        expect(stats.excusedDays, equals(5));
      });

      test('creates empty stats', () {
        const stats = AttendanceStats.empty();

        expect(stats.totalDays, equals(0));
        expect(stats.presentDays, equals(0));
        expect(stats.absentDays, equals(0));
        expect(stats.lateDays, equals(0));
        expect(stats.excusedDays, equals(0));
      });
    });

    group('attendancePercentage', () {
      test('calculates percentage correctly with excused days', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 10,
          lateDays: 5,
          excusedDays: 5,
        );
        // (present + excused) / total * 100 = (80 + 5) / 100 * 100 = 85%
        expect(stats.attendancePercentage, equals(85.0));
      });

      test('returns 100% when all days present', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 100,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('returns 0% when all days absent', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 0,
          absentDays: 100,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(0.0));
      });

      test('returns 100% when totalDays is 0', () {
        const stats = AttendanceStats.empty();
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('includes excused absences in positive percentage', () {
        final stats = AttendanceStats(
          totalDays: 10,
          presentDays: 5,
          absentDays: 3,
          lateDays: 0,
          excusedDays: 2,
        );
        // (5 + 2) / 10 * 100 = 70%
        expect(stats.attendancePercentage, equals(70.0));
      });

      test('handles all excused days correctly', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 100,
        );
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('handles mixed scenario correctly', () {
        final stats = AttendanceStats(
          totalDays: 50,
          presentDays: 30,
          absentDays: 10,
          lateDays: 5,
          excusedDays: 5,
        );
        // (30 + 5) / 50 * 100 = 70%
        expect(stats.attendancePercentage, equals(70.0));
      });

      test('handles small numbers correctly', () {
        final stats = AttendanceStats(
          totalDays: 3,
          presentDays: 2,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 1,
        );
        // (2 + 1) / 3 * 100 = 100%
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('returns correct percentage for 50/50 split', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 50,
          absentDays: 50,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(50.0));
      });
    });

    group('percentageColor', () {
      test('returns gradeExcellent for 95% and above', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 95,
          absentDays: 5,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeExcellent));
      });

      test('returns gradeExcellent for 100%', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 100,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeExcellent));
      });

      test('returns gradeGood for 90-94%', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 90,
          absentDays: 10,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeGood));
      });

      test('returns gradeAverage for 80-89%', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 20,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeAverage));
      });

      test('returns gradeBelowAverage for 70-79%', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 70,
          absentDays: 30,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeBelowAverage));
      });

      test('returns gradeFailing for below 70%', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 60,
          absentDays: 40,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeFailing));
      });

      test('returns gradeFailing for 0%', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 0,
          absentDays: 100,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.percentageColor, equals(CleanColors.gradeFailing));
      });
    });

    group('toString', () {
      test('returns readable representation', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 10,
          lateDays: 5,
          excusedDays: 5,
        );

        final str = stats.toString();
        expect(str, contains('AttendanceStats'));
        expect(str, contains('100'));
        expect(str, contains('80'));
        expect(str, contains('10'));
      });
    });
  });

  group('DailyAttendanceStatus', () {
    group('color', () {
      test('returns correct colors for all statuses', () {
        expect(
          DailyAttendanceStatus.allPresent.color,
          equals(CleanColors.attendancePresent),
        );
        expect(
          DailyAttendanceStatus.partialAbsent.color,
          equals(CleanColors.attendanceLate),
        );
        expect(
          DailyAttendanceStatus.allAbsent.color,
          equals(CleanColors.attendanceAbsent),
        );
        expect(
          DailyAttendanceStatus.wasLate.color,
          equals(CleanColors.attendanceExcused),
        );
        expect(
          DailyAttendanceStatus.noData.color,
          equals(CleanColors.attendanceUnknown),
        );
      });
    });

    group('label', () {
      test('returns correct labels for all statuses', () {
        expect(
          DailyAttendanceStatus.allPresent.label,
          equals('Present'),
        );
        expect(
          DailyAttendanceStatus.partialAbsent.label,
          equals('Partial Absence'),
        );
        expect(
          DailyAttendanceStatus.allAbsent.label,
          equals('Absent'),
        );
        expect(
          DailyAttendanceStatus.wasLate.label,
          equals('Late'),
        );
        expect(
          DailyAttendanceStatus.noData.label,
          equals('No Data'),
        );
      });
    });
  });
}
