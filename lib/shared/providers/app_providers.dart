import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kisolo/users/services/auth_service.dart';

// Auth State Model
class AuthState {
  final User? user;
  final bool isLoading;
  final Map<String, dynamic>? profile;

  const AuthState({
    this.user,
    this.isLoading = true,
    this.profile,
  });
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    // Listen to auth state changes
    AuthService.authStateChanges.listen((event) {
      final user = event.session?.user;
      state = AuthState(
        user: user,
        isLoading: false,
      );

      // Load user profile if logged in
      if (user != null) {
        _loadUserProfile();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService.getUserProfile();
    state = AuthState(
      user: state.user,
      isLoading: false,
      profile: profile,
    );
  }

  Future<bool> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    final success = await AuthService.signInWithProvider();
    if (!success) {
      state = const AuthState(isLoading: false);
    }
    return success;
  }

  Future<bool> signOut() async {
    state = const AuthState(isLoading: true);
    final success = await AuthService.signOut();
    if (success) {
      state = const AuthState(isLoading: false);
    } else {
      state = AuthState(user: state.user, isLoading: false);
    }
    return success;
  }

  Future<bool> createProfile({
    required String name,
    required String gender,
  }) async {
    final success = await AuthService.createUserProfile(
      name: name,
      gender: gender,
    );
    if (success) {
      await _loadUserProfile();
    }
    return success;
  }

  Future<bool> updateProfile({
    String? name,
    String? gender,
    int? points,
  }) async {
    final success = await AuthService.updateUserProfile(
      name: name,
      gender: gender,
      points: points,
    );
    if (success) {
      await _loadUserProfile();
    }
    return success;
  }
}

// User Profile Provider
final userProfileProvider = Provider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.profile;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

// Loading State Provider
final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.isLoading;
});
