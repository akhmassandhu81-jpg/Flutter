import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/features/onboarding/providers/onboarding_provider.dart';
import 'package:learning_plateform/features/onboarding/screens/subject_selection_screen.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_onboarding_scaffold.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_primary_button.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_selection_card.dart';

/// Step 2 of 3 — student selects their curriculum / board.
///
/// The list is data-driven via [_curricula] so adding new options later
/// requires no structural change — just extend the list.
class CurriculumSelectionScreen extends ConsumerWidget {
  const CurriculumSelectionScreen({super.key});

  static const _curricula = [
    _CurriculumOption(
      id:       'punjab',
      label:    'Punjab Curriculum',
      subtitle: 'Punjab Curriculum & Textbook Board (PCTB)',
      icon:     Icons.school_outlined,
    ),
    _CurriculumOption(
      id:       'sindh',
      label:    'Sindh Curriculum',
      subtitle: 'Sindh Textbook Board (STBB)',
      icon:     Icons.school_outlined,
    ),
    _CurriculumOption(
      id:       'federal',
      label:    'Federal Board',
      subtitle: 'Federal Board of Intermediate & Secondary Education',
      icon:     Icons.account_balance_outlined,
    ),
    _CurriculumOption(
      id:       'aga_khan',
      label:    'Aga Khan Board',
      subtitle: 'Aga Khan University Examination Board',
      icon:     Icons.school_outlined,
    ),
    _CurriculumOption(
      id:       'cambridge',
      label:    'Cambridge (O/A Level)',
      subtitle: 'Cambridge Assessment International Education',
      icon:     Icons.public_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state    = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return LMSOnboardingScaffold(
      title:       'Choose Your Curriculum',
      subtitle:    'Select the curriculum or board you follow.',
      stepCurrent: 2,
      stepTotal:   3,
      showBack:    true,
      content: Column(
        children: _curricula.map((c) {
          final selected = state.selectedCurriculum == c.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LMSSelectionCard(
              title:      c.label,
              subtitle:   c.subtitle,
              isSelected: selected,
              onTap:      () => notifier.selectCurriculum(c.id),
              leading:    _CurriculumIcon(icon: c.icon, selected: selected),
            ),
          );
        }).toList(),
      ),
      bottomAction: LMSPrimaryButton(
        label:        'Continue',
        trailingIcon: Icons.arrow_forward,
        onTap: state.hasCurriculum
            ? () => Navigator.of(context).push(_fade(const SubjectSelectionScreen()))
            : null,
      ),
    );
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────
class _CurriculumOption {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  const _CurriculumOption({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
  });
}

class _CurriculumIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  const _CurriculumIcon({required this.icon, required this.selected});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: selected
            ? AppColors.accentBlue.withValues(alpha: 0.15)
            : AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? AppColors.accentBlue.withValues(alpha: 0.3)
              : AppColors.borderColor,
        ),
      ),
      child: Icon(
        icon,
        color: selected ? AppColors.accentBlue : AppColors.textTertiary,
        size: 20,
      ),
    );
  }
}

PageRoute<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder:        (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 280),
    );
