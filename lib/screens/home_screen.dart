import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/exercise_card.dart';
import '../widgets/points_badge.dart';
import 'breathing_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Check if we've unlocked new animation styles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.isStyleUnlocked('Linear') &&
          !appState.unlockedAnimations['Linear']!) {
        _showUnlockDialog(context, 'Linear Animation Style',
            'You\'ve unlocked the Linear animation style!');
      } else if (appState.isStyleUnlocked('Square') &&
          !appState.unlockedAnimations['Square']!) {
        _showUnlockDialog(context, 'Square Animation Style',
            'You\'ve unlocked the Square animation style!');
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mainGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(context),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Breathly',
                      style: AppTheme.titleStyle,
                    ),
                    const Spacer(),
                    _buildAnimationStyleDropdown(context, appState),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Take a moment to breathe',
                  style: AppTheme.subtitleStyle,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  appState.getNextUnlockMessage(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildExercisesList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnlockDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Great!'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PointsBadge(points: appState.points),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            splashRadius: 24,
            color: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationStyleDropdown(BuildContext context, AppState appState) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: DropdownButton<String>(
        value: appState.animationStyle,
        onChanged: (String? newValue) {
          if (newValue != null && appState.isStyleUnlocked(newValue)) {
            appState.setAnimationStyle(newValue);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Earn more points to unlock $newValue style!'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        items: [
          DropdownMenuItem(
            value: 'Circle',
            child: const Text('Circle'),
          ),
          DropdownMenuItem(
            value: 'Linear',
            child: Row(
              children: [
                const Text('Linear'),
                if (!appState.isStyleUnlocked('Linear'))
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.lock, size: 16),
                  ),
              ],
            ),
          ),
          DropdownMenuItem(
            value: 'Square',
            child: Row(
              children: [
                const Text('Square'),
                if (!appState.isStyleUnlocked('Square'))
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(Icons.lock, size: 16),
                  ),
              ],
            ),
          ),
        ],
        icon: const Icon(Icons.animation, size: 16),
        underline: Container(height: 0),
        isDense: true,
      ),
    );
  }

  Widget _buildExercisesList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 10),
      itemCount: ExercisesList.exercises.length,
      itemBuilder: (context, index) {
        final exercise = ExercisesList.exercises[index];
        return ExerciseCard(
          exercise: exercise,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BreathingScreen(
                  exercise: exercise,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
