import 'package:flutter/material.dart';
import 'package:sooq/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Poppins';

  // =========================
  // DISPLAY (Hero only)
  // =========================

  static const TextStyle displaySmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    color: AppColors.primaryText,
    height: 1.2,
  );

  // =========================
  // HEADINGS
  // =========================

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: fontFamily,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: AppColors.primaryText,
    height: 1.3,
  );

  // =========================
  // BODY
  // =========================

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: AppColors.primaryText,
    height: 1.4,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: AppColors.mutedText,
    height: 1.3,
  );

  // =========================
  // LABELS / UI TEXT
  // =========================

  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: AppColors.primaryText,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
    color: AppColors.secondaryText,
    letterSpacing: 0.2,
  );

  static const TextStyle button = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontFamily: fontFamily,
    color: AppColors.white,
    letterSpacing: 0.3,
  );

  // =========================
  // CAPTION
  // =========================

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: fontFamily,
    color: AppColors.mutedText,
    height: 1.2,
  );
}
