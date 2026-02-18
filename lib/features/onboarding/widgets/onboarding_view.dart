import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/onboarding/widgets/onboarding_content_card.dart';
import 'package:weather_cup/features/onboarding/widgets/page_indicator.dart';

class OnboardingView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onSkip;
  final VoidCallback? onNext;
  final bool isLastPage;

  const OnboardingView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.currentPage,
    required this.totalPages,
    this.onSkip,
    this.onNext,
    this.isLastPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: onSkip,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.buttonTextSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Icon card (only icon inside)
                OnboardingContentCard(icon: icon),

                const SizedBox(height: 40),

                // Title and description OUTSIDE the card
                Text(
                  title,
                  style: AppTextStyles.headline2,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    description,
                    style: AppTextStyles.bodyText2,
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 3),

                // Page indicator
                const PageIndicator(),

                const SizedBox(height: 32),

                // Next/Get Started button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onNext,
                    child: Text(isLastPage ? 'Get started' : 'Next'),
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
}
