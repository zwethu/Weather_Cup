import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/features/history/intake_provider.dart';
import 'package:weather_cup/features/home/widgets/weather_card.dart';
import 'package:weather_cup/features/home/widgets/welcome_text.dart';
import 'package:weather_cup/features/profile/user_provider.dart';

import '../../core/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

                  // Water Dispenser Machine Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      // Machine body - metallic silver/gray gradient
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFE8E8E8),
                          Color(0xFFD0D0D0),
                          Color(0xFFC0C0C0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFB0B0B0),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top panel - Display screen
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            // LCD screen look
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF333355),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                // inset: true,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Digital display text
                              Text(
                                '250',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00E5FF),
                                  fontFamily: 'monospace',
                                  shadows: [
                                    Shadow(
                                      color: const Color(0xFF00E5FF).withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'ml',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: const Color(0xFF00E5FF).withOpacity(0.8),
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Water nozzle area
                        Container(
                          width: 60,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFF808080),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 20,
                              height: 15,
                              decoration: BoxDecoration(
                                color: const Color(0xFF505050),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),

                        // Water drops animation placeholder
                        const SizedBox(height: 8),
                        Icon(
                          CupertinoIcons.drop_fill,
                          size: 20,
                          color: AppColors.primary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 8),

                        // Cup/Glass platform
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF909090),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Dispense Button - Big circular button like real machines
                        GestureDetector(
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
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              // Button gradient - blue water button
                              gradient: const RadialGradient(
                                center: Alignment(-0.2, -0.2),
                                colors: [
                                  Color(0xFF4FC3F7),
                                  Color(0xFF0288D1),
                                  Color(0xFF01579B),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFF606060),
                                width: 4,
                              ),
                              boxShadow: [
                                // Outer shadow
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                                // Inner highlight
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.2),
                                  blurRadius: 2,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                CupertinoIcons.drop_fill,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Button label
                        const Text(
                          'PUSH',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF505050),
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Bottom panel - drainage grate
                        Container(
                          width: double.infinity,
                          height: 20,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF707070),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              12,
                              (index) => Container(
                                width: 2,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF505050),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
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
