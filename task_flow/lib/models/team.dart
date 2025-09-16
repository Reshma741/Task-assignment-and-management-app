class Team {
  final String id;
  final String name;
  final String description;
  final String leaderId;
  final List<String> memberIds;
  final DateTime createdAt;
  final bool isActive;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    this.memberIds = const [],
    required this.createdAt,
    this.isActive = true,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      memberIds: List<String>.from(json['memberIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Team copyWith({
    String? id,
    String? name,
    String? description,
    String? leaderId,
    List<String>? memberIds,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      leaderId: leaderId ?? this.leaderId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

