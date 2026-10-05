import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/subject_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';
import 'package:learning_plateform/features/learning/screens/chapter_list_screen.dart';
import 'package:learning_plateform/features/onboarding/screens/class_selection_screen.dart';
import 'package:learning_plateform/providers/subjects_provider.dart';
import 'package:learning_plateform/widgets/app_bottom_nav_bar.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsStateProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Subjects', style: AppTextStyles.heading1),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh Subjects',
            onPressed: () => ref.invalidate(subjectsStateProvider),
          ),
        ],
      ),
      body: subjectsAsync.when(
        loading: () => const _SubjectsLoadingSkeleton(),
        error: (err, _) => _SubjectsError(
          onRetry: () => ref.invalidate(subjectsStateProvider),
        ),
        data: (state) => _SubjectsContent(state: state),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENT
// ══════════════════════════════════════════════════════════════════════════════
class _SubjectsContent extends StatelessWidget {
  final SubjectsState state;

  const _SubjectsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    if (!state.hasSelectedSubjects) {
      return _EmptySubjectsView();
    }

    final subjects = state.subjects;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Class & Enrolled Banner ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accentCyan.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.accentCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_rounded,
                        color: AppColors.accentCyan, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${state.classLabel.toUpperCase()} ENROLLED',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.accentCyan,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${subjects.length} ${subjects.length == 1 ? "Subject" : "Subjects"} Selected',
                          style: AppTextStyles.heading2.copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Subjects Section Title ──────────────────────────────────────
            Text(
              'ENROLLED SUBJECTS',
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // ── Subject Cards List ──────────────────────────────────────────
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) {
                final subject = subjects[i];
                final progress =
                    state.progressFor(subject.id, subject.name);

                return _SubjectListCard(
                  subject: subject,
                  progress: progress,
                  classLabel: state.classLabel,
                  onTap: () {
                    if (subject.id == 'computer_science') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ChapterListScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Subject List Card ─────────────────────────────────────────────────────────
class _SubjectListCard extends StatelessWidget {
  final SubjectModel subject;
  final SubjectProgressModel progress;
  final String classLabel;
  final VoidCallback onTap;

  const _SubjectListCard({
    required this.subject,
    required this.progress,
    required this.classLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasProgress = !progress.isNotStarted;
    final percent = progress.progressPercent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: subject.iconColor.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Row ───────────────────────────────────────────────
            Row(
              children: [
                // Subject Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: subject.iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      subject.iconLabel,
                      style: TextStyle(
                        color: subject.iconColor,
                        fontSize: subject.iconLabel.length > 2 ? 12 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Title + Class
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: AppTextStyles.heading2.copyWith(fontSize: 17),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        classLabel,
                        style: AppTextStyles.body3
                            .copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                // Percentage badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasProgress
                        ? AppColors.accentCyan.withValues(alpha: 0.15)
                        : AppColors.borderColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasProgress
                        ? '${percent.toStringAsFixed(0)}% Complete'
                        : 'Not Started',
                    style: AppTextStyles.captionBold.copyWith(
                      color: hasProgress
                          ? AppColors.accentCyan
                          : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ── Progress Bar ──────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (percent / 100).clamp(0.0, 1.0),
                backgroundColor: AppColors.borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  hasProgress ? subject.iconColor : AppColors.borderColor,
                ),
                minHeight: 5,
              ),
            ),

            const SizedBox(height: 12),

            // ── Footer Row ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasProgress
                      ? '${progress.completedTopics} of ${progress.totalTopics} Topics Completed'
                      : '0 Topics Completed',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    Text(
                      hasProgress ? 'Continue Learning' : 'Start Subject',
                      style: AppTextStyles.captionBold.copyWith(
                        color: subject.iconColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: subject.iconColor,
                      size: 14,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ══════════════════════════════════════════════════════════════════════════════
class _EmptySubjectsView extends StatelessWidget {
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
                  Icons.menu_book_rounded,
                  color: AppColors.accentBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Subjects Selected Yet',
                style: AppTextStyles.heading2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your class and subjects to begin your learning journey and track your progress.',
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ClassSelectionScreen(),
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
                      Text('Select Subjects', style: AppTextStyles.button),
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
class _SubjectsLoadingSkeleton extends StatelessWidget {
  const _SubjectsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerCard(height: 70, radius: 16),
            const SizedBox(height: 20),
            _ShimmerCard(height: 16, radius: 6, width: 140),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (_, __) => _ShimmerCard(height: 130, radius: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatefulWidget {
  final double height;
  final double radius;
  final double? width;

  const _ShimmerCard({
    required this.height,
    required this.radius,
    this.width,
  });

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
        width: widget.width ?? double.infinity,
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
class _SubjectsError extends StatelessWidget {
  final VoidCallback onRetry;

  const _SubjectsError({required this.onRetry});

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
            Text('Unable to load your subjects.', style: AppTextStyles.heading3),
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
