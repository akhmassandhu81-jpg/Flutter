import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/data/models/bookmark_model.dart';
import 'package:learning_plateform/data/repositories/bookmark_repository.dart';
import 'package:learning_plateform/providers/auth_providers.dart';

// ── Search & Filter State Providers ──────────────────────────────────────────
final bookmarkSearchQueryProvider = StateProvider<String>((ref) => '');
final bookmarkFilterCategoryProvider = StateProvider<String>((ref) => 'All');

// ── Realtime User Bookmarks Stream ────────────────────────────────────────────
final userBookmarksStreamProvider = StreamProvider<List<BookmarkModel>>((ref) {
  final uid = ref.watch(currentUidProvider) ?? '';
  return BookmarkRepository.instance.bookmarksStream(uid);
});

// ── Filtered & Searched Bookmarks Provider ───────────────────────────────────
final filteredBookmarksProvider = Provider<AsyncValue<List<BookmarkModel>>>((ref) {
  final bookmarksAsync = ref.watch(userBookmarksStreamProvider);
  final searchQuery = ref.watch(bookmarkSearchQueryProvider).trim().toLowerCase();
  final filterCategory = ref.watch(bookmarkFilterCategoryProvider);

  return bookmarksAsync.whenData((list) {
    return list.where((b) {
      // 1. Filter Category check
      if (filterCategory != 'All') {
        if (filterCategory == 'Lessons' && b.contentType != 'Lesson') {
          return false;
        }
        if (filterCategory == 'Activities' && b.contentType != 'Activity') {
          return false;
        }
        if (filterCategory == 'Quizzes' && b.contentType != 'Quiz') {
          return false;
        }
      }

      // 2. Search Query check
      if (searchQuery.isNotEmpty) {
        final matchSubject = b.subjectName.toLowerCase().contains(searchQuery);
        final matchChapter = b.chapterName.toLowerCase().contains(searchQuery);
        final matchTopic   = b.topicTitle.toLowerCase().contains(searchQuery);
        final matchDesc    = b.description.toLowerCase().contains(searchQuery);
        return matchSubject || matchChapter || matchTopic || matchDesc;
      }

      return true;
    }).toList();
  });
});

// ── Check if Specific Topic is Bookmarked ────────────────────────────────────
final isTopicBookmarkedProvider = Provider.family<bool, String>((ref, topicId) {
  final bookmarks = ref.watch(userBookmarksStreamProvider).valueOrNull ?? [];
  return bookmarks.any((b) => b.topicId == topicId);
});
