import 'package:flutter/material.dart';

enum AssignmentStatus {
  pending,
  approved,
  rejected,
}

class TaskAssignment {
  final String id;
  final String taskId;
  final String assignedTo;
  final String assignedBy;
  final String? approvedBy;
  final AssignmentStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? rejectionReason;
  final String? notes;

  TaskAssignment({
    required this.id,
    required this.taskId,
    required this.assignedTo,
    required this.assignedBy,
    this.approvedBy,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.rejectionReason,
    this.notes,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    return TaskAssignment(
      id: json['id'],
      taskId: json['taskId'],
      assignedTo: json['assignedTo'],
      assignedBy: json['assignedBy'],
      approvedBy: json['approvedBy'],
      status: AssignmentStatus.values.firstWhere(
        (e) => e.toString() == 'AssignmentStatus.${json['status']}',
        orElse: () => AssignmentStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      rejectionReason: json['rejectionReason'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'approvedBy': approvedBy,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
      'notes': notes,
    };
  }

  TaskAssignment copyWith({
    String? id,
    String? taskId,
    String? assignedTo,
    String? assignedBy,
    String? approvedBy,
    AssignmentStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? rejectionReason,
    String? notes,
  }) {
    return TaskAssignment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedBy: assignedBy ?? this.assignedBy,
      approvedBy: approvedBy ?? this.approvedBy,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      notes: notes ?? this.notes,
    );
  }

  Color get statusColor {
    switch (status) {
      case AssignmentStatus.pending:
        return Colors.orange;
      case AssignmentStatus.approved:
        return Colors.green;
      case AssignmentStatus.rejected:
        return Colors.red;
    }
  }

  String get statusText {
    switch (status) {
      case AssignmentStatus.pending:
        return 'Pending Approval';
      case AssignmentStatus.approved:
        return 'Approved';
      case AssignmentStatus.rejected:
        return 'Rejected';
    }
  }

  bool get isPending => status == AssignmentStatus.pending;
  bool get isApproved => status == AssignmentStatus.approved;
  bool get isRejected => status == AssignmentStatus.rejected;
}
