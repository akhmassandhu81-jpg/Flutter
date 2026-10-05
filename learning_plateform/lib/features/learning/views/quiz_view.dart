import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class QuizView extends StatelessWidget {
  final TopicLearningState state;
  final TopicLearningNotifier notifier;

  const QuizView({
    super.key,
    required this.state,
    required this.notifier,
  });

  @override
  Widget build(BuildContext context) {
    final questions = state.topic.assessmentQuestions;

    if (questions.isEmpty) {
      return Center(
        child: Text('No quiz questions available for this topic.',
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
                  color: AppColors.accentPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.quiz_outlined,
                    color: AppColors.accentPurple, size: 20),
              ),
              const SizedBox(width: 10),
              Text('TOPIC ASSESSMENT',
                  style: AppTextStyles.label.copyWith(color: AppColors.accentPurple)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Topic Quiz', style: AppTextStyles.heading1),
          const SizedBox(height: 6),
          Text('Answer all questions and submit to complete this topic.',
              style: AppTextStyles.body2),
          const SizedBox(height: 20),

          ...List.generate(questions.length, (qIndex) {
            final q = questions[qIndex];
            final selected = state.quizAnswers[qIndex];

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
                  Text('Question ${qIndex + 1} of ${questions.length}',
                      style: AppTextStyles.captionBold
                          .copyWith(color: AppColors.accentPurple)),
                  const SizedBox(height: 6),
                  Text(q.question, style: AppTextStyles.heading3),
                  const SizedBox(height: 14),

                  ...List.generate(q.options.length, (oIndex) {
                    final isSelected = selected == oIndex;

                    return GestureDetector(
                      onTap: () => notifier.selectQuizAnswer(qIndex, oIndex),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentPurple.withValues(alpha: 0.15)
                              : AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentPurple
                                : AppColors.borderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentPurple
                                    : AppColors.borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + oIndex),
                                  style: AppTextStyles.badge.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
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
                ],
              ),
            );
          }),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: state.quizAnswers.length == questions.length
                  ? notifier.submitQuiz
                  : null,
              child: Text('Submit Assessment', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
