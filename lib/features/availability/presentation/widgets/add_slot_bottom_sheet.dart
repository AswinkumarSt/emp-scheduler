import 'package:flutter/material.dart';

class AddSlotBottomSheet extends StatefulWidget {
  final Function(DateTime, DateTime) onAddSlot;

  const AddSlotBottomSheet({super.key, required this.onAddSlot});

  @override
  State<AddSlotBottomSheet> createState() => _AddSlotBottomSheetState();
}

class _AddSlotBottomSheetState extends State<AddSlotBottomSheet> {
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        // Auto-adjust end time if it's before start time
        if (_endTime.hour < picked.hour || 
            (_endTime.hour == picked.hour && _endTime.minute <= picked.minute)) {
          _endTime = TimeOfDay(hour: picked.hour + 1, minute: picked.minute);
        }
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _addSlot() {
    final now = DateTime.now();
    final startDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _startTime.hour,
      _startTime.minute,
    );
    final endDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _endTime.hour,
      _endTime.minute,
    );

    if (endDateTime.isBefore(startDateTime) || endDateTime == startDateTime) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End time must be after start time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onAddSlot(startDateTime, endDateTime);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Add Availability Slot',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // Start Time
          Row(
            children: [
              const Text('Start Time:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _selectStartTime,
                child: Text(
                  _startTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // End Time
          Row(
            children: [
              const Text('End Time:', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _selectEndTime,
                child: Text(
                  _endTime.format(context),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Duration
          Text(
            'Duration: ${_calculateDuration()}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 24),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addSlot,
                  child: const Text('Add Slot'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _calculateDuration() {
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;
    final totalMinutes = endMinutes - startMinutes;
    
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }
}