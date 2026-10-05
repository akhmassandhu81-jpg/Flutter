import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';

/// Standard scaffold wrapper for all three onboarding screens.
/// Provides:
///   - Dark LMS ARENA background
///   - Optional back button
///   - Step indicator (e.g. "1 of 3")
///   - Title + subtitle header
///   - Scrollable content area
///   - Sticky bottom CTA area
class LMSOnboardingScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final int stepCurrent;   // 1-based
  final int stepTotal;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget content;         // the list/grid of selection cards
  final Widget bottomAction;    // the Continue / Start Learning button

  const LMSOnboardingScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.stepCurrent,
    required this.stepTotal,
    required this.content,
    required this.bottomAction,
    this.showBack = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  if (showBack)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBack ?? () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.borderColor, width: 0.8),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const Spacer(),
                  // Step pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.borderColor, width: 0.8),
                    ),
                    child: Text(
                      'Step $stepCurrent of $stepTotal',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Step progress bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: stepCurrent / stepTotal,
                  backgroundColor: AppColors.borderColor,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentBlue,
                  ),
                  minHeight: 4,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.displayLarge),
                  const SizedBox(height: 8),
                  Text(subtitle,
                      style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Scrollable content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: content,
              ),
            ),

            // ── Sticky bottom CTA ──────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground,
                border: const Border(
                  top: BorderSide(color: AppColors.borderColor, width: 0.6),
                ),
              ),
              child: bottomAction,
            ),
          ],
        ),
      ),
    );
  }
}
