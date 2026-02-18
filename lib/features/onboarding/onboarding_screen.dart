import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/features/onboarding/onboarding_provider.dart';
import 'package:weather_cup/features/onboarding/widgets/onboarding_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: CupertinoIcons.drop, // ✅ Changed from Icons.water_drop
      title: 'Track your water',
      description: 'Log each drink with one tap.',
    ),
    OnboardingData(
      icon: CupertinoIcons.cloud_sun, // ✅ Changed from Icons.wb_sunny_outlined
      title: 'Weather-smart goals',
      description: 'Your daily target adjusts on hot days.',
    ),
    OnboardingData(
      icon: CupertinoIcons.bell, // ✅ Changed from Icons.notifications_outlined
      title: 'Gentle reminders',
      description: 'Stay hydrated during class and study time.',
    ),
  ];

  void _onPageChanged(int page) {
    context.read<OnboardingProvider>().setPage(page);
  }

  void _onNext() {
    final provider = context.read<OnboardingProvider>();

    if (!provider.isLastPage) {
      // Go to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Last page - navigate to home
      _navigateToHome();
    }
  }

  void _onSkip() {
    // Skip all pages and go to home
    _navigateToHome();
  }

  void _navigateToHome() {
    // Reset onboarding state
    context.read<OnboardingProvider>().reset();
    // Navigate to home screen
    context.go('/main');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        return PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: _pages.length,
          itemBuilder: (context, index) {
            final page = _pages[index];
            return OnboardingView(
              icon: page.icon,
              title: page.title,
              description: page.description,
              currentPage: provider.currentPage,
              totalPages: provider.totalPages,
              onSkip: _onSkip,
              onNext: _onNext,
              isLastPage: provider.isLastPage,
            );
          },
        );
      },
    );
  }
}

class OnboardingData {
  final IconData icon;
  final String title;
  final String description;

  OnboardingData({
    required this.icon,
    required this.title,
    required this.description,
  });
}
