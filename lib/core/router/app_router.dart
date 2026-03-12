import 'package:go_router/go_router.dart';
import 'package:weather_cup/features/home/main_screen.dart';
import 'package:weather_cup/features/landing/landing_screen.dart';
import 'package:weather_cup/features/onboarding/onboarding_screen.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_screen.dart';
import 'package:weather_cup/features/settings/settings_screen.dart';
import 'package:weather_cup/persistence/user_repository.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',  // ← back to onboarding as initial
    redirect: (context, state) {
      final hasCompletedOnboarding =
      UserRepository.instance.hasCompletedOnboarding();
      final isOnboarding = state.matchedLocation == '/';
      final isProfileSetup = state.matchedLocation == '/profile-setup';

      if (hasCompletedOnboarding && (isOnboarding || isProfileSetup)) {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(                    // NEW — standalone, not in the flow
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
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
