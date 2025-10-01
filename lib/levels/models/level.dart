import 'package:hive/hive.dart';
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

class LevelAdapter extends TypeAdapter<Level> {
  @override
  final int typeId = 1; // Un ID unique pour l'adapter

  @override
  Level read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Level(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      order: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.order)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}