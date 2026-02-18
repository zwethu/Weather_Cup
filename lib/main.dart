import 'package:flutter/material.dart';
import 'package:weather_cup/core/router/app_router.dart';

void main() {
  runApp(const WeatherCupApp());
}

class WeatherCupApp extends StatelessWidget {
  const WeatherCupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Weather Cup',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
