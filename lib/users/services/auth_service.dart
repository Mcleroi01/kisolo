import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/core/local_storage/local_storage_service.dart';

class AuthService {
  static final _client = SupabaseConfig.client;

  // Vérifie si l'utilisateur est authentifié
  static bool get isAuthenticated => _client.auth.currentSession != null;

  // Stream des changements d'état d'authentification
  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // 🔐 Connexion avec Google OAuth - Configuration correcte pour Web
  static Future<bool> signInWithProvider() async {
    try {
      debugPrint('🚀 Connexion OAuth Google - Mobile');

      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'kisolo://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      debugPrint('✅ OAuth initié: $response');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur OAuth: $e');
      return false;
    }
  }

  static Future<bool> signOut() async {
    try {
      await _client.auth.signOut();
      await _clearLocalProfile();
      return true;
    } catch (e) {
      return false;
    }
  }

  static User? get currentUser => _client.auth.currentUser;

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      // Try to get from Supabase first
      final user = currentUser;
      if (user != null) {
        final response = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        await _cacheProfileLocally(response);
        return response;
      }

      // Fallback to local cache if no internet
      return await _getCachedProfile();
    } catch (e) {
      return await _getCachedProfile();
    }
  }

  static Future<bool> createUserProfile({
    required String name,
    required String gender,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final profile = {
        'id': user.id,
        'name': name,
        'gender': gender,
        'points': 0,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _client.from('profiles').upsert(profile);

      await _cacheProfileLocally(profile);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateUserProfile({
    String? name,
    String? gender,
    int? points,
  }) async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (gender != null) updates['gender'] = gender;
      if (points != null) updates['points'] = points;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', user.id);

      // Update local cache
      final cachedProfile = await _getCachedProfile();
      if (cachedProfile != null) {
        cachedProfile.addAll(updates);
        await _cacheProfileLocally(cachedProfile);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _cacheProfileLocally(Map<String, dynamic> profile) async {
    await LocalStorageService.saveUserProfile(profile);
    if (profile['access_token'] != null) {
      await LocalStorageService.saveAuthToken(profile['access_token']);
    }
  }

  static Future<Map<String, dynamic>?> _getCachedProfile() async {
    return LocalStorageService.getUserProfile();
  }

  static Future<void> _clearLocalProfile() async {
    await LocalStorageService.clearAll();
  }
}