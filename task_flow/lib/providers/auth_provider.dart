import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._prefs) {
    _loadUserFromStorage();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void _loadUserFromStorage() {
    final userJson = _prefs.getString('current_user');
    if (userJson != null) {
      try {
        // In a real app, you'd parse JSON here
        // For demo purposes, we'll create a mock user
        _currentUser = User(
          id: '1',
          name: 'John Doe',
          email: 'john.doe@example.com',
          role: UserRole.projectManager,
          createdAt: DateTime.now(),
          department: 'Engineering',
          teamId: 'team_1',
        );
        notifyListeners();
      } catch (e) {
        _error = 'Failed to load user data';
        notifyListeners();
      }
    }
  }

  static const String _apiBase = 'http://localhost:5000';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uri = Uri.parse('$_apiBase/api/users/login');
      final res = await http.post(
        uri,
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'email': email, 'password': password })
      );

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final data = jsonDecode(res.body)['data'];
        final userJson = data['user'];
        _currentUser = User(
          id: userJson['_id'] ?? userJson['id'],
          name: userJson['name'],
          email: userJson['email'],
          role: UserRole.values.firstWhere(
            (e) => e.toString() == 'UserRole.' + (userJson['role'] ?? 'teamMember'),
            orElse: () => UserRole.teamMember,
          ),
          avatar: userJson['avatar'],
          createdAt: DateTime.parse(userJson['createdAt'] ?? DateTime.now().toIso8601String()),
          isActive: userJson['isActive'] ?? true,
          department: userJson['department'],
          teamId: userJson['teamId']?.toString(),
        );
        await _prefs.setString('current_user', jsonEncode(userJson));
        await _prefs.setBool('is_logged_in', true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final msg = jsonDecode(res.body)['message'] ?? 'Login failed';
        _error = msg;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear stored data
      await _prefs.remove('current_user');
      await _prefs.remove('is_logged_in');

      _currentUser = null;
      _error = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

