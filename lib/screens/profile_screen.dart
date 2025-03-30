import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userTitle = appState.getUserTitle();

    return Scaffold(
      body: Container(
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
              _buildUserHeader(context, userTitle, appState),
              const SizedBox(height: 30),
              Expanded(
                child: _buildUserStats(context, appState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.pop(context),
          child: Ink(
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.arrow_back_ios,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader(
      BuildContext context, String userTitle, AppState appState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withAlpha((0.2 * 255).toInt()),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${appState.points} Points',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.lightTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.trending_up,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Level ${appState.level}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.lightTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, appState.dailyStreak.toString(),
                  'Day Streak', Icons.calendar_today),
              _buildStatItem(
                  context,
                  appState.completedChallenges.length.toString(),
                  'Challenges',
                  Icons.emoji_events),
              _buildStatItem(context, '${appState.level * 100}/100',
                  'Level Progress', Icons.bolt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Completed Challenges',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: appState.completedChallenges.isEmpty
                ? _buildEmptyChallengeState()
                : ListView.builder(
                    itemCount: appState.completedChallenges.length,
                    itemBuilder: (context, index) {
                      final challengeId = appState.completedChallenges[index];
                      final challengeName =
                          appState.challengeDescriptions[challengeId] ??
                              'Unknown Challenge';
                      return _buildChallengeItem(context, challengeName,
                          _getChallengeIcon(challengeId));
                    },
                  ),
          ),
          const SizedBox(height: 20),
          const Text(
            'How to Advance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAdvancementTip(context, appState),
        ],
      ),
    );
  }

  Widget _buildEmptyChallengeState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No challenges completed yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete exercises consistently to earn challenges',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(BuildContext context, String name, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancementTip(BuildContext context, AppState appState) {
    String nextTitle;
    String requirement;

    if (appState.points < 50) {
      nextTitle = "Calm Seeker";
      requirement = "Earn ${50 - appState.points} more points";
    } else if (appState.points < 100 || appState.completedChallenges.isEmpty) {
      nextTitle = "Breath Master";
      if (appState.points < 100) {
        requirement =
            "Earn ${100 - appState.points} more points and complete 1 challenge";
      } else {
        requirement = "Complete at least 1 challenge";
      }
    } else if (appState.points < 200 ||
        appState.completedChallenges.length < 2) {
      nextTitle = "Breath Legend";
      if (appState.points < 200) {
        requirement =
            "Earn ${200 - appState.points} more points and complete ${2 - appState.completedChallenges.length} more challenge(s)";
      } else {
        requirement =
            "Complete ${2 - appState.completedChallenges.length} more challenge(s)";
      }
    } else {
      nextTitle = "Breath Legend";
      requirement = "You've reached the highest title!";
    }

    return Card(
      elevation: 0,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Title: $nextTitle',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              requirement,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getChallengeIcon(String challengeId) {
    switch (challengeId) {
      case 'streak_7':
        return Icons.date_range;
      case 'streak_30':
        return Icons.calendar_month;
      case 'all_styles':
        return Icons.animation;
      case 'all_exercises':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }
}
