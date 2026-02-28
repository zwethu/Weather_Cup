import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_provider.dart';

class DailyRoutineStep extends StatelessWidget {
  const DailyRoutineStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileSetupProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Daily Routine',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Set your wake and sleep times for reminders',
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: 32),

          // Wake time
          _TimeSelector(
            label: 'Wake time',
            icon: CupertinoIcons.sunrise,
            time: provider.wakeTime,
            onTimeChanged: provider.setWakeTime,
          ),

          const SizedBox(height: 24),

          // Sleep time
          _TimeSelector(
            label: 'Sleep time',
            icon: CupertinoIcons.moon,
            time: provider.sleepTime,
            onTimeChanged: provider.setSleepTime,
          ),
        ],
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final IconData icon;
  final String time;
  final ValueChanged<String> onTimeChanged;

  const _TimeSelector({
    required this.label,
    required this.icon,
    required this.time,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.subtitle1,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showTimePicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  time,
                  style: AppTextStyles.subtitle1,
                ),
                const Spacer(),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTimePicker(BuildContext context) {
    final timeParts = time.split(':');
    final initialHour = int.parse(timeParts[0]);
    final initialMinute = int.parse(timeParts[1]);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2024, 1, 1, initialHour, initialMinute),
                use24hFormat: true,
                onDateTimeChanged: (DateTime newTime) {
                  final formattedTime =
                      '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
                  onTimeChanged(formattedTime);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
