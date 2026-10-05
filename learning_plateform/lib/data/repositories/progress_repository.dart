import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_plateform/data/models/continue_learning_model.dart';
import 'package:learning_plateform/data/models/progress_model.dart';
import 'package:learning_plateform/data/models/subject_progress_model.dart';

/// Reads learning progress from Firebase Realtime Database.
///
/// Paths:
///   users/{uid}/progress/summary            → ProgressModel
///   users/{uid}/subjectProgress             → List of SubjectProgressModel
///   users/{uid}/recentLearning/last         → ContinueLearningModel?
///
/// All streams always emit (never hang). Missing nodes → safe empty defaults.
class ProgressRepository {
  ProgressRepository._();
  static final ProgressRepository instance = ProgressRepository._();

  final _db = FirebaseDatabase.instance;

  // ── Overall progress summary ──────────────────────────────────────────────
  Stream<ProgressModel> progressStream(String uid) {
    if (uid.isEmpty) return Stream.value(ProgressModel.empty(uid));
    return _db.ref('users/$uid/progress/summary').onValue.map<ProgressModel>((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) {
        return ProgressModel.empty(uid);
      }
      try {
        return ProgressModel.fromMap(uid, Map<dynamic, dynamic>.from(val));
      } catch (e) {
        debugPrint('[ProgressRepo] summary parse: $e');
        return ProgressModel.empty(uid);
      }
    }).handleError((e) {
      debugPrint('[ProgressRepo] summary stream error: $e');
      return ProgressModel.empty(uid);
    });
  }

  // ── Per-subject progress ──────────────────────────────────────────────────
  Stream<List<SubjectProgressModel>> subjectProgressStream(String uid) {
    if (uid.isEmpty) return Stream.value(<SubjectProgressModel>[]);
    return _db.ref('users/$uid/subjectProgress').onValue.map<List<SubjectProgressModel>>((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) return <SubjectProgressModel>[];
      try {
        final list = <SubjectProgressModel>[];
        val.forEach((k, v) {
          if (v is Map) {
            list.add(SubjectProgressModel.fromMap(Map<dynamic, dynamic>.from(v)));
          }
        });
        return list;
      } catch (e) {
        debugPrint('[ProgressRepo] subjectProgress parse: $e');
        return <SubjectProgressModel>[];
      }
    }).handleError((e) {
      debugPrint('[ProgressRepo] subjectProgress stream error: $e');
      return <SubjectProgressModel>[];
    });
  }

  // ── Continue learning ─────────────────────────────────────────────────────
  Stream<ContinueLearningModel?> continueLearningStream(String uid) {
    if (uid.isEmpty) return Stream.value(null);
    return _db.ref('users/$uid/recentLearning/last').onValue.map<ContinueLearningModel?>((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) return null;
      try {
        return ContinueLearningModel.fromMap(Map<dynamic, dynamic>.from(val));
      } catch (e) {
        debugPrint('[ProgressRepo] continueLearning parse: $e');
        return null;
      }
    }).handleError((e) {
      debugPrint('[ProgressRepo] continueLearning stream error: $e');
      return null;
    });
  }
}
