import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/widgets/edit_bottom_sheets.dart';
import 'package:weather_cup/features/profile/widgets/profile_header_card.dart';
import 'package:weather_cup/features/profile/widgets/profile_info_item.dart';
import 'package:weather_cup/features/profile/widgets/profile_info_section.dart';
import 'package:weather_cup/features/profile/widgets/profile_setting_card.dart';
import 'package:weather_cup/features/profile/user_provider.dart';

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
    // Get user data via UserProvider
    final userProvider = context.watch<UserProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileHeaderCard(),

        // Body information
        BodyInfoSection(
          title: 'Body information',
          items: [
            ProfileInfoItem(
              label: 'Gender',
              value: userProvider.gender,
              onEdit: () => _editGender(context, userProvider),
            ),
            ProfileInfoItem(
              label: 'Weight',
              value: '${userProvider.weight.toStringAsFixed(1)} kg',
              onEdit: () => _editWeight(context, userProvider),
            ),
            ProfileInfoItem(
              label: 'Height',
              value: '${userProvider.height.toStringAsFixed(0)} cm',
              onEdit: () => _editHeight(context, userProvider),
            ),
          ],
        ),

        // Daily routine
        BodyInfoSection(
          title: 'Daily routine',
          items: [
            ProfileInfoItem(
              label: 'Wake time',
              value: userProvider.wakeTime,
              onEdit: () => _editWakeTime(context, userProvider),
            ),
            ProfileInfoItem(
              label: 'Sleep time',
              value: userProvider.sleepTime,
              onEdit: () => _editSleepTime(context, userProvider),
            ),
          ],
        ),

        // Location
        BodyInfoSection(
          title: 'Location',
          items: [
            ProfileInfoItem(
              label: 'Country',
              value: userProvider.country,
              onEdit: () => _editCountry(context, userProvider),
            ),
            ProfileInfoItem(
              label: 'City',
              value: userProvider.city,
              onEdit: () => _editCity(context, userProvider),
            ),
          ],
        ),

        // Preferences
        BodyInfoSection(
          title: 'Preferences',
          items: [
            ProfileInfoItem(
              label: 'Nickname',
              value: userProvider.userName,
              onEdit: () => _editName(context, userProvider),
            ),
            ProfileInfoItem(
              label: 'Daily goal',
              value: '${userProvider.recommendedDailyIntake} ml',
              onEdit: null, // Auto-calculated based on weight
            ),
          ],
        ),

        // Settings row
        const ProfileSettingsCard(),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _editName(BuildContext context, UserProvider userProvider) async {
    final result = await showEditTextBottomSheet(
      context: context,
      title: 'Nickname',
      currentValue: userProvider.userName,
      hintText: 'Enter your nickname',
      validator: (value) => value.isEmpty ? 'Please enter a name' : null,
    );
    if (result != null && context.mounted) {
      await userProvider.updateUser(name: result);
    }
  }

  Future<void> _editGender(BuildContext context, UserProvider userProvider) async {
    final result = await showSelectBottomSheet(
      context: context,
      title: 'Gender',
      options: ['Male', 'Female', 'Other'],
      currentValue: userProvider.gender,
    );
    if (result != null && context.mounted) {
      await userProvider.updateUser(gender: result);
    }
  }

  Future<void> _editWeight(BuildContext context, UserProvider userProvider) async {
    final result = await showEditTextBottomSheet(
      context: context,
      title: 'Weight',
      currentValue: userProvider.weight.toStringAsFixed(1),
      hintText: 'Enter your weight in kg',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
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
  }

  Future<void> _editHeight(BuildContext context, UserProvider userProvider) async {
    final result = await showEditTextBottomSheet(
      context: context,
      title: 'Height',
      currentValue: userProvider.height.toStringAsFixed(0),
      hintText: 'Enter your height in cm',
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
      ],
      validator: (value) {
        final height = double.tryParse(value);
        if (height == null || height <= 0) {
          return 'Please enter a valid height';
        }
        return null;
      },
    );
    if (result != null && context.mounted) {
      final height = double.tryParse(result);
      if (height != null) {
        await userProvider.updateUser(height: height);
      }
    }
  }

  Future<void> _editWakeTime(BuildContext context, UserProvider userProvider) async {
    final result = await showTimePickerBottomSheet(
      context: context,
      title: 'Wake Time',
      currentValue: userProvider.wakeTime,
    );
    if (result != null && context.mounted) {
      await userProvider.updateUser(wakeTime: result);
    }
  }

  Future<void> _editSleepTime(BuildContext context, UserProvider userProvider) async {
    final result = await showTimePickerBottomSheet(
      context: context,
      title: 'Sleep Time',
      currentValue: userProvider.sleepTime,
    );
    if (result != null && context.mounted) {
      await userProvider.updateUser(sleepTime: result);
    }
  }

  Future<void> _editCountry(BuildContext context, UserProvider userProvider) async {
    final result = await showEditTextBottomSheet(
      context: context,
      title: 'Country',
      currentValue: userProvider.country,
      hintText: 'Enter your country',
      validator: (value) => value.isEmpty ? 'Please enter a country' : null,
    );
    if (result != null && context.mounted) {
      await userProvider.updateUser(country: result);
    }
  }

  Future<void> _editCity(BuildContext context, UserProvider userProvider) async {
    final result = await showEditTextBottomSheet(
      context: context,
      title: 'City',
      currentValue: userProvider.city,
      hintText: 'Enter your city',
      validator: (value) => value.isEmpty ? 'Please enter a city' : null,
    );
    if (result != null && context.mounted) {
      await userProvider.updateUser(city: result);
    }
  }
}
