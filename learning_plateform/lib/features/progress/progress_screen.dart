import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/student_learning_progress_model.dart';
import 'package:learning_plateform/features/learning/screens/chapter_list_screen.dart';
import 'package:learning_plateform/features/learning/screens/topic_learning_screen.dart';
import 'package:learning_plateform/providers/progress_provider.dart';
import 'package:learning_plateform/widgets/app_bottom_nav_bar.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressDetailsStateProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Learning Progress', style: AppTextStyles.heading1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh Progress',
            onPressed: () => ref.invalidate(progressDetailsStateProvider),
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () => const _ProgressLoadingSkeleton(),
        error: (err, _) => _ProgressError(
          onRetry: () => ref.invalidate(progressDetailsStateProvider),
        ),
        data: (state) => _ProgressContent(state: state),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENT
// ══════════════════════════════════════════════════════════════════════════════
class _ProgressContent extends StatelessWidget {
  final ProgressDetailsState state;

  const _ProgressContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.isNewStudent) {
      return _EmptyProgressView();
    }

    final summary = state.summary;
    final detProg = state.detailedSubjectProgress;
    final chapters = state.chapters;

    int totalTopics = 0;
    for (final c in chapters) {
      totalTopics += c.topics.length;
    }
    final completedTopicsCount = detProg.completedTopics;
    final overallPercent = totalTopics > 0
        ? ((completedTopicsCount / totalTopics) * 100.0).clamp(0.0, 100.0)
        : summary.overallPercent;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Overall Academic Progress Banner ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color:
                                  AppColors.accentCyan.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${state.classLabel.toUpperCase()} • ACADEMIC PROGRESS',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.accentCyan,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Text(
                        '${overallPercent.toStringAsFixed(0)}%',
                        style: AppTextStyles.statValue.copyWith(
                          color: AppColors.accentCyan,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Overall Course Completion',
                      style: AppTextStyles.heading2),
                  const SizedBox(height: 4),
                  Text(
                    '$completedTopicsCount of $totalTopics Topics Completed',
                    style: AppTextStyles.body3,
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (overallPercent / 100).clamp(0.0, 1.0),
                      backgroundColor: AppColors.borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accentCyan),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Four Key Stats Grid ─────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ProgressStatTile(
                    icon: Icons.bar_chart_rounded,
                    iconColor: AppColors.accentBlue,
                    value: '${overallPercent.toStringAsFixed(0)}%',
                    label: 'Overall',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ProgressStatTile(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: AppColors.accentCyan,
                    value: '${state.quizAverageScore.toStringAsFixed(0)}%',
                    label: 'Accuracy',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ProgressStatTile(
                    icon: Icons.local_fire_department_rounded,
                    iconColor: AppColors.accentOrange,
                    value: '${summary.streakDays} Days',
                    label: 'Streak',
                    valueSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ProgressStatTile(
                    icon: Icons.check_rounded,
                    iconColor: AppColors.accentPurple,
                    value: '$completedTopicsCount/$totalTopics',
                    label: 'Topics',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Performance Breakdown Cards ─────────────────────────────────
            Text(
              'PERFORMANCE METRICS',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Practice Avg',
                    value: '${state.practiceAverageScore.toStringAsFixed(0)}%',
                    icon: Icons.fitness_center_rounded,
                    accentColor: AppColors.accentBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Quiz Avg',
                    value: '${state.quizAverageScore.toStringAsFixed(0)}%',
                    icon: Icons.quiz_outlined,
                    accentColor: AppColors.accentPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Quiz Attempts',
                    value: '${state.totalAttempts}',
                    icon: Icons.repeat_rounded,
                    accentColor: AppColors.accentOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Chapter & Topic Progress Breakdown ─────────────────────────
            Text(
              'CHAPTER & TOPIC BREAKDOWN',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            ...chapters.map((chapter) {
              return _ChapterProgressCard(
                chapter: chapter,
                detProg: detProg,
                totalSubjectTopics: totalTopics,
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Stat Tile Widget ─────────────────────────────────────────────────────────
class _ProgressStatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final double valueSize;

  const _ProgressStatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.valueSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.statValue.copyWith(fontSize: valueSize),
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.statLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Metric Card Widget ───────────────────────────────────────────────────────
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: accentColor, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(title, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ── Chapter Progress Card ────────────────────────────────────────────────────
class _ChapterProgressCard extends StatelessWidget {
  final ChapterModel chapter;
  final StudentSubjectProgressModel detProg;
  final int totalSubjectTopics;

  const _ChapterProgressCard({
    required this.chapter,
    required this.detProg,
    required this.totalSubjectTopics,
  });

  @override
  Widget build(BuildContext context) {
    int completedCount = 0;
    for (final topic in chapter.topics) {
      final tp = detProg.topicProgress[topic.id];
      if (tp != null && tp.completed) {
        completedCount++;
      }
    }

    final totalInChapter = chapter.topics.length;
    final chPercent = totalInChapter > 0
        ? ((completedCount / totalInChapter) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CHAPTER ${chapter.order}',
                  style: AppTextStyles.badge.copyWith(color: AppColors.accentBlue)),
              Text(
                '${chPercent.toStringAsFixed(0)}% Complete',
                style: AppTextStyles.captionBold.copyWith(color: AppColors.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(chapter.title, style: AppTextStyles.heading3),
          const SizedBox(height: 4),
          Text('$completedCount of $totalInChapter Topics Completed',
              style: AppTextStyles.body3),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (chPercent / 100).clamp(0.0, 1.0),
              backgroundColor: AppColors.borderColor,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 14),

          const Divider(color: AppColors.dividerColor, height: 1),
          const SizedBox(height: 12),

          // ── Topics checklist list ────────────────────────────────────────
          ...chapter.topics.map((topic) {
            final tp = detProg.topicProgress[topic.id];
            final isCompleted = tp?.completed == true;
            final isAttempted = tp != null && (tp.activityCompleted || tp.practiceScore > 0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.4)
                          : AppColors.borderColor,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted
                            ? Icons.check_circle_rounded
                            : (isAttempted
                                ? Icons.play_circle_outline_rounded
                                : Icons.radio_button_unchecked_rounded),
                        color: isCompleted
                            ? AppColors.success
                            : (isAttempted
                                ? AppColors.accentCyan
                                : AppColors.textTertiary),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic.title,
                              style: AppTextStyles.body2.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isCompleted
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (tp != null && (tp.practiceScore > 0 || tp.quizScore > 0)) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Practice: ${tp.practiceScore.toStringAsFixed(0)}% • Quiz: ${tp.quizScore.toStringAsFixed(0)}%',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.accentCyan, fontSize: 11),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textTertiary, size: 18),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════
class _EmptyProgressView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor, width: 0.8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.accentBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text('No Progress Yet', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Complete your first learning activity, practice, or quiz to start tracking your academic progress.',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChapterListScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Start Learning', style: AppTextStyles.button),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOADING SKELETON
// ══════════════════════════════════════════════════════════════════════════════
class _ProgressLoadingSkeleton extends StatelessWidget {
  const _ProgressLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerCard(height: 120, radius: 16),
            const SizedBox(height: 20),
            Row(
              children: List.generate(
                4,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _ShimmerCard(height: 80, radius: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ShimmerCard(height: 140, radius: 16),
            const SizedBox(height: 14),
            _ShimmerCard(height: 180, radius: 16),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final double height;
  final double radius;

  const _ShimmerCard({required this.height, required this.radius});

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withValues(alpha: _anim.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ══════════════════════════════════════════════════════════════════════════════
class _ProgressError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ProgressError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 16),
            Text('Unable to load your progress.', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text('Please check your connection and try again.',
                style: AppTextStyles.body3, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text('Retry', style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
