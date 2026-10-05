import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralised typography for LMS ARENA.
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 28, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, letterSpacing: -0.3,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.2,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: 0,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: 0,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: 0,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w400,
    color: AppColors.textPrimary, letterSpacing: 0.1,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, letterSpacing: 0.1,
  );

  static const TextStyle body3 = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, letterSpacing: 0.1,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500,
    color: AppColors.textTertiary, letterSpacing: 0.3,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, letterSpacing: 0.3,
  );

  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w600,
    color: AppColors.textTertiary, letterSpacing: 0.8,
  );

  static const TextStyle button = TextStyle(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: 0.3,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary, letterSpacing: 0.2,
  );

  static const TextStyle statValue = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.3,
  );

  static const TextStyle statLabel = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500,
    color: AppColors.textSecondary, letterSpacing: 0.2,
  );

  static const TextStyle progressPercent = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w600,
    color: AppColors.accentCyan, letterSpacing: 0,
  );

  static const TextStyle badge = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: 0.5,
  );
}
