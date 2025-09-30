import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/exams/models/exam.dart';

class ExamService {
  static const String _tableName = 'exams';

  // Récupérer tous les examens d'un niveau spécifique
  static Future<List<Exam>> getExamsByLevel(String levelId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('level_id', levelId)
          .order('created_at');

      return (response as List)
          .map((json) => Exam.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des examens: $e');
    }
  }

  // Récupérer un examen par son ID
  static Future<Exam> getExamById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Exam.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'examen: $e');
    }
  }

  // Créer un nouvel examen
  static Future<Exam> createExam({
    required String levelId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'level_id': levelId,
            'title': title,
            'description': description,
          })
          .select()
          .single();

      return Exam.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'examen: $e');
    }
  }

  // Mettre à jour un examen
  static Future<Exam> updateExam({
    required String id,
    String? title,
    String? description,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Exam.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'examen: $e');
    }
  }

  // Supprimer un examen
  static Future<void> deleteExam(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'examen: $e');
    }
  }

 
}
