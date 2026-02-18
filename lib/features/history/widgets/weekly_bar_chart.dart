import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/models/daily_intake.dart';

class WeeklyBarChart extends StatelessWidget {
  final List<DailyIntake> weeklyData;

  const WeeklyBarChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    final daysReached = weeklyData.where((day) => day.isGoalReached).length;

    return Container(

      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,  // ✅ Outer container color
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section
          Text(
            'History',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'Last 7 days',
            style: AppTextStyles.headline3.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'See how consistently you reached your goal.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Inner white card containing bars
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,  // ✅ White background
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Achievement text
                Text(
                  '$daysReached / 7 days goal reached this week',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),

                // Bar chart
                SizedBox(
                  height: 160,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyData.map((day) {
                      return _buildBar(day);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(DailyIntake day) {
    // Calculate bar height
    final maxHeight = 130.0;
    final barHeight = (day.percentage / 100 * maxHeight).clamp(20.0, maxHeight);

    // Determine bar color
    final barColor = day.isGoalReached
        ? AppColors.primary
        : AppColors.progressEmpty;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bar - fully rounded (pill shape)
        Container(
          width: 40,
          height: barHeight,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(18),  // ✅ Half of width for pill shape
          ),
        ),
        const SizedBox(height: 8),

        // Day label
        Text(
          day.day,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
