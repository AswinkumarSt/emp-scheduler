import 'package:employee_scheduler/features/availability/data/models/availability_model.dart';
import 'package:flutter/material.dart';

class AvailabilitySlotItem extends StatelessWidget {
  final Availability availability;
  final VoidCallback onDelete;

  const AvailabilitySlotItem({
    super.key,
    required this.availability,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      child: ListTile(
        leading: const Icon(Icons.access_time, color: Colors.blue),
        title: Text(
          _formatTimeRange(availability.startTime, availability.endTime),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text('Duration: ${_formatDuration(availability.duration)}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }
}