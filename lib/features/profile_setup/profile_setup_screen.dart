import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_provider.dart';
import 'package:weather_cup/features/profile_setup/widgets/body_info_step.dart';
import 'package:weather_cup/features/profile_setup/widgets/daily_routine_step.dart';
import 'package:weather_cup/features/profile_setup/widgets/location_step.dart';
import 'package:weather_cup/features/profile_setup/widgets/personal_info_step.dart';
import 'package:weather_cup/features/profile_setup/widgets/progress_stepper.dart';
import 'package:weather_cup/features/profile_setup/widgets/welcome_step.dart';
import 'package:weather_cup/features/profile/user_provider.dart';
import 'package:weather_cup/persistence/user_repository.dart';
import 'package:weather_cup/services/auth_service.dart';
import 'package:weather_cup/services/firestore_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Default initial page is 0; we will sync with provider after first build
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileSetupProvider>(
      builder: (context, provider, child) {
        // Ensure the PageController reflects provider.currentStep. Use a post frame callback
        // so we only change pages after the current frame and avoid interfering with build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (!_pageController.hasClients) return;
          final currentPage = _pageController.page?.round() ?? _pageController.initialPage;
          if (currentPage != provider.currentStep) {
            // Jump without animation if the difference is large or to avoid visual glitches
            _pageController.animateToPage(
              provider.currentStep,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        });

        return Container(
          decoration:const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Column(
                children: [
                  Text(
                    'Step ${provider.currentStep + 1} of ${provider.totalSteps}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProgressStepper(
                    currentStep: provider.currentStep,
                    totalSteps: provider.totalSteps,
                  ),
                ],
              ),
              centerTitle: true,
              toolbarHeight: 80,
            ),
            body: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: provider.goToStep,
                    children: const [
                      WelcomeStep(),
                      PersonalInfoStep(),
                      BodyInfoStep(),
                      DailyRoutineStep(),
                      LocationStep(),
                    ],
                  ),
                ),
                // Bottom navigation buttons
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      if (provider.currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              provider.previousStep();
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'Back',
                              style: AppTextStyles.buttonText.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      if (provider.currentStep > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              provider.canProceedFromStep(provider.currentStep)
                                  ? () async {
                                      if (provider.isLastStep) {
                                        // 1. Save profile to local Hive storage.
                                        await provider.saveProfile();

                                        // 2. Read the freshly-written user
                                        //    from Hive (NOT from UserProvider,
                                        //    which has not been refreshed yet
                                        //    and may still be null).
                                        final savedUser =
                                            UserRepository.instance.getUser();
                                        final uid = AuthService.instance
                                            .currentUser?.uid;

                                        // 3. Sync Hive → Firestore so the
                                        //    cloud record matches local state
                                        //    and profileSetupComplete is set.
                                        if (uid != null && savedUser != null) {
                                          await FirestoreService.instance
                                              .saveUserProfile(
                                                  uid, savedUser);
                                        }

                                        // 4. Refresh UserProvider so every
                                        //    screen re-reads the new Hive data.
                                        if (context.mounted) {
                                          context.read<UserProvider>().refresh();
                                          context.go('/main');
                                        }
                                      } else {
                                        provider.nextStep();
                                        _pageController.nextPage(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                    }
                                  : null,
                          child: Text(
                            provider.isLastStep ? 'Finish' : 'Continue',
                            style: AppTextStyles.buttonText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
