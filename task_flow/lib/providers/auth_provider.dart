import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

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

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock authentication - in real app, this would be an API call
      if (email.isNotEmpty && password.isNotEmpty) {
        // Create different users based on email for testing
        UserRole role = UserRole.teamMember;
        String name = 'John Doe';
        String department = 'Engineering';
        String teamId = 'team_1';
        
        if (email.contains('ceo')) {
          role = UserRole.ceo;
          name = 'CEO User';
          department = 'Executive';
        } else if (email.contains('pm') || email.contains('manager')) {
          role = UserRole.projectManager;
          name = 'Project Manager';
          department = 'Engineering';
        } else if (email.contains('hr')) {
          role = UserRole.hr;
          name = 'HR Manager';
          department = 'Human Resources';
        } else if (email.contains('team')) {
          role = UserRole.teamMember;
          name = 'Team Member';
          department = 'Engineering';
        }

        _currentUser = User(
          id: '1',
          name: name,
          email: email,
          role: role,
          createdAt: DateTime.now(),
          department: department,
          teamId: teamId,
        );

        // Save user to storage
        await _prefs.setString('current_user', 'mock_user_data');
        await _prefs.setBool('is_logged_in', true);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
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

