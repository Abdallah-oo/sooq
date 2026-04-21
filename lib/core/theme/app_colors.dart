import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =========================
  // BASE PALETTE
  // =========================

  static const Color white = Color(0xFFFFFFFF);

  static const Color black = Color(0xFF1A1A1A); // soft black (important)
  static const Color green = Color(0xFF08650B);
  static const Color greenLight = Color(0xFFB4F3B6);
  static const Color grey50 = Color(0xFFF7F7F7);
  static const Color grey100 = Color(0xFFE5E5E5);
  static const Color grey300 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF4A4A4A);
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);

  // =========================
  // SEMANTIC COLORS (UI)
  // =========================

  static const Color background = white;

  static const Color surface = grey50;

  static const Color primaryText = black;

  static const Color secondaryText = grey500;

  static const Color mutedText = grey300;

  static const Color primary = green;
  static const Color primaryLight = greenLight;

  static const Color secondary = grey700;

  static const Color border = grey100;



   // =========================
  // SHADOWS 🔥
  // =========================

  static final List<BoxShadow> shadowSm = [
    BoxShadow(
      color: black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static final List<BoxShadow> shadowMd = [
    BoxShadow(
      color: black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> shadowLg = [
    BoxShadow(
      color: black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static final List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: primary.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}
