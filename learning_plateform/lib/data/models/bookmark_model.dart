/// Represents a bookmarked learning item saved by a student.
/// Stored in RTDB at: users/{uid}/bookmarks/{topicId}
class BookmarkModel {
  final String id;
  final String subjectId;
  final String subjectName;
  final String chapterId;
  final String chapterName;
  final String topicId;
  final String topicTitle;
  final String description;
  final String contentType; // 'Lesson' | 'Activity' | 'Quiz'
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.subjectId,
    required this.subjectName,
    required this.chapterId,
    required this.chapterName,
    required this.topicId,
    required this.topicTitle,
    required this.description,
    required this.contentType,
    required this.createdAt,
  });

  factory BookmarkModel.fromMap(Map<dynamic, dynamic> m) {
    return BookmarkModel(
      id:          m['id']?.toString()          ?? '',
      subjectId:   m['subjectId']?.toString()   ?? '',
      subjectName: m['subjectName']?.toString() ?? '',
      chapterId:   m['chapterId']?.toString()   ?? '',
      chapterName: m['chapterName']?.toString() ?? '',
      topicId:     m['topicId']?.toString()     ?? '',
      topicTitle:  m['topicTitle']?.toString()  ?? '',
      description: m['description']?.toString() ?? '',
      contentType: m['contentType']?.toString() ?? 'Lesson',
      createdAt: m['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as num).toInt())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id':          id,
    'subjectId':   subjectId,
    'subjectName': subjectName,
    'chapterId':   chapterId,
    'chapterName': chapterName,
    'topicId':     topicId,
    'topicTitle':  topicTitle,
    'description': description,
    'contentType': contentType,
    'createdAt':   createdAt.millisecondsSinceEpoch,
  };
}
