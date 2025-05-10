import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen size to ensure proper layout
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Colors.white],
          ),
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
                  'Challenges',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2F4F4F),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Complete challenges to earn rewards',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildChallengesList(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Breathly',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha(26), // 0.1 * 255 ≈ 26
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  FeatherIcons.award,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Challenges',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesList(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Get all challenge IDs
    final allChallenges = appState.challengeRequirements.keys.toList();

    // If there are no challenges
    if (allChallenges.isEmpty) {
      return _buildEmptyChallengeState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: allChallenges.length,
      itemBuilder: (context, index) {
        final challengeId = allChallenges[index];
        final challengeName =
            appState.challengeDescriptions[challengeId] ?? 'Unknown Challenge';
        final progress = appState.getChallengeProgressSync(challengeId);
        final isCompleted = progress['completed'] as bool;
        final currentProgress = progress['progress'] as int;
        final target = progress['target'] as int;

        return _buildChallengeCard(
          context,
          challengeName,
          _getChallengeDescription(challengeId),
          _getChallengeIcon(challengeId),
          currentProgress,
          target,
          isCompleted,
        );
      },
    );
  }

  Widget _buildEmptyChallengeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FeatherIcons.flag,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No challenges available yet!',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete exercises to unlock challenges',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    int progress,
    int target,
    bool isCompleted,
  ) {
    final double percentage =
        target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withAlpha(51) // 0.2 * 255 ≈ 51
                        : AppTheme.primaryColor.withAlpha(26), // 0.1 * 255 ≈ 26
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isCompleted ? Colors.green : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26), // 0.1 * 255 ≈ 26
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      FeatherIcons.check,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor:
                          Colors.grey.withAlpha(26), // 0.1 * 255 ≈ 26
                      minHeight: 8,
                      color: isCompleted ? Colors.green : AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  target > 0 ? '$progress/$target' : 'In Progress',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    FeatherIcons.award,
                    size: 16,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reward: 50 points',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber[700],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getChallengeDescription(String challengeId) {
    switch (challengeId) {
      case 'streak_7':
        return 'Complete breathing exercises for 7 consecutive days';
      case 'streak_30':
        return 'Complete breathing exercises for 30 consecutive days';
      case 'all_styles':
        return 'Unlock all animation styles';
      case 'all_exercises':
        return 'Try all breathing techniques at least once';
      case 'exercises_10':
        return 'Complete 10 breathing exercises';
      case 'exercises_50':
        return 'Complete 50 breathing exercises';
      case 'level_2':
        return 'Reach level 2';
      default:
        return 'Complete this challenge to earn rewards';
    }
  }

  IconData _getChallengeIcon(String challengeId) {
    switch (challengeId) {
      case 'streak_7':
      case 'streak_30':
        return FeatherIcons.calendar;
      case 'all_styles':
        return FeatherIcons.eye;
      case 'all_exercises':
        return FeatherIcons.checkCircle;
      case 'exercises_10':
      case 'exercises_50':
        return FeatherIcons.activity;
      case 'level_2':
        return FeatherIcons.award;
      default:
        return FeatherIcons.flag;
    }
  }
}
