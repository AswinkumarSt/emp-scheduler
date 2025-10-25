// lib/features/task/presentation/widgets/duration_selection_widget.dart
import 'package:employee_scheduler/features/task/domain/cubit/task_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DurationSelectionWidget extends StatefulWidget {
  const DurationSelectionWidget({super.key});

  @override
  State<DurationSelectionWidget> createState() => _DurationSelectionWidgetState();
}

class _DurationSelectionWidgetState extends State<DurationSelectionWidget> {
  final List<int> _availableDurations = [10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        final taskCubit = context.read<TaskCubit>();
        final selectedDuration = taskCubit.selectedDuration;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Step 3: Choose Duration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select how long the task will take',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Duration options
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemCount: _availableDurations.length,
              itemBuilder: (context, index) {
                final duration = _availableDurations[index];
                final isSelected = selectedDuration == duration;

                return _buildDurationOption(
                  duration: duration,
                  isSelected: isSelected,
                  onTap: () => taskCubit.updateDuration(duration),
                );
              },
            ),

            // Selected duration info
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Duration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          _formatDuration(selectedDuration),
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Helper text
            const SizedBox(height: 16),
            Text(
              'This duration will be used to find available time slots for all collaborators',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDurationOption({
    required int duration,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.grey[50],
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$duration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
            Text(
              _getDurationLabel(duration),
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDurationLabel(int duration) {
    switch (duration) {
      case 10:
        return '10 minutes';
      case 15:
        return '15 minutes';
      case 30:
        return '30 minutes';
      case 60:
        return '1 hour';
      default:
        return '$duration minutes';
    }
  }

  String _formatDuration(int duration) {
    if (duration == 60) {
      return '1 hour';
    } else if (duration > 60) {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      if (minutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} $minutes minute${minutes > 1 ? 's' : ''}';
      }
    } else {
      return '$duration minute${duration > 1 ? 's' : ''}';
    }
  }
}