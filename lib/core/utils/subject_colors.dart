/// Subject color utilities for consistent coloring across the app.
/// Uses int color values to avoid Flutter dependency in data layer.
class SubjectColors {
  SubjectColors._();

  /// Standard subject color palette (as int values, not Flutter Colors)
  /// These are ARGB values that can be converted to Color in UI layer
  static const List<int> palette = [
    0xFF2196F3, // Blue
    0xFFFF5722, // Deep Orange
    0xFF4CAF50, // Green
    0xFF9C27B0, // Purple
    0xFF009688, // Teal
    0xFFF44336, // Red
    0xFF3F51B5, // Indigo
    0xFFFFC107, // Amber
    0xFF00BCD4, // Cyan
    0xFFE91E63, // Pink
    0xFFCDDC39, // Lime
    0xFF795548, // Brown
    0xFF673AB7, // Deep Purple
    0xFF03A9F4, // Light Blue
    0xFFFF9800, // Orange
  ];

  /// Get a color for a subject based on its index
  static int getColorForIndex(int index) {
    return palette[index % palette.length];
  }

  /// Get a color for a subject based on its string ID (hashes to index)
  static int getColorForId(String id) {
    final hash = id.hashCode.abs();
    return palette[hash % palette.length];
  }
}
