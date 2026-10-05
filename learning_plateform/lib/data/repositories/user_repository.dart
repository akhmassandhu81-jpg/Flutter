import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_plateform/models/user_model.dart';

/// All Firebase Realtime Database operations for users/{uid}.
///
/// Contract: [userStream] NEVER emits null — missing doc → safe fallback.
class UserRepository {
  UserRepository._();
  static final UserRepository instance = UserRepository._();

  final _db = FirebaseDatabase.instance;
  DatabaseReference _ref(String uid) => _db.ref('users/$uid');

  // ── Real-time stream — never null ─────────────────────────────────────────
  Stream<UserModel> userStream(String uid) {
    return _ref(uid).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        debugPrint('[UserRepo] node missing for $uid — fallback');
        return UserModel.newStudent(uid: uid, fullName: '', email: '');
      }
      try {
        return UserModel.fromMap(Map<dynamic, dynamic>.from(data as Map));
      } catch (e) {
        debugPrint('[UserRepo] parse error: $e');
        return UserModel.newStudent(uid: uid, fullName: '', email: '');
      }
    }).handleError((e) {
      debugPrint('[UserRepo] stream error: $e');
      return UserModel.newStudent(uid: uid, fullName: '', email: '');
    });
  }

  // ── One-shot read ─────────────────────────────────────────────────────────
  Future<UserModel?> getUser(String uid) async {
    try {
      final snap = await _ref(uid).get();
      if (!snap.exists || snap.value == null) return null;
      return UserModel.fromMap(Map<dynamic, dynamic>.from(snap.value as Map));
    } catch (e) {
      debugPrint('[UserRepo] getUser error: $e');
      return null;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────
  Future<void> createUser(UserModel user) async {
    debugPrint('[UserRepo] writing users/${user.uid}');
    try {
      await _ref(user.uid).set(user.toMap());
      debugPrint('[UserRepo] write SUCCESS');
    } catch (e) {
      debugPrint('[UserRepo] write FAILED: $e');
      rethrow;
    }
  }

  // ── Partial update ────────────────────────────────────────────────────────
  Future<void> updateUser(String uid, Map<String, dynamic> fields) async {
    try {
      await _ref(uid).update({
        ...fields,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('[UserRepo] updated users/$uid: ${fields.keys}');
    } catch (e) {
      debugPrint('[UserRepo] updateUser error: $e');
      rethrow;
    }
  }

  // ── Save onboarding data ──────────────────────────────────────────────────
  /// Atomically writes classLevel, curriculum, selectedSubjects and sets
  /// onboardingCompleted = true.  Called from SubjectSelectionScreen on
  /// "Start Learning".
  ///
  /// Fields written:
  ///   classLevel            String
  ///   curriculum            String
  ///   selectedSubjects      Map of subjectId -> true
  ///   onboardingCompleted   true
  ///   updatedAt             int millis
  Future<void> updateOnboarding({
    required String uid,
    required String classLevel,
    required String curriculum,
    required Map<String, bool> selectedSubjects,
  }) async {
    debugPrint('[UserRepo] saving onboarding for $uid');
    try {
      await _ref(uid).update({
        'classLevel':          classLevel,
        'curriculum':          curriculum,
        'selectedSubjects':    selectedSubjects,
        'onboardingCompleted': true,
        'updatedAt':           DateTime.now().millisecondsSinceEpoch,
      });
      debugPrint('[UserRepo] onboarding saved — onboardingCompleted=true');
    } catch (e) {
      debugPrint('[UserRepo] updateOnboarding FAILED: $e');
      rethrow;
    }
  }
}
