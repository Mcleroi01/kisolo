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

  // Marquer une leçon spécifique comme terminée
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

  // Marquer la prochaine leçon comme terminée (trouve automatiquement la première leçon non terminée)
  static Future<UserLesson?> completeNextLesson(String userId) async {
    try {
      // Récupérer toutes les leçons de l'utilisateur triées par ordre
      final userLessons = await getUserLessons(userId);

      // Trouver la première leçon non terminée
      final nextLesson = userLessons.where((lesson) => !lesson.completed).cast<UserLesson?>().firstOrNull;

      if (nextLesson != null) {
        // Marquer cette leçon comme terminée
        final response = await SupabaseConfig.client
            .from(_tableName)
            .update({'completed': true})
            .eq('id', nextLesson.id)
            .select()
            .single();

        return UserLesson.fromJson(response);
      }

      return null; // Aucune leçon à marquer comme terminée
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la prochaine leçon: $e');
    }
  }

  // Incrémenter simplement le compteur de leçons terminées (approche alternative)
  static Future<int> incrementCompletedLessonsCount(String userId) async {
    try {
      // Récupérer le nombre actuel de leçons terminées
      final currentCount = await getCompletedLessonsCount(userId);

      return currentCount + 1;
    } catch (e) {
      throw Exception('Erreur lors de l\'incrémentation du compteur: $e');
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

  // Récupérer le nombre de leçons terminées pour un utilisateur
  static Future<int> getCompletedLessonsCount(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select('id')
          .eq('user_id', userId)
          .eq('completed', true);

      return (response as List).length;
    } catch (e) {
      throw Exception('Erreur lors du comptage des leçons terminées: $e');
    }
  }

  // Récupérer toutes les leçons terminées pour un utilisateur
  static Future<List<UserLesson>> getCompletedLessons(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('completed', true)
          .order('created_at');

      return (response as List).map((json) => UserLesson.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des leçons terminées: $e');
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
