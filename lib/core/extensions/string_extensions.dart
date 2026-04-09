import 'package:flutter/material.dart';

/// Extension to convert string to IconData
extension StringToIconData on String {
  /// Convert category type string to corresponding IconData
  /// 
  /// Example:
  /// ```dart
  /// 'work'.toIconData() // Returns Icons.work
  /// 'leisure'.toIconData() // Returns Icons.sports_esports
  /// 'unknown'.toIconData() // Returns Icons.category (fallback)
  /// ```
  IconData toIconData() {
    final iconMap = {
      'work': Icons.work,
      'leisure': Icons.sports_esports,
      'Focus': Icons.bolt,
      'productivity': Icons.trending_up,
      'Fun': Icons.sports_esports,
      'Learning': Icons.school,
      'Social': Icons.people,
      'custom': Icons.category,
    };
    
    return iconMap[this] ?? Icons.category;
  }
}
