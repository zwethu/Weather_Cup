import 'package:flutter/material.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/features/profile_setup/widgets/profile_header_card.dart';
import 'package:weather_cup/features/profile_setup/widgets/profile_info_item.dart';
import 'package:weather_cup/features/profile_setup/widgets/profile_info_section.dart';
import 'package:weather_cup/features/profile_setup/widgets/profile_save_actions.dart';
import 'package:weather_cup/features/profile_setup/widgets/profile_setting_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: const SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 24),
            child: _ProfileContent(),
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderCard(),

        // Body information
        BodyInfoSection(
          title: 'Body information',
          items: [
            ProfileInfoItem(label: 'Gender', value: 'Male'),
            ProfileInfoItem(label: 'Weight', value: '68 kg'),
            ProfileInfoItem(label: 'Height', value: '172 cm'),
          ],
        ),

        // Daily routine
        BodyInfoSection(
          title: 'Daily routine',
          items: [
            ProfileInfoItem(label: 'Wake time', value: '06:30'),
            ProfileInfoItem(label: 'Sleep time', value: '23:30'),
          ],
        ),

        // Location
        BodyInfoSection(
          title: 'Location',
          items: [
            ProfileInfoItem(label: 'Country', value: 'Thailand'),
            ProfileInfoItem(label: 'City', value: 'Chiang Rai'),
          ],
        ),

        // Preferences
        BodyInfoSection(
          title: 'Preferences',
          items: [
            ProfileInfoItem(label: 'Nickname', value: 'Frank'),
            ProfileInfoItem(label: 'Units', value: 'Metric (ml, kg, cm)'),
          ],
        ),

        // Settings row
        ProfileSettingsCard(),
        SizedBox(height: 24),
        // Save + delete actions
        ProfileSaveActions(),
      ],
    );
  }
}
