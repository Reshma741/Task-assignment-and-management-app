import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/task_assignment.dart';
import '../models/notice.dart';

class RoleProvider with ChangeNotifier {
  List<TaskAssignment> _pendingAssignments = [];
  List<Notice> _notices = [];
  bool _isLoading = false;
  String? _error;

  List<TaskAssignment> get pendingAssignments => _pendingAssignments;
  List<Notice> get notices => _notices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get assignments pending approval for a specific user
  List<TaskAssignment> getPendingAssignmentsForUser(String userId) {
    return _pendingAssignments.where((assignment) => 
      assignment.assignedTo == userId && assignment.isPending
    ).toList();
  }

  // Get assignments that need approval from a specific user
  List<TaskAssignment> getAssignmentsNeedingApproval(String approverId) {
    return _pendingAssignments.where((assignment) => 
      assignment.isPending
    ).toList();
  }

  // Get notices visible to a specific role
  List<Notice> getNoticesForRole(UserRole role) {
    return _notices.where((notice) => 
      notice.isActive && 
      !notice.isExpired &&
      (notice.targetRoles.isEmpty || notice.targetRoles.contains(role.toString().split('.').last))
    ).toList();
  }

  // Check if user can assign task to another user
  bool canAssignTask(User assigner, User assignee) {
    switch (assigner.role) {
      case UserRole.ceo:
        return true; // CEO can assign to anyone
      case UserRole.projectManager:
        return true; // PM can assign to team members
      case UserRole.hr:
        return true; // HR can assign but needs CEO approval
      case UserRole.teamMember:
        return assigner.teamId == assignee.teamId; // Can only assign to peers in same team
    }
  }

  // Check if assignment needs approval
  bool needsApproval(User assigner, User assignee) {
    switch (assigner.role) {
      case UserRole.ceo:
      case UserRole.projectManager:
        return false; // No approval needed
      case UserRole.hr:
        return true; // Needs CEO approval
      case UserRole.teamMember:
        return true; // Needs PM approval
    }
  }

  // Get who can approve the assignment
  UserRole? getApproverRole(User assigner) {
    switch (assigner.role) {
      case UserRole.hr:
        return UserRole.ceo;
      case UserRole.teamMember:
        return UserRole.projectManager;
      default:
        return null; // No approval needed
    }
  }

  // Load pending assignments
  Future<void> loadPendingAssignments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      _pendingAssignments = [
        TaskAssignment(
          id: '1',
          taskId: 'task_1',
          assignedTo: 'user_2',
          assignedBy: 'user_3', // HR user
          status: AssignmentStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          notes: 'Please review this task assignment',
        ),
        TaskAssignment(
          id: '2',
          taskId: 'task_2',
          assignedTo: 'user_4',
          assignedBy: 'user_5', // Team member
          status: AssignmentStatus.pending,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          notes: 'Team member requesting to assign task to peer',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load pending assignments';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load notices
  Future<void> loadNotices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock data
      _notices = [
        Notice(
          id: '1',
          title: 'Company Holiday - New Year',
          content: 'The office will be closed on January 1st for New Year celebration.',
          type: NoticeType.holiday,
          postedBy: 'hr_user',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          scheduledDate: DateTime(2024, 1, 1),
          expiryDate: DateTime(2024, 1, 2),
          targetRoles: ['teamMember', 'projectManager'],
        ),
        Notice(
          id: '2',
          title: 'Happy Birthday John!',
          content: 'Today is John Doe\'s birthday. Let\'s wish him a great day!',
          type: NoticeType.birthday,
          postedBy: 'hr_user',
          createdAt: DateTime.now(),
          targetRoles: ['teamMember', 'projectManager', 'ceo'],
        ),
        Notice(
          id: '3',
          title: 'Team Meeting Tomorrow',
          content: 'We have a team meeting scheduled for tomorrow at 2 PM.',
          type: NoticeType.meeting,
          postedBy: 'pm_user',
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          scheduledDate: DateTime.now().add(const Duration(days: 1)),
          targetRoles: ['teamMember'],
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notices';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Approve task assignment
  Future<bool> approveAssignment(String assignmentId, String approverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _pendingAssignments.indexWhere((a) => a.id == assignmentId);
      if (index != -1) {
        _pendingAssignments[index] = _pendingAssignments[index].copyWith(
          status: AssignmentStatus.approved,
          approvedBy: approverId,
          approvedAt: DateTime.now(),
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to approve assignment';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reject task assignment
  Future<bool> rejectAssignment(String assignmentId, String approverId, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _pendingAssignments.indexWhere((a) => a.id == assignmentId);
      if (index != -1) {
        _pendingAssignments[index] = _pendingAssignments[index].copyWith(
          status: AssignmentStatus.rejected,
          approvedBy: approverId,
          approvedAt: DateTime.now(),
          rejectionReason: reason,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to reject assignment';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Create new notice
  Future<bool> createNotice(Notice notice) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _notices.add(notice);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to create notice';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete notice
  Future<bool> deleteNotice(String noticeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      _notices.removeWhere((notice) => notice.id == noticeId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete notice';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
