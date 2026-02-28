import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/history/intake_provider.dart';
import 'package:weather_cup/features/history/widgets/daily_detail_card.dart';
import 'package:weather_cup/features/history/widgets/weekly_bar_chart.dart';
import 'package:weather_cup/features/profile/user_provider.dart';
import 'package:weather_cup/models/daily_intake.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final userProvider = context.read<UserProvider>();
    final intakeProvider = context.read<IntakeProvider>();
    await intakeProvider.loadWeeklyIntake(dailyGoal: userProvider.recommendedDailyIntake);
  }

  @override
  Widget build(BuildContext context) {
    final intakeProvider = context.watch<IntakeProvider>();
    final weeklyData = intakeProvider.weeklyIntake;
    final allData = intakeProvider.allIntake; // All records, newest first

    // Weekly data for bar chart
    final List<DailyIntake> chartData = weeklyData.isNotEmpty
        ? weeklyData
        : _getEmptyWeekData();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weekly bar chart (current week only)
                WeeklyBarChart(weeklyData: chartData),

                const SizedBox(height: 24),

                // Statistics summary
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildStatisticsCard(intakeProvider),
                ),

                const SizedBox(height: 24),

                // Daily details section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Records',
                        style: AppTextStyles.headline3.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${allData.length} days',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Daily detail cards - ALL records sorted by date desc
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: allData.isEmpty
                      ? _buildEmptyState()
                      : Column(
                          children: allData.map((day) {
                            return DailyDetailCard(
                              day: day.dayAbbreviation,
                              date: day.formattedDate,
                              currentAmount: day.amount,
                              goalAmount: day.goal,
                              percentage: day.percentage,
                            );
                          }).toList(),
                        ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.water_drop_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No records yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Start drinking water to see your history!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(IntakeProvider intakeProvider) {
    final stats = intakeProvider.getStatistics(days: 7);
    final daysReached = stats['daysReachedGoal'] ?? 0;
    final avgIntake = stats['averageIntake'] ?? 0;
    final avgPercentage = stats['averagePercentage'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
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
          const Text(
            'This Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle_outline,
                value: '$daysReached/7',
                label: 'Goals reached',
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.water_drop_outlined,
                value: '${avgIntake}ml',
                label: 'Avg. intake',
                color: const Color(0xFF00B4D8),
              ),
              _buildStatItem(
                icon: Icons.percent,
                value: '$avgPercentage%',
                label: 'Avg. progress',
                color: Colors.amber,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // Generate empty week data for display when no data exists
  List<DailyIntake> _getEmptyWeekData() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return DailyIntake(
        date: date,
        amount: 0,
        goal: 2500,
      );
    });
  }
}
