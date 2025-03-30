import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/breathing_animation.dart';
import '../widgets/mood_dialog.dart';

class BreathingScreen extends StatefulWidget {
  final Exercise exercise;

  const BreathingScreen({super.key, required this.exercise});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  bool _isRunning = false;
  bool _isCompleted = false;
  String _currentPhase = "Get Ready";
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  int _currentCycle = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _calculateTotalTime();
  }

  void _calculateTotalTime() {
    int cycleTime = widget.exercise.inhaleTime +
        widget.exercise.holdTime +
        widget.exercise.exhaleTime;
    _totalSeconds = cycleTime * widget.exercise.cycles;
    _remainingSeconds = _totalSeconds;
  }

  void _startBreathing() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
      if (_currentPhase == "Get Ready") {
        _currentPhase = "inhale";
        _currentCycle = 1;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _completeExercise();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      _updateBreathingPhase();
    });
  }

  void _pauseBreathing() {
    if (!_isRunning) return;

    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _updateBreathingPhase() {
    int cycleTime = widget.exercise.inhaleTime +
        widget.exercise.holdTime +
        widget.exercise.exhaleTime;

    int currentTimeInCycle = _totalSeconds - _remainingSeconds;
    currentTimeInCycle = currentTimeInCycle % cycleTime;

    // Calculate current cycle
    _currentCycle =
        ((_totalSeconds - _remainingSeconds) / cycleTime).floor() + 1;
    if (_currentCycle > widget.exercise.cycles) {
      _currentCycle = widget.exercise.cycles;
    }

    String newPhase;
    if (currentTimeInCycle < widget.exercise.inhaleTime) {
      newPhase = "inhale";
    } else if (currentTimeInCycle <
        widget.exercise.inhaleTime + widget.exercise.holdTime) {
      newPhase = "hold";
    } else {
      newPhase = "exhale";
    }

    if (newPhase != _currentPhase) {
      setState(() {
        _currentPhase = newPhase;
      });
    }
  }

  void _completeExercise() {
    _timer?.cancel();

    // Add points
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addPoints(10);

    setState(() {
      _isRunning = false;
      _isCompleted = true;
      _currentPhase = "Completed";
    });

    // Show mood dialog
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return MoodDialog(
              onCompleted: () {
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            );
          },
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAppBar(),
              const Spacer(),
              _buildPhaseText(),
              const SizedBox(height: 30),
              _buildAnimation(),
              const SizedBox(height: 30),
              _buildTimer(),
              const Spacer(),
              _buildControlButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
            color: AppTheme.primaryColor,
          ),
          Expanded(
            child: Text(
              widget.exercise.title,
              style: AppTheme.titleStyle.copyWith(
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance for the back button
        ],
      ),
    );
  }

  Widget _buildPhaseText() {
    String displayPhase = _currentPhase;
    if (displayPhase == "inhale") {
      displayPhase = "Inhale";
    } else if (displayPhase == "hold") {
      displayPhase = "Hold";
    } else if (displayPhase == "exhale") {
      displayPhase = "Exhale";
    }

    return AnimatedOpacity(
      opacity: _isCompleted ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: Text(
        displayPhase,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: widget.exercise.color,
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    // Adjust animation durations based on exercise type
    Duration duration;
    if (_currentPhase == "inhale") {
      switch (widget.exercise.title) {
        case "Calm":
          duration = const Duration(seconds: 4);
          break;
        case "Sleep":
          duration = const Duration(seconds: 4);
          break;
        case "Energy":
          duration = const Duration(seconds: 2);
          break;
        default:
          duration = Duration(seconds: widget.exercise.inhaleTime);
      }
    } else if (_currentPhase == "hold") {
      duration = Duration(seconds: widget.exercise.holdTime);
    } else if (_currentPhase == "exhale") {
      switch (widget.exercise.title) {
        case "Calm":
          duration = const Duration(seconds: 4);
          break;
        case "Sleep":
          duration = const Duration(seconds: 7);
          break;
        case "Energy":
          duration = const Duration(seconds: 2);
          break;
        default:
          duration = Duration(seconds: widget.exercise.exhaleTime);
      }
    } else {
      duration = const Duration(seconds: 1);
    }

    return Center(
      child: _currentPhase == "Get Ready" || _currentPhase == "Completed"
          ? Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.exercise.color.withAlpha((0.2 * 255).toInt()),
                border: Border.all(
                  color: widget.exercise.color.withAlpha((0.5 * 255).toInt()),
                  width: 3,
                ),
              ),
              child: _isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 80,
                      color: Colors.green,
                    )
                  : const Icon(
                      Icons.play_arrow,
                      size: 80,
                      color: Colors.blue,
                    ),
            )
          : BreathingAnimation(
              phase: _currentPhase,
              duration: duration,
              minSize: 150,
              maxSize: 250,
            ),
    );
  }

  Widget _buildTimer() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Column(
      children: [
        Text(
          '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCompleted
              ? 'Great job!'
              : 'Cycle $_currentCycle/${widget.exercise.cycles}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton() {
    return SizedBox(
      width: 60, // Increased FAB size
      height: 60, // Increased FAB size
      child: FloatingActionButton(
        onPressed: _isCompleted
            ? () => Navigator.pop(context)
            : _isRunning
                ? _pauseBreathing
                : _startBreathing,
        backgroundColor: _isCompleted ? Colors.green : widget.exercise.color,
        elevation: 8, // Add shadow for depth
        child: Icon(
          _isCompleted
              ? Icons.check
              : _isRunning
                  ? Icons.pause
                  : Icons.play_arrow,
          size: 28, // Larger icon size
        ),
      ),
    );
  }
}
