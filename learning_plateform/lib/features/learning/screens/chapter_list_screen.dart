import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/student_learning_progress_model.dart';
import 'package:learning_plateform/data/models/learning/topic_model.dart';
import 'package:learning_plateform/features/learning/screens/chapter_detail_screen.dart';
import 'package:learning_plateform/features/learning/screens/topic_learning_screen.dart';
import 'package:learning_plateform/providers/learning_provider.dart';

class ChapterListScreen extends ConsumerWidget {
  const ChapterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chaptersAsync = ref.watch(computerScienceChaptersProvider);
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
        title: Text('Computer Science', style: AppTextStyles.heading2),
      ),
      body: chaptersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
              color: AppColors.accentCyan, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Text('Unable to load Computer Science curriculum.',
              style: AppTextStyles.body2),
        ),
        data: (chapters) {
          final progress = progressAsync.valueOrNull;
          final percent = progress?.progressPercent ?? 0.0;
          final completedCount = progress?.completedTopics ?? 0;
          int totalTopics = 0;
          for (final c in chapters) {
            totalTopics += c.topics.length;
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header card ──────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.accentPurple.withValues(alpha: 0.3),
                          width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.csColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text('</>',
                                    style: TextStyle(
                                        color: AppColors.accentPurple,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Class 6 Computer Science',
                                      style: AppTextStyles.heading2),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$completedCount of $totalTopics Topics Completed',
                                    style: AppTextStyles.body3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (percent / 100).clamp(0.0, 1.0),
                            backgroundColor: AppColors.borderColor,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accentCyan),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Progress', style: AppTextStyles.caption),
                            Text('${percent.toStringAsFixed(0)}%',
                                style: AppTextStyles.progressPercent),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Continue Learning Banner ──────────────────────────────
                  if (progress?.lastTopicId != null && chapters.isNotEmpty) ...[
                    _buildContinueLearningBanner(
                        context, chapters, progress!.lastTopicId!),
                    const SizedBox(height: 24),
                  ],

                  // ── Chapters Section Title ────────────────────────────────
                  Text(
                    'CHAPTERS',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Chapter List ──────────────────────────────────────────
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: chapters.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, i) {
                      final chapter = chapters[i];
                      return _ChapterCard(
                        chapter: chapter,
                        progress: progress,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChapterDetailScreen(
                                chapter: chapter,
                                totalSubjectTopics: totalTopics,
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
          );
        },
      ),
    );
  }

  Widget _buildContinueLearningBanner(
      BuildContext context, List<ChapterModel> chapters, String lastTopicId) {
    ChapterModel? foundChapter;
    TopicModel? foundTopic;

    for (final c in chapters) {
      for (final t in c.topics) {
        if (t.id == lastTopicId) {
          foundChapter = c;
          foundTopic = t;
          break;
        }
      }
      if (foundChapter != null) break;
    }

    if (foundChapter == null || foundTopic == null) {
      return const SizedBox.shrink();
    }

    int totalTopics = 0;
    for (final c in chapters) {
      totalTopics += c.topics.length;
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TopicLearningScreen(
              chapter: foundChapter!,
              topic: foundTopic!,
              totalSubjectTopics: totalTopics,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cyanGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded,
                color: Colors.white, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CONTINUE LEARNING',
                      style: AppTextStyles.badge.copyWith(color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(foundTopic.title,
                      style: AppTextStyles.heading3
                          .copyWith(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final StudentSubjectProgressModel? progress;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;
    if (progress != null) {
      for (final topic in chapter.topics) {
        final tp = progress!.topicProgress[topic.id];
        if (tp != null && tp.completed) {
          completedCount++;
        }
      }
    }

    final total = chapter.topics.length;
    final isCompleted = completedCount == total && total > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderColor, width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.accentBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isCompleted ? 'COMPLETED' : 'CHAPTER ${chapter.order}',
                    style: AppTextStyles.badge.copyWith(
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.accentBlue,
                    ),
                  ),
                ),
                Text('$completedCount/$total Topics',
                    style: AppTextStyles.captionBold),
              ],
            ),
            const SizedBox(height: 10),
            Text(chapter.title, style: AppTextStyles.heading3),
            const SizedBox(height: 4),
            Text(
              chapter.description,
              style: AppTextStyles.body3,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isCompleted ? 'Review Chapter' : 'Explore Topics',
                  style: AppTextStyles.captionBold
                      .copyWith(color: AppColors.accentCyan),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.accentCyan, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
