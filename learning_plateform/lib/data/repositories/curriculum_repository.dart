import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_plateform/data/models/learning/chapter_model.dart';
import 'package:learning_plateform/data/models/learning/class_curriculum_data.dart';
import 'package:learning_plateform/data/models/learning/student_learning_progress_model.dart';

class CurriculumRepository {
  CurriculumRepository._();
  static final CurriculumRepository instance = CurriculumRepository._();

  final _db = FirebaseDatabase.instance;

  DatabaseReference _curriculumRef(String classLevel, String subjectId) =>
      _db.ref('curriculum/$classLevel/$subjectId');

  DatabaseReference _progressRef(String uid, String classLevel, String subjectId) =>
      _db.ref('users/$uid/progress/$classLevel/$subjectId');

  // ── Stream Curriculum Chapters ────────────────────────────────────────────
  Stream<List<ChapterModel>> chaptersStream(String classLevel, String subjectId) {
    final effectiveClass = (classLevel.isEmpty || classLevel == 'class_6') ? 'class6' : classLevel;
    final effectiveSubject = subjectId.isEmpty ? 'computer_science' : subjectId;
    final ref = _curriculumRef(effectiveClass, effectiveSubject);

    return ref.onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) {
        // Auto-seed sample curriculum for this specific class if empty
        _seedSampleCurriculum(effectiveClass, effectiveSubject);
        return _getSampleChapters(effectiveClass);
      }
      try {
        if (val is Map) {
          final chaptersVal = val['chapters'];
          if (chaptersVal is Map) {
            final list = chaptersVal.values
                .whereType<Map>()
                .map((e) => ChapterModel.fromMap(e))
                .toList();
            list.sort((a, b) => a.order.compareTo(b.order));
            return list.isEmpty ? _getSampleChapters(effectiveClass) : list;
          }
        }
        return _getSampleChapters(effectiveClass);
      } catch (e) {
        debugPrint('[CurriculumRepo] parse error: $e');
        return _getSampleChapters(effectiveClass);
      }
    }).handleError((e) {
      debugPrint('[CurriculumRepo] stream error: $e');
      return _getSampleChapters(effectiveClass);
    });
  }

  // ── Stream Student Progress for Subject ───────────────────────────────────
  Stream<StudentSubjectProgressModel> studentProgressStream(
      String uid, String classLevel, String subjectId) {
    if (uid.isEmpty) {
      return Stream.value(
          StudentSubjectProgressModel.empty(subjectId, classLevel));
    }
    final effectiveClass = (classLevel.isEmpty || classLevel == 'class_6') ? 'class6' : classLevel;
    final effectiveSubject = subjectId.isEmpty ? 'computer_science' : subjectId;

    return _progressRef(uid, effectiveClass, effectiveSubject).onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null || val is! Map) {
        return StudentSubjectProgressModel.empty(effectiveSubject, effectiveClass);
      }
      try {
        return StudentSubjectProgressModel.fromMap(val);
      } catch (e) {
        debugPrint('[CurriculumRepo] progress parse error: $e');
        return StudentSubjectProgressModel.empty(effectiveSubject, effectiveClass);
      }
    }).handleError((e) {
      debugPrint('[CurriculumRepo] progress stream error: $e');
      return StudentSubjectProgressModel.empty(effectiveSubject, effectiveClass);
    });
  }

  // ── Save Topic Completion & Sync Overall Progress ─────────────────────────
  Future<void> saveTopicProgress({
    required String uid,
    required String classLevel,
    required String subjectId,
    required String subjectName,
    required String chapterId,
    required String chapterName,
    required String topicId,
    required String topicName,
    required double practiceScore,
    required double quizScore,
    required int totalSubjectTopics,
  }) async {
    if (uid.isEmpty) return;

    final effectiveClass = (classLevel.isEmpty || classLevel == 'class_6') ? 'class6' : classLevel;
    final effectiveSubject = subjectId.isEmpty ? 'computer_science' : subjectId;
    final now = DateTime.now().millisecondsSinceEpoch;

    try {
      final subjectProgRef = _progressRef(uid, effectiveClass, effectiveSubject);
      final snap = await subjectProgRef.get();

      Map<String, dynamic> currentData = {};
      if (snap.exists && snap.value is Map) {
        currentData = Map<String, dynamic>.from(snap.value as Map);
      }

      Map<String, dynamic> topics = {};
      if (currentData['topics'] is Map) {
        topics = Map<String, dynamic>.from(currentData['topics'] as Map);
      }

      final existingTopic = topics[topicId] is Map
          ? Map<String, dynamic>.from(topics[topicId] as Map)
          : {};

      final attempts = ((existingTopic['attempts'] as num?)?.toInt() ?? 0) + 1;

      final updatedTopic = {
        'topicId':           topicId,
        'chapterId':         chapterId,
        'completed':         true,
        'activityCompleted': true,
        'practiceScore':     practiceScore,
        'quizScore':         quizScore,
        'attempts':          attempts,
        'lastAccessed':      now,
      };

      topics[topicId] = updatedTopic;

      int completedCount = 0;
      topics.forEach((_, v) {
        if (v is Map && v['completed'] == true) {
          completedCount++;
        }
      });

      final totalTopics = totalSubjectTopics > 0 ? totalSubjectTopics : 3;
      final progressPercent =
          ((completedCount / totalTopics) * 100).clamp(0.0, 100.0);

      // 1. Save student progress for subject in RTDB
      await subjectProgRef.update({
        'subjectId':       effectiveSubject,
        'classLevel':      effectiveClass,
        'completedTopics': completedCount,
        'totalTopics':     totalTopics,
        'progressPercent': progressPercent,
        'lastChapterId':   chapterId,
        'lastTopicId':     topicId,
        'lastAccessedAt':  now,
        'topics':          topics,
      });

      // 2. Sync to users/{uid}/subjectProgress/{subjectId}
      await _db.ref('users/$uid/subjectProgress/$effectiveSubject').set({
        'subjectId':       effectiveSubject,
        'subjectName':     subjectName,
        'progressPercent': progressPercent,
        'completedTopics': completedCount,
        'totalTopics':     totalTopics,
        'status':          completedCount == totalTopics
            ? 'completed'
            : (completedCount > 0 ? 'in_progress' : 'not_started'),
        'updatedAt':       now,
      });

      // 3. Sync to users/{uid}/recentLearning/last
      await _db.ref('users/$uid/recentLearning/last').set({
        'subjectId':       effectiveSubject,
        'subjectName':     subjectName,
        'chapterId':       chapterId,
        'chapterName':     chapterName,
        'topicId':         topicId,
        'topicName':       topicName,
        'progressPercent': progressPercent,
        'description':     'Last active in $chapterName',
        'lastAccessedAt':  now,
      });

      // 4. Sync summary progress
      await _db.ref('users/$uid/progress/summary').set({
        'overallPercent':  progressPercent,
        'quizAccuracy':    quizScore,
        'streakDays':      1,
        'completedTopics': completedCount,
        'totalTopics':     totalTopics,
        'updatedAt':       now,
      });

      debugPrint('[CurriculumRepo] Successfully saved topic progress for $topicId');
    } catch (e) {
      debugPrint('[CurriculumRepo] error saving topic progress: $e');
    }
  }

  // ── Seed Sample Curriculum ────────────────────────────────────────────────
  Future<void> _seedSampleCurriculum(String classLevel, String subjectId) async {
    try {
      final sampleMap = ClassCurriculumData.getCurriculum(classLevel);
      await _curriculumRef(classLevel, subjectId).set(sampleMap);

      // Cleanup legacy prototype nodes if present
      try { await _db.ref('curriculum/class12').remove(); } catch (_) {}
      try { await _db.ref('curriculum/class_6').remove(); } catch (_) {}

      debugPrint('[CurriculumRepo] Seeded sample $classLevel CS curriculum to RTDB');
    } catch (e) {
      debugPrint('[CurriculumRepo] seed failed: $e');
    }
  }

  static List<ChapterModel> _getSampleChapters(String classLevel) {
    final map = ClassCurriculumData.getCurriculum(classLevel);
    final chaptersVal = map['chapters'];
    if (chaptersVal is Map) {
      final list = chaptersVal.values
          .whereType<Map>()
          .map((e) => ChapterModel.fromMap(e))
          .toList();
      list.sort((a, b) => a.order.compareTo(b.order));
      return list;
    }
    return [];
  }
}
