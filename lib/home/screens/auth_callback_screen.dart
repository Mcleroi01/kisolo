// auth_callback_screen.dart
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
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _handleAuthCallback();
  }

  void _handleAuthCallback() {
    // Annule tout listener existant
    _authSubscription?.cancel();

    // Écoute une seule fois avec take(1) ou firstWhere
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!mounted) return;

        final session = data.session;

        if (session != null) {
          // ✅ Utilisateur connecté
          context.go('/home');
        } else {
          // ❌ Échec de connexion
          context.go('/onboarding');
        }
      },
    );

    // Timeout de sécurité (30 secondes)
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && context.canPop()) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connexion en cours...'),
          ],
        ),
      ),
    );
  }
}
