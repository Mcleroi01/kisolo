import 'package:kisolo/core/config/supabase_config.dart';
import 'package:kisolo/users/services/auth_service.dart';

class DeepLinkService {
  static void handleInitialUri() {
    // Gérer l'URI initial au lancement
  }
  
  static void handleUriReceived(Uri uri) {
    // Gérer les URIs reçus pendant l'exécution
    if (uri.scheme == 'kisolo' && uri.host == 'auth') {
      // Traitement du callback d'authentification
      _handleAuthCallback(uri);
    }
  }
  
  static void _handleAuthCallback(Uri uri) {
    // Extraire les paramètres d'authentification et les traiter
    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];
    
    if (code != null) {
      // Échanger le code contre un token
      _exchangeCodeForToken(code);
    } else if (error != null) {
      // Gérer l'erreur d'authentification
      print('Erreur d\'authentification: $error');
    }
  }
  
  static Future<void> _exchangeCodeForToken(String code) async {
    try {
      // For Supabase OAuth with deep links, we need to handle the callback
      // The session should be automatically established when the user returns
      // to the app with the authorization code

      // Check if we have a valid session
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null && session.accessToken.isNotEmpty) {
        print('Authentication successful - session established');
        // Optionally refresh user profile
        await AuthService.getUserProfile();
      } else {
        print('No valid session found after callback');
      }
    } catch (e) {
      print('Error handling auth callback: $e');
      // Handle error appropriately
    }
  }
}