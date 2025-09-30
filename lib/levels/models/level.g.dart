// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Level _$LevelFromJson(Map<String, dynamic> json) => Level(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: (json['order'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$LevelToJson(Level instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'order': instance.order,
      'created_at': instance.createdAt.toIso8601String(),
    };
