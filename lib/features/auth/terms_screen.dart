import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';

class TermsScreen extends StatelessWidget {
  /// If true, shows Accept/Decline buttons (onboarding flow).
  /// If false, shows only a back button (viewed from settings).
  final bool showActions;

  const TermsScreen({super.key, this.showActions = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back,
                color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Please read carefully',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
              Text('Terms & Conditions', style: AppTextStyles.headline3),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLastUpdated(),
                      _buildSection(
                        '1. Acceptance of Terms',
                        'By downloading, installing, or using Weather Cup, you agree to be bound by these Terms & Conditions. If you do not agree, please do not use the app.',
                      ),
                      _buildSection(
                        '2. Account & Authentication',
                        'You must create an account using a valid email address and password via Firebase Authentication. You are responsible for maintaining the confidentiality of your credentials. We are not liable for any loss resulting from unauthorized access to your account.',
                      ),
                      _buildSection(
                        '3. Data We Collect',
                        'Weather Cup collects and stores the following data to provide its services:\n\n• Personal profile: nickname, gender, weight, height, wake/sleep times, and location (city and country).\n• Hydration data: daily water intake logs, timestamps, and drink entries.\n• Account data: your email address.\n\nAll data is stored securely in Google Firebase Firestore and locally on your device.',
                      ),
                      _buildSection(
                        '4. How We Use Your Data',
                        'Your data is used solely to:\n\n• Calculate your personalized daily hydration goal (based on weight × 33 ml).\n• Display weather-adjusted hydration recommendations.\n• Show your hydration history and progress.\n• Send hydration reminder notifications.\n\nWe do not sell, rent, or share your personal data with third parties.',
                      ),
                      _buildSection(
                        '5. Health Disclaimer',
                        'Weather Cup\'s hydration recommendations are general estimates based on body weight and activity level. They are NOT medical advice. Always consult a qualified healthcare professional for personalized health and hydration guidance. The app developers are not liable for any health issues arising from following the app\'s suggestions.',
                      ),
                      _buildSection(
                        '6. Data Security',
                        'Your data is protected using Firebase\'s industry-standard security measures, including encryption in transit and at rest. However, no digital system is 100% secure. You use the app at your own risk.',
                      ),
                      _buildSection(
                        '7. Data Deletion',
                        'You can delete all your local data at any time via Settings → Reset all settings. To permanently delete your Firebase account and associated data, please contact us.',
                      ),
                      _buildSection(
                        '8. Changes to These Terms',
                        'We may update these Terms & Conditions from time to time. Significant changes will be communicated within the app. Continued use of the app after changes constitutes your acceptance of the new terms.',
                      ),
                      _buildSection(
                        '9. Contact',
                        'If you have any questions about these terms or how your data is used, please contact us at:\n\n6731503097@lamduan.mfu.ac.th',
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action bar — only shown in onboarding/register flow
            if (showActions)
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
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        child: Text('Decline',
                            style: AppTextStyles.buttonText
                                .copyWith(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop(true); // returns true = accepted
                        },
                        child: Text('I Agree',
                            style: AppTextStyles.buttonText),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'Last updated: April 2026',
        style: AppTextStyles.caption,
      ),
    );
  }

  Widget _buildSection(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.subtitle1),
          const SizedBox(height: 6),
          Text(body,
              style: AppTextStyles.bodyText2
                  .copyWith(color: AppColors.textSecondary, height: 1.6)),
        ],
      ),
    );
  }
}