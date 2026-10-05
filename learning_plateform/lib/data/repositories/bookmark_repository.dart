import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_plateform/data/models/bookmark_model.dart';

/// Reads and writes user bookmarks to Firebase Realtime Database at:
/// users/{uid}/bookmarks/{topicId}
class BookmarkRepository {
  BookmarkRepository._();
  static final BookmarkRepository instance = BookmarkRepository._();

  final _db = FirebaseDatabase.instance;

  DatabaseReference _bookmarksRef(String uid) => _db.ref('users/$uid/bookmarks');

  // ── Stream User Bookmarks ──────────────────────────────────────────────────
  Stream<List<BookmarkModel>> bookmarksStream(String uid) {
    if (uid.isEmpty) return Stream.value([]);

    return _bookmarksRef(uid).onValue.map<List<BookmarkModel>>((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) return [];
      try {
        final list = <BookmarkModel>[];
        val.forEach((k, v) {
          if (v is Map) {
            list.add(BookmarkModel.fromMap(Map<dynamic, dynamic>.from(v)));
          }
        });
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      } catch (e) {
        debugPrint('[BookmarkRepo] parse error: $e');
        return [];
      }
    }).handleError((e) {
      debugPrint('[BookmarkRepo] stream error: $e');
      return <BookmarkModel>[];
    });
  }

  // ── Add Bookmark ──────────────────────────────────────────────────────────
  Future<void> addBookmark(String uid, BookmarkModel bookmark) async {
    if (uid.isEmpty) return;
    try {
      await _bookmarksRef(uid).child(bookmark.topicId).set(bookmark.toMap());
      debugPrint('[BookmarkRepo] Added bookmark for topic: ${bookmark.topicId}');
    } catch (e) {
      debugPrint('[BookmarkRepo] addBookmark error: $e');
      rethrow;
    }
  }

  // ── Remove Bookmark ───────────────────────────────────────────────────────
  Future<void> removeBookmark(String uid, String topicId) async {
    if (uid.isEmpty) return;
    try {
      await _bookmarksRef(uid).child(topicId).remove();
      debugPrint('[BookmarkRepo] Removed bookmark for topic: $topicId');
    } catch (e) {
      debugPrint('[BookmarkRepo] removeBookmark error: $e');
      rethrow;
    }
  }

  // ── Toggle Bookmark ───────────────────────────────────────────────────────
  Future<bool> toggleBookmark(String uid, BookmarkModel bookmark) async {
    if (uid.isEmpty) return false;
    try {
      final snap = await _bookmarksRef(uid).child(bookmark.topicId).get();
      if (snap.exists && snap.value != null) {
        await removeBookmark(uid, bookmark.topicId);
        return false; // Now unbookmarked
      } else {
        await addBookmark(uid, bookmark);
        return true; // Now bookmarked
      }
    } catch (e) {
      debugPrint('[BookmarkRepo] toggleBookmark error: $e');
      return false;
    }
  }
}
