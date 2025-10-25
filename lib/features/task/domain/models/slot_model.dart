// lib/features/task/domain/models/slot_model.dart
class AvailableSlot {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final List<String> availableUserIds;

  AvailableSlot({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.availableUserIds,
  });

  String get formattedTime {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String get formattedDate {
    return '${startTime.month}/${startTime.day}/${startTime.year}';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  String toString() {
    return 'AvailableSlot($formattedTime, ${availableUserIds.length} users)';
  }
}