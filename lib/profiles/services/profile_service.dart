import 'package:flutter/foundation.dart';
import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/profiles/models/profile.dart';
import 'package:kisolo/user_progress/services/user_lesson_service.dart';

class ProfileService {
  static const String _tableName = 'profiles';

  // Récupérer le profil de l'utilisateur connecté
  static Future<Profile> getCurrentUserProfile() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du profil: $e');
    }
  }

  // Créer ou mettre à jour un profil
  static Future<Profile> upsertProfile({
    required String userId,
    required String name,
    required Gender gender,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .upsert({
            'id': userId,
            'name': name,
            'gender': gender.toString().split('.').last,
            'points': 0, // Points initiaux
            'streak_days': 0, // Série initiale
          })
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du profil: $e');
    }
  }

  // Mettre à jour le nom d'un profil
  static Future<Profile> updateName(String userId, String newName) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'name': newName})
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du nom: $e');
    }
  }

  // Mettre à jour le genre d'un profil
  static Future<Profile> updateGender(String userId, Gender newGender) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'gender': newGender.toString().split('.').last})
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du genre: $e');
    }
  }

  // Ajouter des points au profil
  static Future<Profile> addPoints(String userId, int pointsToAdd) async {
    try {
      final currentProfile = await getCurrentUserProfile();
      final newPoints = currentProfile.points + pointsToAdd;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'points': newPoints})
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de points: $e');
    }
  }

  // Réinitialiser les points d'un profil
  static Future<Profile> resetPoints(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({'points': 0})
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation des points: $e');
    }
  }

  // Supprimer un profil
  static Future<void> deleteProfile(String userId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du profil: $e');
    }
  }

  // Mettre à jour les statistiques du profil (série et leçons terminées)
  static Future<Profile> updateStats(String userId) async {
    try {
      // Calculer les statistiques depuis les leçons utilisateur
      final userLessons = await _getUserLessonStats(userId);

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update({
            'streak_days': userLessons['streakDays'],

          })
          .eq('id', userId)
          .select()
          .single();

      return Profile.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des statistiques: $e');
    }
  }

  // Calculer les statistiques depuis les leçons utilisateur
  static Future<Map<String, int>> _getUserLessonStats(String userId) async {
    try {
      // Get all user lessons to calculate statistics
      final userLessons = await UserLessonService.getUserLessons(userId);

      // Count completed lessons
      final completedLessons = userLessons.where((lesson) => lesson.completed).length;

      // Calculate streak days (simplified - would need more complex logic for real streak calculation)
      final streakDays = _calculateStreakDays(userLessons);

      return {
        'streakDays': streakDays,
        'lessonsCompleted': completedLessons,
      };
    } catch (e) {
      debugPrint('Erreur lors du calcul des statistiques: $e');
      return {
        'streakDays': 0,
        'lessonsCompleted': 0,
      };
    }
  }

  // Calculer la série de jours (logique simplifiée)
  static int _calculateStreakDays(List userLessons) {
    // For now, return 0 as a placeholder
    // Real implementation would track consecutive days of activity
    return 0;
  }

  // Vérifier si un profil existe
  static Future<bool> profileExists(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', userId);

      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Erreur lors de la vérification du profil: $e');
    }
  }
}
