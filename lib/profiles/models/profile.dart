import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('other')
  other,
}

@JsonSerializable()
class Profile {
  final String id;
  final String name;
  final Gender gender;
  final int points;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Profile({
    required this.id,
    required this.name,
    required this.gender,
    required this.points,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  // Crée une copie du profil avec des valeurs mises à jour
  Profile copyWith({
    String? name,
    Gender? gender,
    int? points,
  }) {
    return Profile(
      id: id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      points: points ?? this.points,
      createdAt: createdAt,
    );
  }

  @override
  String toString() {
    return 'Profile(id: $id, name: $name, points: $points)';
  }
}
