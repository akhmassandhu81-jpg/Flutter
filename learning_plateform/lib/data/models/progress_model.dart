/// Aggregated learning progress for a student.
/// Stored at RTDB: users/{uid}/progress/summary
class ProgressModel {
  final String uid;
  final double overallPercent; // 0–100
  final double quizAccuracy; // 0–100
  final int streakDays;
  final int completedTopics;
  final int totalTopics;
  final DateTime updatedAt;

  const ProgressModel({
    required this.uid,
    required this.overallPercent,
    required this.quizAccuracy,
    required this.streakDays,
    required this.completedTopics,
    required this.totalTopics,
    required this.updatedAt,
  });

  factory ProgressModel.empty(String uid) => ProgressModel(
        uid: uid,
        overallPercent: 0,
        quizAccuracy: 0,
        streakDays: 0,
        completedTopics: 0,
        totalTopics: 0,
        updatedAt: DateTime.now(),
      );

  factory ProgressModel.fromMap(String uid, Map<dynamic, dynamic> m) {
    return ProgressModel(
      uid: uid,
      overallPercent: (m['overallPercent'] as num?)?.toDouble() ?? 0,
      quizAccuracy: (m['quizAccuracy'] as num?)?.toDouble() ?? 0,
      streakDays: (m['streakDays'] as num?)?.toInt() ?? 0,
      completedTopics: (m['completedTopics'] as num?)?.toInt() ?? 0,
      totalTopics: (m['totalTopics'] as num?)?.toInt() ?? 0,
      updatedAt: _parseTs(m['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
        'overallPercent': overallPercent,
        'quizAccuracy': quizAccuracy,
        'streakDays': streakDays,
        'completedTopics': completedTopics,
        'totalTopics': totalTopics,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
      };

  static DateTime _parseTs(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {}
    return DateTime.now();
  }

  bool get isNewStudent =>
      overallPercent == 0 && completedTopics == 0 && streakDays == 0;
}
