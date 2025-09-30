class User {
  final String id;
  final String name;
  final String avatar;
  final int currentLevel;
  final int totalXP;
  final int streakDays;
  final List<String> badges;

  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.currentLevel,
    required this.totalXP,
    required this.streakDays,
    required this.badges,
  });

  User copyWith({
    String? id,
    String? name,
    String? avatar,
    int? currentLevel,
    int? totalXP,
    int? streakDays,
    List<String>? badges,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      currentLevel: currentLevel ?? this.currentLevel,
      totalXP: totalXP ?? this.totalXP,
      streakDays: streakDays ?? this.streakDays,
      badges: badges ?? this.badges,
    );
  }
}