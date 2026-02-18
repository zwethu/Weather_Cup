import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/history/widgets/daily_detail_card.dart';
import 'package:weather_cup/features/history/widgets/weekly_bar_chart.dart';
import 'package:weather_cup/services/mock_data_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weeklyData = MockDataService.getWeeklyIntakeData();

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
                // Weekly bar chart (no horizontal padding)
                WeeklyBarChart(weeklyData: weeklyData),

                // const SizedBox(height: 4),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Divider(color: AppColors.textSecondary.withOpacity(0.2)),
                // ),
                const SizedBox(height: 24),

                // Daily details section title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Daily details',
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Daily detail cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: weeklyData.map((day) {
                      return DailyDetailCard(
                        day: day.day,
                        date: _formatDate(day.day),
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

  // Helper method to format date (mock implementation)
  String _formatDate(String day) {
    final dates = {
      'Mon': '29 Jan',
      'Tue': '30 Jan',
      'Wed': '31 Jan',
      'Thu': '1 Feb',
      'Fri': '2 Feb',
      'Sat': '3 Feb',
      'Sun': '4 Feb',
    };
    return dates[day] ?? '';
  }
}
