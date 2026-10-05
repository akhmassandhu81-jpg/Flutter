import 'topic_model.dart';

class ChapterModel {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<TopicModel> topics;

  const ChapterModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.topics,
  });

  factory ChapterModel.fromMap(Map<dynamic, dynamic> map) {
    final rawTopics = map['topics'];
    List<TopicModel> parsedTopics = [];
    if (rawTopics is Map) {
      final topicList = rawTopics.values
          .whereType<Map>()
          .map((e) => TopicModel.fromMap(e))
          .toList();
      topicList.sort((a, b) => a.order.compareTo(b.order));
      parsedTopics = topicList;
    } else if (rawTopics is List) {
      parsedTopics = rawTopics
          .whereType<Map>()
          .map((e) => TopicModel.fromMap(e))
          .toList();
      parsedTopics.sort((a, b) => a.order.compareTo(b.order));
    }

    return ChapterModel(
      id:          map['id']?.toString()          ?? '',
      title:       map['title']?.toString()       ?? '',
      description: map['description']?.toString() ?? '',
      order:       (map['order'] as num?)?.toInt() ?? 1,
      topics:      parsedTopics,
    );
  }

  Map<String, dynamic> toMap() {
    final topicMap = <String, dynamic>{};
    for (final t in topics) {
      topicMap[t.id] = t.toMap();
    }
    return {
      'id':          id,
      'title':       title,
      'description': description,
      'order':       order,
      'topics':      topicMap,
    };
  }
}
