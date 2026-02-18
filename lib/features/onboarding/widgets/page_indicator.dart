import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/features/onboarding/onboarding_provider.dart';
import 'package:weather_cup/features/onboarding/widgets/onboarding_dot.dart';

class PageIndicator extends StatelessWidget {
  const PageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            provider.totalPages,
                (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OnboardingDot(isActive: index == provider.currentPage),
            ),
          ),
        );
      },
    );
  }
}
