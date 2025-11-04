import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2D9CDB); // Teal Blue
  static const Color primaryDark = Color(0xFF1B7FB8);
  static const Color primaryLight = Color(0xFF56B4EB);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF9F43); // Orange
  static const Color secondaryDark = Color(0xFFE88620);
  static const Color secondaryLight = Color(0xFFFFB366);

  // Accent Colors
  static const Color accent = Color(0xFF6C5CE7); // Purple
  static const Color accentLight = Color(0xFF9B8CF3);

  // Status Colors
  static const Color success = Color(0xFF00D68F); // Green
  static const Color warning = Color(0xFFFFAA00); // Yellow
  static const Color error = Color(0xFFEB5757); // Red
  static const Color info = Color(0xFF0095FF); // Blue

  // Text Colors
  static const Color textPrimary = Color(0xFF2E3A59);
  static const Color textSecondary = Color(0xFF6B7588);
  static const Color textTertiary = Color(0xFF9AA5B8);
  static const Color textLight = Color(0xFFFFFFFF);

  // Background Colors
  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFFF0F1F5);

  // Border Colors
  static const Color border = Color(0xFFE4E9F2);
  static const Color borderLight = Color(0xFFF1F3F6);

  // Other Colors
  static const Color divider = Color(0xFFE4E9F2);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // Verification Badge Colors
  static const Color verified = Color(0xFF00D68F);
  static const Color pending = Color(0xFFFFAA00);
  static const Color unverified = Color(0xFF9AA5B8);
  static const Color rejected = Color(0xFFEB5757);

  // Rating Stars
  static const Color starFilled = Color(0xFFFFB800);
  static const Color starEmpty = Color(0xFFE4E9F2);

  // Property Type Colors
  static const Color apartment = Color(0xFF6C5CE7);
  static const Color house = Color(0xFF2D9CDB);
  static const Color villa = Color(0xFFFF9F43);
  static const Color condo = Color(0xFF00D68F);
  static const Color cabin = Color(0xFFEB5757);

  // Gradient colors for premium features
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient premiumGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFFF9F43)],
  );
}
