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
                          _getChallengeIcon(challengeId), true);
                    },
                  ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Challenge Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _buildChallengeProgressList(context, appState),
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

  Widget _buildChallengeItem(
      BuildContext context, String name, IconData icon, bool completed) {
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
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (completed)
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildChallengeProgressList(BuildContext context, AppState appState) {
    // Get all challenge IDs that haven't been completed yet
    final incompleteChallenges = appState.challengeRequirements.keys
        .where((id) => !appState.completedChallenges.contains(id))
        .toList();

    if (incompleteChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 36,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              'All challenges completed!',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: incompleteChallenges.length,
      itemBuilder: (context, index) {
        final challengeId = incompleteChallenges[index];
        final challengeName =
            appState.challengeDescriptions[challengeId] ?? 'Unknown Challenge';
        final progress = appState.getChallengeProgress(challengeId);

        return _buildChallengeProgressCard(
          context,
          challengeName,
          _getChallengeIcon(challengeId),
          progress['progress'],
          progress['target'],
        );
      },
    );
  }

  Widget _buildChallengeProgressCard(
    BuildContext context,
    String name,
    IconData icon,
    int progress,
    int target,
  ) {
    final double percentage =
        target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha((0.1 * 255).toInt())),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).toInt()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            const SizedBox(height: 4),
            Text(
              target > 0 ? '$progress/$target' : 'In Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: Colors.grey.withAlpha((0.1 * 255).toInt()),
                minHeight: 6,
                color: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
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
      case 'exercises_10':
        return Icons.ten_k;
      case 'exercises_50':
        return Icons.confirmation_number;
      case 'level_2':
        return Icons.upgrade;
      default:
        return Icons.emoji_events;
    }
  }
}
