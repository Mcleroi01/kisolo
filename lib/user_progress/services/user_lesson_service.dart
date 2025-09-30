import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/user_progress/models/user_lesson.dart';

class UserLessonService {
  static const String _tableName = 'user_lessons';

  // Récupérer toutes les leçons d'un utilisateur
  static Future<List<UserLesson>> getUserLessons(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at');

      return (response as List)
          .map((json) => UserLesson.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des leçons utilisateur: $e');
    }
  }

  // Récupérer la dernière leçon en cours de l'utilisateur
  static Future<Map<String, dynamic>?> getLastUserLesson(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('lesson_id, lesson:lesson_id(level_id)')
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        return {
          'lessonId': response['lesson_id'] as String,
          'levelId': response['lesson']?['level_id'] as String?,
        };
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la dernière leçon: $e');
      return null;
    }
  }

  // Récupérer une leçon spécifique d'un utilisateur
  static Future<UserLesson?> getUserLesson({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('lesson_id', lessonId)
          .maybeSingle();

      return response != null ? UserLesson.fromJson(response) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la leçon utilisateur: $e');
    }
  }

  // Marquer une leçon comme terminée
  static Future<UserLesson> completeLesson({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final existing = await getUserLesson(userId: userId, lessonId: lessonId);

      if (existing != null) {
        // Mettre à jour si la leçon existe déjà
        final response = await SupabaseConfig.client
            .from(_tableName)
            .update({'completed': true})
            .eq('id', existing.id)
            .select()
            .single();

        return UserLesson.fromJson(response);
      } else {
        // Créer une nouvelle entrée
        final response = await SupabaseConfig.client
            .from(_tableName)
            .insert({
              'user_id': userId,
              'lesson_id': lessonId,
              'completed': true,
            })
            .select()
            .single();

        return UserLesson.fromJson(response);
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la leçon: $e');
    }
  }

  // Vérifier si une leçon est terminée
  static Future<bool> isLessonCompleted({
    required String userId,
    required String lessonId,
  }) async {
    try {
      final userLesson = await getUserLesson(
        userId: userId,
        lessonId: lessonId,
      );
      return userLesson?.completed ?? false;
    } catch (e) {
      throw Exception('Erreur lors de la vérification de la leçon: $e');
    }
  }

  
}
