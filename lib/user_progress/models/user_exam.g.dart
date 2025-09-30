// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_exam.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserExam _$UserExamFromJson(Map<String, dynamic> json) => UserExam(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      examId: json['exam_id'] as String,
      score: (json['score'] as num).toInt(),
      passed: json['passed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserExamToJson(UserExam instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'exam_id': instance.examId,
      'score': instance.score,
      'passed': instance.passed,
      'created_at': instance.createdAt.toIso8601String(),
    };
