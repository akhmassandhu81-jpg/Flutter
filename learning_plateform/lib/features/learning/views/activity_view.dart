import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class ActivityView extends StatelessWidget {
  final TopicLearningState state;
  final TopicLearningNotifier notifier;

  const ActivityView({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final activity = state.topic.activity;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.extension_outlined,
                    color: AppColors.accentOrange, size: 20),
              ),
              const SizedBox(width: 10),
              Text('INTERACTIVE ACTIVITY',
                  style: AppTextStyles.label.copyWith(color: AppColors.accentOrange)),
            ],
          ),
          const SizedBox(height: 12),
          Text(activity.title, style: AppTextStyles.heading1),
          const SizedBox(height: 6),
          Text(activity.instruction, style: AppTextStyles.body2),
          const SizedBox(height: 20),

          // ── Drag or Swap Reorder List ─────────────────────────────────────
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.activityItems.length,
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) =>
                notifier.reorderActivityItem(oldIndex, newIndex),
            itemBuilder: (ctx, index) {
              final item = state.activityItems[index];
              return Padding(
                key: ValueKey(item),
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.captionBold
                                .copyWith(color: AppColors.accentOrange),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(item, style: AppTextStyles.body1),
                      ),
                      const Icon(Icons.drag_handle_rounded,
                          color: AppColors.textTertiary),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // ── Submit Button ─────────────────────────────────────────────────
          if (!state.activitySubmitted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: notifier.submitActivity,
                child: Text('Submit Answer', style: AppTextStyles.button),
              ),
            ),

          // ── Feedback Banner ───────────────────────────────────────────────
          if (state.activitySubmitted) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: state.activityIsCorrect
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.error.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: state.activityIsCorrect ? AppColors.success : AppColors.error,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.activityIsCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: state.activityIsCorrect
                            ? AppColors.success
                            : AppColors.error,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        state.activityIsCorrect
                            ? 'Excellent! Correct Sequence!'
                            : 'Incorrect Sequence',
                        style: AppTextStyles.heading3.copyWith(
                          color: state.activityIsCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ],
                  ),
                  if (!state.activityIsCorrect) ...[
                    const SizedBox(height: 10),
                    Text('Correct Order:',
                        style: AppTextStyles.captionBold
                            .copyWith(color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    ...activity.correctOrder.asMap().entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text('${e.key + 1}. ${e.value}',
                                style: AppTextStyles.body3),
                          ),
                        ),
                  ]
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
