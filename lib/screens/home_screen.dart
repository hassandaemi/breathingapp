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
                child: Text(
                  'Breathly',
                  style: AppTheme.titleStyle,
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
              const SizedBox(height: 30),
              Expanded(
                child: _buildExercisesList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
