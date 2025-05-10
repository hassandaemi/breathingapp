import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import 'settings_screen.dart';
import 'dart:async';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _levelUpTimer;

  // Mood analysis state
  List<Map<String, dynamic>> _moodData = [];
  bool _isLoadingMoodData = true;

  final Map<String, double> _moodScores = {
    'Happy': 5.0,
    'Relaxed': 4.0,
    'Neutral': 3.0,
    'Tired': 2.0,
    'Angry': 1.0,
  };

  final Map<String, Color> _moodColors = {
    'Happy': Colors.green,
    'Relaxed': Colors.blue,
    'Neutral': Colors.grey,
    'Tired': Colors.orange,
    'Angry': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Check for level up after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForLevelUp();
      _loadMoodData(); // Load mood data when screen initializes
    });
  }

  Future<void> _loadMoodData() async {
    try {
      final moodEntries = await DatabaseHelper.instance.getMoods();
      if (mounted) {
        setState(() {
          _moodData = moodEntries;
          _isLoadingMoodData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMoodData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _levelUpTimer?.cancel();
    super.dispose();
  }

  void _checkForLevelUp() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.justLeveledUp) {
      // Play level up animation
      _animationController.repeat(reverse: true);

      // Get the appropriate message based on the level
      String message = '';

      // Check if this level unlocks a new profile image
      if (appState.level == 1) {
        message =
            'Congratulations! You reached Level ${appState.level}! You\'ve unlocked the Breath Novice profile image!';
      } else if (appState.level == 2) {
        message =
            'Congratulations! You reached Level ${appState.level}! You\'ve unlocked the Calm Seeker profile image!';
      } else if (appState.level == 3) {
        message =
            'Congratulations! You reached Level ${appState.level}! You\'ve unlocked the Breath Master profile image!';
      } else if (appState.level >= 5) {
        message =
            'Congratulations! You reached Level ${appState.level}! You\'ve unlocked the Breath Legend profile image!';
      } else {
        message = 'Congratulations! You reached Level ${appState.level}!';
      }

      // Show level up message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );

      // Stop animation after 3 seconds
      _levelUpTimer = Timer(const Duration(seconds: 3), () {
        _animationController.stop();
        _animationController.reset();
        appState.resetLevelUpFlag();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userTitle = appState.getUserTitle();
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
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAppBar(context),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildUserHeader(context, userTitle, appState),
                    SizedBox(height: screenSize.height * 0.03),
                    _buildUserStats(context, appState),
                    SizedBox(height: screenSize.height * 0.03),
                    _buildNotificationSection(context, appState),
                  ],
                ),
              ),
            );
          }),
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
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: profileSize,
                      height: profileSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                        boxShadow: appState.justLeveledUp
                            ? [
                                BoxShadow(
                                  color: Colors.amber.withAlpha(
                                      128), // 0.5 * 255 = 127.5 ≈ 128
                                  blurRadius: 10,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          appState.getProfileImagePath(),
                          fit: BoxFit.cover,
                          width: profileSize,
                          height: profileSize,
                        ),
                      ),
                    ),
                  );
                },
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
                color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
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
                      color:
                          AppTheme.primaryColor.withAlpha(26), // 0.1 * 255 ≈ 26
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
                  : Column(
                      children: List.generate(
                        appState.completedChallenges.length,
                        (index) {
                          final challengeId =
                              appState.completedChallenges[index];
                          final challengeName =
                              appState.challengeDescriptions[challengeId] ??
                                  'Unknown Challenge';
                          return _buildChallengeItem(context, challengeName,
                              _getChallengeIcon(challengeId), true);
                        },
                      ),
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

        // Mood Analysis Section
        Container(
          padding: EdgeInsets.all(screenSize.width * 0.06),
          margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mood Analysis',
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
                      setState(() {
                        _isLoadingMoodData = true;
                      });
                      _loadMoodData();
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
              _buildMoodAnalysis(context),
            ],
          ),
        ),

        SizedBox(height: screenSize.height * 0.04),
      ],
    );
  }

  Widget _buildMoodAnalysis(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_isLoadingMoodData) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_moodData.isEmpty) {
      return _buildEmptyMoodState(context);
    }

    return Column(
      children: [
        _buildEnhancedMoodChart(context),
        SizedBox(height: screenSize.height * 0.03),
        _buildMoodDistribution(context),
        SizedBox(height: screenSize.height * 0.02),
        _buildMoodInsights(context),
      ],
    );
  }

  Widget _buildEmptyMoodState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No mood data yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Complete breathing exercises to track your mood patterns',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Start Breathing Exercise'),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMoodChart(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    List<FlSpot> spots = [];

    if (_moodData.isNotEmpty) {
      final recentMoods =
          _moodData.length > 14 ? _moodData.sublist(0, 14) : _moodData;

      spots = recentMoods.asMap().entries.map((entry) {
        final mood = entry.value['mood'] as String;
        final score = _moodScores[mood] ?? 3.0;
        return FlSpot(entry.key.toDouble(), score);
      }).toList();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Mood Trend',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F4F4F),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          SizedBox(
            height: screenSize.height * 0.2,
            child: spots.isEmpty
                ? Center(
                    child: Text(
                      'Not enough data to display chart',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 1,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withAlpha((0.2 * 255).toInt()),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withAlpha((0.2 * 255).toInt()),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              String text = '';
                              switch (value.toInt()) {
                                case 1:
                                  text = 'Angry';
                                  break;
                                case 2:
                                  text = 'Tired';
                                  break;
                                case 3:
                                  text = 'Neutral';
                                  break;
                                case 4:
                                  text = 'Relaxed';
                                  break;
                                case 5:
                                  text = 'Happy';
                                  break;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  text,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: Colors.grey.withAlpha((0.2 * 255).toInt()),
                        ),
                      ),
                      minY: 0.5,
                      maxY: 5.5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4CAF50)
                                  .withAlpha((0.8 * 255).toInt()),
                              const Color(0xFF2196F3)
                                  .withAlpha((0.6 * 255).toInt()),
                            ],
                          ),
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 6,
                                color: Colors.white,
                                strokeWidth: 2,
                                strokeColor: AppTheme.primaryColor,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    Map<String, int> moodCounts = {};
    for (var item in _moodData) {
      final mood = item['mood'] as String;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(screenSize.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Distribution',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F4F4F),
            ),
          ),
          SizedBox(height: screenSize.height * 0.02),
          ...moodCounts.entries.map((entry) {
            final percentage = (entry.value / _moodData.length) * 100;
            final color = _moodColors[entry.key] ?? Colors.grey;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withAlpha((0.3 * 255).toInt()),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getMoodEmoji(entry.key),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor:
                          Colors.grey.withAlpha((0.1 * 255).toInt()),
                      minHeight: 6,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodInsights(BuildContext context) {
    if (_moodData.isEmpty || _moodData.length < 3) {
      return const SizedBox.shrink();
    }

    // Calculate dominant mood
    Map<String, int> moodCounts = {};
    for (var item in _moodData) {
      final mood = item['mood'] as String;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    String dominantMood = '';
    int maxCount = 0;

    moodCounts.forEach((mood, count) {
      if (count > maxCount) {
        maxCount = count;
        dominantMood = mood;
      }
    });

    // Calculate mood trend (improving, worsening, or stable)
    String moodTrend = 'stable';
    if (_moodData.length >= 5) {
      final recentMoods = _moodData.sublist(0, 5);
      double avgRecent = 0;

      for (var item in recentMoods) {
        final mood = item['mood'] as String;
        avgRecent += _moodScores[mood] ?? 3.0;
      }
      avgRecent /= recentMoods.length;

      if (avgRecent > 3.5) {
        moodTrend = 'improving';
      } else if (avgRecent < 2.5) {
        moodTrend = 'worsening';
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withAlpha((0.8 * 255).toInt()),
            AppTheme.primaryColor.withAlpha((0.6 * 255).toInt()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha((0.3 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Mood Insights',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your dominant mood is $dominantMood',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getMoodTrendMessage(moodTrend, dominantMood),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getMoodAdvice(dominantMood),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'Happy':
        return '😊';
      case 'Relaxed':
        return '😌';
      case 'Neutral':
        return '😐';
      case 'Tired':
        return '😓';
      case 'Angry':
        return '😡';
      default:
        return '😐';
    }
  }

  String _getMoodTrendMessage(String trend, String dominantMood) {
    switch (trend) {
      case 'improving':
        return 'Your mood has been improving recently!';
      case 'worsening':
        return 'Your mood has been declining recently.';
      default:
        return 'Your mood has been relatively stable.';
    }
  }

  String _getMoodAdvice(String dominantMood) {
    switch (dominantMood) {
      case 'Happy':
        return 'Keep up the good work with regular breathing exercises!';
      case 'Relaxed':
        return 'Your breathing practice is helping you maintain calm.';
      case 'Neutral':
        return 'Try increasing your breathing practice to boost your mood.';
      case 'Tired':
        return 'Consider energizing breathing techniques like Bellows Breath.';
      case 'Angry':
        return 'Deep breathing can help manage stress and reduce anger.';
      default:
        return 'Regular breathing practice can help improve your mood.';
    }
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
        final progress = appState.getChallengeProgressSync(challengeId);

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

    if (appState.points < 100) {
      nextTitle = "Calm Seeker";
      requirement = "Earn ${100 - appState.points} more points";
    } else if (appState.points < 250 ||
        appState.completedChallenges.length < 2) {
      nextTitle = "Breath Master";
      if (appState.points < 250 && appState.completedChallenges.length < 2) {
        requirement =
            "Earn ${250 - appState.points} more points and complete ${2 - appState.completedChallenges.length} more challenge(s)";
      } else if (appState.points < 250) {
        requirement = "Earn ${250 - appState.points} more points";
      } else {
        requirement =
            "Complete ${2 - appState.completedChallenges.length} more challenge(s)";
      }
    } else if (appState.points < 500 ||
        appState.completedChallenges.length < 4) {
      nextTitle = "Breath Legend";
      if (appState.points < 500 && appState.completedChallenges.length < 4) {
        requirement =
            "Earn ${500 - appState.points} more points and complete ${4 - appState.completedChallenges.length} more challenge(s)";
      } else if (appState.points < 500) {
        requirement = "Earn ${500 - appState.points} more points";
      } else {
        requirement =
            "Complete ${4 - appState.completedChallenges.length} more challenge(s)";
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

  Widget _buildNotificationSection(BuildContext context, AppState appState) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(screenSize.width * 0.06),
      margin: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F4F4F),
                ),
              ),
              Switch(
                value: appState.notificationsEnabled,
                onChanged: (value) {
                  appState.toggleNotifications();
                  if (value && appState.reminderTime == null) {
                    _showNotificationTimePicker(context, appState);
                  }
                },
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          SizedBox(height: screenSize.height * 0.02),
          if (appState.notificationsEnabled)
            _buildReminderTimeSetting(context, appState),
        ],
      ),
    );
  }

  Widget _buildReminderTimeSetting(BuildContext context, AppState appState) {
    return InkWell(
      onTap: () => _showNotificationTimePicker(context, appState),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha((0.1 * 255).toInt()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.access_time,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Reminder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appState.reminderTime ?? 'Not set - tap to set time',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationTimePicker(
      BuildContext context, AppState appState) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _parseTimeOfDay(appState.reminderTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && context.mounted) {
      final formattedTime = _formatTimeOfDay(pickedTime);
      appState.setReminderTime(formattedTime);

      // Show a loading indicator while scheduling notification
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Schedule notification for this time
        await appState.scheduleNotification();

        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Daily reminder set for $formattedTime'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog
        if (context.mounted) Navigator.of(context).pop();

        String errorMessage = 'Failed to set reminder';

        // Handle specific error cases
        if (e.toString().contains('exact_alarms_not_permitted')) {
          errorMessage =
              'Reminders may not be exact due to system restrictions. They will still work, but timing may vary slightly.';

          // Still show partial success message since we're using inexact alarms as fallback
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () {
                    // Navigate to the settings screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        } else {
          // Show error message for other errors
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$errorMessage: ${e.toString()}'),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;

    // Parse time like "8:00 PM"
    final parts = timeString.split(' ');
    if (parts.length != 2) return null;

    final timeParts = parts[0].split(':');
    if (timeParts.length != 2) return null;

    int hour = int.tryParse(timeParts[0]) ?? 0;
    final int minute = int.tryParse(timeParts[1]) ?? 0;

    if (parts[1] == 'PM' && hour < 12) hour += 12;
    if (parts[1] == 'AM' && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
