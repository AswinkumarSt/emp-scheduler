class Availability {
  final int id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;

  Availability({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
  });

  // Convert from JSON (Supabase response) to Dart object
  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convert to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  Duration get duration => endTime.difference(startTime);

  bool overlapsWith(Availability other) {
    return startTime.isBefore(other.endTime) && endTime.isAfter(other.startTime);
  }

  bool isSameDay(DateTime date) {
    return startTime.year == date.year &&
        startTime.month == date.month &&
        startTime.day == date.day;
  }

  @override
  String toString() {
    return 'Availability(id: $id, userId: $userId, start: $startTime, end: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Availability && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}