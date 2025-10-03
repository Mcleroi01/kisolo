import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/core/local_storage/local_storage_service.dart';
import 'package:kisolo/levels/models/level.dart';

class LevelService {
  static const String _tableName = 'levels';

  // Récupérer tous les niveaux triés par ordre
  static Future<List<Level>> getLevels() async {
    try {
      // Vérifier d'abord le cache local
      if (LocalStorageService.hasLevels()) {
        final levels = LocalStorageService.getLevels();
        if (levels.isNotEmpty) {
          return levels;
        }
      }

      // Si pas de cache, récupérer depuis Supabase
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('order', ascending: true);

      // Convertir la réponse en liste de Level
      final levels = (response as List)
          .map((json) => Level.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Sauvegarder en cache
      if (levels.isNotEmpty) {
        await LocalStorageService.saveLevels(levels);
      }

      return levels;
    } catch (e) {
      print('❌ Erreur getLevels: $e');

      // En cas d'erreur réseau, essayer de récupérer depuis le cache
      try {
        final cachedLevels = LocalStorageService.getLevels();
        if (cachedLevels.isNotEmpty) {
          return cachedLevels;
        }
      } catch (cacheError) {
        print('❌ Erreur cache: $cacheError');
      }

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

      return Level.fromJson(Map<String, dynamic>.from(response));
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

      // Invalider le cache
      await _invalidateCache();

      return Level.fromJson(Map<String, dynamic>.from(response));
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

      // Invalider le cache
      await _invalidateCache();

      return Level.fromJson(Map<String, dynamic>.from(response));
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du niveau: $e');
    }
  }

  // Supprimer un niveau
  static Future<void> deleteLevel(String id) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', id);

      // Invalider le cache
      await _invalidateCache();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du niveau: $e');
    }
  }

  // Invalider le cache des niveaux
  static Future<void> _invalidateCache() async {
    try {
      await LocalStorageService.saveLevels([]);
      print('🗑️ Cache des niveaux invalidé');
    } catch (e) {
      print('⚠️ Erreur invalidation cache: $e');
    }
  }

  // Forcer le rechargement depuis Supabase
  static Future<List<Level>> refreshLevels() async {
    await _invalidateCache();
    return getLevels();
  }
}
