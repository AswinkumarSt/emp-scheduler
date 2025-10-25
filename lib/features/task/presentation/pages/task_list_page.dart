// lib/features/task/presentation/pages/task_list_page.dart
import 'package:employee_scheduler/features/availability/presentation/pages/availability_page.dart';
import 'package:employee_scheduler/features/task/domain/cubit/task_cubit.dart';
import 'package:employee_scheduler/features/task/domain/models/task_model.dart';
import 'package:employee_scheduler/features/task/domain/repository/task_repository.dart';
import 'package:employee_scheduler/features/task/presentation/pages/create_task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskListPage extends StatefulWidget {
  final String userId;

  const TaskListPage({super.key, required this.userId});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _currentFilter = 'All'; // All, Created, Mine

  @override
  void initState() {
    
    super.initState();
    // Load tasks when page starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskCubit>().loadTasks(widget.userId);
    });
  }

  List<Task> _filterTasks(List<Task> tasks) {
    switch (_currentFilter) {
      case 'Created':
        return tasks.where((task) => task.createdBy == widget.userId).toList();
      case 'Mine':
        return tasks.where((task) => 
          task.createdBy == widget.userId || 
          task.collaboratorIds.contains(widget.userId)
        ).toList();
      case 'All':
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TaskCubit(
        taskRepository: TaskRepository(supabase: Supabase.instance.client),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvailabilityPage(userId: widget.userId),
                  ),
                );
              },
              tooltip: 'Manage Availability',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Filter Chips
              Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _currentFilter == 'All',
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = 'All';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Created'),
                    selected: _currentFilter == 'Created',
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = 'Created';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Mine'),
                    selected: _currentFilter == 'Mine',
                    onSelected: (selected) {
                      setState(() {
                        _currentFilter = 'Mine';
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tasks List
              Expanded(
                child: BlocConsumer<TaskCubit, TaskState>(
                  listener: (context, state) {
                    if (state is TaskCreated) {
                      // Reload tasks when a new task is created
                      context.read<TaskCubit>().loadTasks(widget.userId);
                    }
                  },
                  builder: (context, state) {
                    if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TaskError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<TaskCubit>().loadTasks(widget.userId);
                              },
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is TasksLoaded) {
                      final filteredTasks = _filterTasks(state.tasks);

                      if (filteredTasks.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.task, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _currentFilter == 'All' 
                                  ? 'No tasks found'
                                  : 'No ${_currentFilter.toLowerCase()} tasks',
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Create your first task to get started',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateTaskPage(currentUserId: widget.userId),
                                    ),
                                  );
                                },
                                child: const Text('Create First Task'),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<TaskCubit>().loadTasks(widget.userId);
                        },
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = filteredTasks[index];
                            return _buildTaskCard(task, context);
                          },
                        ),
                      );
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTaskPage(currentUserId: widget.userId),
              ),
            ).then((_) {
              // Refresh tasks when returning from create task page
              context.read<TaskCubit>().loadTasks(widget.userId);
            });
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (task.createdBy == widget.userId)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Creator',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (task.duration != null)
                  _buildInfoChip(
                    Icons.access_time,
                    '${task.duration} min',
                  ),
                _buildInfoChip(
                  Icons.people,
                  '${task.collaboratorIds.length} collaborator${task.collaboratorIds.length != 1 ? 's' : ''}',
                ),
                if (task.startTime != null && task.endTime != null) 
                  _buildInfoChip(
                    Icons.schedule,
                    '${_formatTime(task.startTime!)} - ${_formatTime(task.endTime!)}',
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(task.createdAt)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 16),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}