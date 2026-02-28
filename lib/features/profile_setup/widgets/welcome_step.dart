import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        // Water drop icon
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            CupertinoIcons.drop_fill,
            size: 60,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Let\'s set up your profile',
          style: AppTextStyles.headline1.copyWith(fontSize: 28),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'We need a few details to personalize your hydration goals and reminders.',
            style: AppTextStyles.bodyText2,
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(flex: 2),
      ],
    );
  }
}
