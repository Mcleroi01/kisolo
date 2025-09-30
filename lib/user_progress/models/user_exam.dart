import 'package:json_annotation/json_annotation.dart';

part 'user_exam.g.dart';

@JsonSerializable()
class UserExam {
  final String id;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'exam_id')
  final String examId;
  final int score;
  final bool passed;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserExam({
    required this.id,
    required this.userId,
    required this.examId,
    required this.score,
    required this.passed,
    required this.createdAt,
  });

  factory UserExam.fromJson(Map<String, dynamic> json) => _$UserExamFromJson(json);
  Map<String, dynamic> toJson() => _$UserExamToJson(this);

  UserExam copyWith({
    int? score,
    bool? passed,
  }) {
    return UserExam(
      id: id,
      userId: userId,
      examId: examId,
      score: score ?? this.score,
      passed: passed ?? this.passed,
      createdAt: createdAt,
    );
  }
}
