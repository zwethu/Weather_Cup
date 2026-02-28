import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/router/app_router.dart';
import 'package:weather_cup/core/theme/app_theme.dart';
import 'package:weather_cup/features/home/navigation_provider.dart';
import 'package:weather_cup/features/onboarding/onboarding_provider.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_provider.dart';
import 'package:weather_cup/features/settings/settings_provider.dart';
import 'package:weather_cup/features/profile/user_provider.dart';
import 'package:weather_cup/persistence/hive_initializer.dart';
 import 'package:weather_cup/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive and all repositories
  await HiveInitializer.init();

  // Initialize notification service
  await NotificationService().initializeNotifications();
  await NotificationService().requestPermissions();

  runApp(const WeatherCupApp());
}

class WeatherCupApp extends StatelessWidget {
  const WeatherCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileSetupProvider()),
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
