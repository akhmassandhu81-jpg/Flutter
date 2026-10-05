import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/home_state.dart';
import 'package:learning_plateform/features/home/widgets/continue_learning_card.dart';
import 'package:learning_plateform/features/home/widgets/get_started_card.dart';
import 'package:learning_plateform/features/home/widgets/home_header.dart';
import 'package:learning_plateform/features/home/widgets/progress_stats_card.dart';
import 'package:learning_plateform/features/home/widgets/recommendation_section.dart';
import 'package:learning_plateform/features/home/widgets/subject_card.dart';
import 'package:learning_plateform/features/learning/screens/chapter_list_screen.dart';
import 'package:learning_plateform/providers/home_provider.dart';
import 'package:learning_plateform/widgets/app_bottom_nav_bar.dart';

/// LMS ARENA Home Screen.
///
/// Single screen — multiple DATA STATES:
///   • loading        → shimmer skeleton
///   • error          → friendly retry
///   • new student    → GetStartedCard + empty stats
///   • returning      → ContinueLearningCard + real stats
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeStateProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: homeAsync.when(
        loading: () => const _HomeLoadingSkeleton(),
        error:   (e, _) => _HomeError(onRetry: () => ref.invalidate(homeStateProvider)),
        data:    (state) => _HomeContent(state: state),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CONTENT (real data)
// ══════════════════════════════════════════════════════════════════════════════
class _HomeContent extends StatelessWidget {
  final HomeState state;
  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [

          // ── Header ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: HomeHeader(user: state.user),
          ),

          // ── Hero card: Get Started OR Continue Learning ──────────────────
          SliverToBoxAdapter(
            child: state.isNewStudent
                ? GetStartedCard(onExploreSubjects: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ChapterListScreen()),
                    );
                  })
                : (state.continueLearning != null
                    ? ContinueLearningCard(
                        data:       state.continueLearning!,
                        onContinue: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ChapterListScreen()),
                          );
                        },
                      )
                    : GetStartedCard(onExploreSubjects: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const ChapterListScreen()),
                        );
                      })),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Progress stats ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: ProgressStatsCard(progress: state.progress),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── My Subjects header ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'MY SUBJECTS',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View All →',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Subjects 2-column grid ───────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:     2,
                crossAxisSpacing:   12,
                mainAxisSpacing:    12,
                childAspectRatio:   0.95,
              ),
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final subject  = state.subjects[i];
                  final progress = state.progressFor(subject.id, subject.name);
                  return SubjectCard(
                    subject:  subject,
                    progress: progress,
                    onTap:    () {
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
                childCount: state.subjects.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── Recommendations ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: RecommendationSection(state: state),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOADING skeleton
// ══════════════════════════════════════════════════════════════════════════════
class _HomeLoadingSkeleton extends StatelessWidget {
  const _HomeLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Shimmer(width: 120, height: 22, radius: 8),
                Row(
                  children: [
                    _Shimmer(width: 40, height: 40, radius: 12),
                    const SizedBox(width: 10),
                    _Shimmer(width: 40, height: 40, radius: 12),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _Shimmer(width: 240, height: 28, radius: 8),
            const SizedBox(height: 8),
            _Shimmer(width: 180, height: 18, radius: 6),
            const SizedBox(height: 20),
            // Hero card shimmer
            _Shimmer(width: double.infinity, height: 180, radius: 16),
            const SizedBox(height: 24),
            // Stats row
            Row(
              children: List.generate(4, (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _Shimmer(width: double.infinity, height: 90, radius: 14),
                ),
              )),
            ),
            const SizedBox(height: 24),
            _Shimmer(width: 120, height: 16, radius: 6),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount:   2,
              crossAxisSpacing: 12,
              mainAxisSpacing:  12,
              childAspectRatio: 1.05,
              shrinkWrap:       true,
              physics:          const NeverScrollableScrollPhysics(),
              children: List.generate(4, (_) =>
                  _Shimmer(width: double.infinity, height: double.infinity, radius: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatefulWidget {
  final double width;
  final double height;
  final double radius;
  const _Shimmer({required this.width, required this.height, required this.radius});

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double>   _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 0.9).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width:  widget.width,
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
// ERROR state
// ══════════════════════════════════════════════════════════════════════════════
class _HomeError extends StatelessWidget {
  final VoidCallback onRetry;
  const _HomeError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: AppColors.textTertiary, size: 48),
              const SizedBox(height: 16),
              Text(
                'Unable to load your learning data.',
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again.',
                style: AppTextStyles.body3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text('Try Again', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
