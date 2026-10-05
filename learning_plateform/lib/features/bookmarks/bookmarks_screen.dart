import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/models/bookmark_model.dart';
import 'package:learning_plateform/data/repositories/bookmark_repository.dart';
import 'package:learning_plateform/features/learning/screens/chapter_list_screen.dart';
import 'package:learning_plateform/features/learning/screens/topic_learning_screen.dart';
import 'package:learning_plateform/providers/auth_providers.dart';
import 'package:learning_plateform/providers/bookmark_provider.dart';
import 'package:learning_plateform/providers/learning_provider.dart';
import 'package:learning_plateform/widgets/app_bottom_nav_bar.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  late TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(
        text: ref.read(bookmarkSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredBookmarksProvider);
    final totalBookmarks =
        ref.watch(userBookmarksStreamProvider).valueOrNull ?? [];
    final activeFilter = ref.watch(bookmarkFilterCategoryProvider);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bookmarks', style: AppTextStyles.heading1),
            Text('Your saved learning materials',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textTertiary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh Bookmarks',
            onPressed: () => ref.invalidate(userBookmarksStreamProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search & Filter Controls ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: AppColors.borderColor, width: 0.8),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: AppTextStyles.body2,
                      decoration: InputDecoration(
                        hintText: 'Search bookmarks...',
                        hintStyle: AppTextStyles.body2
                            .copyWith(color: AppColors.textTertiary),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textSecondary, size: 20),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded,
                                    color: AppColors.textSecondary, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ref
                                      .read(
                                          bookmarkSearchQueryProvider.notifier)
                                      .state = '';
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onChanged: (val) {
                        ref
                            .read(bookmarkSearchQueryProvider.notifier)
                            .state = val;
                        setState(() {});
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Lessons', 'Activities', 'Quizzes']
                          .map((cat) {
                        final isSelected = activeFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(
                                      bookmarkFilterCategoryProvider.notifier)
                                  .state = cat;
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentBlue
                                    : AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.accentBlue
                                      : AppColors.borderColor,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: AppTextStyles.caption.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Bookmarks Content List ─────────────────────────────────────
            Expanded(
              child: filteredAsync.when(
                loading: () => const _BookmarksLoadingSkeleton(),
                error: (err, _) => _BookmarksError(
                  onRetry: () => ref.invalidate(userBookmarksStreamProvider),
                ),
                data: (filteredList) {
                  if (totalBookmarks.isEmpty) {
                    return _EmptyBookmarksView();
                  }

                  if (filteredList.isEmpty) {
                    return _NoMatchingSearchFilterView(
                      onClear: () {
                        _searchCtrl.clear();
                        ref.read(bookmarkSearchQueryProvider.notifier).state =
                            '';
                        ref
                            .read(bookmarkFilterCategoryProvider.notifier)
                            .state = 'All';
                        setState(() {});
                      },
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final bookmark = filteredList[index];
                      return _BookmarkCard(
                        bookmark: bookmark,
                        onTap: () => _openBookmarkedTopic(context, ref, bookmark),
                        onRemove: () async {
                          final uid = ref.read(currentUidProvider) ?? '';
                          await BookmarkRepository.instance
                              .removeBookmark(uid, bookmark.topicId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Removed "${bookmark.topicTitle}" from bookmarks.'),
                                backgroundColor: AppColors.borderColor,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }

  void _openBookmarkedTopic(
      BuildContext context, WidgetRef ref, BookmarkModel bookmark) {
    final chaptersAsync = ref.read(computerScienceChaptersProvider);
    final chapters = chaptersAsync.valueOrNull ?? [];

    for (final c in chapters) {
      for (final t in c.topics) {
        if (t.id == bookmark.topicId) {
          int totalTopics = 0;
          for (final ch in chapters) {
            totalTopics += ch.topics.length;
          }
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TopicLearningScreen(
                chapter: c,
                topic: t,
                totalSubjectTopics: totalTopics,
              ),
            ),
          );
          return;
        }
      }
    }

    // Fallback: Open ChapterListScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ChapterListScreen(),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// BOOKMARK CARD
// ══════════════════════════════════════════════════════════════════════════════
class _BookmarkCard extends StatelessWidget {
  final BookmarkModel bookmark;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              children: [
                // Subject Icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.csColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '</>',
                      style: TextStyle(
                        color: AppColors.accentPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${bookmark.subjectName} • ${bookmark.chapterName}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textTertiary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        bookmark.topicTitle,
                        style: AppTextStyles.heading3.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_rounded,
                      color: AppColors.accentBlue, size: 22),
                  tooltip: 'Remove Bookmark',
                  onPressed: onRemove,
                ),
              ],
            ),
            if (bookmark.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                bookmark.description,
                style: AppTextStyles.body3,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bookmark.contentType.toUpperCase(),
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.accentCyan,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text('Open Lesson',
                        style: AppTextStyles.captionBold
                            .copyWith(color: AppColors.accentCyan)),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded,
                        color: AppColors.accentCyan, size: 14),
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
// EMPTY STATE (NO BOOKMARKS SAVED)
// ══════════════════════════════════════════════════════════════════════════════
class _EmptyBookmarksView extends StatelessWidget {
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
                  Icons.bookmark_outline_rounded,
                  color: AppColors.accentBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text('No Bookmarks Yet', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Save topics, lessons, and learning materials to access them quickly anytime.',
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
                      Text('Explore Lessons', style: AppTextStyles.button),
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
// NO MATCHING SEARCH/FILTER RESULTS
// ══════════════════════════════════════════════════════════════════════════════
class _NoMatchingSearchFilterView extends StatelessWidget {
  final VoidCallback onClear;

  const _NoMatchingSearchFilterView({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                color: AppColors.textTertiary, size: 48),
            const SizedBox(height: 16),
            Text('No Matching Bookmarks', style: AppTextStyles.heading3),
            const SizedBox(height: 8),
            Text('Try adjusting your search terms or selecting a different filter.',
                style: AppTextStyles.body3, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onClear,
              child: Text('Clear Filters',
                  style: AppTextStyles.buttonSmall
                      .copyWith(color: AppColors.accentCyan)),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// LOADING SKELETON
// ══════════════════════════════════════════════════════════════════════════════
class _BookmarksLoadingSkeleton extends StatelessWidget {
  const _BookmarksLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShimmerCard(height: 120, radius: 16),
          ),
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
class _BookmarksError extends StatelessWidget {
  final VoidCallback onRetry;

  const _BookmarksError({required this.onRetry});

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
            Text('Unable to load your bookmarks.',
                style: AppTextStyles.heading3),
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
