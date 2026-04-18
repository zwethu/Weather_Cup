import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/core/widgets/edit_bottom_sheets.dart';
import 'package:weather_cup/features/auth/auth_provider.dart';
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
              leadingWidth: 44,
              titleSpacing: 8,
              leading: IconButton(
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
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      'Manage reminders and profile.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  ProfileCard(
                    name: userProvider.userName,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.read<NavigationProvider>().setIndex(2);
                    },
                  ),

                  const SizedBox(height: 24),

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
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 72,
                        ),
                        // 🧪 Test mode — disabled when hourly reminders are OFF
                        ToggleSettingTile(
                          icon: CupertinoIcons.lab_flask,
                          title: 'Test mode',
                          subtitle:
                              'Send 5 quick test reminders, one minute apart.',
                          value: provider.testMode,
                          onChanged: provider.hourlyReminders
                              ? provider.toggleTestMode
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Hydration preferences'),
                  const SizedBox(height: 8),
                  DailyGoalCard(
                    onTap: () async {
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

                  const SizedBox(height: 24),
                  _buildSectionTitle('About App'),
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

                  _buildSectionTitle('Account'),
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
                        SettingTile(
                          icon: CupertinoIcons.square_arrow_right,
                          title: 'Log out',
                          onTap: () => _confirmLogout(context),
                        ),
                        const Divider(
                          height: 1,
                          color: AppColors.divider,
                          indent: 72,
                        ),
                        SettingTile(
                          icon: CupertinoIcons.delete,
                          title: 'Delete account',
                          onTap: () => _confirmDeleteAccount(context),
                        ),
                      ],
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

  // ─── Account actions ────────────────────────────────

  void _confirmLogout(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to use Weather Cup.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await context.read<AuthProvider>().signOut();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final password = await _promptForPassword(context);
    if (password == null || password.isEmpty) return;
    if (!context.mounted) return;

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your profile, hydration history, '
          'and account. This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.deleteAccount(password: password);
    if (!context.mounted) return;

    if (success) {
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Could not delete account.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Modal that asks the user to re-enter their password so we can
  /// re-authenticate before deleting the account (Firebase requires a
  /// recent login for `user.delete()`).
  Future<String?> _promptForPassword(BuildContext context) {
    final controller = TextEditingController();
    return showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Confirm it\'s you'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Current password',
            obscureText: true,
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(null),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
