// lib/features/task/domain/cubit/task_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:employee_scheduler/features/task/domain/models/slot_model.dart';
import 'package:employee_scheduler/features/task/domain/models/task_model.dart';
import 'package:employee_scheduler/features/task/domain/models/user_model.dart' as user_model;
import 'package:employee_scheduler/features/task/domain/repository/task_repository.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository taskRepository;
  List<user_model.User> _selectedCollaborators = [];
  int _selectedDuration = 30;
  List<AvailableSlot> _availableSlots = [];
  AvailableSlot? _selectedSlot;
  List<Task> _tasks = [];

  TaskCubit({required this.taskRepository}) : super(TaskInitial());

  // Existing methods
  Future<void> createTask(Task task) async {
    emit(TaskLoading());
    try {
      await taskRepository.createTask(task);
      emit(TaskCreated());
      // Reload tasks after creating a new one
      await loadTasks(task.createdBy);
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

  Future<void> loadUsers() async {
  print('🔄 loadUsers() called from:');
  print(StackTrace.current); // This will show where it's called from
  
  emit(TaskLoading());
  
  try {
    final users = await taskRepository.getUsers();
    emit(UsersLoaded(users));
  } catch (e) {
    emit(TaskError(e.toString()));
  }
}

  void toggleCollaborator(user_model.User user) {
  print('🔄 Toggling collaborator: ${user.name}');
  
  if (_selectedCollaborators.any((u) => u.id == user.id)) {
    _selectedCollaborators.removeWhere((u) => u.id == user.id);
    print('❌ Removed collaborator: ${user.name}');
  } else {
    _selectedCollaborators.add(user);
    print('✅ Added collaborator: ${user.name}');
  }
  
  print('📊 Selected collaborators count: ${_selectedCollaborators.length}');
  
  // Clear available slots when collaborators change
  _availableSlots.clear();
  _selectedSlot = null;
  
  // Only emit CollaboratorsUpdated - DO NOT emit UsersLoaded
  emit(CollaboratorsUpdated([..._selectedCollaborators]));
}

  void clearCollaborators() {
    _selectedCollaborators.clear();
    emit(CollaboratorsUpdated([]));
  }

  void updateDuration(int duration) {
    _selectedDuration = duration;
    emit(DurationUpdated(_selectedDuration));
  }

  Future<void> calculateAvailableSlots() async {
  emit(TaskLoading());
  try {
    print('🔄 Starting calculateAvailableSlots...');
    print('👥 Selected collaborators: ${_selectedCollaborators.length}');
    print('⏱️ Selected duration: $_selectedDuration minutes');

    // Get availability for all selected collaborators
    final allAvailability = await _getAllCollaboratorAvailability();
    print('📅 Fetched availability for ${allAvailability.length} collaborators');
    
    // Calculate common available slots
    _availableSlots = _findCommonSlots(
      allAvailability: allAvailability,
      duration: _selectedDuration,
      collaboratorIds: _selectedCollaborators.map((u) => u.id).toList(),
    );

    print('🎯 Found ${_availableSlots.length} common slots');
    
    if (_availableSlots.isNotEmpty) {
      for (var slot in _availableSlots) {
        print('⏰ Slot: ${slot.startTime} to ${slot.endTime}');
      }
    } else {
      print('❌ No common slots found');
    }

    emit(SlotsCalculated([..._availableSlots]));
    print('✅ Slots calculation completed');
  } catch (e) {
    print('💥 ERROR in calculateAvailableSlots: $e');
    emit(TaskError('Failed to calculate slots: $e'));
  }
}

  void selectSlot(AvailableSlot slot) {
    _selectedSlot = slot;
    // You could emit a state here if you want to show selection visually
  }

  // NEW METHOD: Load tasks for user
  Future<void> loadTasks(String userId) async {
    emit(TaskLoading());
    try {
      _tasks = await taskRepository.getTasksForUser(userId);
      emit(TasksLoaded([..._tasks]));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  // NEW METHOD: Clear task creation state (useful when navigating away)
  void clearTaskCreationState() {
    _selectedCollaborators.clear();
    _selectedDuration = 30;
    _availableSlots.clear();
    _selectedSlot = null;
    emit(TaskInitial());
  }

  // Existing private methods
  Future<Map<String, List<Map<String, dynamic>>>> _getAllCollaboratorAvailability() async {
    final Map<String, List<Map<String, dynamic>>> allAvailability = {};

    for (final collaborator in _selectedCollaborators) {
      final availability = await taskRepository.getUserAvailability(collaborator.id);
      allAvailability[collaborator.id] = availability;
    }

    return allAvailability;
  }

  List<AvailableSlot> _findCommonSlots({
    required Map<String, List<Map<String, dynamic>>> allAvailability,
    required int duration,
    required List<String> collaboratorIds,
  }) {
    if (collaboratorIds.isEmpty) return [];

    // Get the next 7 days for slot calculation
    final now = DateTime.now();
    final daysToCheck = 7;
    final slots = <AvailableSlot>[];

    for (int day = 0; day < daysToCheck; day++) {
      final currentDate = DateTime(now.year, now.month, now.day + day);
      
      // Generate time slots for this day (9 AM to 6 PM)
      final daySlots = _generateTimeSlotsForDay(
        date: currentDate,
        duration: duration,
        allAvailability: allAvailability,
        collaboratorIds: collaboratorIds,
      );

      slots.addAll(daySlots);
    }

    return slots;
  }

  List<AvailableSlot> _generateTimeSlotsForDay({
    required DateTime date,
    required int duration,
    required Map<String, List<Map<String, dynamic>>> allAvailability,
    required List<String> collaboratorIds,
  }) {
    final slots = <AvailableSlot>[];
    const startHour = 9; // 9 AM
    const endHour = 18;  // 6 PM

    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += 15) { // Check every 15 minutes
        final slotStart = DateTime(date.year, date.month, date.day, hour, minute);
        final slotEnd = slotStart.add(Duration(minutes: duration));

        // Check if this slot is within working hours
        if (slotEnd.hour >= endHour && slotEnd.minute > 0) continue;

        // Check availability for all collaborators
        final availableUsers = _getAvailableUsersForSlot(
          slotStart: slotStart,
          slotEnd: slotEnd,
          allAvailability: allAvailability,
          collaboratorIds: collaboratorIds,
        );

        // If all collaborators are available, add this slot
        if (availableUsers.length == collaboratorIds.length) {
          slots.add(AvailableSlot(
            startTime: slotStart,
            endTime: slotEnd,
            duration: Duration(minutes: duration),
            availableUserIds: availableUsers,
          ));
        }
      }
    }

    return slots;
  }

  List<String> _getAvailableUsersForSlot({
    required DateTime slotStart,
    required DateTime slotEnd,
    required Map<String, List<Map<String, dynamic>>> allAvailability,
    required List<String> collaboratorIds,
  }) {
    final availableUsers = <String>[];

    for (final userId in collaboratorIds) {
      final userAvailability = allAvailability[userId] ?? [];
      
      // Check if user is available during this slot
      final isAvailable = userAvailability.any((availability) {
        final availabilityStart = availability['start_time'] as DateTime;
        final availabilityEnd = availability['end_time'] as DateTime;

        // Slot should be completely within availability period
        return (slotStart.isAfter(availabilityStart) || slotStart.isAtSameMomentAs(availabilityStart)) &&
               (slotEnd.isBefore(availabilityEnd) || slotEnd.isAtSameMomentAs(availabilityEnd));
      });

      if (isAvailable) {
        availableUsers.add(userId);
      }
    }

    return availableUsers;
  }

  // Getters
  List<user_model.User> get selectedCollaborators => _selectedCollaborators;
  int get selectedDuration => _selectedDuration;
  List<AvailableSlot> get availableSlots => _availableSlots;
  AvailableSlot? get selectedSlot => _selectedSlot;
  List<Task> get tasks => _tasks;
}