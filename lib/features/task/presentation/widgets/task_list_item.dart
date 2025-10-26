import 'package:employee_scheduler/features/task/domain/models/task_model.dart';
import 'package:flutter/material.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(task),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
            ],
            if (task.startTime != null) 
              Text('Time: ${_formatTime(task.startTime!)} - ${_formatTime(task.endTime!)}'),
            Text('Collaborators: ${task.collaboratorIds.length}'),
            Text('Created: ${_formatDate(task.createdAt)}'),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          // TODO: Navigate to task details page
          // Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailsPage(task: task)));
        },
      ),
    );
  }

  Color _getStatusColor(Task task) {
    if (task.endTime != null && task.endTime!.isBefore(DateTime.now())) {
      return Colors.green; // Completed
    } else if (task.startTime != null && task.startTime!.isBefore(DateTime.now())) {
      return Colors.orange; // In progress
    }
    return Colors.blue; // Upcoming
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}