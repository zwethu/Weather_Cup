import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_provider.dart';

class PersonalInfoStep extends StatelessWidget {
  const PersonalInfoStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileSetupProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Personal Information',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Tell us a bit about yourself',
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: 32),

          // Name input
          const Text(
            'Your name',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: provider.setName,
            decoration: InputDecoration(
              hintText: 'Enter your name',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.person,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Gender selection
          const Text(
            'Gender',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _GenderOption(
                  label: 'Male',
                  icon: CupertinoIcons.person,
                  isSelected: provider.gender == 'Male',
                  onTap: () => provider.setGender('Male'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GenderOption(
                  label: 'Female',
                  icon: CupertinoIcons.person,
                  isSelected: provider.gender == 'Female',
                  onTap: () => provider.setGender('Female'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.subtitle1.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
