import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/core/widgets/edit_bottom_sheets.dart';
import 'package:weather_cup/features/home/navigation_provider.dart';
import 'package:weather_cup/features/settings/settings_provider.dart';
import 'package:weather_cup/features/settings/widgets/daily_goal_card.dart';
import 'package:weather_cup/features/settings/widgets/profile_card.dart';
import 'package:weather_cup/features/settings/widgets/setting_tile.dart';
import 'package:weather_cup/features/settings/widgets/toggle_setting_tile.dart';
import 'package:weather_cup/features/profile/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, provider, child) {
        // Get user data via UserProvider
        final userProvider = context.watch<UserProvider>();

        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              // Reduce the gap between the leading widget and the title
              leadingWidth: 44,
              titleSpacing: 8,
              leading: IconButton(
                // Remove default padding to bring the icon closer to the title
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(
                  CupertinoIcons.back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'Control your experience',
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
              toolbarHeight: 80,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'Manage reminders and profile.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  // Profile Card
                  ProfileCard(
                    name: userProvider.userName,
                    onTap: () {
                      // Navigate back and switch to profile tab
                      Navigator.of(context).pop();
                      context.read<NavigationProvider>().setIndex(2); // Profile tab
                    },
                  ),

                  const SizedBox(height: 24),

                  // Notifications Section
                  _buildSectionTitle('Notifications'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
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
                      children: [
                        ToggleSettingTile(
                          icon: CupertinoIcons.bell,
                          title: 'Hourly reminders',
                          subtitle:
                              'Send hydration reminders between your wake and sleep times.',
                          value: provider.hourlyReminders,
                          onChanged: provider.toggleHourlyReminders,
                        ),
                        // const Divider(
                        //   height: 1,
                        //   color: AppColors.divider,
                        //   indent: 72,
                        // ),
                        // ToggleSettingTile(
                        //   icon: CupertinoIcons.device_phone_portrait,
                        //   title: 'Vibration only',
                        //   value: provider.vibrationOnly,
                        //   onChanged: provider.toggleVibration,
                        // ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Hydration Preferences Section
                  _buildSectionTitle('Hydration preferences'),
                  const SizedBox(height: 8),
                  DailyGoalCard(
                    onTap: () async {
                      // Daily goal is based on weight, so edit weight
                      final result = await showEditTextBottomSheet(
                        context: context,
                        title: 'Weight',
                        currentValue: userProvider.weight.toStringAsFixed(1),
                        hintText: 'Enter your weight in kg (goal = weight × 33ml)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      );
                      if (result != null && context.mounted) {
                        final weight = double.tryParse(result);
                        if (weight != null) {
                          await userProvider.updateUser(weight: weight);
                        }
                      }
                    },
                  ),

                  // Location Section
                  // _buildSectionTitle('Location'),
                  // const SizedBox(height: 8),
                  // Container(
                  //   decoration: BoxDecoration(
                  //     color: AppColors.surface,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.05),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     children: [
                  //       SettingTile(
                  //         icon: CupertinoIcons.location,
                  //         title: 'Country',
                  //         subtitle: provider.country,
                  //         onTap: () {
                  //           // TODO: Open country selector
                  //         },
                  //       ),
                  //       const Divider(
                  //         height: 1,
                  //         color: AppColors.divider,
                  //         indent: 72,
                  //       ),
                  //       SettingTile(
                  //         icon: CupertinoIcons.location_fill,
                  //         title: 'City',
                  //         subtitle: provider.city,
                  //         onTap: () {
                  //           // TODO: Open city selector
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 4, top: 8),
                  //   child: Text(
                  //     'Used only to fetch local weather.',
                  //     style: AppTextStyles.caption.copyWith(
                  //       color: AppColors.textSecondary,
                  //       fontSize: 11,
                  //     ),
                  //   ),
                  // ),

                  const SizedBox(height: 24),
                  _buildSectionTitle('About App'),
                  const SizedBox(height: 8),
                  // Other Settings
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
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
                      children: [
                        // SettingTile(
                        //   icon: CupertinoIcons.paintbrush,
                        //   title: 'Appearance',
                        //   subtitle: provider.appearance,
                        //   onTap: () {
                        //     // TODO: Open appearance selector
                        //   },
                        // ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 72,
                        ),
                        SettingTile(
                          icon: CupertinoIcons.info_circle,
                          title: 'About Weather Cup',
                          onTap: () {
                            // TODO: Show about dialog
                          },
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 72,
                        ),
                        SettingTile(
                          icon: CupertinoIcons.lock_shield,
                          title: 'Privacy & data',
                          onTap: () {
                            // TODO: Navigate to privacy screen
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reset Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showResetDialog(context, provider);
                      },
                      child: Text(
                        'Reset all settings',
                        style: AppTextStyles.buttonText.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.subtitle2.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsProvider provider) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Reset all settings?'),
        content: const Text(
          'This will clear all your data and return to the onboarding screen.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              // Reset settings provider
              provider.resetAllSettings();
              // Clear user data from storage
              await context.read<UserProvider>().clearUser();
              // Close dialog
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              // Navigate to onboarding
              if (context.mounted) {
                context.go('/');
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
