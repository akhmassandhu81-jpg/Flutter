class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuestionModel.fromMap(Map<dynamic, dynamic> map) {
    final rawOptions = map['options'];
    List<String> parsedOptions = [];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList();
    }

    return QuestionModel(
      id:           map['id']?.toString()           ?? '',
      question:     map['question']?.toString()     ?? '',
      options:      parsedOptions,
      correctIndex: (map['correctIndex'] as num?)?.toInt() ?? 0,
      explanation:  map['explanation']?.toString()  ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'id':           id,
    'question':     question,
    'options':      options,
    'correctIndex': correctIndex,
    'explanation':  explanation,
  };
}
