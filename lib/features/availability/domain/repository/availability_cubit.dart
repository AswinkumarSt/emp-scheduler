import 'package:employee_scheduler/core/services/supabase_service.dart';
import 'package:employee_scheduler/features/availability/data/models/availability_model.dart';
import 'package:employee_scheduler/features/availability/data/repositories/availability_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'availability_state.dart';

class AvailabilityCubit extends Cubit<AvailabilityState> {
  final AvailabilityRepository _availabilityRepository;

  AvailabilityCubit() 
    : _availabilityRepository = AvailabilityRepository(SupabaseService()),
      super(const AvailabilityInitial());

  Future<void> loadUserAvailability(String userId) async {
    emit(const AvailabilityLoading());
    try {
      final availabilities = await _availabilityRepository.getUserAvailability(userId);
      emit(AvailabilityLoaded(availabilities));
    } catch (e) {
      emit(AvailabilityError('Failed to load availability: $e'));
    }
  }

  Future<void> addAvailability(
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    emit(const AvailabilityAdding());
    try {
      final hasOverlap = await _availabilityRepository.hasOverlappingSlot(
        userId, 
        startTime, 
        endTime
      );
      
      if (hasOverlap) {
        emit(const AvailabilityError('This time slot overlaps with existing availability'));
        return;
      }

      final newAvailability = await _availabilityRepository.addAvailability(
        userId,
        startTime,
        endTime,
      );
      
      emit(AvailabilityAdded(newAvailability));
      await loadUserAvailability(userId);
    } catch (e) {
      emit(AvailabilityError('Failed to add availability: $e'));
    }
  }

  Future<void> deleteAvailability(int availabilityId, String userId) async {
    emit(const AvailabilityDeleting());
    try {
      await _availabilityRepository.deleteAvailability(availabilityId);
      emit(const AvailabilityDeleted());
      await loadUserAvailability(userId);
    } catch (e) {
      emit(AvailabilityError('Failed to delete availability: $e'));
    }
  }

  void clearError() {
    final currentState = state;
    if (currentState is AvailabilityLoaded) {
      emit(currentState);
    } else {
      emit(const AvailabilityInitial());
    }
  }
}