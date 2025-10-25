// lib/features/task/domain/cubit/task_state.dart


part of 'task_cubit.dart';

abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskCreated extends TaskState {}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

class UsersLoaded extends TaskState {
  final List<user_model.User> users;
  UsersLoaded(this.users);
}

class CollaboratorsUpdated extends TaskState {
  final List<user_model.User> collaborators;
  CollaboratorsUpdated(this.collaborators);
}

class DurationUpdated extends TaskState {
  final int duration;
  DurationUpdated(this.duration);
}

class SlotsCalculated extends TaskState {
  final List<AvailableSlot> slots;
  SlotsCalculated(this.slots);
}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  TasksLoaded(this.tasks);
}