class ExplanationModel {
  final String title;
  final String content;

  const ExplanationModel({
    required this.title,
    required this.content,
  });

  factory ExplanationModel.fromMap(Map<dynamic, dynamic> map) {
    return ExplanationModel(
      title:   map['title']?.toString()   ?? '',
      content: map['content']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'title':   title,
    'content': content,
  };
}
