import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:learning_plateform/data/models/subject_model.dart';

/// Reads the subjects catalogue from Firestore.
///
/// Path:  subjects/{classLevel}/list/{subjectId}
///
/// Always emits — falls back to [SubjectModel.defaultSubjects] when the
/// Firestore collection is empty or a permission error occurs.
class SubjectRepository {
  SubjectRepository._();
  static final SubjectRepository instance = SubjectRepository._();

  final _db = FirebaseFirestore.instance;

  Stream<List<SubjectModel>> subjectsStream(String classLevel) {
    final effectiveClass =
        classLevel.isEmpty ? 'class8' : classLevel;

    return _db
        .collection('subjects')
        .doc(effectiveClass)
        .collection('list')
        .snapshots()
        .map<List<SubjectModel>>((snap) {
          if (snap.docs.isEmpty) {
            return SubjectModel.defaultSubjects(effectiveClass);
          }
          final parsed = snap.docs.map((d) {
            try {
              return SubjectModel.fromMap({'id': d.id, ...d.data()});
            } catch (e) {
              debugPrint('[SubjectRepo] parse: $e');
              return null;
            }
          }).whereType<SubjectModel>().toList();
          return parsed.isEmpty
              ? SubjectModel.defaultSubjects(effectiveClass)
              : parsed;
        })
        .handleError((e) {
          debugPrint('[SubjectRepo] stream error: $e');
          return SubjectModel.defaultSubjects(effectiveClass);
        });
  }
}
