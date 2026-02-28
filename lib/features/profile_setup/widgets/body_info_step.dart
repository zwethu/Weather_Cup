import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';
import 'package:weather_cup/features/profile_setup/profile_setup_provider.dart';

class BodyInfoStep extends StatefulWidget {
  const BodyInfoStep({super.key});

  @override
  State<BodyInfoStep> createState() => _BodyInfoStepState();
}

class _BodyInfoStepState extends State<BodyInfoStep> {
  late TextEditingController _weightController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ProfileSetupProvider>();
    // Initialize controller text from provider if different
    if (_weightController.text != provider.weight) {
      _weightController.text = provider.weight;
    }
    if (_heightController.text != provider.height) {
      _heightController.text = provider.height;
    }

    // Add listeners that update provider when controllers change
    _weightController.removeListener(_onWeightChanged);
    _weightController.addListener(_onWeightChanged);
    _heightController.removeListener(_onHeightChanged);
    _heightController.addListener(_onHeightChanged);
  }

  void _onWeightChanged() {
    final provider = context.read<ProfileSetupProvider>();
    if (_weightController.text != provider.weight) {
      provider.setWeight(_weightController.text);
    }
  }

  void _onHeightChanged() {
    final provider = context.read<ProfileSetupProvider>();
    if (_heightController.text != provider.height) {
      provider.setHeight(_heightController.text);
    }
  }

  @override
  void dispose() {
    _weightController.removeListener(_onWeightChanged);
    _heightController.removeListener(_onHeightChanged);
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

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
            'Body Information',
            style: AppTextStyles.headline2,
          ),
          const SizedBox(height: 8),
          const Text(
            'Help us calculate your hydration needs',
            style: AppTextStyles.bodyText2,
          ),
          const SizedBox(height: 32),

          // Weight input
          const Text(
            'Weight (kg)',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          // Use TextFormField with input formatter to restrict input to numbers
          TextFormField(
            controller: _weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                // Normalize comma to dot and prevent multiple dots
                String sanitized = newValue.text.replaceAll(',', '.');
                final parts = sanitized.split('.');
                if (parts.length > 2) {
                  sanitized = parts.sublist(0, 2).join('.');
                }
                return TextEditingValue(
                  text: sanitized,
                  selection: TextSelection.collapsed(offset: sanitized.length),
                );
              }),
            ],
            decoration: InputDecoration(
              hintText: 'Enter your weight',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.chart_bar_alt_fill,
                color: AppColors.primary,
              ),
              suffixText: 'kg',
              errorText: provider.weight.isNotEmpty && !provider.weightIsValid
                  ? 'Enter a valid weight (> 0)'
                  : null,
            ),
          ),

          const SizedBox(height: 24),

          // Height input
          const Text(
            'Height (cm)',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                String sanitized = newValue.text.replaceAll(',', '.');
                final parts = sanitized.split('.');
                if (parts.length > 2) {
                  sanitized = parts.sublist(0, 2).join('.');
                }
                return TextEditingValue(
                  text: sanitized,
                  selection: TextSelection.collapsed(offset: sanitized.length),
                );
              }),
            ],
            decoration: InputDecoration(
              hintText: 'Enter your height',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.arrow_up_down,
                color: AppColors.primary,
              ),
              suffixText: 'cm',
              errorText: provider.height.isNotEmpty && !provider.heightIsValid
                  ? 'Enter a valid height (> 0)'
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
