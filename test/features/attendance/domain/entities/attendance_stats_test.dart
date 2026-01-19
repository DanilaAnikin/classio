import 'package:flutter_test/flutter_test.dart';
import 'package:classio/core/theme/app_colors.dart';
import 'package:classio/features/student/domain/entities/attendance.dart';

/// Dedicated tests for AttendanceStats percentage calculation.
///
/// The attendance percentage calculation is critical for student reports
/// and must be accurate. The formula is:
///
///   attendancePercentage = (presentDays + excusedDays) / totalDays * 100
///
/// Key behaviors:
/// - Present days count positively
/// - Excused days count positively (they're not penalized)
/// - Absent and late days reduce the percentage
/// - Zero total days returns 100% (edge case)
void main() {
  group('AttendanceStats - Percentage Calculation', () {
    group('Basic calculations', () {
      test('attendancePercentage includes excused absences', () {
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

      test('100% when all days present', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 100,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('0% when all days absent', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 0,
          absentDays: 100,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(0.0));
      });

      test('100% when all days excused', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 100,
        );
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('100% when totalDays is 0 (edge case)', () {
        const stats = AttendanceStats.empty();
        expect(stats.attendancePercentage, equals(100.0));
      });
    });

    group('Mixed scenarios', () {
      test('50% with half present, half absent', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 50,
          absentDays: 50,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(50.0));
      });

      test('75% with 70 present and 5 excused out of 100', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 70,
          absentDays: 20,
          lateDays: 5,
          excusedDays: 5,
        );
        // (70 + 5) / 100 * 100 = 75%
        expect(stats.attendancePercentage, equals(75.0));
      });

      test('90% with mostly present and some excused', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 85,
          absentDays: 5,
          lateDays: 5,
          excusedDays: 5,
        );
        // (85 + 5) / 100 * 100 = 90%
        expect(stats.attendancePercentage, equals(90.0));
      });

      test('late days do not count positively', () {
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 0,
          lateDays: 20,
          excusedDays: 0,
        );
        // Late days are NOT added to positive count
        // Only present + excused = 80%
        expect(stats.attendancePercentage, equals(80.0));
      });
    });

    group('Small numbers', () {
      test('handles single day correctly - present', () {
        final stats = AttendanceStats(
          totalDays: 1,
          presentDays: 1,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('handles single day correctly - absent', () {
        final stats = AttendanceStats(
          totalDays: 1,
          presentDays: 0,
          absentDays: 1,
          lateDays: 0,
          excusedDays: 0,
        );
        expect(stats.attendancePercentage, equals(0.0));
      });

      test('handles single day correctly - excused', () {
        final stats = AttendanceStats(
          totalDays: 1,
          presentDays: 0,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 1,
        );
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('handles 3 days with mixed attendance', () {
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

      test('handles 3 days with 1 absent', () {
        final stats = AttendanceStats(
          totalDays: 3,
          presentDays: 2,
          absentDays: 1,
          lateDays: 0,
          excusedDays: 0,
        );
        // (2 + 0) / 3 * 100 = 66.666...%
        expect(
          stats.attendancePercentage,
          closeTo(66.67, 0.01),
        );
      });
    });

    group('Decimal precision', () {
      test('handles non-integer percentages correctly', () {
        final stats = AttendanceStats(
          totalDays: 3,
          presentDays: 1,
          absentDays: 2,
          lateDays: 0,
          excusedDays: 0,
        );
        // 1 / 3 * 100 = 33.333...%
        expect(
          stats.attendancePercentage,
          closeTo(33.33, 0.01),
        );
      });

      test('handles 1/7 correctly', () {
        final stats = AttendanceStats(
          totalDays: 7,
          presentDays: 1,
          absentDays: 6,
          lateDays: 0,
          excusedDays: 0,
        );
        // 1 / 7 * 100 = 14.285...%
        expect(
          stats.attendancePercentage,
          closeTo(14.29, 0.01),
        );
      });
    });

    group('Real-world scenarios', () {
      test('typical school month - good attendance', () {
        final stats = AttendanceStats(
          totalDays: 20,
          presentDays: 18,
          absentDays: 1,
          lateDays: 0,
          excusedDays: 1,
        );
        // (18 + 1) / 20 * 100 = 95%
        expect(stats.attendancePercentage, equals(95.0));
      });

      test('typical school month - poor attendance', () {
        final stats = AttendanceStats(
          totalDays: 20,
          presentDays: 12,
          absentDays: 5,
          lateDays: 3,
          excusedDays: 0,
        );
        // (12 + 0) / 20 * 100 = 60%
        expect(stats.attendancePercentage, equals(60.0));
      });

      test('full semester stats', () {
        final stats = AttendanceStats(
          totalDays: 90,
          presentDays: 75,
          absentDays: 5,
          lateDays: 5,
          excusedDays: 5,
        );
        // (75 + 5) / 90 * 100 = 88.888...%
        expect(
          stats.attendancePercentage,
          closeTo(88.89, 0.01),
        );
      });

      test('full year stats', () {
        final stats = AttendanceStats(
          totalDays: 180,
          presentDays: 160,
          absentDays: 10,
          lateDays: 5,
          excusedDays: 5,
        );
        // (160 + 5) / 180 * 100 = 91.666...%
        expect(
          stats.attendancePercentage,
          closeTo(91.67, 0.01),
        );
      });
    });

    group('Edge cases', () {
      test('all late days', () {
        final stats = AttendanceStats(
          totalDays: 10,
          presentDays: 0,
          absentDays: 0,
          lateDays: 10,
          excusedDays: 0,
        );
        // Late days do NOT count as positive attendance
        expect(stats.attendancePercentage, equals(0.0));
      });

      test('half late, half present', () {
        final stats = AttendanceStats(
          totalDays: 10,
          presentDays: 5,
          absentDays: 0,
          lateDays: 5,
          excusedDays: 0,
        );
        // Only present counts: 5/10 = 50%
        expect(stats.attendancePercentage, equals(50.0));
      });

      test('excused days save the percentage', () {
        // Student was absent 20 days but all were excused
        final stats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 0, // No unexcused absences
          lateDays: 0,
          excusedDays: 20, // All absences were excused
        );
        // (80 + 20) / 100 * 100 = 100%
        expect(stats.attendancePercentage, equals(100.0));
      });

      test('comparison: unexcused vs excused absences', () {
        // Same situation, but absences not excused
        final unexcusedStats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 20, // Unexcused absences
          lateDays: 0,
          excusedDays: 0,
        );

        final excusedStats = AttendanceStats(
          totalDays: 100,
          presentDays: 80,
          absentDays: 0,
          lateDays: 0,
          excusedDays: 20, // Excused absences
        );

        // Unexcused: only present counts = 80%
        expect(unexcusedStats.attendancePercentage, equals(80.0));

        // Excused: present + excused = 100%
        expect(excusedStats.attendancePercentage, equals(100.0));
      });
    });
  });

  group('AttendanceStats - Percentage Color', () {
    test('returns green for 95% and above', () {
      final stats95 = AttendanceStats(
        totalDays: 100,
        presentDays: 95,
        absentDays: 5,
        lateDays: 0,
        excusedDays: 0,
      );
      final stats100 = AttendanceStats(
        totalDays: 100,
        presentDays: 100,
        absentDays: 0,
        lateDays: 0,
        excusedDays: 0,
      );

      expect(stats95.percentageColor, equals(CleanColors.gradeExcellent));
      expect(stats100.percentageColor, equals(CleanColors.gradeExcellent));
    });

    test('returns lightGreen for 90-94%', () {
      final stats90 = AttendanceStats(
        totalDays: 100,
        presentDays: 90,
        absentDays: 10,
        lateDays: 0,
        excusedDays: 0,
      );
      final stats94 = AttendanceStats(
        totalDays: 100,
        presentDays: 94,
        absentDays: 6,
        lateDays: 0,
        excusedDays: 0,
      );

      expect(stats90.percentageColor, equals(CleanColors.gradeGood));
      expect(stats94.percentageColor, equals(CleanColors.gradeGood));
    });

    test('returns orange for 80-89%', () {
      final stats80 = AttendanceStats(
        totalDays: 100,
        presentDays: 80,
        absentDays: 20,
        lateDays: 0,
        excusedDays: 0,
      );
      final stats89 = AttendanceStats(
        totalDays: 100,
        presentDays: 89,
        absentDays: 11,
        lateDays: 0,
        excusedDays: 0,
      );

      expect(stats80.percentageColor, equals(CleanColors.gradeAverage));
      expect(stats89.percentageColor, equals(CleanColors.gradeAverage));
    });

    test('returns deepOrange for 70-79%', () {
      final stats70 = AttendanceStats(
        totalDays: 100,
        presentDays: 70,
        absentDays: 30,
        lateDays: 0,
        excusedDays: 0,
      );
      final stats79 = AttendanceStats(
        totalDays: 100,
        presentDays: 79,
        absentDays: 21,
        lateDays: 0,
        excusedDays: 0,
      );

      expect(stats70.percentageColor, equals(CleanColors.gradeBelowAverage));
      expect(stats79.percentageColor, equals(CleanColors.gradeBelowAverage));
    });

    test('returns red for below 70%', () {
      final stats69 = AttendanceStats(
        totalDays: 100,
        presentDays: 69,
        absentDays: 31,
        lateDays: 0,
        excusedDays: 0,
      );
      final stats0 = AttendanceStats(
        totalDays: 100,
        presentDays: 0,
        absentDays: 100,
        lateDays: 0,
        excusedDays: 0,
      );

      expect(stats69.percentageColor, equals(CleanColors.gradeFailing));
      expect(stats0.percentageColor, equals(CleanColors.gradeFailing));
    });

    test('boundary between green and lightGreen at 95%', () {
      final stats94_99 = AttendanceStats(
        totalDays: 1000,
        presentDays: 949, // 94.9%
        absentDays: 51,
        lateDays: 0,
        excusedDays: 0,
      );
      final stats95 = AttendanceStats(
        totalDays: 100,
        presentDays: 95,
        absentDays: 5,
        lateDays: 0,
        excusedDays: 0,
      );

      expect(stats94_99.percentageColor, equals(CleanColors.gradeGood));
      expect(stats95.percentageColor, equals(CleanColors.gradeExcellent));
    });
  });

  group('AttendanceStats.empty()', () {
    test('creates stats with all zeroes', () {
      const stats = AttendanceStats.empty();

      expect(stats.totalDays, equals(0));
      expect(stats.presentDays, equals(0));
      expect(stats.absentDays, equals(0));
      expect(stats.lateDays, equals(0));
      expect(stats.excusedDays, equals(0));
    });

    test('empty stats has 100% attendance', () {
      const stats = AttendanceStats.empty();
      expect(stats.attendancePercentage, equals(100.0));
    });

    test('empty stats color is green', () {
      const stats = AttendanceStats.empty();
      expect(stats.percentageColor, equals(CleanColors.gradeExcellent));
    });
  });
}
