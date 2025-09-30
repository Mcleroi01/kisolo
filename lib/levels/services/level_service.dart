import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/levels/models/level.dart';

class LevelService {
  static const String _tableName = 'levels';

  // Récupérer tous les niveaux triés par ordre
  static Future<List<Level>> getLevels() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('order');

      return (response as List)
          .map((json) => Level.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des niveaux: $e');
    }
  }

  // Récupérer un niveau par son ID
  static Future<Level> getLevelById(String id) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Level.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la récupération du niveau: $e');
    }
  }

  // Créer un nouveau niveau
  static Future<Level> createLevel({
    required String title,
    required String description,
    required int order,
  }) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert({
            'title': title,
            'description': description,
            'order': order,
          })
          .select()
          .single();

      return Level.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la création du niveau: $e');
    }
  }

  // Mettre à jour un niveau
  static Future<Level> updateLevel({
    required String id,
    String? title,
    String? description,
    int? order,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (order != null) updates['order'] = order;

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return Level.fromJson(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du niveau: $e');
    }
  }

  // Supprimer un niveau
  static Future<void> deleteLevel(String id) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Erreur lors de la suppression du niveau: $e');
    }
  }
}