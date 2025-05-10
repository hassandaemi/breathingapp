import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_dialog.dart';
import '../widgets/custom_breathing_animation.dart';
import '../widgets/music_player_widget.dart';
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
  late AppState _appState; // Store reference to AppState

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

    // Initialize AppState reference
    _appState = Provider.of<AppState>(context, listen: false);

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
    // Removed automatic background music start. Music is now only controlled by the music widget.
  }

  // Empty audio initialization method - kept for future use if needed
  Future<void> _initAudio() async {
    // Audio initialization is no longer needed as sound feature has been removed
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    // Removed automatic background music stop. Music is now only controlled by the music widget.
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
    // Removed automatic background music start. Music is now only controlled by the music widget.
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

    // Sound feature has been removed

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

  void _completeExercise() async {
    if (!mounted || _isCompleted) return;
    _controller.stop();

    // First update the UI to show completion
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = true;
      _currentPhaseKey = "completed";
      _currentPhaseDuration = 0;
    });

    // Sound feature has been removed

    // Removed automatic background music stop. Music is now only controlled by the music widget.

    // Add points and update stats
    _appState.addPoints(10);
    _appState.updateDailyStreak();
    _appState.checkAllExercisesChallenge(widget.technique.name);

    // Save exercise to history
    await _appState.saveExerciseToHistory(widget.technique);

    // Show dialog with a slight delay and make it dismissible
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true, // Allow dismissing by tapping outside
            builder: (BuildContext context) {
              return MoodDialog(
                onCompleted: () {
                  if (mounted) {
                    // Don't pop the breathing screen, just check for title unlock
                    // This allows the user to stay on this screen and practice again
                    _checkForTitleUnlock(_appState);
                  }
                },
              );
            },
          );
        }
      });
    }
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
          // Use LayoutBuilder to ensure the layout respects its constraints
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // Ensure the column doesn't overflow
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Responsive top cycle indicator
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate available space
                      final screenHeight = MediaQuery.of(context).size.height;
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isSmallScreen =
                          screenWidth < 360 || screenHeight < 600;
                      final isVerySmallScreen =
                          screenWidth < 300 || screenHeight < 500;

                      return Padding(
                        padding: EdgeInsets.only(
                          top: isVerySmallScreen
                              ? 8.0
                              : (isSmallScreen ? 12.0 : 16.0),
                          left: 8.0,
                          right: 8.0,
                          bottom: isVerySmallScreen ? 0.0 : 4.0,
                        ),
                        child: Text(
                          _isCompleted
                              ? 'Well Done!'
                              : _currentCycle > 0
                                  ? 'Cycle $_currentCycle of ${_getRequiredCycles()}'
                                  : (_isRunning ? 'Get Ready...' : ' '),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: isVerySmallScreen
                                ? 14
                                : (isSmallScreen ? 16 : 18),
                            color: AppTheme.primaryColor
                                .withAlpha((0.8 * 255).toInt()),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available space
                        final screenHeight = MediaQuery.of(context).size.height;
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isSmallScreen =
                            screenWidth < 360 || screenHeight < 600;
                        final isVerySmallScreen =
                            screenWidth < 300 || screenHeight < 500;

                        // Calculate the smaller dimension for proportional sizing
                        final smallerDimension = screenWidth < screenHeight
                            ? screenWidth
                            : screenHeight;

                        // Adaptive sizes based on screen dimensions
                        final animationSize = isVerySmallScreen
                            ? smallerDimension * 0.5
                            : (isSmallScreen
                                ? smallerDimension * 0.6
                                : smallerDimension * 0.65);

                        final pulseSize = animationSize *
                            1.1; // Slightly larger than animation

                        final timerSize = isVerySmallScreen
                            ? 90.0
                            : (isSmallScreen ? 100.0 : 120.0);

                        final timerFontSize = isVerySmallScreen
                            ? 32.0
                            : (isSmallScreen ? 38.0 : 46.0);

                        final phaseNameFontSize = isVerySmallScreen
                            ? 18.0
                            : (isSmallScreen ? 22.0 : 26.0);

                        final subtextFontSize = isVerySmallScreen
                            ? 9.0
                            : (isSmallScreen ? 10.0 : 12.0);

                        // Spacing between elements
                        final topSpacing = isVerySmallScreen
                            ? 8.0
                            : (isSmallScreen ? 12.0 : 20.0);

                        final bottomSpacing = isVerySmallScreen
                            ? 4.0
                            : (isSmallScreen ? 6.0 : 10.0);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Animation container with adaptive sizing
                            SizedBox(
                              height: animationSize,
                              width: animationSize,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Pulse animation for phase transitions
                                  if (_showPulse)
                                    AnimatedBuilder(
                                      animation: _pulseController,
                                      builder: (context, child) {
                                        return Container(
                                          width: pulseSize,
                                          height: pulseSize,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                AppTheme.primaryColor.withAlpha(
                                              ((1.0 - _pulseController.value) *
                                                      0.3 *
                                                      255)
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
                            ),

                            // Responsive spacing
                            SizedBox(height: topSpacing),

                            // Phase name with responsive font size
                            Text(
                              _currentPhaseDisplayName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                fontSize: phaseNameFontSize,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4682B4),
                              ),
                            ),

                            // Responsive spacing
                            SizedBox(height: bottomSpacing),

                            // Timer display with responsive sizing
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: timerSize,
                                  height: timerSize,
                                  child: CircularProgressIndicator(
                                    value: _controller.isAnimating
                                        ? _controller.value
                                        : 0,
                                    strokeWidth: timerSize *
                                        0.067, // Proportional stroke width
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
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      // Format to show one decimal place for smoother countdown
                                      '${timeRemainingInPhase.toStringAsFixed(1)}s',
                                      style: GoogleFonts.lato(
                                        fontSize: timerFontSize,
                                        fontWeight: FontWeight.w300,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      _currentPhaseKey == "get_ready"
                                          ? "Starting soon..."
                                          : (_isCompleted ? "Completed!" : ""),
                                      style: GoogleFonts.lato(
                                        fontSize: subtextFontSize,
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
                        );
                      },
                    ),
                  ),
                  // Bottom controls section with improved responsive layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate available space
                      final screenHeight = MediaQuery.of(context).size.height;
                      final screenWidth = MediaQuery.of(context).size.width;
                      final isSmallScreen =
                          screenWidth < 360 || screenHeight < 600;
                      final isVerySmallScreen =
                          screenWidth < 300 || screenHeight < 500;

                      // Calculate adaptive sizes
                      final buttonHeight = isVerySmallScreen
                          ? 36.0
                          : (isSmallScreen ? 40.0 : 48.0);
                      final musicPlayerHeight = isVerySmallScreen
                          ? screenHeight * 0.12
                          : (isSmallScreen
                              ? screenHeight * 0.15
                              : screenHeight * 0.18);

                      return _appState.backgroundMusicEnabled
                          ? Container(
                              padding: EdgeInsets.only(
                                bottom: isVerySmallScreen
                                    ? 6.0
                                    : (isSmallScreen ? 10.0 : 16.0),
                                top: isVerySmallScreen ? 4.0 : 8.0,
                              ),
                              constraints: BoxConstraints(
                                maxHeight: isVerySmallScreen
                                    ? screenHeight * 0.22
                                    : screenHeight * 0.25,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        bottom: isVerySmallScreen ? 6.0 : 8.0,
                                      ),
                                      constraints: BoxConstraints(
                                        maxHeight: musicPlayerHeight,
                                      ),
                                      child: const MusicPlayerWidget(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: screenWidth *
                                        (isVerySmallScreen ? 0.5 : 0.6),
                                    height: buttonHeight,
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
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isVerySmallScreen
                                              ? 16
                                              : (isSmallScreen ? 24 : 32),
                                          vertical: isVerySmallScreen
                                              ? 6
                                              : (isSmallScreen ? 8 : 10),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        textStyle: GoogleFonts.lato(
                                          fontSize: isVerySmallScreen
                                              ? 14
                                              : (isSmallScreen ? 16 : 18),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      child: Text(
                                        _isCompleted
                                            ? 'Practice Again'
                                            : (_isRunning && !_isPaused
                                                ? 'Pause'
                                                : (_isPaused
                                                    ? 'Resume'
                                                    : 'Start')),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                bottom: isVerySmallScreen
                                    ? 6.0
                                    : (isSmallScreen ? 10.0 : 16.0),
                                top: isVerySmallScreen ? 4.0 : 8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: screenWidth *
                                        (isVerySmallScreen ? 0.5 : 0.6),
                                    height: buttonHeight,
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
                                        padding: EdgeInsets.symmetric(
                                          horizontal: isVerySmallScreen
                                              ? 16
                                              : (isSmallScreen ? 24 : 32),
                                          vertical: isVerySmallScreen
                                              ? 6
                                              : (isSmallScreen ? 8 : 10),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                        ),
                                        textStyle: GoogleFonts.lato(
                                          fontSize: isVerySmallScreen
                                              ? 14
                                              : (isSmallScreen ? 16 : 18),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      child: Text(
                                        _isCompleted
                                            ? 'Practice Again'
                                            : (_isRunning && !_isPaused
                                                ? 'Pause'
                                                : (_isPaused
                                                    ? 'Resume'
                                                    : 'Start')),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
