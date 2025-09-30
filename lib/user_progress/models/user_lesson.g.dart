// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_lesson.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserLesson _$UserLessonFromJson(Map<String, dynamic> json) => UserLesson(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      lessonId: json['lesson_id'] as String,
      completed: json['completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$UserLessonToJson(UserLesson instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'lesson_id': instance.lessonId,
      'completed': instance.completed,
      'created_at': instance.createdAt.toIso8601String(),
    };
