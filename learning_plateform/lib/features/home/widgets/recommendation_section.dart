import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/home_state.dart';

/// "RECOMMENDED FOR YOU" section at the bottom of the home screen.
/// Shows an empty-state message for new students and a placeholder list
/// for returning students (real recommendation data can be added later).
class RecommendationSection extends StatelessWidget {
  final HomeState state;

  const RecommendationSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section header ─────────────────────────────────────────────
          Text(
            'RECOMMENDED FOR YOU',
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.isNewStudent
                ? 'Recommendations will appear as you learn.'
                : 'Improve the topics that need more practice',
            style: AppTextStyles.body3,
          ),
          const SizedBox(height: 14),

          // ── Content ────────────────────────────────────────────────────
          if (state.isNewStudent)
            _EmptyRecommendations()
          else
            _RecommendationPlaceholder(state: state),
        ],
      ),
    );
  }
}

class _EmptyRecommendations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            color: AppColors.textTertiary,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Your recommendations will appear\nhere once you start learning.',
            style: AppTextStyles.body3.copyWith(color: AppColors.textTertiary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RecommendationPlaceholder extends StatelessWidget {
  final HomeState state;
  const _RecommendationPlaceholder({required this.state});

  @override
  Widget build(BuildContext context) {
    // Show the weakest subjects (lowest progress) as recommendations
    final sorted = [...state.subjectProgress]
      ..sort((a, b) => a.progressPercent.compareTo(b.progressPercent));

    final items = sorted.take(2).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: items.map((sp) {
        // Find the matching SubjectModel for icon data
        final subject = state.subjects.firstWhere(
          (s) => s.id == sp.subjectId,
          orElse: () => state.subjects.first,
        );
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderColor, width: 0.8),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: subject.iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      subject.iconLabel,
                      style: TextStyle(
                        color: subject.iconColor,
                        fontSize: subject.iconLabel.length > 2 ? 11 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(sp.subjectName, style: AppTextStyles.heading3.copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Practice weak topics to improve',
                        style: AppTextStyles.body3.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: AppColors.textTertiary, size: 14),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
