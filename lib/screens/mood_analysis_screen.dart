import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';

class MoodAnalysisScreen extends StatefulWidget {
  const MoodAnalysisScreen({super.key});

  @override
  State<MoodAnalysisScreen> createState() => _MoodAnalysisScreenState();
}

class _MoodAnalysisScreenState extends State<MoodAnalysisScreen> {
  List<Map<String, dynamic>> _moodData = [];
  bool _isLoading = true;
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
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    try {
      final moodEntries = await DatabaseHelper.instance.getMoods();
      setState(() {
        _moodData = moodEntries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Analysis'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _moodData.isEmpty
              ? _buildEmptyState()
              : _buildMoodAnalysis(),
    );
  }

  Widget _buildEmptyState() {
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
        ],
      ),
    );
  }

  Widget _buildMoodAnalysis() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMoodChart(),
        const SizedBox(height: 24),
        _buildMoodStats(),
      ],
    );
  }

  Widget _buildMoodChart() {
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

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Mood Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: spots.isEmpty
                  ? const Center(
                      child: Text('Not enough data to display chart'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                String text = '';
                                switch (value.toInt()) {
                                  case 1:
                                    text = 'Angry';
                                    break;
                                  case 3:
                                    text = 'Neutral';
                                    break;
                                  case 5:
                                    text = 'Happy';
                                    break;
                                }
                                return Text(text,
                                    style: const TextStyle(fontSize: 10));
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
                        borderData: FlBorderData(show: false),
                        minY: 0.5,
                        maxY: 5.5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: spots,
                            isCurved: true,
                            color: AppTheme.primaryColor,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryColor
                                  .withAlpha((0.2 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStats() {
    Map<String, int> moodCounts = {};
    for (var item in _moodData) {
      final mood = item['mood'] as String;
      moodCounts[mood] = (moodCounts[mood] ?? 0) + 1;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...moodCounts.entries.map((entry) {
              final percentage = (entry.value / _moodData.length) * 100;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _moodColors[entry.key],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(entry.key),
                    const Spacer(),
                    Text('${percentage.toStringAsFixed(1)}%'),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
