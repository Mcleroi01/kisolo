import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'lesson.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class Lesson extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  @JsonKey(name: 'level_id')
  final String levelId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String content;

  @HiveField(4)
  final int order;

  @HiveField(5)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Lesson({
    required this.id,
    required this.levelId,
    required this.title,
    required this.content,
    required this.order,
    required this.createdAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
