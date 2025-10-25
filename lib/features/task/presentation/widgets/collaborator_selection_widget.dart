// lib/features/task/presentation/widgets/collaborator_selection_widget.dart
import 'package:employee_scheduler/features/task/domain/cubit/task_cubit.dart';
import 'package:employee_scheduler/features/task/domain/models/user_model.dart' as user_model;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollaboratorSelectionWidget extends StatefulWidget {
  const CollaboratorSelectionWidget({super.key});

  @override
  State<CollaboratorSelectionWidget> createState() => _CollaboratorSelectionWidgetState();
}

class _CollaboratorSelectionWidgetState extends State<CollaboratorSelectionWidget> {
  List<user_model.User> _allUsers = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listener: (context, state) {
        // ONLY store users when UsersLoaded state occurs
        // DO NOT call loadUsers() here
        if (state is UsersLoaded) {
          _allUsers = state.users;
        }
      },
      builder: (context, state) {
        final taskCubit = context.read<TaskCubit>();
        final selectedCollaborators = taskCubit.selectedCollaborators;

        // Show UI for multiple states
        if (state is UsersLoaded || state is CollaboratorsUpdated || state is SlotsCalculated) {
          return _buildUserSelectionUI(_allUsers, selectedCollaborators, taskCubit);
        }

        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is TaskError) {
          return Column(
            children: [
              Text('Error: ${state.message}'),
              ElevatedButton(
                onPressed: () => taskCubit.loadUsers(),
                child: const Text('Retry'),
              ),
            ],
          );
        }

        // Load users only once when widget first builds
        if (_allUsers.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            taskCubit.loadUsers();
          });
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildUserSelectionUI(
    List<user_model.User> users,
    List<user_model.User> selectedCollaborators,
    TaskCubit taskCubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step 2: Choose Collaborators',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (selectedCollaborators.isNotEmpty)
              TextButton(
                onPressed: () => taskCubit.clearCollaborators(),
                child: const Text('Clear All'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select team members to collaborate with',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),

        // Selected collaborators chips
        if (selectedCollaborators.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedCollaborators.map((user) {
              return Chip(
                label: Text(user.name),
                onDeleted: () => taskCubit.toggleCollaborator(user),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Users list - ALWAYS show all users
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(maxHeight: 200),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = selectedCollaborators.any((u) => u.id == user.id);

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
                title: Text(user.name),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) => taskCubit.toggleCollaborator(user),
                ),
                onTap: () => taskCubit.toggleCollaborator(user),
              );
            },
          ),
        ),

        // Selection count
        const SizedBox(height: 8),
        Text(
          'Selected: ${selectedCollaborators.length} collaborator(s)',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}