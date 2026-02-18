import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';

class OnboardingDot extends StatelessWidget {
  final bool isActive;

  const OnboardingDot({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
