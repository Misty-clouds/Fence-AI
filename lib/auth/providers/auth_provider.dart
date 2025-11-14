import 'package:fence_ai/auth/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Provider for AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream provider to track authentication state
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.read(authServiceProvider);
  return repo.onAuthStateChange;
});

/// Current user provider (computed from auth state)
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider).asData?.value;
  return authState?.session?.user;
});


final authActionsProvider = Provider<AuthService>((ref) {
  return ref.read(authServiceProvider);
});

/// Provider for Google sign in
final googleSignInProvider = FutureProvider.autoDispose<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.signInWithGoogle();
});

/// Provider for Apple sign in
final appleSignInProvider = FutureProvider.autoDispose<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.signInWithApple();
});

final getUserRoleProvider = FutureProvider<String?>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return null; 
  final repo = ref.read(authServiceProvider);
  return repo.getUserRole(currentUser.id);
});



// This is meant to be used to choose userrole from the form only 
final userRoleProvider = StateProvider<String?>((ref) => null);