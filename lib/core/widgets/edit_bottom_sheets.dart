import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';

/// Shows a bottom sheet dialog for editing a text field
Future<String?> showEditTextBottomSheet({
  required BuildContext context,
  required String title,
  required String currentValue,
  String? hintText,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String)? validator,
}) async {
  final controller = TextEditingController(text: currentValue);
  String? errorText;

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  title,
                  style: AppTextStyles.headline3,
                ),
                const SizedBox(height: 16),
                // Text field
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: hintText,
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    errorText: errorText,
                  ),
                  onChanged: (value) {
                    if (validator != null) {
                      setState(() {
                        errorText = validator(value);
                      });
                    }
                  },
                ),
                const SizedBox(height: 24),
                // Update button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final value = controller.text.trim();
                      if (validator != null) {
                        final error = validator(value);
                        if (error != null) {
                          setState(() {
                            errorText = error;
                          });
                          return;
                        }
                      }
                      Navigator.of(context).pop(value);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      'Update $title',
                      style: AppTextStyles.buttonText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Shows a bottom sheet dialog for selecting from a list of options
Future<String?> showSelectBottomSheet({
  required BuildContext context,
  required String title,
  required List<String> options,
  required String currentValue,
}) async {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              title,
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 16),
            // Options
            ...options.map((option) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    option,
                    style: AppTextStyles.bodyText1,
                  ),
                  trailing: currentValue == option
                      ? const Icon(
                          CupertinoIcons.checkmark_circle_fill,
                          color: AppColors.primary,
                        )
                      : const Icon(
                          CupertinoIcons.circle,
                          color: AppColors.textSecondary,
                        ),
                  onTap: () => Navigator.of(context).pop(option),
                )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

/// Shows a bottom sheet dialog for selecting time
Future<String?> showTimePickerBottomSheet({
  required BuildContext context,
  required String title,
  required String currentValue,
}) async {
  // Parse current time
  final parts = currentValue.split(':');
  int hour = int.tryParse(parts[0]) ?? 6;
  int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      height: 350,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title and buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: AppTextStyles.headline3,
                ),
                TextButton(
                  onPressed: () {
                    final timeStr =
                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
                    Navigator.of(context).pop(timeStr);
                  },
                  child: Text(
                    'Done',
                    style: AppTextStyles.buttonText.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Time picker
          Expanded(
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: Duration(hours: hour, minutes: minute),
              onTimerDurationChanged: (Duration duration) {
                hour = duration.inHours;
                minute = duration.inMinutes % 60;
              },
            ),
          ),
        ],
      ),
    ),
  );
}

