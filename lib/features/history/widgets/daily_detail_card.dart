import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';

class DailyDetailCard extends StatelessWidget {
  final String day;
  final String date;
  final int currentAmount;
  final int goalAmount;
  final int percentage;

  const DailyDetailCard({
    super.key,
    required this.day,
    required this.date,
    required this.currentAmount,
    required this.goalAmount,
    required this.percentage,
  });

  bool get isGoalReached => percentage >= 100;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Date column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day and Date
                Text(
                  '$day · $date',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),

                // Current / Goal amount
                Text(
                  '$currentAmount / $goalAmount ml',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Middle: Progress bar
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.progressEmpty,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isGoalReached ? AppColors.primary : AppColors.progressEmpty,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Right: Percentage text
          Text(
            '$percentage%',
            style: AppTextStyles.subtitle1.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(width: 8),

          // Far right: Status icon - ✅ Using Cupertino icons
          Icon(
            isGoalReached
                ? CupertinoIcons.checkmark_circle_fill  // ✅ Changed to Cupertino
                : CupertinoIcons.drop,
            color: isGoalReached
                ? AppColors.success
                : AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }
}
