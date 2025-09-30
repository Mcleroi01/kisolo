import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/lessons/model/lesson.dart';
import 'package:kisolo/core/local_storage/local_storage_service.dart';

class LessonService {
  static const String _tableName = 'lessons';

  // Récupérer toutes les leçons d'un niveau spécifique
  static Future<List<Lesson>> getLessonsByLevel(String levelId) async {
    try {
      // Vérifier d'abord si on a les données en local
      if (LocalStorageService.hasLessonsForLevel(levelId)) {
        final localLessons = LocalStorageService.getLessonsForLevel(levelId);
        if (localLessons.isNotEmpty) {
          return localLessons;
        }
      }

      // Si pas de données locales ou erreur, récupérer depuis Supabase
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('level_id', levelId)
          .order('order');

      final lessons = (response as List)
          .map((json) => Lesson.fromJson(json))
          .toList();

      // Sauvegarder en local pour une utilisation ultérieure
      if (lessons.isNotEmpty) {
        await LocalStorageService.saveLessonsForLevel(levelId, lessons);
        await LocalStorageService.saveUserLevel(levelId);
      }

      return lessons;
    } catch (e) {
      // En cas d'erreur, essayer de récupérer les données locales
      try {
        final localLessons = LocalStorageService.getLessonsForLevel(levelId);
        if (localLessons.isNotEmpty) {
          return localLessons;
        }
        throw Exception('Erreur lors de la récupération des leçons: $e');
      } catch (localError) {
        throw Exception('Erreur lors de la récupération des leçons (local et distant): $e');
      }
    }
  }

  // Récupérer une leçon par son ID
  static Future<Lesson?> getLessonById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return response != null ? Lesson.fromJson(response) : null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la leçon: $e');
    }
  }

  // Créer une nouvelle leçon
  static Future<Lesson> createLesson({
    required String levelId,
    required String title,
    required String content,
    required int order,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'level_id': levelId,
            'title': title,
            'content': content,
            'order': order,
          })
          .select()
          .single();

      return Lesson.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création de la leçon: $e');
    }
  }

  // Mettre à jour une leçon existante
  static Future<Lesson> updateLesson({
    required String id,
    String? title,
    String? content,
    int? order,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (order != null) updates['order'] = order;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Lesson.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la leçon: $e');
    }
  }

  // Supprimer une leçon
  static Future<void> deleteLesson(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de la leçon: $e');
    }
  }

 
}
