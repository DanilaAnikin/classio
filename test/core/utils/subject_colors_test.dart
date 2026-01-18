import 'package:flutter_test/flutter_test.dart';
import 'package:classio/core/utils/subject_colors.dart';

void main() {
  group('SubjectColors', () {
    test('palette should have 15 colors', () {
      expect(SubjectColors.palette.length, 15);
    });

    test('all colors should be valid ARGB values', () {
      for (final color in SubjectColors.palette) {
        // ARGB values should have alpha channel (0xFF prefix for opaque)
        expect(color >> 24, 0xFF, reason: 'Color should be fully opaque');
      }
    });

    test('palette should contain expected color values', () {
      // Verify first few colors are correct
      expect(SubjectColors.palette[0], 0xFF2196F3); // Blue
      expect(SubjectColors.palette[1], 0xFFFF5722); // Deep Orange
      expect(SubjectColors.palette[2], 0xFF4CAF50); // Green
      expect(SubjectColors.palette[3], 0xFF9C27B0); // Purple
      expect(SubjectColors.palette[4], 0xFF009688); // Teal
    });

    test('getColorForIndex should return color from palette', () {
      expect(SubjectColors.getColorForIndex(0), SubjectColors.palette[0]);
      expect(SubjectColors.getColorForIndex(1), SubjectColors.palette[1]);
      expect(SubjectColors.getColorForIndex(5), SubjectColors.palette[5]);
      expect(SubjectColors.getColorForIndex(14), SubjectColors.palette[14]);
    });

    test('getColorForIndex should wrap around for large indices', () {
      final paletteSize = SubjectColors.palette.length;

      // Test wrap around at palette size
      expect(
        SubjectColors.getColorForIndex(paletteSize),
        SubjectColors.palette[0],
      );

      // Test wrap around at palette size + 1
      expect(
        SubjectColors.getColorForIndex(paletteSize + 1),
        SubjectColors.palette[1],
      );

      // Test wrap around at 2x palette size
      expect(
        SubjectColors.getColorForIndex(paletteSize * 2),
        SubjectColors.palette[0],
      );

      // Test with large index
      expect(
        SubjectColors.getColorForIndex(100),
        SubjectColors.palette[100 % paletteSize],
      );
    });

    test('getColorForIndex should handle zero', () {
      expect(
        SubjectColors.getColorForIndex(0),
        SubjectColors.palette[0],
      );
    });

    test('getColorForId should return consistent color for same ID', () {
      const testId = 'subject-123';
      final color1 = SubjectColors.getColorForId(testId);
      final color2 = SubjectColors.getColorForId(testId);

      expect(color1, color2);
    });

    test('getColorForId should return valid color for any ID', () {
      final testIds = [
        'subject-1',
        'subject-2',
        'math',
        'science',
        'history',
        'geography',
        'english',
        'art',
        'music',
        'physical-education',
        '12345',
        'abcdefghijklmnop',
        '',
      ];

      for (final id in testIds) {
        final color = SubjectColors.getColorForId(id);

        expect(color, isNotNull);
        expect(SubjectColors.palette.contains(color), isTrue,
            reason: 'Color should be from palette for ID: $id');
        expect(color >> 24, 0xFF,
            reason: 'Color should be fully opaque for ID: $id');
      }
    });

    test('getColorForId should distribute colors across palette', () {
      // Generate many IDs and check that we get different colors
      final colors = <int>{};

      for (var i = 0; i < 100; i++) {
        final color = SubjectColors.getColorForId('subject-$i');
        colors.add(color);
      }

      // With 100 different IDs and 15 colors, we should see multiple colors
      expect(colors.length, greaterThan(5),
          reason: 'Should use multiple colors from palette');
    });

    test('getColorForId should handle empty string', () {
      final color = SubjectColors.getColorForId('');

      expect(color, isNotNull);
      expect(SubjectColors.palette.contains(color), isTrue);
    });

    test('getColorForId should handle special characters', () {
      final testIds = [
        'subject-with-dash',
        'subject_with_underscore',
        'subject with spaces',
        r'subject@with#special$chars',
        'subject\nwith\nnewlines',
      ];

      for (final id in testIds) {
        final color = SubjectColors.getColorForId(id);

        expect(color, isNotNull);
        expect(SubjectColors.palette.contains(color), isTrue,
            reason: 'Should handle special characters in ID: $id');
      }
    });

    test('getColorForId should use hashCode for color selection', () {
      // Test that similar IDs can produce different colors
      final color1 = SubjectColors.getColorForId('a');
      final color2 = SubjectColors.getColorForId('b');
      final color3 = SubjectColors.getColorForId('aa');

      // All should be valid colors
      expect(SubjectColors.palette.contains(color1), isTrue);
      expect(SubjectColors.palette.contains(color2), isTrue);
      expect(SubjectColors.palette.contains(color3), isTrue);
    });

    test('getColorForIndex and getColorForId should return colors from same palette', () {
      final indexColor = SubjectColors.getColorForIndex(5);
      final idColor = SubjectColors.getColorForId('test-id');

      expect(SubjectColors.palette.contains(indexColor), isTrue);
      expect(SubjectColors.palette.contains(idColor), isTrue);
    });

    test('palette should have distinct colors', () {
      final paletteSet = SubjectColors.palette.toSet();

      // All colors should be unique
      expect(paletteSet.length, SubjectColors.palette.length,
          reason: 'All colors in palette should be distinct');
    });

    test('color values should be in valid range', () {
      for (var i = 0; i < SubjectColors.palette.length; i++) {
        final color = SubjectColors.palette[i];

        // Color should be a valid 32-bit ARGB value
        expect(color, greaterThanOrEqualTo(0));
        expect(color, lessThanOrEqualTo(0xFFFFFFFF));

        // Alpha channel should be fully opaque (0xFF)
        final alpha = (color >> 24) & 0xFF;
        expect(alpha, 0xFF,
            reason: 'Color at index $i should be fully opaque');
      }
    });
  });
}
