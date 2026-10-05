import 'package:flutter/material.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class ResultView extends StatelessWidget {
  final TopicLearningState state;
  final TopicLearningNotifier notifier;
  final int totalSubjectTopics;

  const ResultView({
    super.key,
    required this.state,
    required this.notifier,
    required this.totalSubjectTopics,
  });

  @override
  Widget build(BuildContext context) {
    final score = state.quizScorePercent;
    final passed = score >= 50.0;
    final questions = state.topic.assessmentQuestions;

    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      if (state.quizAnswers[i] == questions[i].correctIndex) {
        correctCount++;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Score Badge Circle ───────────────────────────────────────────
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: passed
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: passed ? AppColors.success : AppColors.error,
                width: 3,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.toStringAsFixed(0)}%',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: passed ? AppColors.success : AppColors.error,
                    ),
                  ),
                  Text('SCORE', style: AppTextStyles.label),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            passed ? 'Topic Assessment Passed!' : 'Keep Practicing!',
            style: AppTextStyles.heading1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            passed
                ? 'Great job! You answered $correctCount of ${questions.length} questions correctly.'
                : 'You answered $correctCount of ${questions.length} questions correctly. Review the topic and try again.',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // ── Questions Summary Cards ──────────────────────────────────────
          ...List.generate(questions.length, (i) {
            final q = questions[i];
            final selected = state.quizAnswers[i];
            final isCorrect = selected == q.correctIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? AppColors.success : AppColors.error,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(q.question, style: AppTextStyles.body2),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── Complete & Save Progress Button ──────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: state.isSaving
                  ? null
                  : () async {
                      await notifier.completeTopic(totalSubjectTopics);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Topic completed! Progress saved to Firebase.'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    },
              child: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Complete Topic & Return',
                      style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}
