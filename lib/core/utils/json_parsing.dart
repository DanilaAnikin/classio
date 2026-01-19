import 'package:flutter/foundation.dart';

/// Safe JSON parsing utilities with validation logging.
///
/// Provides type-safe parsing methods that handle null values, type mismatches,
/// and format errors gracefully while logging warnings for debugging.
///
/// Example:
/// ```dart
/// final createdAt = JsonParser.parseDateTime(json['created_at'], fieldName: 'created_at');
/// final score = JsonParser.parseDouble(json['score'], fieldName: 'score', defaultValue: 0.0);
/// ```
class JsonParser {
  /// Private constructor to prevent instantiation.
  JsonParser._();

  /// Parses a dynamic value to DateTime.
  ///
  /// Handles:
  /// - null values (returns null)
  /// - DateTime objects (returns as-is)
  /// - ISO 8601 strings (parses to DateTime)
  /// - Timestamps in milliseconds (as int or String)
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Optional field name for logging.
  ///
  /// Returns the parsed DateTime or null if parsing fails.
  static DateTime? parseDateTime(dynamic value, {String? fieldName}) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is String) {
      if (value.isEmpty) return null;

      final parsed = DateTime.tryParse(value);
      if (parsed == null) {
        debugPrint(
          'Warning: Failed to parse DateTime for field ${fieldName ?? 'unknown'}: $value',
        );
      }
      return parsed;
    }

    // Handle timestamp in milliseconds
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (e) {
        debugPrint(
          'Warning: Failed to parse timestamp for field ${fieldName ?? 'unknown'}: $value - $e',
        );
        return null;
      }
    }

    debugPrint(
      'Warning: Unexpected type for DateTime field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return null;
  }

  /// Parses a dynamic value to DateTime, throwing if the value is required but null/invalid.
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Field name for error messages.
  ///
  /// Returns the parsed DateTime.
  /// Throws [FormatException] if the value is null or cannot be parsed.
  static DateTime parseDateTimeRequired(dynamic value, {required String fieldName}) {
    final parsed = parseDateTime(value, fieldName: fieldName);
    if (parsed == null) {
      throw FormatException('Required DateTime field "$fieldName" is null or invalid: $value');
    }
    return parsed;
  }

  /// Parses a dynamic value to double.
  ///
  /// Handles:
  /// - null values (returns defaultValue)
  /// - double values (returns as-is)
  /// - int values (converts to double)
  /// - numeric strings (parses to double)
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Optional field name for logging.
  /// [defaultValue] - Value to return if parsing fails (default: 0.0).
  ///
  /// Returns the parsed double or defaultValue.
  static double parseDouble(
    dynamic value, {
    String? fieldName,
    double defaultValue = 0.0,
  }) {
    if (value == null) return defaultValue;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    if (value is String) {
      if (value.isEmpty) return defaultValue;

      final parsed = double.tryParse(value);
      if (parsed == null) {
        debugPrint(
          'Warning: Failed to parse double for field ${fieldName ?? 'unknown'}: $value',
        );
        return defaultValue;
      }
      return parsed;
    }

    debugPrint(
      'Warning: Unexpected type for double field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return defaultValue;
  }

  /// Parses a dynamic value to double, returning null if parsing fails.
  ///
  /// Unlike [parseDouble], this returns null instead of a default value,
  /// allowing callers to detect missing or invalid values.
  static double? parseDoubleNullable(dynamic value, {String? fieldName}) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is int) return value.toDouble();

    if (value is num) return value.toDouble();

    if (value is String) {
      if (value.isEmpty) return null;

      final parsed = double.tryParse(value);
      if (parsed == null) {
        debugPrint(
          'Warning: Failed to parse double for field ${fieldName ?? 'unknown'}: $value',
        );
      }
      return parsed;
    }

    debugPrint(
      'Warning: Unexpected type for double field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return null;
  }

  /// Parses a dynamic value to int.
  ///
  /// Handles:
  /// - null values (returns defaultValue)
  /// - int values (returns as-is)
  /// - double values (truncates to int)
  /// - numeric strings (parses to int)
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Optional field name for logging.
  /// [defaultValue] - Value to return if parsing fails (default: 0).
  ///
  /// Returns the parsed int or defaultValue.
  static int parseInt(
    dynamic value, {
    String? fieldName,
    int defaultValue = 0,
  }) {
    if (value == null) return defaultValue;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is num) return value.toInt();

    if (value is String) {
      if (value.isEmpty) return defaultValue;

      final parsed = int.tryParse(value);
      if (parsed == null) {
        // Try parsing as double first, then convert
        final doubleVal = double.tryParse(value);
        if (doubleVal != null) {
          return doubleVal.toInt();
        }
        debugPrint(
          'Warning: Failed to parse int for field ${fieldName ?? 'unknown'}: $value',
        );
        return defaultValue;
      }
      return parsed;
    }

    debugPrint(
      'Warning: Unexpected type for int field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return defaultValue;
  }

  /// Parses a dynamic value to int, returning null if parsing fails.
  static int? parseIntNullable(dynamic value, {String? fieldName}) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    if (value is num) return value.toInt();

    if (value is String) {
      if (value.isEmpty) return null;

      final parsed = int.tryParse(value);
      if (parsed == null) {
        final doubleVal = double.tryParse(value);
        if (doubleVal != null) {
          return doubleVal.toInt();
        }
        debugPrint(
          'Warning: Failed to parse int for field ${fieldName ?? 'unknown'}: $value',
        );
      }
      return parsed;
    }

    debugPrint(
      'Warning: Unexpected type for int field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return null;
  }

  /// Parses a dynamic value to String.
  ///
  /// Handles:
  /// - null values (returns defaultValue)
  /// - String values (returns as-is)
  /// - Other types (converts via toString())
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Optional field name for logging.
  /// [defaultValue] - Value to return if value is null (default: '').
  ///
  /// Returns the parsed String or defaultValue.
  static String parseString(
    dynamic value, {
    String? fieldName,
    String defaultValue = '',
  }) {
    if (value == null) return defaultValue;

    if (value is String) return value;

    // Convert other types to string
    return value.toString();
  }

  /// Parses a dynamic value to String, returning null if value is null.
  static String? parseStringNullable(dynamic value, {String? fieldName}) {
    if (value == null) return null;

    if (value is String) return value;

    return value.toString();
  }

  /// Parses a dynamic value to String, throwing if the value is required but null.
  static String parseStringRequired(dynamic value, {required String fieldName}) {
    if (value == null) {
      throw FormatException('Required String field "$fieldName" is null');
    }
    if (value is String) return value;
    return value.toString();
  }

  /// Parses a dynamic value to bool.
  ///
  /// Handles:
  /// - null values (returns defaultValue)
  /// - bool values (returns as-is)
  /// - int values (0 = false, other = true)
  /// - String values ('true', '1', 'yes' = true, others = false)
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Optional field name for logging.
  /// [defaultValue] - Value to return if parsing fails (default: false).
  ///
  /// Returns the parsed bool or defaultValue.
  static bool parseBool(
    dynamic value, {
    String? fieldName,
    bool defaultValue = false,
  }) {
    if (value == null) return defaultValue;

    if (value is bool) return value;

    if (value is int) return value != 0;

    if (value is String) {
      final lower = value.toLowerCase();
      if (lower == 'true' || lower == '1' || lower == 'yes') {
        return true;
      }
      if (lower == 'false' || lower == '0' || lower == 'no' || lower.isEmpty) {
        return false;
      }
      debugPrint(
        'Warning: Unexpected bool string for field ${fieldName ?? 'unknown'}: $value',
      );
      return defaultValue;
    }

    debugPrint(
      'Warning: Unexpected type for bool field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return defaultValue;
  }

  /// Parses a dynamic value to an enum.
  ///
  /// Handles:
  /// - null values (returns defaultValue)
  /// - String values matching enum names (case-insensitive)
  /// - Enum values of the correct type
  ///
  /// [value] - The value to parse.
  /// [values] - List of all enum values to match against.
  /// [fieldName] - Optional field name for logging.
  /// [defaultValue] - Value to return if parsing fails (default: null).
  ///
  /// Returns the matched enum value or defaultValue.
  static T? parseEnum<T extends Enum>(
    dynamic value,
    List<T> values, {
    String? fieldName,
    T? defaultValue,
  }) {
    if (value == null) return defaultValue;

    if (value is T) return value;

    if (value is String) {
      if (value.isEmpty) return defaultValue;

      final lower = value.toLowerCase();
      for (final enumValue in values) {
        if (enumValue.name.toLowerCase() == lower) {
          return enumValue;
        }
      }
      debugPrint(
        'Warning: Unknown enum value for field ${fieldName ?? 'unknown'}: $value. '
        'Valid values: ${values.map((e) => e.name).join(', ')}',
      );
      return defaultValue;
    }

    // Handle int index
    if (value is int) {
      if (value >= 0 && value < values.length) {
        return values[value];
      }
      debugPrint(
        'Warning: Enum index out of range for field ${fieldName ?? 'unknown'}: $value',
      );
      return defaultValue;
    }

    debugPrint(
      'Warning: Unexpected type for enum field ${fieldName ?? 'unknown'}: '
      '${value.runtimeType} (value: $value)',
    );
    return defaultValue;
  }

  /// Parses a dynamic value to an enum, throwing if required but invalid.
  static T parseEnumRequired<T extends Enum>(
    dynamic value,
    List<T> values, {
    required String fieldName,
  }) {
    final parsed = parseEnum<T>(value, values, fieldName: fieldName);
    if (parsed == null) {
      throw FormatException(
        'Required enum field "$fieldName" is null or invalid: $value. '
        'Valid values: ${values.map((e) => e.name).join(', ')}',
      );
    }
    return parsed;
  }

  /// Parses a time string (HH:MM or HH:MM:SS) into a DateTime for a given date.
  ///
  /// [timeStr] - The time string to parse.
  /// [date] - The date to use for year, month, day.
  /// [fieldName] - Optional field name for logging.
  ///
  /// Returns the DateTime with the parsed time, or null if parsing fails.
  static DateTime? parseTimeString(
    String? timeStr,
    DateTime date, {
    String? fieldName,
  }) {
    if (timeStr == null || timeStr.isEmpty) return null;

    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) {
        debugPrint(
          'Warning: Invalid time format for field ${fieldName ?? 'unknown'}: $timeStr',
        );
        return null;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        debugPrint(
          'Warning: Failed to parse time components for field ${fieldName ?? 'unknown'}: $timeStr',
        );
        return null;
      }

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        debugPrint(
          'Warning: Time out of range for field ${fieldName ?? 'unknown'}: $timeStr',
        );
        return null;
      }

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (e) {
      debugPrint(
        'Warning: Failed to parse time string for field ${fieldName ?? 'unknown'}: $timeStr - $e',
      );
      return null;
    }
  }

  /// Parses a list of dynamic values to a typed list.
  ///
  /// [value] - The value to parse (should be a List).
  /// [mapper] - Function to map each item to the desired type.
  /// [fieldName] - Optional field name for logging.
  ///
  /// Returns the parsed list or an empty list if value is null/not a list.
  static List<T> parseList<T>(
    dynamic value,
    T Function(dynamic) mapper, {
    String? fieldName,
  }) {
    if (value == null) return [];

    if (value is! List) {
      debugPrint(
        'Warning: Expected List for field ${fieldName ?? 'unknown'}, '
        'got ${value.runtimeType}',
      );
      return [];
    }

    final result = <T>[];
    for (var i = 0; i < value.length; i++) {
      try {
        result.add(mapper(value[i]));
      } catch (e) {
        debugPrint(
          'Warning: Failed to parse list item $i for field ${fieldName ?? 'unknown'}: $e',
        );
      }
    }
    return result;
  }

  /// Parses a Map from a dynamic value.
  ///
  /// [value] - The value to parse.
  /// [fieldName] - Optional field name for logging.
  ///
  /// Returns the map or null if value is not a Map.
  static Map<String, dynamic>? parseMap(dynamic value, {String? fieldName}) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }

    debugPrint(
      'Warning: Expected Map for field ${fieldName ?? 'unknown'}, '
      'got ${value.runtimeType}',
    );
    return null;
  }

  /// Extracts a nested profile name from joined data.
  ///
  /// Common pattern in Supabase joins where profile data is nested.
  ///
  /// [profileData] - The nested profile map.
  /// [fieldName] - Optional field name for logging.
  ///
  /// Returns the full name or null.
  static String? parseProfileName(
    Map<String, dynamic>? profileData, {
    String? fieldName,
  }) {
    if (profileData == null) return null;

    final firstName = profileData['first_name'] as String?;
    final lastName = profileData['last_name'] as String?;

    if (firstName == null && lastName == null) return null;

    return [firstName, lastName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
  }
}
