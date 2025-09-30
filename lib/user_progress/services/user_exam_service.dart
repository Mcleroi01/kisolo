import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/user_progress/models/user_exam.dart';

class UserExamService {
  static const String _tableName = 'user_exams';

  // Récupérer tous les examens d'un utilisateur
  static Future<List<UserExam>> getUserExams(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserExam.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des examens utilisateur: $e');
    }
  }

  // Récupérer un examen spécifique d'un utilisateur
  static Future<UserExam?> getUserExam({
    required String userId,
    required String examId,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('exam_id', examId)
          .maybeSingle();

      return response != null ? UserExam.fromJson(response) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'examen utilisateur: $e');
    }
  }

  // Enregistrer le résultat d'un examen
  static Future<UserExam> saveExamResult({
    required String userId,
    required String examId,
    required int score,
    required bool passed,
  }) async {
    try {
      final existing = await getUserExam(userId: userId, examId: examId);

      if (existing != null) {
        // Mettre à jour si l'examen existe déjà (ne mettre à jour que si le score est meilleur)
        if (score > existing.score) {
          final response = await SupabaseConfig.client
              .from(_tableName)
              .update({
                'score': score,
                'passed': passed,
              })
              .eq('id', existing.id)
              .select()
              .single();

          return UserExam.fromJson(response);
        }
        return existing;
      } else {
        // Créer une nouvelle entrée
        final response = await SupabaseConfig.client
            .from(_tableName)
            .insert({
              'user_id': userId,
              'exam_id': examId,
              'score': score,
              'passed': passed,
            })
            .select()
            .single();

        return UserExam.fromJson(response);
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'enregistrement du résultat: $e');
    }
  }

  // Vérifier si un utilisateur a réussi un examen
  static Future<bool> hasPassedExam({
    required String userId,
    required String examId,
  }) async {
    try {
      final userExam = await getUserExam(userId: userId, examId: examId);
      return userExam?.passed ?? false;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de l\'examen: $e');
    }
  }

  // Obtenir le meilleur score pour un examen
  static Future<int> getBestScore({
    required String userId,
    required String examId,
  }) async {
    try {
      final userExam = await getUserExam(userId: userId, examId: examId);
      return userExam?.score ?? 0;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du meilleur score: $e');
    }
  }

 
}
