import 'package:flutter/material.dart';

class Exercise {
  final String title;
  final String description;
  final String iconName;
  final Color color;
  final int inhaleTime;
  final int holdTime;
  final int exhaleTime;
  final int cycles;

  Exercise({
    required this.title,
    required this.description,
    required this.iconName,
    required this.color,
    required this.inhaleTime,
    required this.holdTime,
    required this.exhaleTime,
    required this.cycles,
  });
}

// Predefined exercises
class ExercisesList {
  static List<Exercise> exercises = [
    Exercise(
      title: 'Calm',
      description: '4-4-4 breathing for balance and calm',
      iconName: 'feather',
      color: Colors.blue,
      inhaleTime: 4,
      holdTime: 4,
      exhaleTime: 4,
      cycles: 5,
    ),
    Exercise(
      title: 'Sleep',
      description: '4-7-8 breathing for deep relaxation',
      iconName: 'moon',
      color: Colors.indigo,
      inhaleTime: 4,
      holdTime: 7,
      exhaleTime: 8,
      cycles: 4,
    ),
    Exercise(
      title: 'Energy',
      description: 'Rapid breathing for energy boost',
      iconName: 'flash',
      color: Colors.lightBlue,
      inhaleTime: 2,
      holdTime: 0,
      exhaleTime: 2,
      cycles: 10,
    ),
  ];
}
