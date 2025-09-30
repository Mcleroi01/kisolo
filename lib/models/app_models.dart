

class Question {
  final String id;
  final String lingalaText;
  final String correctAnswer;
  final List<String> options;
  final String explanation;

  const Question({
    required this.id,
    required this.lingalaText,
    required this.correctAnswer,
    required this.options,
    required this.explanation,
  });
}

class Progress {
  final int currentLessonIndex;
  final int totalLessons;
  final double dailyProgress;
  final DateTime lastStudyDate;

  const Progress({
    required this.currentLessonIndex,
    required this.totalLessons,
    required this.dailyProgress,
    required this.lastStudyDate,
  });
}
