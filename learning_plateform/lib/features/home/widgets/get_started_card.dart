import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';

/// Shown when the student has zero progress.
/// Matches the "Start Your Learning Journey" design state.
class GetStartedCard extends StatelessWidget {
  final VoidCallback onExploreSubjects;

  const GetStartedCard({super.key, required this.onExploreSubjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: chip + completion ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.accentGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'GET STARTED',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.accentGreen,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Text(
                '0% Complete',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Book illustration ──────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Start Your Learning Journey',
                      style: AppTextStyles.heading1.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose a subject and begin your first lesson.',
                      style: AppTextStyles.body3,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _BookIllustration(),
            ],
          ),

          const SizedBox(height: 18),

          // ── CTA button ─────────────────────────────────────────────────
          GestureDetector(
            onTap: onExploreSubjects,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Explore Subjects', style: AppTextStyles.button),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.accentBlue.withValues(alpha: 0.2),
        ),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: AppColors.accentBlue,
        size: 32,
      ),
    );
  }
}
