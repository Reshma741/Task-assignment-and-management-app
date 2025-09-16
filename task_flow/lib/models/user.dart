enum UserRole {
  ceo,
  projectManager,
  hr,
  teamMember,
}

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? avatar;
  final DateTime createdAt;
  final bool isActive;
  final String? department;
  final String? teamId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    required this.createdAt,
    this.isActive = true,
    this.department,
    this.teamId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.teamMember,
      ),
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
      department: json['department'],
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last,
      'avatar': avatar,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'department': department,
      'teamId': teamId,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? avatar,
    DateTime? createdAt,
    bool? isActive,
    String? department,
    String? teamId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      department: department ?? this.department,
      teamId: teamId ?? this.teamId,
    );
  }

  // Role-based permission methods
  bool get canAssignTasksDirectly {
    return role == UserRole.ceo || role == UserRole.projectManager;
  }

  bool get canAssignTasksWithApproval {
    return role == UserRole.hr || role == UserRole.teamMember;
  }

  bool get canPostNotices {
    return role == UserRole.hr || role == UserRole.ceo;
  }

  bool get canApproveTaskAssignments {
    return role == UserRole.ceo || role == UserRole.projectManager;
  }

  bool get canViewAllTasks {
    return role == UserRole.ceo || role == UserRole.projectManager;
  }

  bool get canManageTeams {
    return role == UserRole.ceo || role == UserRole.projectManager;
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.ceo:
        return 'CEO';
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.hr:
        return 'HR';
      case UserRole.teamMember:
        return 'Team Member';
    }
  }
}

