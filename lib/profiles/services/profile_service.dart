import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/profiles/models/profile.dart';

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
