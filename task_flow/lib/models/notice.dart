import 'package:flutter/material.dart';

enum NoticeType {
  holiday,
  birthday,
  announcement,
  meeting,
  general,
}

class Notice {
  final String id;
  final String title;
  final String content;
  final NoticeType type;
  final String postedBy;
  final DateTime createdAt;
  final DateTime? scheduledDate;
  final DateTime? expiryDate;
  final bool isActive;
  final List<String> targetRoles; // Which roles should see this notice
  final String? imageUrl;
  final List<String> attachments;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.postedBy,
    required this.createdAt,
    this.scheduledDate,
    this.expiryDate,
    this.isActive = true,
    this.targetRoles = const [],
    this.imageUrl,
    this.attachments = const [],
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      type: NoticeType.values.firstWhere(
        (e) => e.toString() == 'NoticeType.${json['type']}',
        orElse: () => NoticeType.general,
      ),
      postedBy: json['postedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      isActive: json['isActive'] ?? true,
      targetRoles: List<String>.from(json['targetRoles'] ?? []),
      imageUrl: json['imageUrl'],
      attachments: List<String>.from(json['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type.toString().split('.').last,
      'postedBy': postedBy,
      'createdAt': createdAt.toIso8601String(),
      'scheduledDate': scheduledDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'isActive': isActive,
      'targetRoles': targetRoles,
      'imageUrl': imageUrl,
      'attachments': attachments,
    };
  }

  Notice copyWith({
    String? id,
    String? title,
    String? content,
    NoticeType? type,
    String? postedBy,
    DateTime? createdAt,
    DateTime? scheduledDate,
    DateTime? expiryDate,
    bool? isActive,
    List<String>? targetRoles,
    String? imageUrl,
    List<String>? attachments,
  }) {
    return Notice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      postedBy: postedBy ?? this.postedBy,
      createdAt: createdAt ?? this.createdAt,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      targetRoles: targetRoles ?? this.targetRoles,
      imageUrl: imageUrl ?? this.imageUrl,
      attachments: attachments ?? this.attachments,
    );
  }

  Color get typeColor {
    switch (type) {
      case NoticeType.holiday:
        return Colors.green;
      case NoticeType.birthday:
        return Colors.pink;
      case NoticeType.announcement:
        return Colors.blue;
      case NoticeType.meeting:
        return Colors.orange;
      case NoticeType.general:
        return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case NoticeType.holiday:
        return Icons.celebration;
      case NoticeType.birthday:
        return Icons.cake;
      case NoticeType.announcement:
        return Icons.campaign;
      case NoticeType.meeting:
        return Icons.meeting_room;
      case NoticeType.general:
        return Icons.info;
    }
  }

  String get typeDisplayName {
    switch (type) {
      case NoticeType.holiday:
        return 'Holiday';
      case NoticeType.birthday:
        return 'Birthday';
      case NoticeType.announcement:
        return 'Announcement';
      case NoticeType.meeting:
        return 'Meeting';
      case NoticeType.general:
        return 'General';
    }
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isScheduled {
    if (scheduledDate == null) return false;
    return DateTime.now().isBefore(scheduledDate!);
  }
}
