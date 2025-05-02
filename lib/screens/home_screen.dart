import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/points_badge.dart';
import 'technique_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    const SizedBox(height: 20),
                    _buildWelcomeSection(context),
                    const SizedBox(height: 20),
                    _buildAllTechniques(context),
                    const SizedBox(height: 40),
                    _buildRecentHistory(context),
                    const SizedBox(height: 20),
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
    final appState = Provider.of<AppState>(context, listen: false);

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
          PointsBadge(points: appState.points),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final userTitle = appState.getUserTitle();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome, $userTitle',
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F4F4F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to practice today?',
            style: GoogleFonts.lato(
              fontSize: 16,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllTechniques(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final techniques = appState.breathingTechniques;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'All Techniques',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2F4F4F),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              childAspectRatio: 1.0,
            ),
            itemCount: techniques.length,
            itemBuilder: (context, index) {
              final technique = techniques[index];
              return _buildTechniqueCard(context, technique);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTechniqueCard(
      BuildContext context, BreathingTechnique technique) {
    IconData getIconData(String name) {
      switch (name) {
        case 'wind':
          return FeatherIcons.wind;
        case 'moon':
          return FeatherIcons.moon;
        case 'square':
          return FeatherIcons.square;
        case 'git-branch':
          return FeatherIcons.gitBranch;
        case 'sunrise':
          return FeatherIcons.sunrise;
        case 'headphones':
          return FeatherIcons.headphones;
        case 'zap':
          return FeatherIcons.zap;
        default:
          return FeatherIcons.activity;
      }
    }

    return Material(
      color: technique.color,
      elevation: 2.0,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TechniqueDetailScreen(technique: technique),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                getIconData(technique.iconName),
                size: 40.0,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                technique.name,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentHistory(BuildContext context) {
    // For now, we'll use mock data for recent exercises
    // In a real app, this would come from a database or shared preferences
    final mockHistory = [
      {
        'technique': 'Box Breathing',
        'date': DateTime.now().subtract(const Duration(hours: 5)),
        'color': const Color(0xFF3CB371),
        'icon': 'square',
      },
      {
        'technique': 'Belly Breathing',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'color': const Color(0xFF4682B4),
        'icon': 'wind',
      },
      {
        'technique': '4-7-8 Breathing',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'color': const Color(0xFF5F9EA0),
        'icon': 'moon',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2F4F4F),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full history screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full history feature coming soon!'),
                    ),
                  );
                },
                child: Text(
                  'See All',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Use a Column instead of ListView for better initial rendering
        Column(
          children: List.generate(mockHistory.length, (index) {
            final item = mockHistory[index];
            return _buildHistoryItem(
              context,
              item['technique'] as String,
              item['date'] as DateTime,
              item['color'] as Color,
              item['icon'] as String,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String technique,
    DateTime date,
    Color color,
    String iconName,
  ) {
    IconData getIconData(String name) {
      switch (name) {
        case 'wind':
          return FeatherIcons.wind;
        case 'moon':
          return FeatherIcons.moon;
        case 'square':
          return FeatherIcons.square;
        case 'git-branch':
          return FeatherIcons.gitBranch;
        case 'sunrise':
          return FeatherIcons.sunrise;
        case 'headphones':
          return FeatherIcons.headphones;
        case 'zap':
          return FeatherIcons.zap;
        default:
          return FeatherIcons.activity;
      }
    }

    final formatter = DateFormat('MMM d, h:mm a');
    final formattedDate = formatter.format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 0.05 * 255 ≈ 13
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(51), // 0.2 * 255 ≈ 51
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            getIconData(iconName),
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          technique,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          formattedDate,
          style: GoogleFonts.lato(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          FeatherIcons.chevronRight,
          size: 18,
          color: Colors.grey,
        ),
        onTap: () {
          // Navigate to exercise details or repeat the exercise
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You completed $technique on $formattedDate'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
