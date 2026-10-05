import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/student_learning_progress_model.dart';
import 'package:learning_plateform/data/models/progress_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';
import 'package:learning_plateform/data/repositories/curriculum_repository.dart';
import 'package:learning_plateform/data/repositories/progress_repository.dart';
import 'package:learning_plateform/models/user_model.dart';
import 'package:learning_plateform/providers/auth_providers.dart';

class ProgressDetailsState {
  final UserModel user;
  final ProgressModel summary;
  final List<SubjectProgressModel> subjectProgressList;
  final List<ChapterModel> chapters;
  final StudentSubjectProgressModel detailedSubjectProgress;

  const ProgressDetailsState({
    required this.user,
    required this.summary,
    required this.subjectProgressList,
    required this.chapters,
    required this.detailedSubjectProgress,
  });

  bool get isNewStudent =>
      summary.isNewStudent && detailedSubjectProgress.completedTopics == 0;

  String get classLabel {
    final cl = user.classLevel ?? '';
    const map = {
      'class6':  'Class 6',
      'class7':  'Class 7',
      'class8':  'Class 8',
      'class9':  'Class 9',
      'class10': 'Class 10',
      'class11': 'Class 11',
      'class12': 'Class 12',
    };
    return map[cl] ?? (cl.isNotEmpty ? cl.toUpperCase() : 'Class 6');
  }

  double get practiceAverageScore {
    final topics = detailedSubjectProgress.topicProgress.values;
    final attempted =
        topics.where((t) => t.activityCompleted || t.practiceScore > 0).toList();
    if (attempted.isEmpty) return 0.0;
    double sum = 0.0;
    for (final t in attempted) {
      sum += t.practiceScore;
    }
    return (sum / attempted.length).clamp(0.0, 100.0);
  }

  double get quizAverageScore {
    final topics = detailedSubjectProgress.topicProgress.values;
    final attempted =
        topics.where((t) => t.completed || t.quizScore > 0).toList();
    if (attempted.isEmpty) return summary.quizAccuracy;
    double sum = 0.0;
    for (final t in attempted) {
      sum += t.quizScore;
    }
    return (sum / attempted.length).clamp(0.0, 100.0);
  }

  int get totalAttempts {
    final topics = detailedSubjectProgress.topicProgress.values;
    int count = 0;
    for (final t in topics) {
      count += t.attempts;
    }
    return count;
  }
}

class ProgressDetailsNotifier extends AsyncNotifier<ProgressDetailsState> {
  StreamSubscription<ProgressModel>?              _summarySub;
  StreamSubscription<List<SubjectProgressModel>>? _subjSub;
  StreamSubscription<List<ChapterModel>>?         _chaptersSub;
  StreamSubscription<StudentSubjectProgressModel>? _detSub;

  ProgressModel               _summary               = ProgressModel.empty('');
  List<SubjectProgressModel>  _subjectProgressList  = [];
  List<ChapterModel>          _chapters              = [];
  StudentSubjectProgressModel _detailedSubjectProg   = StudentSubjectProgressModel.empty('computer_science', 'class6');

  @override
  Future<ProgressDetailsState> build() async {
    _cancelAll();

    final userModel = await ref.watch(userProfileProvider.future);

    if (userModel.uid.isEmpty) {
      return ProgressDetailsState(
        user:                   userModel,
        summary:                ProgressModel.empty(''),
        subjectProgressList:    const [],
        chapters:               const [],
        detailedSubjectProgress: StudentSubjectProgressModel.empty('computer_science', 'class6'),
      );
    }

    final uid = userModel.uid;
    final classLevel = (userModel.classLevel == null || userModel.classLevel!.isEmpty || userModel.classLevel == 'class_6')
        ? 'class6'
        : userModel.classLevel!;

    _summary = ProgressModel.empty(uid);
    _subjectProgressList = [];
    _chapters = [];
    _detailedSubjectProg = StudentSubjectProgressModel.empty('computer_science', classLevel);

    // 1. Progress summary stream
    _summarySub = ProgressRepository.instance
        .progressStream(uid)
        .listen((s) {
      _summary = s;
      _emit(userModel);
    }, onError: (_) {});

    // 2. Per-subject progress stream
    _subjSub = ProgressRepository.instance
        .subjectProgressStream(uid)
        .listen((list) {
      _subjectProgressList = list;
      _emit(userModel);
    }, onError: (_) {});

    // 3. Chapters stream
    _chaptersSub = CurriculumRepository.instance
        .chaptersStream(classLevel, 'computer_science')
        .listen((chList) {
      _chapters = chList;
      _emit(userModel);
    }, onError: (_) {});

    // 4. Detailed topic progress stream
    _detSub = CurriculumRepository.instance
        .studentProgressStream(uid, classLevel, 'computer_science')
        .listen((det) {
      _detailedSubjectProg = det;
      _emit(userModel);
    }, onError: (_) {});

    ref.onDispose(_cancelAll);

    return ProgressDetailsState(
      user:                   userModel,
      summary:                _summary,
      subjectProgressList:    _subjectProgressList,
      chapters:               _chapters,
      detailedSubjectProgress: _detailedSubjectProg,
    );
  }

  void _emit(UserModel userModel) {
    state = AsyncData(ProgressDetailsState(
      user:                   userModel,
      summary:                _summary,
      subjectProgressList:    _subjectProgressList,
      chapters:               _chapters,
      detailedSubjectProgress: _detailedSubjectProg,
    ));
  }

  void _cancelAll() {
    _summarySub?.cancel();
    _subjSub?.cancel();
    _chaptersSub?.cancel();
    _detSub?.cancel();
    _summarySub = _subjSub = _chaptersSub = _detSub = null;
  }
}

final progressDetailsStateProvider =
    AsyncNotifierProvider<ProgressDetailsNotifier, ProgressDetailsState>(
        ProgressDetailsNotifier.new);
