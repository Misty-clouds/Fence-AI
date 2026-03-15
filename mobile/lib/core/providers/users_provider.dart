import 'package:flutter/foundation.dart';
import '../models/users_model.dart';
import '../services/users_service.dart';

class UsersProvider with ChangeNotifier {
  final UsersService _usersService = UsersService();

  List<UserModel> _users = [];
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  List<UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all users
  Future<void> fetchAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _usersService.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch user by ID
  Future<UserModel?> fetchUserById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _usersService.getUserById(id);
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Fetch current user
  Future<void> fetchCurrentUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _usersService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create user
  Future<UserModel?> createUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newUser = await _usersService.createUser(user);
      _users.add(newUser);
      _isLoading = false;
      notifyListeners();
      return newUser;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Update user
  Future<UserModel?> updateUser(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _usersService.updateUser(id, updates);
      final index = _users.indexWhere((user) => user.id == id);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_currentUser?.id == id) {
        _currentUser = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
      return updatedUser;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Delete user
  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _usersService.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
      if (_currentUser?.id == id) {
        _currentUser = null;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear current user
  void clearCurrentUser() {
    _currentUser = null;
    notifyListeners();
  }
}
