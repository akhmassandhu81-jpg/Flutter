class VisualizationModel {
  final String type; // 'flowchart' | 'diagram' | 'steps' | 'none'
  final String title;
  final List<String> steps;

  const VisualizationModel({
    required this.type,
    required this.title,
    required this.steps,
  });

  factory VisualizationModel.fromMap(Map<dynamic, dynamic> map) {
    final rawSteps = map['steps'];
    List<String> parsedSteps = [];
    if (rawSteps is List) {
      parsedSteps = rawSteps.map((e) => e.toString()).toList();
    }

    return VisualizationModel(
      type:  map['type']?.toString()  ?? 'none',
      title: map['title']?.toString() ?? '',
      steps: parsedSteps,
    );
  }

  Map<String, dynamic> toMap() => {
    'type':  type,
    'title': title,
    'steps': steps,
  };
}
