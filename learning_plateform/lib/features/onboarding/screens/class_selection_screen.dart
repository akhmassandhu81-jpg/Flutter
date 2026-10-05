import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/core/theme/app_colors.dart';
import 'package:learning_plateform/core/theme/app_text_styles.dart';
import 'package:learning_plateform/features/onboarding/providers/onboarding_provider.dart';
import 'package:learning_plateform/features/onboarding/screens/curriculum_selection_screen.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_onboarding_scaffold.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_primary_button.dart';
import 'package:learning_plateform/features/onboarding/widgets/lms_selection_card.dart';

/// Step 1 of 3 — student selects their class (6–12).
class ClassSelectionScreen extends ConsumerWidget {
  const ClassSelectionScreen({super.key});

  static const _classes = [
    _ClassOption('class6',  'Class 6',  '11 – 12 years'),
    _ClassOption('class7',  'Class 7',  '12 – 13 years'),
    _ClassOption('class8',  'Class 8',  '13 – 14 years'),
    _ClassOption('class9',  'Class 9',  '14 – 15 years'),
    _ClassOption('class10', 'Class 10', '15 – 16 years'),
    _ClassOption('class11', 'Class 11', '16 – 17 years'),
    _ClassOption('class12', 'Class 12', '17 – 18 years'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return LMSOnboardingScaffold(
      title:        'Choose Your Class',
      subtitle:     'Select your current class to personalise your learning experience.',
      stepCurrent:  1,
      stepTotal:    3,
      showBack:     false, // first step — nowhere to go back
      content: Column(
        children: _classes.map((c) {
          final selected = state.selectedClass == c.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LMSSelectionCard(
              title:      c.label,
              subtitle:   c.ageRange,
              isSelected: selected,
              onTap:      () => notifier.selectClass(c.id),
              leading:    _ClassBadge(label: c.label.split(' ').last),
            ),
          );
        }).toList(),
      ),
      bottomAction: LMSPrimaryButton(
        label:        'Continue',
        trailingIcon: Icons.arrow_forward,
        onTap: state.hasClass
            ? () => Navigator.of(context).push(
                  _fade(const CurriculumSelectionScreen()),
                )
            : null,
      ),
    );
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────
class _ClassOption {
  final String id;
  final String label;
  final String ageRange;
  const _ClassOption(this.id, this.label, this.ageRange);
}

class _ClassBadge extends StatelessWidget {
  final String label;
  const _ClassBadge({required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.accentBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.25)),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.accentBlue,
            fontSize: 15,
          ),
        ),
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
