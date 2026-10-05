import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_plateform/data/repositories/user_repository.dart';
import 'package:learning_plateform/models/user_model.dart';

/// Result wrapper — carries a value or a user-friendly error string.
/// Firebase exception codes are mapped here; raw codes never reach the UI.
class AuthResult<T> {
  final T? data;
  final String? errorMessage;

  const AuthResult.success(this.data) : errorMessage = null;
  const AuthResult.failure(this.errorMessage) : data = null;

  bool get isSuccess => errorMessage == null;
}

/// Thin authentication layer.
///
/// Responsibilities:
///   - Firebase Auth operations (register / login / logout / password reset)
///   - Writing / recovering the user profile in Realtime Database
///     via [UserRepository] — never direct DB calls here.
///
/// Password is NEVER stored in RTDB.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _repo = UserRepository.instance;

  User?           get currentUser     => _auth.currentUser;
  Stream<User?>   get authStateChanges => _auth.authStateChanges();

  // ── REGISTER ──────────────────────────────────────────────────────────────
  Future<AuthResult<UserModel>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName     = fullName.trim();

    try {
      // ── Step 1: Firebase Authentication ───────────────────────────────────
      debugPrint('[AUTH] Creating Firebase Auth account for $normalizedEmail');
      final cred = await _auth.createUserWithEmailAndPassword(
        email:    normalizedEmail,
        password: password,
      );
      final fbUser = cred.user!;
      debugPrint('[AUTH] Account created — UID: ${fbUser.uid}');

      // ── Step 2: Build model (NO password stored) ───────────────────────────
      final model = UserModel.newStudent(
        uid:      fbUser.uid,
        fullName: trimmedName,
        email:    normalizedEmail,
      );

      // ── Step 3: Write to Realtime Database ────────────────────────────────
      debugPrint('[DB] Writing profile to RTDB: users/${fbUser.uid}');
      try {
        await _repo.createUser(model);
        debugPrint('[DB] Profile written successfully');
      } catch (dbError) {
        // DB write failed → delete the Auth account so user can retry cleanly
        debugPrint('[DB] Write FAILED: $dbError — rolling back Auth account');
        try { await fbUser.delete(); } catch (_) {}
        return const AuthResult.failure(
          'Your account was created, but we couldn\'t save your profile.\n'
          'Please try again.',
        );
      }

      // ── Step 4: Update Auth display name (best-effort, non-blocking) ──────
      try { await fbUser.updateDisplayName(trimmedName); } catch (_) {}

      return AuthResult.success(model);

    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH] FirebaseAuthException: ${e.code}');
      return AuthResult.failure(_mapError(e.code));
    } catch (e) {
      debugPrint('[AUTH] Unexpected register error: $e');
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  // ── LOGIN ─────────────────────────────────────────────────────────────────
  Future<AuthResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      debugPrint('[AUTH] Signing in: $normalizedEmail');
      final cred = await _auth.signInWithEmailAndPassword(
        email:    normalizedEmail,
        password: password,
      );
      final fbUser = cred.user!;
      debugPrint('[AUTH] Sign-in OK — UID: ${fbUser.uid}');

      // Load profile from RTDB; auto-recover if missing (e.g. old account)
      UserModel? model = await _repo.getUser(fbUser.uid);
      if (model == null) {
        debugPrint('[DB] Profile missing — creating recovery doc');
        final recovered = UserModel.newStudent(
          uid:      fbUser.uid,
          fullName: fbUser.displayName ?? '',
          email:    normalizedEmail,
        );
        await _repo.createUser(recovered);
        model = recovered;
      }
      return AuthResult.success(model);

    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (e) {
      debugPrint('[AUTH] Unexpected login error: $e');
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  // ── LOGOUT ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    debugPrint('[AUTH] Signing out');
    await _auth.signOut();
  }

  // ── PASSWORD RESET ────────────────────────────────────────────────────────
  Future<AuthResult<void>> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim().toLowerCase());
      return const AuthResult.success(null);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_mapError(e.code));
    } catch (e) {
      return const AuthResult.failure('Something went wrong. Please try again.');
    }
  }

  // ── Error mapper — Firebase codes → friendly strings ──────────────────────
  static String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.\nPlease sign in instead.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Your password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Unable to connect. Please check your internet connection.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
