import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/topic_model.dart';
import 'package:learning_plateform/features/learning/screens/topic_learning_screen.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class ChapterDetailScreen extends ConsumerWidget {
  final ChapterModel chapter;
  final int totalSubjectTopics;

  const ChapterDetailScreen({
    super.key,
    required this.chapter,
    required this.totalSubjectTopics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(computerScienceProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Chapter Details', style: AppTextStyles.heading2),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Chapter Banner Card ──────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderColor, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CHAPTER ${chapter.order}', style: AppTextStyles.label),
                    const SizedBox(height: 6),
                    Text(chapter.title, style: AppTextStyles.heading1),
                    const SizedBox(height: 8),
                    Text(chapter.description, style: AppTextStyles.body2),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Topics Header ─────────────────────────────────────────────
              Text(
                'TOPICS',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // ── Topic Cards List ─────────────────────────────────────────
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: chapter.topics.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final topic = chapter.topics[i];
                  final progress = progressAsync.valueOrNull;
                  final tp = progress?.topicProgress[topic.id];

                  return _TopicCard(
                    topic: topic,
                    isCompleted: tp?.completed == true,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => TopicLearningScreen(
                            chapter: chapter,
                            topic: topic,
                            totalSubjectTopics: totalSubjectTopics,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final TopicModel topic;
  final bool isCompleted;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted ? AppColors.success.withValues(alpha: 0.5) : AppColors.borderColor,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.accentBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.menu_book_rounded,
                color: isCompleted ? AppColors.success : AppColors.accentBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.title, style: AppTextStyles.heading3.copyWith(fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(topic.description,
                      style: AppTextStyles.body3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isCompleted ? 'Review' : 'Start',
                style: AppTextStyles.buttonSmall.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
