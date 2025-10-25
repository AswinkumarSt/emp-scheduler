// lib/features/task/domain/repository/task_repository.dart
import 'package:employee_scheduler/features/task/domain/models/task_model.dart';
import 'package:employee_scheduler/features/task/domain/models/user_model.dart' as user_model; // Add prefix
import 'package:supabase_flutter/supabase_flutter.dart' hide User; // Hide Supabase User

class TaskRepository {
  final SupabaseClient supabase;

  TaskRepository({required this.supabase});

  Future<void> createTask(Task task) async {
    try {
      print('Creating task: ${task.title}');

      // 1. Insert the main task
      final taskResponse = await supabase
          .from('tasks')
          .insert({
            'title': task.title,
            'description': task.description,
            'created_by': task.createdBy,
            'start_time': task.startTime?.toIso8601String(),
            'end_time': task.endTime?.toIso8601String(),
            'created_at': task.createdAt.toIso8601String(),
          })
          .select()
          .single();

      final taskId = taskResponse['id'] as int;
      print('Task created with ID: $taskId');

      // 2. Insert task collaborators if any
      if (task.collaboratorIds.isNotEmpty) {
        final collaboratorData = task.collaboratorIds.map((userId) => {
          'task_id': taskId,
          'user_id': userId,
        }).toList();

        await supabase
            .from('task_collaborators')
            .insert(collaboratorData);

        print('Added ${task.collaboratorIds.length} collaborators to task $taskId');
      }

      print('Task creation completed successfully');
    } catch (e) {
      print('Error creating task: $e');
      rethrow;
    }
  }

  // Use the prefixed User class
  Future<List<user_model.User>> getUsers() async {
    try {
      print('🔄 Starting getUsers()...');
      
      final response = await supabase
          .from('users')
          .select()
          .order('name');

      print('✅ Supabase query completed');
      print('📊 Response type: ${response.runtimeType}');
      
      if (response == null) {
        print('❌ Response is null');
        throw Exception('No response from server');
      }
      
      if (response is! List) {
        print('❌ Response is not a List: $response');
        throw Exception('Invalid response format');
      }
      
      if (response.isEmpty) {
        print('ℹ️ No users found in database');
        return [];
      }
      
      print('👥 Processing ${response.length} users...');
      
      final List<user_model.User> users = [];
      
      for (var i = 0; i < response.length; i++) {
        try {
          final item = response[i];
          print('Processing user $i: $item');
          
          if (item is Map<String, dynamic>) {
            final user = user_model.User.fromJson(item); // Use prefixed User
            users.add(user);
            print('✅ Added user: ${user.name}');
          } else {
            print('❌ User $i is not a Map: ${item.runtimeType}');
          }
        } catch (e) {
          print('❌ Error processing user $i: $e');
        }
      }
      
      print('🎉 Successfully loaded ${users.length} users');
      return users;
      
    } catch (e) {
      print('💥 CRITICAL ERROR in getUsers(): $e');
      print('Stack trace: ${e.toString()}');
      throw Exception('Failed to load users: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserAvailability(String userId) async {
    try {
      print('Fetching availability for user: $userId');
      
      final response = await supabase
          .from('availability')
          .select()
          .eq('user_id', userId)
          .order('start_time');

      if (response == null) {
        return [];
      }

      final availabilityData = response as List<dynamic>;
      print('Found ${availabilityData.length} availability slots for user $userId');

      return availabilityData.map((availability) {
        final Map<String, dynamic> availabilityMap = availability as Map<String, dynamic>;
        return {
          'id': availabilityMap['id'] as int,
          'user_id': availabilityMap['user_id'] as String,
          'start_time': DateTime.parse(availabilityMap['start_time'] as String),
          'end_time': DateTime.parse(availabilityMap['end_time'] as String),
          'created_at': DateTime.parse(availabilityMap['created_at'] as String),
        };
      }).toList();
    } catch (e) {
      print('Error fetching availability for user $userId: $e');
      rethrow;
    }
  }

  Future<List<Task>> getTasksForUser(String userId) async {
    try {
      print('Fetching tasks for user: $userId');
      
      // Get tasks where user is creator OR collaborator
      final response = await supabase
          .from('tasks')
          .select('''
            *,
            task_collaborators!inner(*)
          ''')
          .or('created_by.eq.$userId,task_collaborators.user_id.eq.$userId')
          .order('created_at', ascending: false);

      if (response == null) {
        return [];
      }

      final tasksData = response as List<dynamic>;
      print('Found ${tasksData.length} tasks for user $userId');

      return tasksData.map((taskJson) {
        final Map<String, dynamic> taskMap = taskJson as Map<String, dynamic>;
        
        // Extract collaborator IDs safely
        final collaboratorsData = taskMap['task_collaborators'] as List<dynamic>? ?? [];
        final collaborators = collaboratorsData
            .map((collab) => (collab as Map<String, dynamic>)['user_id'] as String)
            .toList();

        return Task(
          id: taskMap['id'] as int? ?? 0, // Handle null case
          title: taskMap['title'] as String,
          description: taskMap['description'] as String? ?? '',
          createdBy: taskMap['created_by'] as String,
          startTime: taskMap['start_time'] != null 
              ? DateTime.parse(taskMap['start_time'] as String)
              : null,
          endTime: taskMap['end_time'] != null
              ? DateTime.parse(taskMap['end_time'] as String)
              : null,
          createdAt: DateTime.parse(taskMap['created_at'] as String),
          collaboratorIds: collaborators,
          duration: taskMap['start_time'] != null && taskMap['end_time'] != null
              ? DateTime.parse(taskMap['end_time'] as String)
                  .difference(DateTime.parse(taskMap['start_time'] as String))
                  .inMinutes
              : null,
        );
      }).toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      rethrow;
    }
  }

  // Additional useful methods:

  Future<void> updateTask(Task task) async {
    try {
      // Check if task has an ID
      if (task.id == null) {
        throw Exception('Cannot update task without ID');
      }

      await supabase
          .from('tasks')
          .update({
            'title': task.title,
            'description': task.description,
            'start_time': task.startTime?.toIso8601String(),
            'end_time': task.endTime?.toIso8601String(),
          })
          .eq('id', task.id!); // Use ! since we checked for null

      // Update collaborators
      await supabase
          .from('task_collaborators')
          .delete()
          .eq('task_id', task.id!);

      if (task.collaboratorIds.isNotEmpty) {
        final collaboratorData = task.collaboratorIds.map((userId) => {
          'task_id': task.id,
          'user_id': userId,
        }).toList();

        await supabase
            .from('task_collaborators')
            .insert(collaboratorData);
      }

      print('Task ${task.id} updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      // Delete collaborators first (due to foreign key constraints)
      await supabase
          .from('task_collaborators')
          .delete()
          .eq('task_id', taskId);

      // Then delete the task
      await supabase
          .from('tasks')
          .delete()
          .eq('id', taskId);

      print('Task $taskId deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  // Use prefixed User class here too
  Future<user_model.User?> getUserById(String userId) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response != null) {
        return user_model.User.fromJson(response as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }
}