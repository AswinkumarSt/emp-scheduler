// lib/features/task/domain/models/task_model.dart
class Task {
  final int? id; // Make id nullable for new tasks
  final String title;
  final String description;
  final String createdBy;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;
  final List<String> collaboratorIds;
  final int? duration;

  Task({
    this.id, // Not required for new tasks
    required this.title,
    required this.description,
    required this.createdBy,
    this.startTime,
    this.endTime,
    required this.createdAt,
    this.collaboratorIds = const [],
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'created_by': createdBy,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    String? createdBy,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? createdAt,
    List<String>? collaboratorIds,
    int? duration,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      duration: duration ?? this.duration,
    );
  }
}

// New User model for collaborators
class User {
  final String id;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    this.photoUrl,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id']?.toString() ?? '', // Handle null id
    name: json['name']?.toString() ?? 'Unknown', // Handle null name
    photoUrl: json['photo_url']?.toString(),
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now(), // Fallback for null date
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}