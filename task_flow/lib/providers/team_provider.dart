import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/user.dart';

class TeamProvider with ChangeNotifier {
  List<Team> _teams = [];
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<Team> get teams => _teams;
  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTeams() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _teams = [
        Team(
          id: '1',
          name: 'Frontend Team',
          description: 'Responsible for UI/UX development',
          leaderId: '1',
          memberIds: ['1', '2', '3'],
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
        Team(
          id: '2',
          name: 'Backend Team',
          description: 'Server-side development and APIs',
          leaderId: '2',
          memberIds: ['2', '4', '5'],
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
        ),
        Team(
          id: '3',
          name: 'QA Team',
          description: 'Quality assurance and testing',
          leaderId: '3',
          memberIds: ['3', '6'],
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load teams';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _users = [
        User(
          id: '1',
          name: 'John Doe',
          email: 'john.doe@example.com',
          role: UserRole.projectManager,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          department: 'Engineering',
          teamId: 'team_1',
        ),
        User(
          id: '2',
          name: 'Jane Smith',
          email: 'jane.smith@example.com',
          role: UserRole.teamMember,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          department: 'Engineering',
          teamId: 'team_1',
        ),
        User(
          id: '3',
          name: 'Mike Johnson',
          email: 'mike.johnson@example.com',
          role: UserRole.teamMember,
          createdAt: DateTime.now().subtract(const Duration(days: 40)),
          department: 'Design',
          teamId: 'team_2',
        ),
        User(
          id: '4',
          name: 'Sarah Wilson',
          email: 'sarah.wilson@example.com',
          role: UserRole.teamMember,
          createdAt: DateTime.now().subtract(const Duration(days: 35)),
          department: 'Engineering',
          teamId: 'team_1',
        ),
        User(
          id: '5',
          name: 'David Brown',
          email: 'david.brown@example.com',
          role: UserRole.teamMember,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          department: 'Engineering',
          teamId: 'team_1',
        ),
        User(
          id: '6',
          name: 'Lisa Davis',
          email: 'lisa.davis@example.com',
          role: UserRole.teamMember,
          createdAt: DateTime.now().subtract(const Duration(days: 25)),
          department: 'QA',
          teamId: 'team_3',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTeam(Team team) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _teams.add(team);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add team';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTeam(Team updatedTeam) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _teams.indexWhere((team) => team.id == updatedTeam.id);
      if (index != -1) {
        _teams[index] = updatedTeam;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update team';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTeam(String teamId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _teams.removeWhere((team) => team.id == teamId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete team';
      _isLoading = false;
      notifyListeners();
    }
  }

  User? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Team? getTeamById(String teamId) {
    try {
      return _teams.firstWhere((team) => team.id == teamId);
    } catch (e) {
      return null;
    }
  }

  List<User> getTeamMembers(String teamId) {
    final team = getTeamById(teamId);
    if (team == null) return [];
    
    return team.memberIds
        .map((userId) => getUserById(userId))
        .where((user) => user != null)
        .cast<User>()
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

