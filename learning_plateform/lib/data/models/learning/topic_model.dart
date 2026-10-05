import 'activity_model.dart';
import 'explanation_model.dart';
import 'question_model.dart';
import 'visualization_model.dart';

class TopicModel {
  final String id;
  final String title;
  final String description;
  final int order;
  final ExplanationModel explanation;
  final VisualizationModel visualization;
  final ActivityModel activity;
  final List<QuestionModel> practiceQuestions;
  final List<QuestionModel> assessmentQuestions;

  const TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.explanation,
    required this.visualization,
    required this.activity,
    required this.practiceQuestions,
    required this.assessmentQuestions,
  });

  factory TopicModel.fromMap(Map<dynamic, dynamic> map) {
    final rawPractice = map['practiceQuestions'];
    List<QuestionModel> parsedPractice = [];
    if (rawPractice is List) {
      parsedPractice = rawPractice
          .whereType<Map>()
          .map((e) => QuestionModel.fromMap(e))
          .toList();
    } else if (rawPractice is Map) {
      parsedPractice = rawPractice.values
          .whereType<Map>()
          .map((e) => QuestionModel.fromMap(e))
          .toList();
    }

    final rawAssessment = map['assessmentQuestions'];
    List<QuestionModel> parsedAssessment = [];
    if (rawAssessment is List) {
      parsedAssessment = rawAssessment
          .whereType<Map>()
          .map((e) => QuestionModel.fromMap(e))
          .toList();
    } else if (rawAssessment is Map) {
      parsedAssessment = rawAssessment.values
          .whereType<Map>()
          .map((e) => QuestionModel.fromMap(e))
          .toList();
    }

    return TopicModel(
      id:          map['id']?.toString()          ?? '',
      title:       map['title']?.toString()       ?? '',
      description: map['description']?.toString() ?? '',
      order:       (map['order'] as num?)?.toInt() ?? 1,
      explanation: map['explanation'] is Map
          ? ExplanationModel.fromMap(map['explanation'] as Map)
          : const ExplanationModel(title: '', content: ''),
      visualization: map['visualization'] is Map
          ? VisualizationModel.fromMap(map['visualization'] as Map)
          : const VisualizationModel(type: 'none', title: '', steps: []),
      activity: map['activity'] is Map
          ? ActivityModel.fromMap(map['activity'] as Map)
          : const ActivityModel(
              type: 'algorithm_ordering',
              title: '',
              instruction: '',
              initialItems: [],
              correctOrder: [],
            ),
      practiceQuestions:   parsedPractice,
      assessmentQuestions: parsedAssessment,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':                  id,
    'title':               title,
    'description':         description,
    'order':               order,
    'explanation':         explanation.toMap(),
    'visualization':       visualization.toMap(),
    'activity':            activity.toMap(),
    'practiceQuestions':   practiceQuestions.map((q) => q.toMap()).toList(),
    'assessmentQuestions': assessmentQuestions.map((q) => q.toMap()).toList(),
  };
}
