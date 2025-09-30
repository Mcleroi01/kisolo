// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Question _$QuestionFromJson(Map<String, dynamic> json) => Question(
      id: json['id'] as String,
      examId: json['exam_id'] as String,
      type: $enumDecode(_$QuestionTypeEnumMap, json['type']),
      content: json['content'] as String,
      correctAnswer: json['correct_answer'] as Map<String, dynamic>,
      options: json['options'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$QuestionToJson(Question instance) => <String, dynamic>{
      'id': instance.id,
      'exam_id': instance.examId,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'content': instance.content,
      'correct_answer': instance.correctAnswer,
      'options': instance.options,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$QuestionTypeEnumMap = {
  QuestionType.multipleChoice: 'multiple_choice',
  QuestionType.translation: 'translation',
  QuestionType.trueFalse: 'true_false',
};
