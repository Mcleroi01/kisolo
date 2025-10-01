import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isProcessing = true;
  String _status = 'Traitement de la connexion...';

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  Future<void> _handleAuthCallback() async {
    try {
      debugPrint('🔐 AuthCallbackScreen: Début du traitement');
      
      // 1️⃣ Attendre un court instant pour que Supabase traite l'URL
      await Future.delayed(const Duration(milliseconds: 800));

      // 2️⃣ Vérifier immédiatement si on a une session
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        debugPrint('✅ Session trouvée: ${session.user.email}');
        _navigateToHome();
        return;
      }

      // 3️⃣ Si pas de session, attendre un peu plus longtemps
      debugPrint('⏳ Pas de session immédiate, attente supplémentaire...');
      setState(() {
        _status = 'Finalisation...';
      });

      await Future.delayed(const Duration(seconds: 2));

      // 4️⃣ Vérifier à nouveau
      final sessionRetry = Supabase.instance.client.auth.currentSession;
      
      if (sessionRetry != null) {
        debugPrint('✅ Session trouvée après retry: ${sessionRetry.user.email}');
        _navigateToHome();
        return;
      }

      // 5️⃣ Si toujours pas de session, écouter les changements
      debugPrint('👂 Écoute des changements d\'état...');
      _listenToAuthChanges();

    } catch (e, stack) {
      debugPrint('❌ Erreur dans handleAuthCallback: $e');
      debugPrint('Stack: $stack');
      _navigateToOnboarding('Erreur technique: ${e.toString()}');
    }
  }

  void _listenToAuthChanges() {
    final subscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!mounted || !_isProcessing) return;

        final session = data.session;
        final event = data.event;
        
        debugPrint('📢 Auth event reçu: $event');

        if (session != null) {
          debugPrint('✅ Session reçue via stream: ${session.user.email}');
          _navigateToHome();
        } else if (event == AuthChangeEvent.signedOut) {
          debugPrint('❌ SignedOut reçu');
          _navigateToOnboarding('Connexion échouée');
        }
      },
    );

    // 6️⃣ Timeout de sécurité (15 secondes max)
    Future.delayed(const Duration(seconds: 15), () {
      subscription.cancel();
      if (mounted && _isProcessing) {
        debugPrint('⏱️ Timeout atteint sans session');
        _navigateToOnboarding('La connexion a pris trop de temps');
      }
    });
  }

  void _navigateToHome() {
    if (!mounted || !_isProcessing) return;
    setState(() => _isProcessing = false);
    
    debugPrint('🏠 Navigation vers /home');
    context.go('/home');
  }

  void _navigateToOnboarding(String error) {
    if (!mounted || !_isProcessing) return;
    setState(() => _isProcessing = false);
    
    debugPrint('🔙 Navigation vers /onboarding - Raison: $error');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
    
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ou illustration
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_open,
                size: 50,
                color: Color(0xFFFF6B35),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Spinner
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B35)),
              strokeWidth: 3,
            ),
            
            const SizedBox(height: 24),
            
            // Statut
            Text(
              _status,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              'Veuillez patienter...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
