import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/data/models/subject_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';
import 'package:learning_plateform/data/repositories/progress_repository.dart';
import 'package:learning_plateform/models/user_model.dart';
import 'package:learning_plateform/providers/auth_providers.dart';

class SubjectsState {
  final UserModel user;
  final List<SubjectModel> subjects;
  final List<SubjectProgressModel> subjectProgress;

  const SubjectsState({
    required this.user,
    required this.subjects,
    required this.subjectProgress,
  });

  bool get hasSelectedSubjects => user.hasSelectedSubjects && subjects.isNotEmpty;

  SubjectProgressModel progressFor(String subjectId, String subjectName) {
    return subjectProgress.firstWhere(
      (p) => p.subjectId == subjectId,
      orElse: () => SubjectProgressModel.notStarted(subjectId, subjectName),
    );
  }

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
}

class SubjectsNotifier extends AsyncNotifier<SubjectsState> {
  StreamSubscription<List<SubjectProgressModel>>? _subPrgSub;
  List<SubjectProgressModel> _subjectProgress = [];

  @override
  Future<SubjectsState> build() async {
    _subPrgSub?.cancel();
    _subPrgSub = null;

    final userModel = await ref.watch(userProfileProvider.future);

    if (userModel.uid.isEmpty) {
      return SubjectsState(
        user:            userModel,
        subjects:        const [],
        subjectProgress: const [],
      );
    }

    final uid = userModel.uid;

    List<SubjectModel> resolvedSubjects = [];
    if (userModel.hasSelectedSubjects) {
      resolvedSubjects = SubjectModel.fromSelectedIds(userModel.selectedSubjectIds);
    }

    _subjectProgress = [];

    // Subscribe to per-subject progress stream from Realtime Database
    _subPrgSub = ProgressRepository.instance
        .subjectProgressStream(uid)
        .listen((list) {
          _subjectProgress = list;
          state = AsyncData(SubjectsState(
            user:            userModel,
            subjects:        resolvedSubjects,
            subjectProgress: _subjectProgress,
          ));
        }, onError: (_) {});

    ref.onDispose(() {
      _subPrgSub?.cancel();
      _subPrgSub = null;
    });

    return SubjectsState(
      user:            userModel,
      subjects:        resolvedSubjects,
      subjectProgress: _subjectProgress,
    );
  }
}

final subjectsStateProvider =
    AsyncNotifierProvider<SubjectsNotifier, SubjectsState>(SubjectsNotifier.new);
