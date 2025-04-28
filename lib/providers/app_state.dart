import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../main.dart';

// Define the BreathingTechnique class outside AppState
class BreathingTechnique {
  final String name;
  final String description;
  final List<String> benefits;
  final List<String> instructions;
  final Map<String, int> pattern; // e.g., {"inhale": 4, "hold": 7, "exhale": 8}
  final int cycles; // number of repetitions
  final String iconName; // For FeatherIcons or similar
  final Color color; // Unique color for the button

  const BreathingTechnique({
    required this.name,
    required this.description,
    required this.benefits,
    required this.instructions,
    required this.pattern,
    required this.cycles,
    required this.iconName,
    required this.color,
  });
}

class AppState extends ChangeNotifier {
  int _points = 0;
  String _animationStyle = 'Circle'; // Default animation style
  bool _notificationsEnabled = true;
  int _level = 0; // Current user level
  int _dailyStreak = 0; // Track consecutive days
  String _lastExerciseDate = ''; // Track last exercise date
  int _exercisesCompleted = 0; // Track total completed exercises
  bool _soundEnabled = false; // Sound is disabled by default
  String _selectedSound = 'nature'; // Default sound option
  String? _reminderTime; // Daily reminder time

  // List of completed challenges
  List<String> _completedChallenges = [];

  // Challenge definitions with descriptions and requirements
  final Map<String, String> _challengeDescriptions = {
    'streak_7': '7-Day Streak',
    'streak_30': '30-Day Streak',
    'all_styles': 'Animation Master',
    'all_exercises': 'Exercise Explorer',
    'exercises_10': '10 Exercises Completed',
    'exercises_50': '50 Exercises Completed',
    'level_2': 'Level 2 Achieved',
    'daily_challenge': 'Daily Deep Breathing',
    'weekly_challenge': 'Weekly Relaxation',
  };

  // Challenge requirements and tracking info
  final Map<String, Map<String, dynamic>> _challengeRequirements = {
    'streak_7': {'type': 'streak', 'target': 7},
    'streak_30': {'type': 'streak', 'target': 30},
    'all_styles': {'type': 'styles', 'target': 3},
    'all_exercises': {
      'type': 'exercises',
      'target': -1
    }, // Special case: all techniques
    'exercises_10': {'type': 'count', 'target': 10},
    'exercises_50': {'type': 'count', 'target': 50},
    'level_2': {'type': 'level', 'target': 2},
    'daily_challenge': {
      'type': 'daily',
      'target': 1,
      'description': 'Complete one deep breathing exercise today'
    },
    'weekly_challenge': {
      'type': 'weekly',
      'target': 5,
      'description': 'Complete 5 breathing exercises this week'
    },
  };

  // Track daily and weekly challenge progress
  int _dailyChallengeProgress = 0;
  int _weeklyChallengeProgress = 0;
  String _dailyChallengeDate = '';
  String _weeklyChallengeStartDate = '';

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

  // Add the list of breathing techniques
  final List<BreathingTechnique> _breathingTechniques = [
    const BreathingTechnique(
      name: "Belly Breathing",
      description:
          "A simple technique focusing on deep breathing into the diaphragm to promote relaxation and oxygen flow.",
      benefits: ["Reduces stress", "Lowers heart rate", "Improves focus"],
      instructions: [
        "Sit or lie down comfortably.",
        "Place one hand on your chest and the other on your belly.",
        "Inhale deeply through your nose for 4 seconds, feeling your belly rise.",
        "Exhale slowly through your mouth for 6 seconds, feeling your belly fall.",
      ],
      pattern: {"inhale": 4, "exhale": 6},
      cycles: 5,
      iconName: "wind", // Example icon name
      color: Color(0xFF4682B4), // Steel Blue
    ),
    const BreathingTechnique(
      name: "4-7-8 Breathing",
      description:
          "A calming technique designed to reduce anxiety and help with sleep by regulating breath.",
      benefits: ["Promotes relaxation", "Reduces anxiety", "Aids sleep"],
      instructions: [
        "Sit with your back straight.",
        "Inhale quietly through your nose for 4 seconds.",
        "Hold your breath for 7 seconds.",
        "Exhale completely through your mouth for 8 seconds, making a whooshing sound.",
      ],
      pattern: {"inhale": 4, "hold": 7, "exhale": 8},
      cycles: 4,
      iconName: "moon", // Example icon name
      color: Color(0xFF5F9EA0), // Cadet Blue
    ),
    const BreathingTechnique(
      name: "Box Breathing",
      description:
          "A structured technique used by athletes and professionals to enhance concentration and calm the mind.",
      benefits: ["Improves focus", "Reduces stress", "Balances emotions"],
      instructions: [
        "Sit upright and relax your shoulders.",
        "Inhale through your nose for 4 seconds.",
        "Hold your breath for 4 seconds.",
        "Exhale through your mouth for 4 seconds.",
        "Hold your breath again for 4 seconds.",
      ],
      pattern: {
        "inhale": 4,
        "hold1": 4,
        "exhale": 4,
        "hold2": 4
      }, // Renamed holds for uniqueness
      cycles: 6,
      iconName: "square", // Example icon name
      color: Color(0xFF3CB371), // Medium Sea Green
    ),
    const BreathingTechnique(
      name: "Alternate Nostril Breathing",
      description:
          "A yogic practice that balances the left and right hemispheres of the brain through alternating nostril breathing.",
      benefits: [
        "Enhances mental clarity",
        "Reduces stress",
        "Balances energy"
      ],
      instructions: [
        "Sit comfortably with a straight spine.",
        "Close your right nostril with your thumb and inhale through your left nostril for 4 seconds.",
        "Close your left nostril with your ring finger and hold for 4 seconds.",
        "Release your right nostril and exhale for 6 seconds.",
        "Repeat, alternating nostrils.",
      ],
      pattern: {
        "inhale": 4,
        "hold": 4,
        "exhale": 6
      }, // Note: UI needs to guide nostril switching
      cycles: 5, // Per side
      iconName: "git-branch", // Example icon name
      color: Color(0xFF9370DB), // Medium Purple
    ),
    const BreathingTechnique(
      name: "Pursed Lip Breathing",
      description:
          "A technique to slow down breathing and improve oxygen exchange, often used for lung conditions.",
      benefits: [
        "Improves breathing efficiency",
        "Reduces shortness of breath",
        "Calms the mind"
      ],
      instructions: [
        "Sit or stand comfortably.",
        "Inhale through your nose for 2 seconds.",
        "Purse your lips (like whistling) and exhale slowly for 4 seconds.",
      ],
      pattern: {"inhale": 2, "exhale": 4},
      cycles: 8,
      iconName: "sunrise", // Example icon name
      color: Color(0xFFFFA07A), // Light Salmon
    ),
    const BreathingTechnique(
      name: "Bhramari Pranayama (Bee)",
      description:
          "A humming breath technique that soothes the nervous system with sound vibration.",
      benefits: ["Relieves tension", "Reduces anger", "Improves sleep quality"],
      instructions: [
        "Sit in a quiet place with your eyes closed.",
        "Inhale deeply through your nose for 4 seconds.",
        'Close your ears with your thumbs and exhale for 6 seconds, making a humming "bee" sound.',
      ],
      pattern: {
        "inhale": 4,
        "exhale": 6
      }, // Note: UI needs to remind user to hum
      cycles: 7,
      iconName: "headphones", // Example icon name
      color: Color(0xFFCD853F), // Peru
    ),
    const BreathingTechnique(
      name: "Kapal Bhati Pranayama",
      description:
          "An energizing technique involving forceful exhalations to cleanse the body and mind.",
      benefits: [
        "Boosts energy",
        "Improves digestion",
        "Enhances mental alertness"
      ],
      instructions: [
        "Sit cross-legged with a straight spine.",
        "Take a deep inhale through your nose for 2 seconds.",
        "Exhale forcefully through your nose for 1 second by contracting your abdomen.",
        "Let the inhale happen passively.",
      ],
      pattern: {
        "inhale": 2,
        "exhale": 1
      }, // Note: Exhale is forceful, passive inhale
      cycles: 20,
      iconName: "zap", // Example icon name
      color: Color(0xFFFF6347), // Tomato
    ),
  ];

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
  int get exercisesCompleted => _exercisesCompleted;
  Map<String, Map<String, dynamic>> get challengeRequirements =>
      _challengeRequirements;
  bool get soundEnabled => _soundEnabled;
  String get selectedSound => _selectedSound;
  String? get reminderTime => _reminderTime;
  int get dailyChallengeProgress => _dailyChallengeProgress;
  int get weeklyChallengeProgress => _weeklyChallengeProgress;

  // Getter for breathing techniques
  List<BreathingTechnique> get breathingTechniques => _breathingTechniques;

  // Constructor to load saved preferences
  AppState() {
    _loadFromPrefs();
  }

  // Add points when exercise is completed
  void addPoints(int value) {
    int previousPoints = _points;
    _points += value;

    // Increment completed exercises count
    _exercisesCompleted++;

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

    // Check exercise count challenges
    _checkExerciseCountChallenges();

    // Check level-based challenges
    _checkLevelChallenges();

    // Update daily and weekly challenges
    _updateDailyChallenge();
    _updateWeeklyChallenge();

    _saveToPrefs();
    notifyListeners();
  }

  // Update daily challenge progress
  void _updateDailyChallenge() {
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD

    // Reset progress if it's a new day
    if (_dailyChallengeDate != today) {
      _dailyChallengeProgress = 0;
      _dailyChallengeDate = today;
    }

    // Increment progress
    _dailyChallengeProgress++;

    // Check if daily challenge is completed
    if (_dailyChallengeProgress >= 1 &&
        !_completedChallenges.contains('daily_challenge')) {
      _completedChallenges.add('daily_challenge');
    }
  }

  // Update weekly challenge progress
  void _updateWeeklyChallenge() {
    final now = DateTime.now();

    // Get the start of the current week (Monday)
    final currentWeekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .toIso8601String()
        .split('T')[0];

    // Reset progress if it's a new week
    if (_weeklyChallengeStartDate != currentWeekStart) {
      _weeklyChallengeProgress = 0;
      _weeklyChallengeStartDate = currentWeekStart;
    }

    // Increment progress
    _weeklyChallengeProgress++;

    // Check if weekly challenge is completed
    if (_weeklyChallengeProgress >= 5 &&
        !_completedChallenges.contains('weekly_challenge')) {
      _completedChallenges.add('weekly_challenge');
    }
  }

  // Update level based on points (1 level per 100 points)
  void _updateLevel() {
    int newLevel = _points ~/ 100;
    if (newLevel != _level) {
      _level = newLevel;
      _checkLevelChallenges();
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
        _checkStreakChallenges();
      } else if (difference > 1) {
        // Streak broken
        _dailyStreak = 1;
      }
    }

    _lastExerciseDate = today;
    _saveToPrefs();
    notifyListeners();
  }

  // Check streak-based challenges
  void _checkStreakChallenges() {
    if (_dailyStreak >= 7 && !_completedChallenges.contains('streak_7')) {
      _completedChallenges.add('streak_7');
      notifyListeners();
    }
    if (_dailyStreak >= 30 && !_completedChallenges.contains('streak_30')) {
      _completedChallenges.add('streak_30');
      notifyListeners();
    }
  }

  // Check exercise count challenges
  void _checkExerciseCountChallenges() {
    if (_exercisesCompleted >= 10 &&
        !_completedChallenges.contains('exercises_10')) {
      _completedChallenges.add('exercises_10');
      notifyListeners();
    }
    if (_exercisesCompleted >= 50 &&
        !_completedChallenges.contains('exercises_50')) {
      _completedChallenges.add('exercises_50');
      notifyListeners();
    }
  }

  // Check level-based challenges
  void _checkLevelChallenges() {
    if (_level >= 2 && !_completedChallenges.contains('level_2')) {
      _completedChallenges.add('level_2');
      notifyListeners();
    }
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

    // If all breathing techniques have been completed, add the challenge
    if (completedExercises.length >= _breathingTechniques.length &&
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

  // Set reminder time
  void setReminderTime(String time) {
    _reminderTime = time;
    _saveToPrefs();
    notifyListeners();
  }

  // Toggle sound
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    _saveToPrefs();
    notifyListeners();
  }

  // Set selected sound
  void setSelectedSound(String sound) {
    _selectedSound = sound;
    _saveToPrefs();
    notifyListeners();
  }

  // Schedule notification
  Future<void> scheduleNotification() async {
    if (!_notificationsEnabled || _reminderTime == null) return;

    try {
      // Cancel any existing notifications
      await flutterLocalNotificationsPlugin.cancelAll();

      // Parse reminder time
      final timeParts = _reminderTime!.split(' ');
      if (timeParts.length != 2) return;

      final hourMinute = timeParts[0].split(':');
      if (hourMinute.length != 2) return;

      int hour = int.tryParse(hourMinute[0]) ?? 0;
      final int minute = int.tryParse(hourMinute[1]) ?? 0;

      // Convert to 24-hour format
      if (timeParts[1] == 'PM' && hour < 12) hour += 12;
      if (timeParts[1] == 'AM' && hour == 12) hour = 0;

      // Schedule the daily notification - using DefaultStyleInformation to avoid BigPictureStyle
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'breathing_reminder',
        'Breathing Reminders',
        channelDescription: 'Daily reminders for breathing exercises',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        styleInformation: DefaultStyleInformation(
            true, true), // Use DefaultStyleInformation instead
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      // Use a simple daily notification
      await flutterLocalNotificationsPlugin.periodicallyShow(
        0,
        'Breathly Reminder',
        'Take a moment to breathe and relax',
        RepeatInterval.daily,
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint('Daily notification scheduled for $hour:$minute');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
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
    _exercisesCompleted = prefs.getInt('exercisesCompleted') ?? 0;
    _soundEnabled = prefs.getBool('soundEnabled') ?? false;
    _selectedSound = prefs.getString('selectedSound') ?? 'nature';
    _reminderTime = prefs.getString('reminderTime');

    // Load challenge progress
    _dailyChallengeProgress = prefs.getInt('dailyChallengeProgress') ?? 0;
    _weeklyChallengeProgress = prefs.getInt('weeklyChallengeProgress') ?? 0;
    _dailyChallengeDate = prefs.getString('dailyChallengeDate') ?? '';
    _weeklyChallengeStartDate =
        prefs.getString('weeklyChallengeStartDate') ?? '';

    // Load unlocked animation styles
    _unlockedAnimations['Linear'] = prefs.getBool('unlockedLinear') ?? false;
    _unlockedAnimations['Square'] = prefs.getBool('unlockedSquare') ?? false;

    // Ensure we have a valid animation style (in case of previously saved invalid value)
    if (!_unlockedAnimations[_animationStyle]!) {
      _animationStyle = 'Circle';
    }

    // Make sure level is in sync with points
    _updateLevel();

    // Check if we need to reset daily/weekly challenges
    _checkChallengeResets();

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
    await prefs.setInt('exercisesCompleted', _exercisesCompleted);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setString('selectedSound', _selectedSound);
    if (_reminderTime != null) {
      await prefs.setString('reminderTime', _reminderTime!);
    }

    // Save challenge progress
    await prefs.setInt('dailyChallengeProgress', _dailyChallengeProgress);
    await prefs.setInt('weeklyChallengeProgress', _weeklyChallengeProgress);
    await prefs.setString('dailyChallengeDate', _dailyChallengeDate);
    await prefs.setString(
        'weeklyChallengeStartDate', _weeklyChallengeStartDate);

    // Save unlocked animation styles
    await prefs.setBool('unlockedLinear', _unlockedAnimations['Linear']!);
    await prefs.setBool('unlockedSquare', _unlockedAnimations['Square']!);
  }

  // Check if we need to reset daily/weekly challenges
  void _checkChallengeResets() {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0]; // YYYY-MM-DD

    // Reset daily challenge if it's a new day
    if (_dailyChallengeDate != today) {
      _dailyChallengeProgress = 0;
      _dailyChallengeDate = today;

      // Remove daily challenge from completed challenges to allow it to be completed again
      _completedChallenges.remove('daily_challenge');
    }

    // Get the start of the current week (Monday)
    final currentWeekStart = now
        .subtract(Duration(days: now.weekday - 1))
        .toIso8601String()
        .split('T')[0];

    // Reset weekly challenge if it's a new week
    if (_weeklyChallengeStartDate != currentWeekStart) {
      _weeklyChallengeProgress = 0;
      _weeklyChallengeStartDate = currentWeekStart;

      // Remove weekly challenge from completed challenges to allow it to be completed again
      _completedChallenges.remove('weekly_challenge');
    }
  }

  // Helper method to check challenge progress
  Map<String, dynamic> getChallengeProgress(String challengeId) {
    if (!_challengeRequirements.containsKey(challengeId)) {
      return {'completed': false, 'progress': 0, 'target': 0};
    }

    final requirement = _challengeRequirements[challengeId]!;
    final bool completed = _completedChallenges.contains(challengeId);
    int progress = 0;
    int target = requirement['target'] as int;
    String description = requirement['description'] as String? ?? '';

    switch (requirement['type']) {
      case 'streak':
        progress = _dailyStreak;
        break;
      case 'styles':
        progress =
            _unlockedAnimations.values.where((unlocked) => unlocked).length;
        break;
      case 'count':
        progress = _exercisesCompleted;
        break;
      case 'level':
        progress = _level;
        break;
      case 'daily':
        progress = _dailyChallengeProgress;
        description = 'Complete one breathing exercise today';
        break;
      case 'weekly':
        progress = _weeklyChallengeProgress;
        description = 'Complete 5 breathing exercises this week';
        break;
      case 'exercises':
        // This is a special case handled differently
        progress = 0; // Placeholder, handled in other methods
        break;
    }

    return {
      'completed': completed,
      'progress': progress,
      'target': target,
      'description': description,
    };
  }
}
