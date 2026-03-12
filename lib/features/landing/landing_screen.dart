import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:weather_cup/core/theme/app_colors.dart';
import 'package:weather_cup/core/theme/app_text_styles.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ← gradient background same as home/history
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradientReverse,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 600;
            return isWide
                ? _DesktopLayout(onGetStarted: () => context.go('/'))
                : _MobileLayout(onGetStarted: () => context.go('/'));
          },
        ),
      ),
    );
  }
}

// ─── Mobile Layout ────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _MobileLayout({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _Header(onGetStarted: onGetStarted, compact: true),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  // 1. Hero text
                  const _HeroSection(centerAlign: true),
                  const SizedBox(height: 24),

                  // 2. Get Started button
                  _GetStartedButton(onPressed: onGetStarted),
                  const SizedBox(height: 40),

                  // 3. Phone mockup AFTER button
                  const _PhoneMockup(),
                  const SizedBox(height: 40),

                  // 4. Feature cards
                  const _FeaturesGrid(crossAxisCount: 2),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Desktop Layout ───────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  final VoidCallback onGetStarted;
  const _DesktopLayout({required this.onGetStarted});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header
            _Header(onGetStarted: onGetStarted, compact: false),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: Column(
                children: [
                  const SizedBox(height: 72),

                  // Hero row: text+button LEFT | mockup RIGHT
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _HeroSection(centerAlign: false),
                            const SizedBox(height: 40),
                            _GetStartedButton(onPressed: onGetStarted),
                          ],
                        ),
                      ),
                      const SizedBox(width: 64),
                      const Expanded(
                        child: Center(child: _PhoneMockup()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),

                  // Features: 4 columns
                  const _FeaturesGrid(crossAxisCount: 4),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onGetStarted;
  final bool compact; // true = mobile, false = desktop
  const _Header({required this.onGetStarted, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 24 : 80,
        vertical: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.drop_fill,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Weather Cup',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          // Get Started button — compact on mobile, full on desktop
          compact
              ? TextButton(
                  onPressed: onGetStarted,
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.buttonTextSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                )
              : SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: onGetStarted,
                    icon: const Icon(
                      CupertinoIcons.arrow_right_circle_fill,
                      size: 18,
                    ),
                    label: Text(
                      'Get Started',
                      style: AppTextStyles.buttonTextSmall,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final bool centerAlign;
  const _HeroSection({required this.centerAlign});

  @override
  Widget build(BuildContext context) {
    final align = centerAlign ? TextAlign.center : TextAlign.left;
    final cross =
        centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(
          'Stay Hydrated,\nStay Healthy.',
          style: AppTextStyles.headline1.copyWith(height: 1.2),
          textAlign: align,
        ),
        const SizedBox(height: 16),
        Text(
          'Weather Cup calculates your personal daily water goal '
          'and adjusts it based on today\'s weather — so you always '
          'know exactly how much to drink.',
          style: AppTextStyles.bodyText1.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: align,
        ),
      ],
    );
  }
}

// ─── Phone Mockup Placeholder ─────────────────────────────────────────────────

class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 520,
      child: Image.asset("assets/images/mockup_bg.png", fit: BoxFit.cover)
    );
  }
}

// ─── Features Grid ────────────────────────────────────────────────────────────

class _FeaturesGrid extends StatelessWidget {
  final int crossAxisCount;
  const _FeaturesGrid({required this.crossAxisCount});

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      icon: CupertinoIcons.person_crop_circle,
      title: 'Personalised Goal',
      description: 'A water goal calculated from your body data.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.cloud_sun,
      title: 'Weather-Smart',
      description: 'Target adjusts automatically on hot days.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.bell,
      title: 'Hourly Reminders',
      description: 'Notifications keep you on track all day.',
    ),
    _FeatureItem(
      icon: CupertinoIcons.chart_bar,
      title: 'Track Progress',
      description: 'Log drinks in one tap, view history easily.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Split features into rows based on crossAxisCount
    final List<Widget> rows = [];
    for (int i = 0; i < _features.length; i += crossAxisCount) {
      final rowItems = _features.sublist(
        i,
        (i + crossAxisCount).clamp(0, _features.length),
      );
      rows.add(
        IntrinsicHeight(  // ← makes all cards in a row match the tallest one
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rowItems.asMap().entries.map((entry) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: entry.key == 0 ? 0 : 8,
                    right: entry.key == rowItems.length - 1 ? 0 : 8,
                  ),
                  child: _FeatureCard(item: entry.value),
                ),
              );
            }).toList(),
          ),
        ),
      );
      if (i + crossAxisCount < _features.length) {
        rows.add(const SizedBox(height: 16));
      }
    }

    return Column(children: rows);
  }
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  const _FeatureCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,  // ← shrink to content height
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(item.title, style: AppTextStyles.cardTitle),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: AppTextStyles.cardSubtitle,
            maxLines: 3,           // ← prevent unbounded text overflow
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Get Started Button ───────────────────────────────────────────────────────

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GetStartedButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(CupertinoIcons.arrow_right_circle_fill),
        label: const Text('Get Started', style: AppTextStyles.buttonText),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// ─── Data Class ───────────────────────────────────────────────────────────────

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });
}
