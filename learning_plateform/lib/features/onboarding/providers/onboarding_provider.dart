import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Transient in-memory state that accumulates selections across the three
/// onboarding steps (Class → Curriculum → Subjects).
///
/// This is NOT persisted to RTDB until the student taps "Start Learning"
/// on the SubjectSelectionScreen.  At that point SubjectSelectionScreen calls
/// UserRepository.updateOnboarding() and marks onboardingCompleted = true.
///
/// The state is intentionally cleared after successful save so that if the
/// same ProviderScope ever sees a new user it starts fresh.
class OnboardingState {
  final String? selectedClass;
  final String? selectedCurriculum;
  final Map<String, bool> selectedSubjects;
  final bool isSaving;
  final String? saveError;

  const OnboardingState({
    this.selectedClass,
    this.selectedCurriculum,
    this.selectedSubjects = const {},
    this.isSaving = false,
    this.saveError,
  });

  bool get hasClass       => selectedClass       != null && selectedClass!.isNotEmpty;
  bool get hasCurriculum  => selectedCurriculum  != null && selectedCurriculum!.isNotEmpty;
  bool get hasSubjects    => selectedSubjects.values.any((v) => v);

  /// IDs of currently checked subjects.
  List<String> get selectedSubjectIds =>
      selectedSubjects.entries.where((e) => e.value).map((e) => e.key).toList();

  OnboardingState copyWith({
    String?            selectedClass,
    String?            selectedCurriculum,
    Map<String, bool>? selectedSubjects,
    bool?              isSaving,
    String?            saveError,
    bool               clearError = false,
  }) {
    return OnboardingState(
      selectedClass:      selectedClass      ?? this.selectedClass,
      selectedCurriculum: selectedCurriculum ?? this.selectedCurriculum,
      selectedSubjects:   selectedSubjects   ?? this.selectedSubjects,
      isSaving:           isSaving           ?? this.isSaving,
      saveError:          clearError ? null  : (saveError ?? this.saveError),
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void selectClass(String classLevel) {
    state = state.copyWith(selectedClass: classLevel, clearError: true);
  }

  void selectCurriculum(String curriculum) {
    state = state.copyWith(selectedCurriculum: curriculum, clearError: true);
  }

  void toggleSubject(String subjectId, bool selected) {
    final updated = Map<String, bool>.from(state.selectedSubjects);
    updated[subjectId] = selected;
    state = state.copyWith(selectedSubjects: updated, clearError: true);
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving, clearError: saving);
  }

  void setSaveError(String error) {
    state = state.copyWith(isSaving: false, saveError: error);
  }

  void reset() {
    state = const OnboardingState();
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
