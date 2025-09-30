import 'package:json_annotation/json_annotation.dart';

part 'user_lesson.g.dart';

@JsonSerializable()
class UserLesson {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'lesson_id')
  final String lessonId;
  final bool completed;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserLesson({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completed,
    required this.createdAt,
  });

  factory UserLesson.fromJson(Map<String, dynamic> json) => _$UserLessonFromJson(json);
  Map<String, dynamic> toJson() => _$UserLessonToJson(this);

  UserLesson copyWith({
    bool? completed,
  }) {
    return UserLesson(
      id: id,
      userId: userId,
      lessonId: lessonId,
      completed: completed ?? this.completed,
      createdAt: createdAt,
    );
  }
}
