import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/user_progress/models/user_lesson.dart';
import 'package:kisolo/levels/services/level_service.dart';
import 'package:kisolo/lessons/services/lesson_service.dart';

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

      final lessons =
          (response as List).map((json) => UserLesson.fromJson(json)).toList();

      // If no lessons exist, initialize with first level lessons
      if (lessons.isEmpty) {
        return await _initializeFirstLessons(userId);
      }

      return lessons;
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des leçons utilisateur: $e');
    }
  }

  // Récupérer la dernière leçon en cours de l'utilisateur
  static Future<Map<String, dynamic>?> getLastUserLesson(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('lesson_id, lesson:lesson_id(level_id)')
          .eq('user_id', userId)
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
      throw Exception(
          'Erreur lors de la récupération de la leçon utilisateur: $e');
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

  // Initialiser les premières leçons pour un utilisateur
  static Future<List<UserLesson>> _initializeFirstLessons(String userId) async {
    try {
      // Récupérer tous les niveaux triés par ordre
      final levels = await LevelService.getLevels();

      if (levels.isEmpty) {
        return [];
      }

      // Prendre le premier niveau (avec le plus petit ordre)
      final firstLevel = levels.first;

      // Récupérer toutes les leçons du premier niveau
      final lessons = await LessonService.getLessonsByLevel(firstLevel.id);

      if (lessons.isEmpty) {
        return [];
      }

      // Créer des entrées UserLesson pour chaque leçon du premier niveau
      final userLessons = <UserLesson>[];
      final lessonsData = lessons.map((lesson) => {
        'user_id': userId,
        'lesson_id': lesson.id,
        'completed': false,
      }).toList();

      // Batch insert with conflict resolution
      final response = await SupabaseConfig.client
          .from(_tableName)
          .upsert(
            lessonsData,
            onConflict: 'user_id,lesson_id',
          )
          .select();

      for (final json in response) {
        userLessons.add(UserLesson.fromJson(json));
      }

      return userLessons;
    } catch (e) {
      throw Exception('Erreur lors de l\'initialisation des premières leçons: $e');
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
