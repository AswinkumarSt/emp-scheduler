// lib/features/task/presentation/pages/create_task_page.dart
import 'package:employee_scheduler/features/task/domain/cubit/task_cubit.dart';
import 'package:employee_scheduler/features/task/domain/models/task_model.dart';
import 'package:employee_scheduler/features/task/presentation/widgets/collaborator_selection_widget.dart';
import 'package:employee_scheduler/features/task/presentation/widgets/duration_selection_widget.dart';
import 'package:employee_scheduler/features/task/presentation/widgets/slot_selection_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateTaskPage extends StatefulWidget {
  final String currentUserId;

  const CreateTaskPage({super.key, required this.currentUserId});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Load users when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskCubit>().loadUsers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _createTask(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final taskCubit = context.read<TaskCubit>();
      final collaboratorIds = taskCubit.selectedCollaborators
          .map((u) => u.id)
          .toList();
      final selectedSlot = taskCubit.selectedSlot;

      final task = Task(
        title: _titleController.text,
        description: _descriptionController.text,
        createdBy: widget.currentUserId,
        createdAt: DateTime.now(),
        collaboratorIds: collaboratorIds,
        duration: taskCubit.selectedDuration,
        startTime: selectedSlot?.startTime,
        endTime: selectedSlot?.endTime,
        id: null,
      );

      taskCubit.createTask(task);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Task "${_titleController.text}" created successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  // Simplified validation without context dependency
  bool get _canProceedFromStep1 => _titleController.text.isNotEmpty;

  bool _canProceedFromStep2(BuildContext context) {
    final taskCubit = context.read<TaskCubit>();
    return taskCubit.selectedCollaborators.isNotEmpty;
  }

  bool _canProceedFromStep3(BuildContext context) {
    return true; // Duration always has a default value
  }

  bool _canProceedFromStep4(BuildContext context) {
    final taskCubit = context.read<TaskCubit>();
    return taskCubit.selectedSlot != null;
  }

  bool _canProceedToNextStep(BuildContext context) {
    switch (_currentStep) {
      case 0: // Task details
        return _canProceedFromStep1;
      case 1: // Collaborators
        return _canProceedFromStep2(context);
      case 2: // Duration
        return _canProceedFromStep3(context);
      case 3: // Time slot
        return _canProceedFromStep4(context);
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Stepper indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIndicator(0, 'Details', _currentStep >= 0),
                    _buildStepIndicator(1, 'Team', _currentStep >= 1),
                    _buildStepIndicator(2, 'Duration', _currentStep >= 2),
                    _buildStepIndicator(3, 'Time', _currentStep >= 3),
                  ],
                ),
                const SizedBox(height: 24),

                // Step content
                Expanded(
                  child: IndexedStack(
                    index: _currentStep,
                    children: [
                      _buildStep1(context), // Task Details
                      _buildStep2(context), // Collaborators
                      _buildStep3(context), // Duration
                      _buildStep4(context), // Time Slot
                    ],
                  ),
                ),

                // Navigation Buttons
                const SizedBox(height: 16),
                BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousStep,
                              child: const Text('Back'),
                            ),
                          ),
                        if (_currentStep > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _canProceedToNextStep(context)
                                ? (_currentStep < 3
                                      ? _nextStep
                                      : () => _createTask(context))
                                : null,
                            child: Text(
                              _currentStep < 3 ? 'Next' : 'Create Task',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Step validation info
                const SizedBox(height: 8),
                BlocBuilder<TaskCubit, TaskState>(
                  builder: (context, state) {
                    return _buildStepValidationInfo(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNumber, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${stepNumber + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepValidationInfo(BuildContext context) {
    final taskCubit = context.read<TaskCubit>();

    String message = '';
    Color color = Colors.grey;

    switch (_currentStep) {
      case 0:
        message = _titleController.text.isEmpty
            ? 'Enter task title to continue'
            : 'Ready to continue';
        color = _titleController.text.isNotEmpty ? Colors.green : Colors.orange;
        break;
      case 1:
        final count = taskCubit.selectedCollaborators.length;
        message = count == 0
            ? 'Select at least one collaborator'
            : '$count collaborator${count > 1 ? 's' : ''} selected - Ready to continue';
        color = count > 0 ? Colors.green : Colors.orange;
        break;
      case 2:
        message =
            '${taskCubit.selectedDuration} minutes selected - Ready to continue';
        color = Colors.green;
        break;
      case 3:
        final hasSelectedSlot = taskCubit.selectedSlot != null;
        message = hasSelectedSlot
            ? 'Time slot selected - Ready to create task'
            : 'Select a time slot to continue';
        color = hasSelectedSlot ? Colors.green : Colors.orange;
        break;
    }

    return Text(
      message,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStep1(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 1: Task Details',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),

        // Task Title
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Task Title *',
            border: OutlineInputBorder(),
            hintText: 'Enter task title...',
          ),
          onChanged: (value) {
            // Force rebuild when text changes to update button state
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a task title';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Task Description
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description (Optional)',
            border: OutlineInputBorder(),
            hintText: 'Enter task description...',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildStep2(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        return const CollaboratorSelectionWidget();
      },
    );
  }

  Widget _buildStep3(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        return const DurationSelectionWidget();
      },
    );
  }

  Widget _buildStep4(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        return SlotSelectionWidget(
          onSlotSelected: () {
            // Force rebuild to update button state when slot is selected
            setState(() {});
          },
        );
      },
    );
  }
}
