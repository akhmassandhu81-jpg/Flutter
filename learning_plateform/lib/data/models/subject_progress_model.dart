/// Per-subject progress for a student.
/// Stored at RTDB: users/{uid}/subjectProgress/{subjectId}
class SubjectProgressModel {
  final String subjectId;
  final String subjectName;
  final double progressPercent; // 0–100
  final int completedTopics;
  final int totalTopics;
  final String status; // 'not_started' | 'in_progress' | 'completed'
  final DateTime updatedAt;

  const SubjectProgressModel({
    required this.subjectId,
    required this.subjectName,
    required this.progressPercent,
    required this.completedTopics,
    required this.totalTopics,
    required this.status,
    required this.updatedAt,
  });

  bool get isNotStarted => status == 'not_started' || progressPercent == 0;

  factory SubjectProgressModel.notStarted(
          String subjectId, String subjectName) =>
      SubjectProgressModel(
        subjectId: subjectId,
        subjectName: subjectName,
        progressPercent: 0,
        completedTopics: 0,
        totalTopics: 0,
        status: 'not_started',
        updatedAt: DateTime.now(),
      );

  factory SubjectProgressModel.fromMap(Map<dynamic, dynamic> m) =>
      SubjectProgressModel(
        subjectId: m['subjectId']?.toString() ?? '',
        subjectName: m['subjectName']?.toString() ?? '',
        progressPercent: (m['progressPercent'] as num?)?.toDouble() ?? 0,
        completedTopics: (m['completedTopics'] as num?)?.toInt() ?? 0,
        totalTopics: (m['totalTopics'] as num?)?.toInt() ?? 0,
        status: m['status']?.toString() ?? 'not_started',
        updatedAt: _parseTs(m['updatedAt']),
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
