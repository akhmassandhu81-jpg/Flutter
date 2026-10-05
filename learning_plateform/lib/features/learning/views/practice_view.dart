import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class PracticeView extends StatelessWidget {
  final TopicLearningState state;
  final TopicLearningNotifier notifier;

  const PracticeView({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final questions = state.topic.practiceQuestions;

    if (questions.isEmpty) {
      return Center(
        child: Text('No practice questions available for this topic.',
            style: AppTextStyles.body2),
      );
    }

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
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center_rounded,
                    color: AppColors.accentBlue, size: 20),
              ),
              const SizedBox(width: 10),
              Text('PRACTICE QUESTIONS',
                  style: AppTextStyles.label.copyWith(color: AppColors.accentBlue)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Test Your Knowledge', style: AppTextStyles.heading1),
          const SizedBox(height: 6),
          Text('Select an option to verify your understanding.',
              style: AppTextStyles.body2),
          const SizedBox(height: 20),

          ...List.generate(questions.length, (qIndex) {
            final q = questions[qIndex];
            final selected = state.practiceAnswers[qIndex];

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Question ${qIndex + 1}',
                      style: AppTextStyles.captionBold
                          .copyWith(color: AppColors.accentBlue)),
                  const SizedBox(height: 6),
                  Text(q.question, style: AppTextStyles.heading3),
                  const SizedBox(height: 14),

                  ...List.generate(q.options.length, (oIndex) {
                    final isSelected = selected == oIndex;
                    final isCorrect = oIndex == q.correctIndex;
                    final hasSelected = selected != null;

                    Color borderCol = AppColors.borderColor;
                    Color bgCol = AppColors.cardSurface;

                    if (hasSelected) {
                      if (isSelected && isCorrect) {
                        borderCol = AppColors.success;
                        bgCol = AppColors.success.withValues(alpha: 0.15);
                      } else if (isSelected && !isCorrect) {
                        borderCol = AppColors.error;
                        bgCol = AppColors.error.withValues(alpha: 0.15);
                      } else if (isCorrect) {
                        borderCol = AppColors.success;
                        bgCol = AppColors.success.withValues(alpha: 0.10);
                      }
                    }

                    return GestureDetector(
                      onTap: () => notifier.selectPracticeAnswer(qIndex, oIndex),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgCol,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderCol, width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? borderCol
                                    : AppColors.borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + oIndex),
                                  style: AppTextStyles.badge.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(q.options[oIndex],
                                  style: AppTextStyles.body2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  if (selected != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.borderColor, width: 0.8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline,
                              color: AppColors.accentCyan, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              q.explanation,
                              style: AppTextStyles.body3
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
