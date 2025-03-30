import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  int _points = 0;
  String _animationStyle = 'Circle'; // Default animation style
  bool _notificationsEnabled = true;

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

    // Check if we crossed the Linear threshold
    if (previousPoints < 50 &&
        _points >= 50 &&
        !_unlockedAnimations['Linear']!) {
      _unlockedAnimations['Linear'] = true;
    }

    // Check if we crossed the Square threshold
    if (previousPoints < 100 &&
        _points >= 100 &&
        !_unlockedAnimations['Square']!) {
      _unlockedAnimations['Square'] = true;
    }

    _saveToPrefs();
    notifyListeners();
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

    // Load unlocked animation styles
    _unlockedAnimations['Linear'] = prefs.getBool('unlockedLinear') ?? false;
    _unlockedAnimations['Square'] = prefs.getBool('unlockedSquare') ?? false;

    // Ensure we have a valid animation style (in case of previously saved invalid value)
    if (!_unlockedAnimations[_animationStyle]!) {
      _animationStyle = 'Circle';
    }

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', _points);
    await prefs.setString('animationStyle', _animationStyle);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);

    // Save unlocked animation styles
    await prefs.setBool('unlockedLinear', _unlockedAnimations['Linear']!);
    await prefs.setBool('unlockedSquare', _unlockedAnimations['Square']!);
  }
}
