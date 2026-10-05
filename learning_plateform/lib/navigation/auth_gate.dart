import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/features/onboarding/screens/class_selection_screen.dart';
import 'package:learning_plateform/navigation/main_shell.dart';
import 'package:learning_plateform/providers/auth_providers.dart';
import 'package:learning_plateform/screens/login_screen.dart';

/// Central routing gate.
///
/// Decision tree:
///   Auth loading          → subtle spinner
///   Not authenticated     → LoginScreen
///   Authenticated +
///     profile loading     → subtle spinner  (userProfile still AsyncLoading)
///     onboardingCompleted → MainShell
///     !onboardingCompleted→ ClassSelectionScreen (start of onboarding)
///
/// Using [userProfileProvider] here means the gate reacts immediately when
/// the RTDB document changes (e.g. onboardingCompleted flips to true after
/// the student completes onboarding) — no manual navigation needed from
/// SubjectSelectionScreen; AuthGate will re-render to MainShell on its own.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync    = ref.watch(firebaseAuthStateProvider);
    final profileAsync = ref.watch(userProfileProvider);

    // ── Not yet resolved ─────────────────────────────────────────────────────
    final authLoading    = authAsync.isLoading;
    final profileLoading = profileAsync.isLoading;

    if (authLoading || profileLoading) {
      return const _LoadingScreen();
    }

    // ── Auth error or explicit sign-out ───────────────────────────────────────
    final firebaseUser = authAsync.valueOrNull;
    if (firebaseUser == null) {
      return const LoginScreen();
    }

    // ── Authenticated — check onboarding ─────────────────────────────────────
    final profile = profileAsync.valueOrNull;

    if (profile == null || profile.uid.isEmpty) {
      // Profile stream hasn't emitted a real document yet — keep spinner brief
      return const _LoadingScreen();
    }

    if (profile.onboardingCompleted) {
      return const MainShell();
    }

    // Profile exists but onboarding not done → start onboarding
    return const ClassSelectionScreen();
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.accentCyan,
            strokeWidth: 2,
          ),
        ),
      );
}
