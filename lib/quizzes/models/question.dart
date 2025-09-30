import 'package:json_annotation/json_annotation.dart';

part 'question.g.dart';

enum QuestionType {
  @JsonValue('multiple_choice')
  multipleChoice,
  @JsonValue('translation')
  translation,
  @JsonValue('true_false')
  trueFalse,
}

@JsonSerializable()
class Question {
  final String id;
  @JsonKey(name: 'exam_id')
  final String examId;
  final QuestionType type;
  final String content;
  @JsonKey(name: 'correct_answer')
  final Map<String, dynamic> correctAnswer;
  final Map<String, dynamic>? options;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Question({
    required this.id,
    required this.examId,
    required this.type,
    required this.content,
    required this.correctAnswer,
    this.options,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) => _$QuestionFromJson(json);
  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  String toString() {
    return 'Question(id: $id, type: $type, content: $content, examId: $examId)';
  }
}
