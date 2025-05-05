import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_dialog.dart';
import '../widgets/custom_breathing_animation.dart';
import 'profile_screen.dart';

class BreathingScreen extends StatefulWidget {
  final BreathingTechnique technique;

  const BreathingScreen({super.key, required this.technique});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController
      _pulseController; // For phase transition pulse effect
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioInitialized = false;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  String _currentPhaseKey = "get_ready";
  int _currentPhaseDuration = 3;
  int _currentCycle = 0;
  int _currentPhaseIndex = -1;
  late List<String> _phaseOrder;
  bool _showPulse = false; // Control visibility of pulse animation

  // Default pattern in case the technique's pattern is invalid
  final Map<String, int> _defaultPattern = {
    "inhale": 4,
    "exhale": 4,
  };
  final int _defaultCycles = 5;

  String get _currentPhaseDisplayName {
    if (_currentPhaseKey == "get_ready") return "Get Ready";
    if (_isCompleted) return "Completed";

    // Special handling for hold phases
    if (_currentPhaseKey == "hold1") return "Hold";
    if (_currentPhaseKey == "hold2") return "Hold";

    return _capitalize(_currentPhaseKey.replaceAll(RegExp(r'[0-9]+$'), ''));
  }

  @override
  void initState() {
    super.initState();

    // Validate the technique's pattern
    if (widget.technique.pattern.isEmpty) {
      _phaseOrder = _defaultPattern.keys.toList();
    } else {
      _phaseOrder = widget.technique.pattern.keys.toList();
    }

    _controller = AnimationController(
      vsync: this,
      // Add duration here, will be updated in _prepareForStart
      duration: const Duration(seconds: 3),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_isRunning && !_isPaused) {
            _moveToNextPhase();
          }
        }
      });

    // Add listener for smoother UI updates during animation
    _controller.addListener(() {
      // Only update UI when mounted and running
      if (mounted && _isRunning && !_isPaused) {
        setState(() {
          // This empty setState forces the UI to rebuild with current animation value
        });
      }
    });

    // Initialize pulse animation controller for phase transitions
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showPulse = false;
          });
          _pulseController.reset();
        }
      });

    _prepareForStart();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      // This is just preparation for the actual audio files
      // In a real implementation, proper asset paths would be used
      _isAudioInitialized = true;
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  void _playPhaseSound(String phase) async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.soundEnabled || !_isAudioInitialized) return;

    try {
      // This is a placeholder for actual audio file paths
      // In a production app, you would have real audio files in your assets
      String audioPath;
      switch (phase) {
        case 'inhale':
          audioPath = 'assets/sounds/${appState.selectedSound}/inhale.mp3';
          break;
        case 'hold':
        case 'hold1':
        case 'hold2':
          audioPath = 'assets/sounds/${appState.selectedSound}/hold.mp3';
          break;
        case 'exhale':
          audioPath = 'assets/sounds/${appState.selectedSound}/exhale.mp3';
          break;
        case 'completed':
          audioPath = 'assets/sounds/${appState.selectedSound}/complete.mp3';
          break;
        default:
          audioPath = 'assets/sounds/${appState.selectedSound}/inhale.mp3';
      }

      // For now, we'll use a beep sound as a placeholder
      // In a production app, you would use actual audio files
      // await _audioPlayer.play(AssetSource(audioPath));

      // For now, play the beep at different volumes based on the phase
      await _audioPlayer.stop();

      // We don't actually play a sound here since we don't have the audio files
      // This is just showing how the implementation would work
      debugPrint('Would play sound: $audioPath');
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _prepareForStart() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
      _currentPhaseKey = "get_ready";
      _currentPhaseDuration = 3; // 3 seconds get ready phase
      _currentCycle = 0;
      _currentPhaseIndex = -1;
      _controller.stop();
      _controller.reset();
      _controller.duration = Duration(seconds: _currentPhaseDuration);
    });
  }

  void _startBreathing() {
    if (_isRunning && !_isPaused) return;

    setState(() {
      if (_isCompleted) {
        _prepareForStart();
      }

      _isRunning = true;
      _isPaused = false;

      if (_currentPhaseIndex == -1) {
        // We're at the "Get Ready" phase
        _controller.duration = const Duration(seconds: 3);
        // Use a gentle ease-in curve for the get ready phase
        _controller.forward(from: 0.0);
      } else {
        // We're resuming from a pause - continue from current position
        _controller.forward();
      }
    });
  }

  void _pauseBreathing() {
    if (!_isRunning || _isPaused || _isCompleted) return;

    _controller.stop();
    setState(() {
      _isPaused = true;
    });
  }

  void _moveToNextPhase({bool initialStart = false}) {
    if (_isCompleted || !_isRunning) return;

    int nextPhaseIndex = _currentPhaseIndex;
    int nextCycle = _currentCycle;

    if (_currentPhaseKey == "get_ready" || initialStart) {
      // After "Get Ready" phase, start first cycle, first phase
      nextCycle = 1;
      nextPhaseIndex = 0;
    } else {
      // Move to next phase
      nextPhaseIndex++;

      // If we've reached the end of phases for this cycle
      if (nextPhaseIndex >= _phaseOrder.length) {
        nextCycle++; // Move to next cycle
        nextPhaseIndex = 0; // Reset to first phase

        // If we've completed all cycles
        if (nextCycle > _getRequiredCycles()) {
          _completeExercise();
          return;
        }
      }
    }

    final newPhaseKey = _phaseOrder[nextPhaseIndex];
    final newPhaseDuration = _getPhaseTime(newPhaseKey);

    setState(() {
      _currentCycle = nextCycle;
      _currentPhaseIndex = nextPhaseIndex;
      _currentPhaseKey = newPhaseKey;
      _currentPhaseDuration = newPhaseDuration;
      _controller.duration = Duration(seconds: _currentPhaseDuration);
      _controller.reset();
    });

    // Play sound for the new phase (normalize the phase name to remove numbers)
    String basePhaseKey = newPhaseKey.replaceAll(RegExp(r'[0-9]+$'), '');
    _playPhaseSound(basePhaseKey);

    // Show pulse animation for phase transition
    setState(() {
      _showPulse = true;
    });
    _pulseController.forward(from: 0.0);

    if (_isRunning && !_isPaused) {
      // Apply different animation curves based on the breathing phase
      // This makes the animations feel more natural
      if (newPhaseKey == "inhale") {
        // Inhale should start slow and accelerate (ease-in)
        _controller.forward(from: 0.0);
      } else if (newPhaseKey == "exhale") {
        // Exhale should start fast and decelerate (ease-out)
        _controller.forward(from: 0.0);
      } else if (newPhaseKey.contains("hold")) {
        // Hold phases should be linear
        _controller.forward(from: 0.0);
      } else {
        // Default behavior
        _controller.forward(from: 0.0);
      }
    }
  }

  // Helper method to get the correct phase duration, with fallback to default
  int _getPhaseTime(String phaseKey) {
    // Check the technique's pattern first
    if (widget.technique.pattern.containsKey(phaseKey)) {
      return widget.technique.pattern[phaseKey]!;
    }

    // Fallback to default pattern
    final basePhaseKey = phaseKey.replaceAll(RegExp(r'[0-9]+$'), '');
    if (_defaultPattern.containsKey(basePhaseKey)) {
      return _defaultPattern[basePhaseKey]!;
    }

    // Ultimate fallback
    return 4;
  }

  // Helper method to get the correct cycle count, with fallback to default
  int _getRequiredCycles() {
    return widget.technique.cycles > 0
        ? widget.technique.cycles
        : _defaultCycles;
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  void _completeExercise() {
    if (!mounted || _isCompleted) return;
    _controller.stop();

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addPoints(10);
    appState.updateDailyStreak();
    appState.checkAllExercisesChallenge(widget.technique.name);

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = true;
      _currentPhaseKey = "completed";
      _currentPhaseDuration = 0;
    });

    // Play completion sound
    _playPhaseSound('completed');

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return MoodDialog(
              onCompleted: () {
                if (mounted) {
                  // Don't pop the breathing screen, just check for title unlock
                  // This allows the user to stay on this screen and practice again
                  _checkForTitleUnlock(appState);
                }
              },
            );
          },
        );
      }
    });
  }

  void _checkForTitleUnlock(AppState appState) {
    if (appState.points >= 100 && appState.points < 110) {
      _showTitleUnlockDialog("Calm Seeker");
    } else if (appState.points >= 250 &&
        appState.points < 260 &&
        appState.completedChallenges.length >= 2) {
      _showTitleUnlockDialog("Breath Master");
    } else if (appState.points >= 500 &&
        appState.points < 510 &&
        appState.completedChallenges.length >= 4) {
      _showTitleUnlockDialog("Breath Legend");
    }
  }

  void _showTitleUnlockDialog(String title) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Title Unlocked!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Congratulations! You\'ve earned the title:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            child: const Text('View Profile'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Reset the exercise to allow practicing again
              _prepareForStart();
            },
            child: const Text('Practice Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate time remaining with decimal precision for smoother display
    double timeRemainingInPhase = _currentPhaseDuration.toDouble();
    if (_controller.isAnimating) {
      timeRemainingInPhase =
          _controller.duration!.inSeconds * (1.0 - _controller.value);
    } else if (_isPaused || _currentPhaseKey == "get_ready") {
      timeRemainingInPhase = _currentPhaseDuration.toDouble();
    }

    // Ensure time doesn't go negative
    timeRemainingInPhase = timeRemainingInPhase < 0 ? 0 : timeRemainingInPhase;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.technique.name,
          style: GoogleFonts.lato(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.primaryColor),
          onPressed: () {
            if (_isRunning && !_isCompleted) {
              _pauseBreathing();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit Exercise?'),
                  content: const Text(
                      'Are you sure you want to stop the breathing exercise? Progress will not be saved.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _startBreathing();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('Exit',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _isCompleted
                      ? 'Well Done!'
                      : _currentCycle > 0
                          ? 'Cycle $_currentCycle of ${_getRequiredCycles()}'
                          : (_isRunning ? 'Get Ready...' : ' '),
                  style: GoogleFonts.lato(
                      fontSize: 18,
                      color:
                          AppTheme.primaryColor.withAlpha((0.8 * 255).toInt()),
                      fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse animation for phase transitions
                        if (_showPulse)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 270,
                                height: 270,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryColor.withAlpha(
                                    ((1.0 - _pulseController.value) * 0.3 * 255)
                                        .toInt(),
                                  ),
                                ),
                              );
                            },
                          ),
                        // Main breathing animation
                        CustomBreathingAnimation(
                          controller: _controller,
                          technique: widget.technique,
                          currentPhaseKey: _currentPhaseKey,
                          isCompleted: _isCompleted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Text(
                      _currentPhaseDisplayName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4682B4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value:
                                _controller.isAnimating ? _controller.value : 0,
                            strokeWidth: 8.0,
                            backgroundColor: AppTheme.primaryColor
                                .withAlpha((0.2 * 255).toInt()),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isCompleted
                                  ? Colors.green
                                  : const Color(0xFF4682B4),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              // Format to show one decimal place for smoother countdown
                              '${timeRemainingInPhase.toStringAsFixed(1)}s',
                              style: GoogleFonts.lato(
                                fontSize: 48,
                                fontWeight: FontWeight.w300,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            Text(
                              _currentPhaseKey == "get_ready"
                                  ? "Starting soon..."
                                  : (_isCompleted ? "Completed!" : ""),
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                color: AppTheme.primaryColor
                                    .withAlpha((0.7 * 255).toInt()),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: ElevatedButton(
                  onPressed: _isCompleted
                      ? _prepareForStart
                      : (_isRunning && !_isPaused
                          ? _pauseBreathing
                          : _startBreathing),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCompleted
                        ? Colors.green
                        : (_isRunning && !_isPaused
                            ? Colors.orange
                            : AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    textStyle: GoogleFonts.lato(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_isCompleted
                      ? 'Practice Again'
                      : (_isRunning && !_isPaused
                          ? 'Pause'
                          : (_isPaused ? 'Resume' : 'Start'))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
