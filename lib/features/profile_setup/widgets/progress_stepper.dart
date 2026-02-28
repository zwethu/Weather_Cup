import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        totalSteps,
            (index) => Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? 8 : 0,
            ),
            height: 4,
            decoration: BoxDecoration(
              color: index <= currentStep
                  ? AppColors.primary
                  : AppColors.progressEmpty,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
