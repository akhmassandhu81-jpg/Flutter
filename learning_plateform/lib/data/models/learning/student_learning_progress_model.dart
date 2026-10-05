class StudentTopicProgressModel {
  final String topicId;
  final String chapterId;
  final bool completed;
  final bool activityCompleted;
  final double practiceScore;
  final double quizScore;
  final int attempts;
  final DateTime lastAccessed;

  const StudentTopicProgressModel({
    required this.topicId,
    required this.chapterId,
    required this.completed,
    required this.activityCompleted,
    required this.practiceScore,
    required this.quizScore,
    required this.attempts,
    required this.lastAccessed,
  });

  factory StudentTopicProgressModel.notStarted(String topicId, String chapterId) =>
      StudentTopicProgressModel(
        topicId:           topicId,
        chapterId:         chapterId,
        completed:         false,
        activityCompleted: false,
        practiceScore:     0,
        quizScore:         0,
        attempts:          0,
        lastAccessed:      DateTime.now(),
      );

  factory StudentTopicProgressModel.fromMap(Map<dynamic, dynamic> map) {
    return StudentTopicProgressModel(
      topicId:           map['topicId']?.toString()           ?? '',
      chapterId:         map['chapterId']?.toString()         ?? '',
      completed:         map['completed'] == true,
      activityCompleted: map['activityCompleted'] == true,
      practiceScore:     (map['practiceScore'] as num?)?.toDouble() ?? 0,
      quizScore:         (map['quizScore'] as num?)?.toDouble()     ?? 0,
      attempts:          (map['attempts'] as num?)?.toInt()         ?? 0,
      lastAccessed: map['lastAccessed'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['lastAccessed'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'topicId':           topicId,
    'chapterId':         chapterId,
    'completed':         completed,
    'activityCompleted': activityCompleted,
    'practiceScore':     practiceScore,
    'quizScore':         quizScore,
    'attempts':          attempts,
    'lastAccessed':      lastAccessed.millisecondsSinceEpoch,
  };
}

class StudentSubjectProgressModel {
  final String subjectId;
  final String classLevel;
  final int completedTopics;
  final int totalTopics;
  final double progressPercent;
  final String? lastChapterId;
  final String? lastTopicId;
  final DateTime lastAccessedAt;
  final Map<String, StudentTopicProgressModel> topicProgress;

  const StudentSubjectProgressModel({
    required this.subjectId,
    required this.classLevel,
    required this.completedTopics,
    required this.totalTopics,
    required this.progressPercent,
    required this.lastAccessedAt,
    this.lastChapterId,
    this.lastTopicId,
    this.topicProgress = const {},
  });

  factory StudentSubjectProgressModel.empty(String subjectId, String classLevel) =>
      StudentSubjectProgressModel(
        subjectId:       subjectId,
        classLevel:      classLevel,
        completedTopics: 0,
        totalTopics:     0,
        progressPercent: 0,
        lastAccessedAt:  DateTime.now(),
        topicProgress:   const {},
      );

  factory StudentSubjectProgressModel.fromMap(Map<dynamic, dynamic> map) {
    final rawTopics = map['topics'];
    Map<String, StudentTopicProgressModel> parsedTopics = {};
    if (rawTopics is Map) {
      rawTopics.forEach((k, v) {
        if (k != null && v is Map) {
          parsedTopics[k.toString()] = StudentTopicProgressModel.fromMap(v);
        }
      });
    }

    return StudentSubjectProgressModel(
      subjectId:       map['subjectId']?.toString()       ?? '',
      classLevel:      map['classLevel']?.toString()      ?? '',
      completedTopics: (map['completedTopics'] as num?)?.toInt()    ?? 0,
      totalTopics:     (map['totalTopics'] as num?)?.toInt()        ?? 0,
      progressPercent: (map['progressPercent'] as num?)?.toDouble() ?? 0,
      lastChapterId:   map['lastChapterId']?.toString(),
      lastTopicId:     map['lastTopicId']?.toString(),
      lastAccessedAt: map['lastAccessedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((map['lastAccessedAt'] as num).toInt())
          : DateTime.now(),
      topicProgress:   parsedTopics,
    );
  }

  Map<String, dynamic> toMap() {
    final tMap = <String, dynamic>{};
    topicProgress.forEach((k, v) => tMap[k] = v.toMap());
    return {
      'subjectId':       subjectId,
      'classLevel':      classLevel,
      'completedTopics': completedTopics,
      'totalTopics':     totalTopics,
      'progressPercent': progressPercent,
      'lastChapterId':   lastChapterId,
      'lastTopicId':     lastTopicId,
      'lastAccessedAt':  lastAccessedAt.millisecondsSinceEpoch,
      'topics':          tMap,
    };
  }
}
