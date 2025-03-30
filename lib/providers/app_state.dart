import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  int _points = 0;
  String _animationStyle = 'Circle'; // Default animation style
  bool _notificationsEnabled = true;
  int _level = 0; // Current user level
  int _dailyStreak = 0; // Track consecutive days
  String _lastExerciseDate = ''; // Track last exercise date

  // List of completed challenges
  List<String> _completedChallenges = [];

  // Challenge definitions
  final Map<String, String> _challengeDescriptions = {
    'streak_7': '7-Day Streak',
    'streak_30': '30-Day Streak',
    'all_styles': 'Animation Master',
    'all_exercises': 'Exercise Explorer',
  };

  // Available animation styles and their point thresholds
  final Map<String, int> _animationStyles = {
    'Circle': 0,
    'Linear': 50,
    'Square': 100,
  };

  // Track unlocked animations
  final Map<String, bool> _unlockedAnimations = {
    'Circle': true, // Always unlocked
    'Linear': false,
    'Square': false,
  };

  // Getter methods
  int get points => _points;
  int get level => _level;
  int get dailyStreak => _dailyStreak;
  String get lastExerciseDate => _lastExerciseDate;
  List<String> get completedChallenges => _completedChallenges;
  Map<String, String> get challengeDescriptions => _challengeDescriptions;
  String get animationStyle => _animationStyle;
  bool get notificationsEnabled => _notificationsEnabled;
  Map<String, int> get animationStyles => _animationStyles;
  Map<String, bool> get unlockedAnimations => _unlockedAnimations;

  // Constructor to load saved preferences
  AppState() {
    _loadFromPrefs();
  }

  // Add points when exercise is completed
  void addPoints(int value) {
    int previousPoints = _points;
    _points += value;

    // Update level when points change
    _updateLevel();

    // Check if we crossed the Linear threshold
    if (previousPoints < 50 &&
        _points >= 50 &&
        !_unlockedAnimations['Linear']!) {
      _unlockedAnimations['Linear'] = true;

      // Check if all styles are unlocked for animation master challenge
      _checkAnimationMasterChallenge();
    }

    // Check if we crossed the Square threshold
    if (previousPoints < 100 &&
        _points >= 100 &&
        !_unlockedAnimations['Square']!) {
      _unlockedAnimations['Square'] = true;

      // Check if all styles are unlocked for animation master challenge
      _checkAnimationMasterChallenge();
    }

    _saveToPrefs();
    notifyListeners();
  }

  // Update level based on points (1 level per 100 points)
  void _updateLevel() {
    int newLevel = _points ~/ 100;
    if (newLevel != _level) {
      _level = newLevel;
    }
  }

  // Get user title based on points and challenges
  String getUserTitle() {
    if (_points >= 200 && _completedChallenges.length >= 2) {
      return "Breath Legend";
    } else if (_points >= 100 && _completedChallenges.isNotEmpty) {
      return "Breath Master";
    } else if (_points >= 50) {
      return "Calm Seeker";
    } else {
      return "Breath Novice";
    }
  }

  // Update daily streak when exercise is completed
  void updateDailyStreak() {
    final today =
        DateTime.now().toIso8601String().split('T')[0]; // Just get YYYY-MM-DD

    if (_lastExerciseDate.isEmpty) {
      // First exercise ever
      _dailyStreak = 1;
    } else if (_lastExerciseDate == today) {
      // Already did an exercise today, don't increment streak
      return;
    } else {
      final lastDate = DateTime.parse(_lastExerciseDate);
      final currentDate = DateTime.parse(today);
      final difference = currentDate.difference(lastDate).inDays;

      if (difference == 1) {
        // Consecutive day
        _dailyStreak++;

        // Check streak challenges
        if (_dailyStreak == 7 && !_completedChallenges.contains('streak_7')) {
          _completedChallenges.add('streak_7');
        }
        if (_dailyStreak == 30 && !_completedChallenges.contains('streak_30')) {
          _completedChallenges.add('streak_30');
        }
      } else if (difference > 1) {
        // Streak broken
        _dailyStreak = 1;
      }
    }

    _lastExerciseDate = today;
    _saveToPrefs();
    notifyListeners();
  }

  // Check if all exercises have been completed
  Future<void> checkAllExercisesChallenge(String exerciseTitle) async {
    // Set to track unique completed exercises
    final prefs = await SharedPreferences.getInstance();
    Set<String> completedExercises =
        Set<String>.from(prefs.getStringList('completedExerciseTypes') ?? []);

    // Add current exercise to set
    completedExercises.add(exerciseTitle);

    // Save updated set to preferences
    await prefs.setStringList(
        'completedExerciseTypes', completedExercises.toList());

    // If all three exercise types have been completed, add the challenge
    if (completedExercises.length >= 3 &&
        !_completedChallenges.contains('all_exercises')) {
      _completedChallenges.add('all_exercises');
      _saveToPrefs();
      notifyListeners();
    }
  }

  // Check if all animation styles have been unlocked
  void _checkAnimationMasterChallenge() {
    if (_unlockedAnimations['Circle']! &&
        _unlockedAnimations['Linear']! &&
        _unlockedAnimations['Square']! &&
        !_completedChallenges.contains('all_styles')) {
      _completedChallenges.add('all_styles');
    }
  }

  // Check if a style is available based on points
  bool isStyleUnlocked(String style) {
    return _unlockedAnimations[style] ?? false;
  }

  // Get message about next unlock
  String getNextUnlockMessage() {
    if (!_unlockedAnimations['Linear']!) {
      return 'Earn ${50 - _points} more points to unlock Linear style';
    } else if (!_unlockedAnimations['Square']!) {
      return 'Earn ${100 - _points} more points to unlock Square style';
    } else {
      return 'All animation styles unlocked!';
    }
  }

  // Set animation style
  void setAnimationStyle(String style) {
    // Only allow setting style if it's unlocked
    if (_unlockedAnimations[style] ?? false) {
      _animationStyle = style;
      _saveToPrefs();
      notifyListeners();
    }
  }

  // Toggle notifications
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    _saveToPrefs();
    notifyListeners();
  }

  // Load data from SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _points = prefs.getInt('points') ?? 0;
    _animationStyle = prefs.getString('animationStyle') ?? 'Circle';
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _level = prefs.getInt('level') ?? 0;
    _dailyStreak = prefs.getInt('dailyStreak') ?? 0;
    _lastExerciseDate = prefs.getString('lastExerciseDate') ?? '';
    _completedChallenges = prefs.getStringList('completedChallenges') ?? [];

    // Load unlocked animation styles
    _unlockedAnimations['Linear'] = prefs.getBool('unlockedLinear') ?? false;
    _unlockedAnimations['Square'] = prefs.getBool('unlockedSquare') ?? false;

    // Ensure we have a valid animation style (in case of previously saved invalid value)
    if (!_unlockedAnimations[_animationStyle]!) {
      _animationStyle = 'Circle';
    }

    // Make sure level is in sync with points
    _updateLevel();

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', _points);
    await prefs.setString('animationStyle', _animationStyle);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setInt('level', _level);
    await prefs.setInt('dailyStreak', _dailyStreak);
    await prefs.setString('lastExerciseDate', _lastExerciseDate);
    await prefs.setStringList('completedChallenges', _completedChallenges);

    // Save unlocked animation styles
    await prefs.setBool('unlockedLinear', _unlockedAnimations['Linear']!);
    await prefs.setBool('unlockedSquare', _unlockedAnimations['Square']!);
  }
}
