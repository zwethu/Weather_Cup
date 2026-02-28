import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_provider.dart';

class LocationStep extends StatelessWidget {
  const LocationStep({super.key});

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
            'Location',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Used only to fetch local weather data',
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: 32),

          // Country input
          const Text(
            'Country',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: provider.country,
            onChanged: provider.setCountry,
            decoration: InputDecoration(
              hintText: 'Enter your country',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.location,
                color: AppColors.primary,
              ),
              errorText: provider.country.isEmpty ? 'Please enter your country' : null,
            ),
          ),

          const SizedBox(height: 24),

          // City input
          const Text(
            'City',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: provider.city,
            onChanged: provider.setCity,
            decoration: InputDecoration(
              hintText: 'Enter your city',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.location_fill,
                color: AppColors.primary,
              ),
              errorText: provider.city.isEmpty ? 'Please enter your city' : null,
            ),
          ),
        ],
      ),
    );
  }
}
