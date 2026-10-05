import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/data/repositories/user_repository.dart';
import 'package:learning_plateform/features/onboarding/providers/onboarding_provider.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_onboarding_scaffold.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_primary_button.dart';
import 'package:learning_plateform/navigation/auth_gate.dart';
import 'package:learning_plateform/providers/auth_providers.dart';

/// Step 3 of 3 — student picks their subjects.
///
/// On "Start Learning":
///   1. Validate at least one subject selected
///   2. Show loading state
///   3. Await UserRepository.updateOnboarding() → writes to RTDB
///   4. On success: AuthGate auto-routes to MainShell because
///      userProfileProvider will emit the updated profile with
///      onboardingCompleted = true.
///      We also do an explicit pushAndRemoveUntil to AuthGate to be safe.
///   5. On failure: show inline error, keep onboardingCompleted = false
class SubjectSelectionScreen extends ConsumerWidget {
  const SubjectSelectionScreen({super.key});

  // ── Subject catalogue ─────────────────────────────────────────────────────
  // Designed so subjects can later come from Firebase; for now they are
  // defined here as a static list.  The id keys match Realtime Database paths.
  static const _allSubjects = [
    _SubjectOption(
      id: 'mathematics', label: 'Mathematics',
      desc: 'Algebra, Geometry, Calculus & more',
      iconLabel: 'Σ',
      bgColor: AppColors.mathColor,
      fgColor: AppColors.accentBlue,
    ),
    _SubjectOption(
      id: 'physics', label: 'Physics',
      desc: 'Mechanics, Waves, Electricity & more',
      iconLabel: '⚛',
      bgColor: AppColors.physicsColor,
      fgColor: AppColors.accentCyan,
    ),
    _SubjectOption(
      id: 'chemistry', label: 'Chemistry',
      desc: 'Organic, Inorganic & Physical chemistry',
      iconLabel: '⚗',
      bgColor: AppColors.chemColor,
      fgColor: AppColors.accentGreen,
    ),
    _SubjectOption(
      id: 'biology', label: 'Biology',
      desc: 'Cells, Genetics, Ecology & more',
      iconLabel: '🧬',
      bgColor: AppColors.bioColor,
      fgColor: AppColors.accentGreen,
    ),
    _SubjectOption(
      id: 'computer_science', label: 'Computer Science',
      desc: 'Programming, Algorithms & ICT',
      iconLabel: '</>',
      bgColor: AppColors.csColor,
      fgColor: AppColors.accentPurple,
    ),
    _SubjectOption(
      id: 'english', label: 'English',
      desc: 'Language, Literature & Composition',
      iconLabel: 'En',
      bgColor: AppColors.engColor,
      fgColor: AppColors.accentOrange,
    ),
    _SubjectOption(
      id: 'urdu', label: 'Urdu',
      desc: 'Grammar, Literature & Composition',
      iconLabel: 'اُ',
      bgColor: AppColors.urduColor,
      fgColor: AppColors.accentOrange,
    ),
    _SubjectOption(
      id: 'islamiat', label: 'Islamiat',
      desc: 'Islamic Studies & Quran',
      iconLabel: '☪',
      bgColor: AppColors.islamColor,
      fgColor: AppColors.accentGreen,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return LMSOnboardingScaffold(
      title:       'Choose Your Subjects',
      subtitle:    'Select the subjects you want to learn. Pick at least one.',
      stepCurrent: 3,
      stepTotal:   3,
      showBack:    true,
      content: Column(
        children: [
          // ── 2-column grid of subject cards ──────────────────────────────
          GridView.builder(
            shrinkWrap:  true,
            physics:     const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:   2,
              crossAxisSpacing: 12,
              mainAxisSpacing:  12,
              childAspectRatio: 1.15,
            ),
            itemCount:   _allSubjects.length,
            itemBuilder: (ctx, i) {
              final s        = _allSubjects[i];
              final selected = state.selectedSubjects[s.id] == true;
              return _SubjectCard(
                subject:    s,
                isSelected: selected,
                onTap: () => notifier.toggleSubject(s.id, !selected),
              );
            },
          ),

          const SizedBox(height: 12),

          // ── Error message ────────────────────────────────────────────────
          if (state.saveError != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      state.saveError!,
                      style: AppTextStyles.body3
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
      bottomAction: LMSPrimaryButton(
        label:       'Start Learning',
        trailingIcon: Icons.rocket_launch_outlined,
        isLoading:   state.isSaving,
        onTap: state.hasSubjects && !state.isSaving
            ? () => _save(context, ref)
            : null,
      ),
    );
  }

  // ── Save handler ───────────────────────────────────────────────────────────
  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(onboardingProvider.notifier);
    final state    = ref.read(onboardingProvider);
    final uid      = ref.read(currentUidProvider);

    if (uid == null) {
      notifier.setSaveError('You are not signed in. Please restart the app.');
      return;
    }

    if (!state.hasClass) {
      notifier.setSaveError('Class not selected. Please go back.');
      return;
    }
    if (!state.hasCurriculum) {
      notifier.setSaveError('Curriculum not selected. Please go back.');
      return;
    }
    if (!state.hasSubjects) {
      notifier.setSaveError('Please select at least one subject.');
      return;
    }

    notifier.setSaving(true);

    try {
      await UserRepository.instance.updateOnboarding(
        uid:              uid,
        classLevel:       state.selectedClass!,
        curriculum:       state.selectedCurriculum!,
        selectedSubjects: state.selectedSubjects,
      );

      // Clear temporary onboarding state
      notifier.reset();

      // Navigate — AuthGate will re-render to MainShell automatically once
      // userProfileProvider emits the updated profile (onboardingCompleted=true).
      // We also do an explicit replacement for reliability.
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder:        (_, __, ___) => const AuthGate(),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      notifier.setSaveError(
        'Unable to save your selections. Please check your connection and try again.',
      );
    }
  }
}

// ── Subject card ──────────────────────────────────────────────────────────────
class _SubjectCard extends StatelessWidget {
  final _SubjectOption subject;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubjectCard({
    required this.subject,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentBlue.withValues(alpha: 0.10)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.accentBlue : AppColors.borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.15),
                    blurRadius: 12,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Subject icon
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: subject.bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      subject.iconLabel,
                      style: TextStyle(
                        color:      subject.fgColor,
                        fontSize:   subject.iconLabel.length > 2 ? 11 : 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                // Check
                if (isSelected)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check,
                        color: Colors.white, size: 12),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              subject.label,
              style: AppTextStyles.heading3.copyWith(
                fontSize: 14,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              subject.desc,
              style: AppTextStyles.body3.copyWith(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _SubjectOption {
  final String id;
  final String label;
  final String desc;
  final String iconLabel;
  final Color  bgColor;
  final Color  fgColor;
  const _SubjectOption({
    required this.id,
    required this.label,
    required this.desc,
    required this.iconLabel,
    required this.bgColor,
    required this.fgColor,
  });
}
