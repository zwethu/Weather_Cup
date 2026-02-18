import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF00A8E8);
  static const Color primaryLight = Color(0xFF4DC2F0);
  static const Color primaryDark = Color(0xFF0081B8);

  // Sky blue gradient colors (from-sky-400 to-sky-600)
  static const Color skyBlue400 = Color(0xFF38BDF8);
  static const Color skyBlue600 = Color(0xFF0284C7);
  static const Color skyBlue50 = Color(0xFFF0F9FF);
  static const Color skyBlue200 = Color(0xFFBAE6FD);

  // Background colors
  static const Color background = Color(0xFFF0F9FF); // Light sky blue tint

  // Surface colors with opacity
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceBlur =
      Color(0xB3FFFFFF); // 70% opacity white (bg-white/70)
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1F2937); // Gray-800
  static const Color textSecondary = Color(0xFF6B7280); // Gray-500
  static const Color textHint = Color(0xFF9CA3AF);

  // Accent colors
  static const Color accentBlue = Color(0xFFDCEEF5); // Sky-100
  static const Color accentBlueDark = Color(0xFFBAE6FD); // Sky-200
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // UI element colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderSkyBlue = Color(0x99BAE6FD); // border-sky-200/60
  static const Color shadow = Color(0x1A000000);

  // Icon colors
  static const Color iconPrimary = primary;
  static const Color iconSecondary = Color(0xFF9CA3AF);

  // Progress/Chart colors
  static const Color progressFilled = primary;
  static const Color progressEmpty = Color(0xFFE5E7EB); // Gray-200

  // Special colors for water-related elements
  static const Color waterDrop = primary;
  static const Color weatherIcon = primary;

  static const Color backgroundGradientStart = Color(0xFFB8E6FE); // soft blue
  static const Color backgroundGradientMiddle = Color(0xFFEAF6FF); // very light
  static const Color backgroundGradientEnd = Color(0xFFFFFFFF); // white

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      backgroundGradientStart,
      backgroundGradientMiddle,
      backgroundGradientEnd,
    ],
    stops: [0.0, 0.35, 0.8], // fade to white early
  );

  // Sky blue primary gradient (from-sky-400 to-sky-600)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      skyBlue400,
      skyBlue600,
    ],
  );

  // Card gradient with subtle sky tint
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF0F9FF), // Sky-50
      Color(0xFFFFFFFF), // White
    ],
  );
}
