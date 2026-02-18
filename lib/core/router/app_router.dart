import 'package:go_router/go_router.dart';
import 'package:weather_cup/features/home/home_screen.dart';
import 'package:weather_cup/features/home/main_screen.dart';
import 'package:weather_cup/features/onboarding/onboarding_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/main',  // ✅ Changed from /home to /main
        name: 'main',   // ✅ Changed from home to main
        builder: (context, state) => const MainScreen(),
      ),
    ],
  );
}
