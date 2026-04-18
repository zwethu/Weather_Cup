import 'package:go_router/go_router.dart';
import 'package:weather_cup/features/auth/login_screen.dart';
import 'package:weather_cup/features/auth/register_screen.dart';
import 'package:weather_cup/features/auth/terms_screen.dart';
import 'package:weather_cup/features/home/main_screen.dart';
import 'package:weather_cup/features/landing/landing_screen.dart';
import 'package:weather_cup/features/onboarding/onboarding_screen.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_screen.dart';
import 'package:weather_cup/features/settings/settings_screen.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/auth_service.dart';
import 'package:weather_cup/services/firestore_service.dart';

import '../../features/auth/forget_password_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final loc = state.matchedLocation;

      // 1. Onboarding — always first on fresh install
      final hasSeenOnboarding = UserRepository.instance.hasCompletedOnboarding();
      if (!hasSeenOnboarding) {
        if (loc == '/') return null; // stay on onboarding
        return '/';
      }

      // 2. Not logged in → go to login
      final user = AuthService.instance.currentUser;
      final isAuthRoute = loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password' ||
          loc == '/terms';

      if (user == null) {
        if (isAuthRoute) return null;
        return '/login';
      }

      // 3. Logged in → check if profile is set up
      final profileComplete =
      await FirestoreService.instance.isProfileSetupComplete(user.uid);

      if (!profileComplete) {
        if (loc == '/profile-setup') return null;
        return '/profile-setup';
      }

      // 4. Fully set up → go to main
      if (loc == '/' || isAuthRoute || loc == '/profile-setup') {
        return '/main';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        builder: (context, state) => const TermsScreen(showActions: false),
      ),
      GoRoute(
        path: '/profile-setup',
        name: 'profile_setup',
        builder: (context, state) => const ProfileSetupScreen(),
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
        path: '/landing',
        name: 'landing',
        builder: (context, state) => const LandingScreen(),
      ),
    ],
  );
}