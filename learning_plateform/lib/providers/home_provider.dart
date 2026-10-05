import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learning_plateform/data/models/continue_learning_model.dart';
import 'package:learning_plateform/data/models/home_state.dart';
import 'package:learning_plateform/data/models/progress_model.dart';
import 'package:learning_plateform/data/models/subject_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';
import 'package:learning_plateform/data/repositories/progress_repository.dart';
import 'package:learning_plateform/data/repositories/subject_repository.dart';
import 'package:learning_plateform/models/user_model.dart';
import 'package:learning_plateform/providers/auth_providers.dart';

// ── Bottom navigation ──────────────────────────────────────────────────────
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

// ══════════════════════════════════════════════════════════════════════════════
// Home state — AsyncNotifier approach
//
// Root cause of the old infinite-loading bug:
//   homeStateProvider was a StreamProvider that called Stream.value() inside
//   its builder.  Every time any watched provider changed it created a brand-new
//   Stream, causing Riverpod to mark the provider as "loading" again, which
//   re-triggered watchers, which triggered another rebuild — an infinite loop.
//
// Fix:
//   Use an AsyncNotifier.  It fetches once per UID, subscribes to the three
//   required Firestore streams via listen(), updates state reactively, and
//   cancels subscriptions when the UID changes or the notifier is disposed.
// ══════════════════════════════════════════════════════════════════════════════

class HomeNotifier extends AsyncNotifier<HomeState> {
  StreamSubscription<ProgressModel>?              _progressSub;
  StreamSubscription<List<SubjectProgressModel>>? _subPrgSub;
  StreamSubscription<ContinueLearningModel?>?     _clSub;
  StreamSubscription<List<SubjectModel>>?         _subjectsSub;

  ProgressModel              _progress         = ProgressModel.empty('');
  List<SubjectProgressModel> _subjectProgress  = [];
  ContinueLearningModel?     _continueLearning;
  List<SubjectModel>         _subjects         = [];

  @override
  Future<HomeState> build() async {
    // Cancel any previous subscriptions when the notifier rebuilds (e.g. UID changed)
    _cancelAll();

    // Wait for a real user profile (never null — UserRepository guarantees this)
    final userModel = await ref.watch(userProfileProvider.future);

    // If profile has an empty uid the user is not yet authenticated — surface
    // the empty state immediately rather than spinning.
    if (userModel.uid.isEmpty) {
      return HomeState(
        user:             userModel,
        progress:         ProgressModel.empty(''),
        subjects:         SubjectModel.defaultSubjects(''),
        subjectProgress:  [],
        continueLearning: null,
      );
    }

    final uid        = userModel.uid;
    final classLevel = (userModel.classLevel == null || userModel.classLevel!.isEmpty || userModel.classLevel == 'class_6')
        ? 'class6'
        : userModel.classLevel!;

    // Resolve subjects from the student's own selection (set during onboarding).
    // Falls back to the default 4-subject list for accounts that pre-date
    // the onboarding feature.
    final resolvedFromSelection =
        SubjectModel.fromSelectedIds(userModel.selectedSubjectIds);

    // Prime with defaults so the first emission never waits for all streams
    _progress        = ProgressModel.empty(uid);
    _subjectProgress = [];
    _subjects        = resolvedFromSelection;

    // Subscribe to progress summary
    _progressSub = ProgressRepository.instance
        .progressStream(uid)
        .listen((p) { _progress = p; _emit(userModel); },
                onError: (_) {});

    // Subscribe to per-subject progress
    _subPrgSub = ProgressRepository.instance
        .subjectProgressStream(uid)
        .listen((list) { _subjectProgress = list; _emit(userModel); },
                onError: (_) {});

    // Subscribe to continue-learning
    _clSub = ProgressRepository.instance
        .continueLearningStream(uid)
        .listen((cl) { _continueLearning = cl; _emit(userModel); },
                onError: (_) {});

    // Subscribe to subjects catalogue from Firestore (will override the
    // selection-based list only when matching entries for the user's selection exist).
    _subjectsSub = SubjectRepository.instance
        .subjectsStream(classLevel)
        .listen((list) {
          if (list.isNotEmpty && userModel.hasSelectedSubjects) {
            final ids = userModel.selectedSubjectIds;
            final filtered = list.where((s) => ids.contains(s.id)).toList();
            if (filtered.isNotEmpty) {
              _subjects = filtered;
            }
          } else if (list.isNotEmpty && !userModel.hasSelectedSubjects) {
            _subjects = list;
          }
          _emit(userModel);
        },
        onError: (_) {});

    // Register cleanup
    ref.onDispose(_cancelAll);

    // Return the initial state immediately — streams will update it
    return HomeState(
      user:             userModel,
      progress:         _progress,
      subjects:         _subjects,
      subjectProgress:  _subjectProgress,
      continueLearning: _continueLearning,
    );
  }

  void _emit(UserModel userModel) {
    state = AsyncData(HomeState(
      user:             userModel,
      progress:         _progress,
      subjects:         _subjects,
      subjectProgress:  _subjectProgress,
      continueLearning: _continueLearning,
    ));
  }

  void _cancelAll() {
    _progressSub?.cancel();
    _subPrgSub?.cancel();
    _clSub?.cancel();
    _subjectsSub?.cancel();
    _progressSub = _subPrgSub = _clSub = _subjectsSub = null;
  }
}

final homeStateProvider =
    AsyncNotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
