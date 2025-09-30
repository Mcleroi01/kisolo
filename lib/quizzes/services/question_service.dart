import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/quizzes/models/question.dart';

class QuestionService {
  static const String _tableName = 'questions';

  // Récupérer toutes les questions d'un examen
  static Future<List<Question>> getQuestionsByExam(String examId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('exam_id', examId)
          .order('created_at');

      return (response as List)
          .map((json) => Question.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des questions: $e');
    }
  }

  // Récupérer une question par son ID
  static Future<Question> getQuestionById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la question: $e');
    }
  }

  // Créer une nouvelle question
  static Future<Question> createQuestion({
    required String examId,
    required QuestionType type,
    required String content,
    required Map<String, dynamic> correctAnswer,
    Map<String, dynamic>? options,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'exam_id': examId,
            'type': type.toString().split('.').last,
            'content': content,
            'correct_answer': correctAnswer,
            if (options != null) 'options': options,
          })
          .select()
          .single();

      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création de la question: $e');
    }
  }

  // Mettre à jour une question
  static Future<Question> updateQuestion({
    required String id,
    String? content,
    QuestionType? type,
    Map<String, dynamic>? correctAnswer,
    Map<String, dynamic>? options,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (content != null) updates['content'] = content;
      if (type != null) updates['type'] = type.toString().split('.').last;
      if (correctAnswer != null) updates['correct_answer'] = correctAnswer;
      if (options != null) updates['options'] = options;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Question.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la question: $e');
    }
  }

  // Supprimer une question
  static Future<void> deleteQuestion(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la question: $e');
    }
  }

  // Vérifier si une réponse est correcte
  static bool isAnswerCorrect({
    required Question question,
    required dynamic userAnswer,
  }) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return userAnswer == question.correctAnswer['value'];
      case QuestionType.translation:
        // Pour les traductions, on peut vouloir une correspondance insensible à la casse
        // et ignorer les espaces superflus
        final correct = (question.correctAnswer['value'] as String)
            .toLowerCase()
            .trim();
        final user = (userAnswer as String).toLowerCase().trim();
        return correct == user;
      case QuestionType.trueFalse:
        return userAnswer == question.correctAnswer['value'];
    }
  }

  // Obtenir les statistiques d'un examen
  static Future<Map<String, dynamic>> getExamStats(String examId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('id')
          .eq('exam_id', examId);

      return {
        'total_questions': (response as List).length,
      };
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }
}
