import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get tasks by status
  List<Task> getTasksByStatus(TaskStatus status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  // Get tasks assigned to a specific user
  List<Task> getTasksForUser(String userId) {
    return _tasks.where((task) => task.assignedTo == userId).toList();
  }

  // Get overdue tasks
  List<Task> get overdueTasks {
    return _tasks.where((task) => task.isOverdue).toList();
  }

  // Get high priority tasks
  List<Task> get highPriorityTasks {
    return _tasks.where((task) => 
      task.priority == TaskPriority.high || task.priority == TaskPriority.urgent
    ).toList();
  }

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.status == TaskStatus.completed).length;
  int get inProgressTasks => _tasks.where((task) => task.status == TaskStatus.inProgress).length;
  int get todoTasks => _tasks.where((task) => task.status == TaskStatus.todo).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / totalTasks;
  }

  Future<void> loadTasks() async {
    if (_isLoading) return; // Prevent multiple simultaneous loads
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      _tasks = [
        Task(
          id: '1',
          title: 'Design new dashboard UI',
          description: 'Create a modern and intuitive dashboard interface for the task management app',
          status: TaskStatus.inProgress,
          priority: TaskPriority.high,
          assignedTo: '1',
          assignedBy: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          dueDate: DateTime.now().add(const Duration(days: 3)),
          estimatedHours: 8,
          actualHours: 4,
          tags: ['UI/UX', 'Frontend'],
        ),
        Task(
          id: '2',
          title: 'Implement user authentication',
          description: 'Add login, registration, and password reset functionality',
          status: TaskStatus.todo,
          priority: TaskPriority.urgent,
          assignedTo: '2',
          assignedBy: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          dueDate: DateTime.now().add(const Duration(days: 1)),
          estimatedHours: 12,
          tags: ['Backend', 'Security'],
        ),
        Task(
          id: '3',
          title: 'Write unit tests',
          description: 'Create comprehensive unit tests for all components',
          status: TaskStatus.completed,
          priority: TaskPriority.medium,
          assignedTo: '3',
          assignedBy: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
          estimatedHours: 6,
          actualHours: 6,
          tags: ['Testing', 'Quality'],
        ),
        Task(
          id: '4',
          title: 'Database optimization',
          description: 'Optimize database queries and add proper indexing',
          status: TaskStatus.todo,
          priority: TaskPriority.medium,
          assignedTo: '2',
          assignedBy: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          dueDate: DateTime.now().add(const Duration(days: 5)),
          estimatedHours: 10,
          tags: ['Database', 'Performance'],
        ),
        Task(
          id: '5',
          title: 'Mobile app deployment',
          description: 'Deploy the mobile app to app stores',
          status: TaskStatus.cancelled,
          priority: TaskPriority.low,
          assignedTo: '4',
          assignedBy: '1',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          estimatedHours: 4,
          tags: ['Deployment', 'Mobile'],
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load tasks';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _tasks.add(task);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update task';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      _tasks.removeWhere((task) => task.id == taskId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task';
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

