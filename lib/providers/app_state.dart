import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  int _points = 0;
  String _animationStyle = 'Circle'; // Default animation style
  bool _notificationsEnabled = true;

  // Getter methods
  int get points => _points;
  String get animationStyle => _animationStyle;
  bool get notificationsEnabled => _notificationsEnabled;

  // Constructor to load saved preferences
  AppState() {
    _loadFromPrefs();
  }

  // Add points when exercise is completed
  void addPoints(int value) {
    _points += value;
    _saveToPrefs();
    notifyListeners();
  }

  // Set animation style
  void setAnimationStyle(String style) {
    _animationStyle = style;
    _saveToPrefs();
    notifyListeners();
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
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', _points);
    await prefs.setString('animationStyle', _animationStyle);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }
}
