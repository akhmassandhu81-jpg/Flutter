import 'package:learning_plateform/data/models/continue_learning_model.dart';
import 'package:learning_plateform/data/models/progress_model.dart';
import 'package:learning_plateform/data/models/subject_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';
import 'package:learning_plateform/models/user_model.dart';

/// All data required to render the Home Screen.
/// A single Riverpod AsyncNotifier produces this object.
class HomeState {
  final UserModel user;
  final ProgressModel progress;
  final List<SubjectModel> subjects;
  final List<SubjectProgressModel> subjectProgress;
  final ContinueLearningModel? continueLearning; // null → new student

  const HomeState({
    required this.user,
    required this.progress,
    required this.subjects,
    required this.subjectProgress,
    this.continueLearning,
  });

  bool get isNewStudent => progress.isNewStudent;

  /// Returns progress for a given subjectId, or a not-started placeholder.
  SubjectProgressModel progressFor(String subjectId, String subjectName) {
    return subjectProgress.firstWhere(
      (p) => p.subjectId == subjectId,
      orElse: () => SubjectProgressModel.notStarted(subjectId, subjectName),
    );
  }
}
