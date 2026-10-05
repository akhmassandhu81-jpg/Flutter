import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/student_learning_progress_model.dart';
import 'package:learning_plateform/data/models/learning/topic_model.dart';
import 'package:learning_plateform/data/repositories/curriculum_repository.dart';
import 'package:learning_plateform/providers/auth_providers.dart';

// ── Streams Chapters for Class 6 CS ──────────────────────────────────────────
final computerScienceChaptersProvider = StreamProvider<List<ChapterModel>>((ref) {
  final user = ref.watch(userProfileProvider).valueOrNull;
  final classLevel = (user?.classLevel == null || user!.classLevel!.isEmpty || user.classLevel == 'class_6')
      ? 'class6'
      : user.classLevel!;
  return CurriculumRepository.instance.chaptersStream(classLevel, 'computer_science');
});

// ── Streams Student Progress for Class 6 CS ──────────────────────────────────
final computerScienceProgressProvider = StreamProvider<StudentSubjectProgressModel>((ref) {
  final uid = ref.watch(currentUidProvider) ?? '';
  final user = ref.watch(userProfileProvider).valueOrNull;
  final classLevel = (user?.classLevel == null || user!.classLevel!.isEmpty || user.classLevel == 'class_6')
      ? 'class6'
      : user.classLevel!;
  return CurriculumRepository.instance.studentProgressStream(uid, classLevel, 'computer_science');
});

// ══════════════════════════════════════════════════════════════════════════════
// Topic Learning Session State & Notifier
// ══════════════════════════════════════════════════════════════════════════════
class TopicLearningState {
  final ChapterModel chapter;
  final TopicModel topic;
  final int currentStep; // 0: Explanation, 1: Visualization, 2: Activity, 3: Practice, 4: Quiz, 5: Result
  final List<String> activityItems;
  final bool activitySubmitted;
  final bool activityIsCorrect;
  final Map<int, int> practiceAnswers;
  final Map<int, int> quizAnswers;
  final bool quizSubmitted;
  final double quizScorePercent;
  final bool isSaving;
  final String? error;

  const TopicLearningState({
    required this.chapter,
    required this.topic,
    this.currentStep = 0,
    this.activityItems = const [],
    this.activitySubmitted = false,
    this.activityIsCorrect = false,
    this.practiceAnswers = const {},
    this.quizAnswers = const {},
    this.quizSubmitted = false,
    this.quizScorePercent = 0.0,
    this.isSaving = false,
    this.error,
  });

  TopicLearningState copyWith({
    int? currentStep,
    List<String>? activityItems,
    bool? activitySubmitted,
    bool? activityIsCorrect,
    Map<int, int>? practiceAnswers,
    Map<int, int>? quizAnswers,
    bool? quizSubmitted,
    double? quizScorePercent,
    bool? isSaving,
    String? error,
  }) {
    return TopicLearningState(
      chapter:           chapter,
      topic:             topic,
      currentStep:       currentStep       ?? this.currentStep,
      activityItems:     activityItems     ?? this.activityItems,
      activitySubmitted: activitySubmitted ?? this.activitySubmitted,
      activityIsCorrect: activityIsCorrect ?? this.activityIsCorrect,
      practiceAnswers:   practiceAnswers   ?? this.practiceAnswers,
      quizAnswers:       quizAnswers       ?? this.quizAnswers,
      quizSubmitted:     quizSubmitted     ?? this.quizSubmitted,
      quizScorePercent:  quizScorePercent  ?? this.quizScorePercent,
      isSaving:          isSaving          ?? this.isSaving,
      error:             error,
    );
  }
}

class TopicLearningNotifier extends StateNotifier<TopicLearningState> {
  final Ref ref;

  TopicLearningNotifier(this.ref, ChapterModel chapter, TopicModel topic)
      : super(TopicLearningState(
          chapter: chapter,
          topic: topic,
          activityItems: List.from(topic.activity.initialItems),
        ));

  void setStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  void reorderActivityItem(int oldIndex, int newIndex) {
    if (state.activitySubmitted) return;
    final items = List<String>.from(state.activityItems);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    state = state.copyWith(activityItems: items);
  }

  void submitActivity() {
    final correct = state.topic.activity.correctOrder;
    bool isCorrect = true;
    if (state.activityItems.length != correct.length) {
      isCorrect = false;
    } else {
      for (int i = 0; i < correct.length; i++) {
        if (state.activityItems[i] != correct[i]) {
          isCorrect = false;
          break;
        }
      }
    }
    state = state.copyWith(
      activitySubmitted: true,
      activityIsCorrect: isCorrect,
    );
  }

  void selectPracticeAnswer(int questionIndex, int optionIndex) {
    final updated = Map<int, int>.from(state.practiceAnswers);
    updated[questionIndex] = optionIndex;
    state = state.copyWith(practiceAnswers: updated);
  }

  void selectQuizAnswer(int questionIndex, int optionIndex) {
    if (state.quizSubmitted) return;
    final updated = Map<int, int>.from(state.quizAnswers);
    updated[questionIndex] = optionIndex;
    state = state.copyWith(quizAnswers: updated);
  }

  void submitQuiz() {
    final questions = state.topic.assessmentQuestions;
    if (questions.isEmpty) {
      state = state.copyWith(
        quizSubmitted: true,
        quizScorePercent: 100.0,
        currentStep: 5,
      );
      return;
    }

    int correctCount = 0;
    for (int i = 0; i < questions.length; i++) {
      final selected = state.quizAnswers[i];
      if (selected == questions[i].correctIndex) {
        correctCount++;
      }
    }

    final percent = (correctCount / questions.length) * 100.0;
    state = state.copyWith(
      quizSubmitted: true,
      quizScorePercent: percent,
      currentStep: 5,
    );
  }

  Future<void> completeTopic(int totalSubjectTopics) async {
    final uid = ref.read(currentUidProvider) ?? '';
    final user = ref.read(userProfileProvider).valueOrNull;
    final classLevel = (user?.classLevel == null || user!.classLevel!.isEmpty || user.classLevel == 'class_6')
        ? 'class6'
        : user.classLevel!;

    state = state.copyWith(isSaving: true);

    await CurriculumRepository.instance.saveTopicProgress(
      uid:                 uid,
      classLevel:          classLevel,
      subjectId:           'computer_science',
      subjectName:         'Computer Science',
      chapterId:           state.chapter.id,
      chapterName:         state.chapter.title,
      topicId:             state.topic.id,
      topicName:           state.topic.title,
      practiceScore:       100.0,
      quizScore:           state.quizScorePercent,
      totalSubjectTopics: totalSubjectTopics,
    );

    state = state.copyWith(isSaving: false);
  }
}

final topicLearningProvider = StateNotifierProvider.family<
    TopicLearningNotifier,
    TopicLearningState,
    (ChapterModel, TopicModel)>((ref, arg) {
  return TopicLearningNotifier(ref, arg.$1, arg.$2);
});
