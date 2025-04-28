import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userTitle = appState.getUserTitle();
    final screenSize = MediaQuery.of(context).size;

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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAppBar(context),
                SizedBox(height: screenSize.height * 0.02),
                _buildUserHeader(context, userTitle, appState),
                SizedBox(height: screenSize.height * 0.03),
                _buildUserStats(context, appState),
              ],
            ),
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
            'Profile',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          IconButton(
            icon: const Icon(FeatherIcons.settings),
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

  Widget _buildUserHeader(
      BuildContext context, String userTitle, AppState appState) {
    final screenSize = MediaQuery.of(context).size;
    final profileSize = screenSize.width * 0.2; // Responsive profile image size

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: profileSize,
                height: profileSize,
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
                  size: profileSize * 0.5,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: screenSize.width * 0.05),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userTitle,
                      style: TextStyle(
                        fontSize:
                            22 * MediaQuery.textScalerOf(context).scale(1.0),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.005),
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
          SizedBox(height: screenSize.height * 0.02),
          const Divider(thickness: 1),
          SizedBox(height: screenSize.height * 0.01),
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
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.025),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: screenSize.width * 0.06,
          ),
        ),
        SizedBox(height: screenSize.height * 0.008),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16 * MediaQuery.textScalerOf(context).scale(1.0),
          ),
        ),
        SizedBox(height: screenSize.height * 0.004),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12 * MediaQuery.textScalerOf(context).scale(1.0),
          ),
        ),
      ],
    );
  }

  Widget _buildUserStats(BuildContext context, AppState appState) {
    final screenSize = MediaQuery.of(context).size;

    return Column(
      children: [
        // Points and Challenges Section
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.06),
          margin: EdgeInsets.all(screenSize.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Completed Challenges',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F4F4F),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${appState.completedChallenges.length}/${appState.challengeRequirements.length}',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              appState.completedChallenges.isEmpty
                  ? _buildEmptyChallengeState(context)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
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
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'Challenge Progress',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F4F4F),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              SizedBox(
                height: screenSize.height * 0.18,
                child: _buildChallengeProgressList(context, appState),
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'How to Advance',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F4F4F),
                ),
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildAdvancementTip(context, appState),
            ],
          ),
        ),

        // Mood History Section
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.06),
          margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mood History',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F4F4F),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(FeatherIcons.refreshCw, size: 18),
                    onPressed: () {
                      // Refresh mood data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Refreshing mood data...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    splashRadius: 20,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              SizedBox(height: screenSize.height * 0.02),
              _buildMoodHistory(context),
            ],
          ),
        ),

        SizedBox(height: screenSize.height * 0.04),
      ],
    );
  }

  Widget _buildMoodHistory(BuildContext context) {
    // Mock mood data - in a real app, this would come from a database
    final mockMoodData = [
      {'mood': '😊', 'date': 'April 1, 2025', 'technique': 'Box Breathing'},
      {'mood': '😌', 'date': 'March 30, 2025', 'technique': 'Belly Breathing'},
      {'mood': '😔', 'date': 'March 28, 2025', 'technique': '4-7-8 Breathing'},
      {'mood': '😊', 'date': 'March 27, 2025', 'technique': 'Box Breathing'},
      {
        'mood': '😌',
        'date': 'March 25, 2025',
        'technique': 'Alternate Nostril'
      },
    ];

    return Column(
      children: [
        // Mood summary row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMoodSummaryItem('😊', '8', 'Happy'),
            _buildMoodSummaryItem('😌', '12', 'Relaxed'),
            _buildMoodSummaryItem('😔', '3', 'Sad'),
          ],
        ),
        const SizedBox(height: 20),

        // Mood history list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockMoodData.length,
          itemBuilder: (context, index) {
            final item = mockMoodData[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(
                item['mood'] as String,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                item['technique'] as String,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                item['date'] as String,
                style: GoogleFonts.lato(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              dense: true,
            );
          },
        ),

        // See all button
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Full mood history coming soon!'),
              ),
            );
          },
          child: Text(
            'See All Mood Records',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSummaryItem(String emoji, String count, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChallengeState(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: screenSize.width * 0.12,
            color: Colors.grey[400],
          ),
          SizedBox(height: screenSize.height * 0.02),
          Text(
            'No challenges completed yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: screenSize.height * 0.008),
          Text(
            'Complete exercises consistently to earn challenges',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(
      BuildContext context, String name, IconData icon, bool completed) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(screenSize.width * 0.025),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: screenSize.width * 0.06,
            ),
          ),
          SizedBox(width: screenSize.width * 0.04),
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
    final screenSize = MediaQuery.of(context).size;

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
              size: screenSize.width * 0.09,
              color: Colors.amber,
            ),
            SizedBox(height: screenSize.height * 0.012),
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
    final screenSize = MediaQuery.of(context).size;
    final double percentage =
        target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: screenSize.width * 0.35,
      margin: EdgeInsets.only(right: screenSize.width * 0.03),
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
        padding: EdgeInsets.all(screenSize.width * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(screenSize.width * 0.02),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: screenSize.width * 0.055,
              ),
            ),
            SizedBox(height: screenSize.height * 0.01),
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
            Text(
              target > 0 ? '$progress/$target' : 'In Progress',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: screenSize.height * 0.006),
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
    final screenSize = MediaQuery.of(context).size;
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
        padding: EdgeInsets.all(screenSize.width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Title: $nextTitle',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16 * MediaQuery.textScalerOf(context).scale(1.0),
              ),
            ),
            SizedBox(height: screenSize.height * 0.008),
            Text(
              requirement,
              style: TextStyle(
                fontSize: 14 * MediaQuery.textScalerOf(context).scale(1.0),
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
