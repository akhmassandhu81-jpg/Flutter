class ActivityModel {
  final String type; // 'algorithm_ordering'
  final String title;
  final String instruction;
  final List<String> initialItems;
  final List<String> correctOrder;

  const ActivityModel({
    required this.type,
    required this.title,
    required this.instruction,
    required this.initialItems,
    required this.correctOrder,
  });

  factory ActivityModel.fromMap(Map<dynamic, dynamic> map) {
    final rawInitial = map['initialItems'];
    List<String> parsedInitial = [];
    if (rawInitial is List) {
      parsedInitial = rawInitial.map((e) => e.toString()).toList();
    }

    final rawCorrect = map['correctOrder'];
    List<String> parsedCorrect = [];
    if (rawCorrect is List) {
      parsedCorrect = rawCorrect.map((e) => e.toString()).toList();
    }

    return ActivityModel(
      type:         map['type']?.toString()        ?? 'algorithm_ordering',
      title:        map['title']?.toString()       ?? '',
      instruction:  map['instruction']?.toString() ?? '',
      initialItems: parsedInitial,
      correctOrder: parsedCorrect,
    );
  }

  Map<String, dynamic> toMap() => {
    'type':         type,
    'title':        title,
    'instruction':  instruction,
    'initialItems': initialItems,
    'correctOrder': correctOrder,
  };
}
