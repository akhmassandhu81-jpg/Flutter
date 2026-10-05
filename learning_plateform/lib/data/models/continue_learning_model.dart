/// The most-recently-accessed learning item for "Continue Learning" card.
/// Stored at RTDB: users/{uid}/recentLearning/last
class ContinueLearningModel {
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final String topicId;
  final String topicName;
  final double progressPercent;
  final String description;
  final DateTime lastAccessedAt;

  const ContinueLearningModel({
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.topicId,
    required this.topicName,
    required this.progressPercent,
    required this.description,
    required this.lastAccessedAt,
  });

  factory ContinueLearningModel.fromMap(Map<dynamic, dynamic> m) =>
      ContinueLearningModel(
        subjectId: m['subjectId']?.toString() ?? '',
        subjectName: m['subjectName']?.toString() ?? '',
        chapterId: m['chapterId']?.toString() ?? '',
        chapterName: m['chapterName']?.toString() ?? '',
        topicId: m['topicId']?.toString() ?? '',
        topicName: m['topicName']?.toString() ?? '',
        progressPercent: (m['progressPercent'] as num?)?.toDouble() ?? 0,
        description: m['description']?.toString() ?? '',
        lastAccessedAt: _parseTs(m['lastAccessedAt']),
      );

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
}
