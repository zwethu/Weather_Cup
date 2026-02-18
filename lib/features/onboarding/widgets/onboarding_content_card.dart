import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';

class OnboardingContentCard extends StatelessWidget {
  final IconData icon;

  const OnboardingContentCard({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      padding: const EdgeInsets.all(40),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,  // ✅ Changed to circle
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}
