import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/mood_dialog.dart';
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
  Timer? _holdTimer;

  bool _isRunning = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  String _currentPhaseName = "Get Ready";
  int _currentPhaseDuration = 3;
  int _currentCycle = 0;
  int _currentPhaseIndex = -1;
  late List<String> _phaseOrder;

  @override
  void initState() {
    super.initState();
    _phaseOrder = widget.technique.pattern.keys.toList();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _currentPhaseDuration),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _moveToNextPhase();
        }
      });

    _prepareForStart();
  }

  void _prepareForStart() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = false;
      _currentPhaseName = "Get Ready";
      _currentPhaseDuration = 3;
      _currentCycle = 0;
      _currentPhaseIndex = -1;
      _controller.duration = Duration(seconds: _currentPhaseDuration);
      _controller.reset();
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
        _moveToNextPhase(startCycle: true);
      } else {
        _controller.forward();
      }
    });
  }

  void _pauseBreathing() {
    if (!_isRunning || _isPaused) return;

    _controller.stop();
    setState(() {
      _isPaused = true;
    });
  }

  void _moveToNextPhase({bool startCycle = false}) {
    if (_isCompleted) return;

    int nextPhaseIndex = _currentPhaseIndex + 1;
    int nextCycle = _currentCycle;

    if (startCycle) {
      nextCycle = 1;
      nextPhaseIndex = 0;
    } else if (nextPhaseIndex >= _phaseOrder.length) {
      nextCycle++;
      if (nextCycle > widget.technique.cycles) {
        _completeExercise();
        return;
      }
      nextPhaseIndex = 0;
    }

    final newPhaseName = _phaseOrder[nextPhaseIndex];
    final newPhaseDuration = widget.technique.pattern[newPhaseName]!;

    setState(() {
      _currentCycle = nextCycle;
      _currentPhaseIndex = nextPhaseIndex;
      _currentPhaseName =
          _capitalize(newPhaseName.replaceAll(RegExp(r'[0-9]$'), ''));
      _currentPhaseDuration = newPhaseDuration;
      _controller.duration = Duration(seconds: _currentPhaseDuration);
      _controller.reset();
    });
    _controller.forward();
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  void _completeExercise() {
    if (!mounted) return;
    _controller.stop();

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addPoints(10);
    appState.updateDailyStreak();
    appState.checkAllExercisesChallenge(widget.technique.name);

    setState(() {
      _isRunning = false;
      _isPaused = false;
      _isCompleted = true;
      _currentPhaseName = "Completed";
      _currentPhaseDuration = 0;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return MoodDialog(
              onCompleted: () {
                if (mounted) {
                  Navigator.pop(context);
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
    if (appState.points >= 50 && appState.points < 60) {
      _showTitleUnlockDialog("Calm Seeker");
    } else if (appState.points >= 100 &&
        appState.points < 110 &&
        appState.completedChallenges.isNotEmpty) {
      _showTitleUnlockDialog("Breath Master");
    } else if (appState.points >= 200 &&
        appState.points < 210 &&
        appState.completedChallenges.length >= 2) {
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
  void dispose() {
    _controller.dispose();
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int timeRemainingInPhase = _currentPhaseDuration;
    if (_controller.isAnimating) {
      timeRemainingInPhase =
          (_controller.duration!.inSeconds * (1.0 - _controller.value)).ceil();
    }

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
                      'Are you sure you want to stop the breathing exercise?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
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
                          ? 'Cycle $_currentCycle of ${widget.technique.cycles}'
                          : ' ',
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
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: 1.0,
                                  strokeWidth: 8,
                                  color: AppTheme.primaryColor
                                      .withAlpha((0.2 * 255).toInt()),
                                ),
                              ),
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: _controller.value,
                                  strokeWidth: 8,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF4682B4)),
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _currentPhaseName,
                                    style: GoogleFonts.lato(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4682B4),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '${timeRemainingInPhase}s',
                                    style: GoogleFonts.lato(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w300,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
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
