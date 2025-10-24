  import 'package:employee_scheduler/features/availability/domain/repository/availability_cubit.dart';
import 'package:employee_scheduler/features/availability/presentation/widgets/add_slot_bottom_sheet.dart';
import 'package:employee_scheduler/features/availability/presentation/widgets/availability_slot_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

  class AvailabilityPage extends StatefulWidget {
    final String userId;

    const AvailabilityPage({super.key, required this.userId});

    @override
    State<AvailabilityPage> createState() => _AvailabilityPageState();
  }

  class _AvailabilityPageState extends State<AvailabilityPage> {
    void _showAddSlotSheet(BuildContext context) {
  // Get the cubit BEFORE showing the bottom sheet
  final availabilityCubit = context.read<AvailabilityCubit>();
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddSlotBottomSheet(
      onAddSlot: (startTime, endTime) {
        // Use the pre-obtained cubit instead of context.read
        availabilityCubit.addAvailability(
          widget.userId,
          startTime,
          endTime,
        );
      },
    ),
  );
}

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (context) => AvailabilityCubit()..loadUserAvailability(widget.userId),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('My Availability'),
            // Removed the action button from AppBar
          ),
          body: BlocConsumer<AvailabilityCubit, AvailabilityState>(
            listener: (context, state) {
              if (state is AvailabilityError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is AvailabilityLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is AvailabilityLoaded) {
                final availabilities = state.availabilities;
                
                if (availabilities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No availability slots',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your available time slots',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showAddSlotSheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Availability Slot'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Available Time Slots',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: availabilities.length,
                          itemBuilder: (context, index) {
                            final availability = availabilities[index];
                            return AvailabilitySlotItem(
                              availability: availability,
                              onDelete: () {
                                context.read<AvailabilityCubit>().deleteAvailability(
                                  availability.id,
                                  widget.userId,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Add button at bottom when slots exist
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddSlotSheet(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Another Slot'),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is AvailabilityError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.message,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AvailabilityCubit>().loadUserAvailability(widget.userId);
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
          // Removed FloatingActionButton
        ),
      );
    }
  }