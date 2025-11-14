import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    String name,
    String? role,
  ) async {
    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      return signUp(email, password, name, role);
    } else {
      throw Exception("All fields are required for sign up");
    }
  }

  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
    String? role,
  ) async {
    try {
      final AuthResponse authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'role': role ?? 'user', 'name': name},
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create auth user');
      }

      // Step 2: Create the user profile in public.users table

      await supabase.from('users').insert({
        'id': authResponse.user!.id,
        'email': email,
        'name': name,
        'role': role ?? 'user',
      });

      return authResponse;
    } on AuthException {
      rethrow;
    } catch (e) {
      try {
        await supabase.auth.signOut();
      } catch (_) {}
      throw Exception('Failed to sign up user: $e');
    }
  }

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithMagicLink(String email) async {
    await supabase.auth.signInWithOtp(email: email);
  }

  /// Sign in with Google using OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.fenceai://login-callback',
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Google sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  /// Sign in with Apple using OAuth
  Future<bool> signInWithApple() async {
    try {
      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.fenceai://login-callback',
      );
      return response;
    } on AuthException catch (e) {
      throw Exception('Apple sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('Apple sign in failed: $e');
    }
  }

  /// Handle OAuth callback from deep link
  Future<void> handleOAuthCallback(Uri uri) async {
    try {
      await supabase.auth.getSessionFromUrl(uri);
    } catch (e) {
      throw Exception('Failed to handle OAuth callback: $e');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  String? getCurrentUserEmail() {
    return supabase.auth.currentUser?.email;
  }

  Future<String?> getUserRole(String userId) async {
    final response = await supabase
        .from('users')
        .select('role')
        .eq('id', userId)
        .single();
    return response['role'] as String?;
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Stream<AuthState> get onAuthStateChange => supabase.auth.onAuthStateChange;
}
