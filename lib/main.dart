import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/router/app_router.dart';
import 'package:weather_cup/core/theme/app_theme.dart';
import 'package:weather_cup/features/home/navigation_provider.dart';
import 'package:weather_cup/features/onboarding/onboarding_provider.dart';

void main() {
  runApp(const WeatherCupApp());
}

class WeatherCupApp extends StatelessWidget {
  const WeatherCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp.router(
        title: 'Weather Cup',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
