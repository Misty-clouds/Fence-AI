import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/users_model.dart';

class UsersService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase.from('users').select();
      return (response as List).map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String id) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();
      
      if (response == null) return null;
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch user by email: $e');
    }
  }

  // Create new user
  Future<UserModel> createUser(UserModel user) async {
    try {
      final response = await _supabase
          .from('users')
          .insert(user.toJson())
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Update user
  Future<UserModel> updateUser(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('users')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    try {
      await _supabase.from('users').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;
      
      return await getUserById(userId);
    } catch (e) {
      throw Exception('Failed to fetch current user: $e');
    }
  }
}
