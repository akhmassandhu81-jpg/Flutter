import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/data/repositories/user_repository.dart';
import 'package:learning_plateform/models/user_model.dart';

// ── Raw Firebase auth stream ───────────────────────────────────────────────
final firebaseAuthStateProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

// ── Convenience: current UID (null when signed out) ────────────────────────
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(firebaseAuthStateProvider).valueOrNull?.uid;
});

// ── User profile stream — ALWAYS emits a non-null UserModel ───────────────
//
// Old bug: when the Firestore document hadn't been written yet (signup race)
// this returned Stream.empty() → homeStateProvider watched it via valueOrNull
// → got null → returned Stream.empty() itself → stuck in AsyncLoading forever.
//
// Fix:
//   • StreamProvider<UserModel> (not UserModel?) — always has a value.
//   • When user is null (logged out) → emit a sentinel empty model.
//   • When user is non-null → delegate to UserRepository.userStream() which
//     also guarantees a non-null emission (returns a fallback if doc missing).
final userProfileProvider = StreamProvider<UserModel>((ref) {
  final authState = ref.watch(firebaseAuthStateProvider);

  return authState.when(
    // Auth still initialising — emit an empty sentinel; UI shows loading
    loading: () => Stream.value(UserModel.newStudent(uid: '', fullName: '', email: '')),

    // Auth error — emit sentinel so downstream can show an error state
    error: (_, __) => Stream.value(UserModel.newStudent(uid: '', fullName: '', email: '')),

    data: (user) {
      if (user == null) {
        // Signed out — emit sentinel
        return Stream.value(UserModel.newStudent(uid: '', fullName: '', email: ''));
      }
      // Signed in — stream the real Firestore document (never null per repo contract)
      return UserRepository.instance.userStream(user.uid);
    },
  );
});
