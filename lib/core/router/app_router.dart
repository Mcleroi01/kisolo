import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kisolo/home/screens/home_screen.dart';
import 'package:kisolo/users/screens/onboarding_screen.dart';
import 'package:kisolo/lessons/screens/lesson_screen.dart';
import 'package:kisolo/users/screens/profile_screen.dart';
import 'package:kisolo/home/screens/auth_callback_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/onboarding',
  redirect: (BuildContext context, GoRouterState state) {
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
        child: const HomeScreen(), // Crée un vrai écran home
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

    GoRoute(
      path: '/profile',
      name: 'profile',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const ProfileScreen(),
      ),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page non trouvée: ${state.uri}'),
    ),
  ),
);
