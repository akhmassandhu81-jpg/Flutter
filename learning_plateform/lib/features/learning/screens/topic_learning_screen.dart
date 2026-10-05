import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/bookmark_model.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/topic_model.dart';
import 'package:learning_plateform/data/repositories/bookmark_repository.dart';
import 'package:learning_plateform/features/learning/views/activity_view.dart';
import 'package:learning_plateform/features/learning/views/explanation_view.dart';
import 'package:learning_plateform/features/learning/views/practice_view.dart';
import 'package:learning_plateform/features/learning/views/quiz_view.dart';
import 'package:learning_plateform/features/learning/views/result_view.dart';
import 'package:learning_plateform/features/learning/views/visualization_view.dart';
import 'package:learning_plateform/providers/auth_providers.dart';
import 'package:learning_plateform/providers/bookmark_provider.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class TopicLearningScreen extends ConsumerWidget {
  final ChapterModel chapter;
  final TopicModel topic;
  final int totalSubjectTopics;

  const TopicLearningScreen({
    super.key,
    required this.chapter,
    required this.topic,
    required this.totalSubjectTopics,
  });

  static const _stepTitles = [
    'Explanation',
    'Visualization',
    'Activity',
    'Practice',
    'Quiz',
    'Result',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(topicLearningProvider((chapter, topic)));
    final notifier = ref.read(topicLearningProvider((chapter, topic)).notifier);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(topic.title, style: AppTextStyles.heading2),
        actions: [
          Consumer(
            builder: (ctx, ref, _) {
              final isBookmarked =
                  ref.watch(isTopicBookmarkedProvider(topic.id));
              return IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  color: isBookmarked
                      ? AppColors.accentBlue
                      : AppColors.textSecondary,
                ),
                tooltip:
                    isBookmarked ? 'Remove Bookmark' : 'Bookmark Topic',
                onPressed: () async {
                  final uid = ref.read(currentUidProvider) ?? '';
                  final bookmark = BookmarkModel(
                    id:          topic.id,
                    subjectId:   'computer_science',
                    subjectName: 'Computer Science',
                    chapterId:   chapter.id,
                    chapterName: chapter.title,
                    topicId:     topic.id,
                    topicTitle:  topic.title,
                    description: topic.description,
                    contentType: 'Lesson',
                    createdAt:   DateTime.now(),
                  );
                  final added = await BookmarkRepository.instance
                      .toggleBookmark(uid, bookmark);
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(
                        content: Text(
                          added
                              ? 'Bookmarked "${topic.title}"'
                              : 'Removed "${topic.title}" from bookmarks',
                        ),
                        backgroundColor: added
                            ? AppColors.accentBlue
                            : AppColors.borderColor,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Step Indicator Bar ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.secondaryBackground,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_stepTitles.length, (index) {
                  final isCurrent = state.currentStep == index;
                  final isDone = state.currentStep > index;

                  return GestureDetector(
                    onTap: () => notifier.setStep(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.accentCyan
                            : (isDone
                                ? AppColors.accentBlue.withValues(alpha: 0.2)
                                : AppColors.cardBackground),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.accentCyan
                              : AppColors.borderColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isDone)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(Icons.check,
                                  color: AppColors.accentBlue, size: 12),
                            ),
                          Text(
                            _stepTitles[index],
                            style: AppTextStyles.caption.copyWith(
                              color: isCurrent
                                  ? Colors.black
                                  : (isDone
                                      ? AppColors.accentBlue
                                      : AppColors.textTertiary),
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // ── Step Content ──────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: state.currentStep,
              children: [
                ExplanationView(explanation: topic.explanation),
                VisualizationView(visualization: topic.visualization),
                ActivityView(state: state, notifier: notifier),
                PracticeView(state: state, notifier: notifier),
                QuizView(state: state, notifier: notifier),
                ResultView(
                  state: state,
                  notifier: notifier,
                  totalSubjectTopics: totalSubjectTopics,
                ),
              ],
            ),
          ),

          // ── Bottom Step Navigation Bar ───────────────────────────────────
          if (state.currentStep < 5)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.secondaryBackground,
                border: Border(
                  top: BorderSide(color: AppColors.borderColor, width: 0.8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous
                  TextButton.icon(
                    onPressed: state.currentStep > 0
                        ? () => notifier.setStep(state.currentStep - 1)
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: const Text('Previous'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                  ),

                  // Next
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (state.currentStep < 4) {
                        notifier.setStep(state.currentStep + 1);
                      } else {
                        // In Quiz step -> submit if answered
                        notifier.submitQuiz();
                      }
                    },
                    icon: Icon(
                      state.currentStep == 4
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_rounded,
                      size: 16,
                    ),
                    label: Text(
                      state.currentStep == 4 ? 'Submit Quiz' : 'Next Step',
                      style: AppTextStyles.buttonSmall
                          .copyWith(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
