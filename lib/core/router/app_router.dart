import 'package:go_router/go_router.dart';
import 'package:weather_cup/features/home/main_screen.dart';
import 'package:weather_cup/features/onboarding/onboarding_screen.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_screen.dart';
import 'package:weather_cup/features/settings/settings_screen.dart';
import 'package:weather_cup/persistence/user_repository.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final hasCompletedOnboarding = UserRepository.instance.hasCompletedOnboarding();
      final isOnboarding = state.matchedLocation == '/';
      final isProfileSetup = state.matchedLocation == '/profile-setup';

      // If user has completed onboarding and is trying to access onboarding/profile-setup,
      // redirect them to main
      if (hasCompletedOnboarding && (isOnboarding || isProfileSetup)) {
        return '/main';
      }

      // Allow navigation as normal
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile_setup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),
    ],
  );
}
