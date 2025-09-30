import 'package:json_annotation/json_annotation.dart';

part 'exam.g.dart';

@JsonSerializable()
class Exam {
  final String id;
  @JsonKey(name: 'level_id')
  final String levelId;
  final String title;
  final String description;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Exam({
    required this.id,
    required this.levelId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) => _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);

  @override
  String toString() {
    return 'Exam(id: $id, title: $title, levelId: $levelId)';
  }
}
