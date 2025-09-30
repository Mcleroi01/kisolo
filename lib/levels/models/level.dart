import 'package:json_annotation/json_annotation.dart';

part 'level.g.dart';

@JsonSerializable()
class Level {
  final String id;
  final String title;
  final String description;
  final int order;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Level({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.createdAt,
  });

  factory Level.fromJson(Map<String, dynamic> json) => _$LevelFromJson(json);
  Map<String, dynamic> toJson() => _$LevelToJson(this);

  @override
  String toString() {
    return 'Level(id: $id, title: $title, order: $order)';
  }
}