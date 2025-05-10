import 'package:flutter/material.dart';

class ExerciseHistory {
  final String technique;
  final DateTime date;
  final Color color;
  final String iconName;

  ExerciseHistory({
    required this.technique,
    required this.date,
    required this.color,
    required this.iconName,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    // Store color components separately
    return {
      'technique': technique,
      'date': date.toIso8601String(),
      'color': _colorToInt(color), // Convert color to int without using .value
      'iconName': iconName,
    };
  }

  // Helper method to convert Color to int without using deprecated .value
  static int _colorToInt(Color color) {
    // Manually construct the color int value from its components
    return (0xFF000000 | // Alpha (fully opaque)
        ((color.r.toInt() & 0xFF) << 16) | // Red component
        ((color.g.toInt() & 0xFF) << 8) | // Green component
        (color.b.toInt() & 0xFF)); // Blue component
  }

  // Create from Map for database retrieval
  factory ExerciseHistory.fromMap(Map<String, dynamic> map) {
    return ExerciseHistory(
      technique: map['technique'],
      date: DateTime.parse(map['date']),
      color: Color(map['color']),
      iconName: map['iconName'],
    );
  }
}
