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
  final int order;

  @HiveField(3)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(4)
  @JsonKey(name: 'phrase_pt')
  final String phrasePt;

  @HiveField(5)
  @JsonKey(name: 'phrase_ln')
  final String phraseLn;

  @HiveField(6)
  final String? notes;

  Lesson({
    required this.id,
    required this.levelId,
    required this.order,
    required this.createdAt,
    required this.phrasePt,
    required this.phraseLn,
    this.notes,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
  Map<String, dynamic> toJson() => _$LessonToJson(this);
}
