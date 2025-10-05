import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisolo/users/screens/onboarding_screen.dart';
import 'package:kisolo/lessons/screens/lesson_screen.dart';
import 'package:kisolo/users/services/auth_service.dart';
import 'package:kisolo/home/screens/auth_callback_screen.dart';
import 'package:kisolo/widgets/bottom_navigation.dart';
import 'package:kisolo/widgets/appbar.dart';

// Helper function to build app bar with user information
PreferredSizeWidget? _buildUserAppBar() {
  final currentUser = AuthService.currentUser;
  if (currentUser == null) return null;

  // Use user metadata for display name, with fallback
  final displayName = currentUser.userMetadata?['display_name'] ??
                     currentUser.userMetadata?['name'] ??
                     currentUser.userMetadata?['first_name'] ??
                     'Utilisateur';

  return CustomAppBar(
    title: displayName,
    subtitle: 'Niveau ya 3',
    logoAssetPath: 'assets/images/profile-man.png',
  );
}

final goRouter = GoRouter(
  initialLocation: '/onboarding',
  redirect: (BuildContext context, GoRouterState state) {
    final currentPath = state.uri.path;
    final queryParams = state.uri.queryParameters;

    // ⛔ CRITIQUE : Ne JAMAIS rediriger si on est dans le flux OAuth
    // Vérifie si on a des query params OAuth (code, state, etc.)
    if (currentPath == '/auth-callback' ||
        queryParams.containsKey('code') ||
        queryParams.containsKey('state')) {
      debugPrint('🔐 Flux OAuth détecté, pas de redirection');
      return null;
    }

    final isLoggedIn = AuthService.isAuthenticated;

    // Si pas connecté et pas sur onboarding -> onboarding
    if (!isLoggedIn && currentPath != '/onboarding') {
      return '/onboarding';
    }

    // Si connecté et sur onboarding -> home
    if (isLoggedIn && currentPath == '/onboarding') {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const BottomNavigation(
          initialIndex: 0,
        ),
      ),
    ),

    GoRoute(
      path: '/lessons',
      name: 'lessons-list',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const BottomNavigation(
          initialIndex: 1,
        ), // Démarre sur l'onglet leçons
      ),
    ),

    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const BottomNavigation(
          initialIndex: 2,
        ), // Démarre sur l'onglet profil
      ),
    ),

    GoRoute(
      path: '/lessons/:levelId/:lessonId',
      name: 'lessons',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: LessonScreen(
          levelId: state.pathParameters['levelId']!,
          lessonId: state.pathParameters['lessonId']!,
        ),
      ),
    ),

    // ⚠️ CRITIQUE : Cette route ne doit JAMAIS être redirigée
    GoRoute(
      path: '/auth-callback',
      name: 'auth-callback',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const AuthCallbackScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page non trouvée: ${state.uri}'),
    ),
  ),
);