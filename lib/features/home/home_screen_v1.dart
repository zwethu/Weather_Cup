// VERSION 1 - Original gradient drink card design
// Saved on March 1, 2026

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/features/history/intake_provider.dart';
import 'package:weather_cup/features/home/widgets/weather_card.dart';
import 'package:weather_cup/features/home/widgets/welcome_text.dart';
import 'package:weather_cup/features/profile/user_provider.dart';

import '../../core/theme/app_colors.dart';

class HomeScreenV1 extends StatefulWidget {
  const HomeScreenV1({super.key});

  @override
  State<HomeScreenV1> createState() => _HomeScreenV1State();
}

class _HomeScreenV1State extends State<HomeScreenV1> {
  @override
  void initState() {
    super.initState();
    // Initialize intake tracking after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initIntake();
    });
  }

  Future<void> _initIntake() async {
    final userProvider = context.read<UserProvider>();
    final intakeProvider = context.read<IntakeProvider>();
    await intakeProvider.init(dailyGoal: userProvider.recommendedDailyIntake);
  }

  @override
  Widget build(BuildContext context) {
    // Get user data via UserProvider
    final userProvider = context.watch<UserProvider>();
    final intakeProvider = context.watch<IntakeProvider>();

    final int dailyGoal = userProvider.recommendedDailyIntake;
    final int drunkAmount = intakeProvider.todayAmount;
    final int remaining = intakeProvider.todayRemaining;
    final double progress = intakeProvider.todayProgress;

    // Update intake goal if it changed (e.g., weather updated)
    if (intakeProvider.todayGoal != dailyGoal && !intakeProvider.isLoading) {
      intakeProvider.updateTodayGoal(dailyGoal);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const WelcomeText(),
                  const SizedBox(height: 24),
                  // Today's Goal Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Today's goal",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            if (intakeProvider.isGoalReached)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      CupertinoIcons.checkmark_circle_fill,
                                      size: 16,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Goal reached!',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$dailyGoal ml',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Drunk: $drunkAmount ml · Remaining: $remaining ml',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 12,
                            backgroundColor: const Color(0xFFE0E0E0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              intakeProvider.isGoalReached
                                  ? Colors.green
                                  : const Color(0xFF00B4D8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${intakeProvider.todayPercentage}% of daily goal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Drink Water Card - with gradient background matching page
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.backgroundGradientStart.withOpacity(0.5),
                          AppColors.backgroundGradientMiddle,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Water Glass Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            CupertinoIcons.drop_fill,
                            size: 40,
                            color: Color(0xFF00B4D8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '250 ml',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tap to add water',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Drink Button - matching page gradient
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.backgroundGradient,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                // Add 250ml to intake
                                await intakeProvider.addDrink(
                                  250,
                                  currentGoal: dailyGoal,
                                );

                                if (!context.mounted) return;

                                // Show feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added 250 ml! Total: ${intakeProvider.todayAmount} ml',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () async {
                                        await intakeProvider.undoLastDrink();
                                      },
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(60),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.plus,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const WeatherCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

