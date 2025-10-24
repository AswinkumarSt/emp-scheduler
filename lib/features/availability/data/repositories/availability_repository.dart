import 'package:employee_scheduler/core/services/supabase_service.dart';
import 'package:employee_scheduler/features/availability/data/models/availability_model.dart';

class AvailabilityRepository {
  final SupabaseService _supabaseService;

  AvailabilityRepository(this._supabaseService);

  // Get all availability slots for a user
  Future<List<Availability>> getUserAvailability(String userId) async {
    try {
      final response = await _supabaseService.client
          .from('availability')
          .select()
          .eq('user_id', userId)
          .order('start_time', ascending: true);

      final List<Availability> availabilities = [];
      for (final item in response) {
        availabilities.add(Availability.fromJson(item));
      }
      return availabilities;
    } catch (e) {
      print('Error fetching availability: $e');
      throw Exception('Failed to fetch availability: $e');
    }
  }

  // Get all availability slots (for slot finding algorithm)
  Future<List<Availability>> getAllAvailability() async {
    try {
      final response = await _supabaseService.client
          .from('availability')
          .select()
          .order('start_time', ascending: true);

      final List<Availability> availabilities = [];
      for (final item in response) {
        availabilities.add(Availability.fromJson(item));
      }
      return availabilities;
    } catch (e) {
      print('Error fetching all availability: $e');
      throw Exception('Failed to fetch all availability: $e');
    }
  }

  // Add a new availability slot
  Future<Availability> addAvailability(
    String userId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Validate time range
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }

      if (endTime.difference(startTime).inMinutes < 15) {
        throw Exception('Time slot must be at least 15 minutes');
      }

      final response = await _supabaseService.client
          .from('availability')
          .insert({
            'user_id': userId,
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
          })
          .select()
          .single();

      return Availability.fromJson(response);
    } catch (e) {
      print('Error adding availability: $e');
      throw Exception('Failed to add availability: $e');
    }
  }

  // Update an existing availability slot
  Future<Availability> updateAvailability(
    int availabilityId,
    DateTime startTime,
    DateTime endTime,
  ) async {
    try {
      // Validate time range
      if (startTime.isAfter(endTime)) {
        throw Exception('Start time must be before end time');
      }

      if (endTime.difference(startTime).inMinutes < 15) {
        throw Exception('Time slot must be at least 15 minutes');
      }

      final response = await _supabaseService.client
          .from('availability')
          .update({
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
          })
          .eq('id', availabilityId)
          .select()
          .single();

      return Availability.fromJson(response);
    } catch (e) {
      print('Error updating availability: $e');
      throw Exception('Failed to update availability: $e');
    }
  }

  // Delete an availability slot
  Future<void> deleteAvailability(int availabilityId) async {
    try {
      await _supabaseService.client
          .from('availability')
          .delete()
          .eq('id', availabilityId);
    } catch (e) {
      print('Error deleting availability: $e');
      throw Exception('Failed to delete availability: $e');
    }
  }

  // Check for overlapping slots for a user
  Future<bool> hasOverlappingSlot(
    String userId,
    DateTime startTime,
    DateTime endTime,
    {int? excludeAvailabilityId}
  ) async {
    try {
      var query = _supabaseService.client
          .from('availability')
          .select()
          .eq('user_id', userId)
          .lt('start_time', endTime.toIso8601String())
          .gt('end_time', startTime.toIso8601String());

      if (excludeAvailabilityId != null) {
        query = query.neq('id', excludeAvailabilityId);
      }

      final response = await query;
      return response.isNotEmpty;
    } catch (e) {
      print('Error checking overlapping slots: $e');
      return false;
    }
  }
}