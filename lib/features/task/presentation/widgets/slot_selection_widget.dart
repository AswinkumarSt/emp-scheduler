// lib/features/task/presentation/widgets/slot_selection_widget.dart
import 'package:employee_scheduler/features/task/domain/cubit/task_cubit.dart';
import 'package:employee_scheduler/features/task/domain/models/slot_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SlotSelectionWidget extends StatefulWidget {
  final VoidCallback? onSlotSelected;
  
  const SlotSelectionWidget({super.key, this.onSlotSelected});

  @override
  State<SlotSelectionWidget> createState() => _SlotSelectionWidgetState();
}

class _SlotSelectionWidgetState extends State<SlotSelectionWidget> {
  AvailableSlot? _selectedSlot;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listener: (context, state) {
        if (state is SlotsCalculated) {
          // Reset selection when new slots are calculated
          _selectedSlot = null;
        }
      },
      builder: (context, state) {
        final taskCubit = context.read<TaskCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Step 4: Choose Available Slot',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a time when all collaborators are available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // Calculate Slots Button
            if (state is! SlotsCalculated && state is! TaskLoading)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => taskCubit.calculateAvailableSlots(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Find Available Slots',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

            // Loading State
            if (state is TaskLoading) ...[
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Calculating available slots...'),
                  ],
                ),
              ),
            ],

            // Available Slots List
            if (state is SlotsCalculated) ...[
              const SizedBox(height: 20),
              Text(
                'Available Time Slots (${state.slots.length} found)',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              if (state.slots.isEmpty)
                _buildNoSlotsFound()
              else
                _buildSlotsList(state.slots, taskCubit),
            ],

            // Selected Slot Info
            if (_selectedSlot != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Time Slot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            '${_selectedSlot!.formattedDate} • ${_selectedSlot!.formattedTime}',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildNoSlotsFound() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.schedule, size: 48, color: Colors.orange[400]),
          const SizedBox(height: 16),
          const Text(
            'No Common Slots Found',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no time slots where all selected collaborators are available for the chosen duration.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Try:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• Selecting different collaborators\n• Choosing a shorter duration\n• Checking availability for different days',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotsList(List<AvailableSlot> slots, TaskCubit taskCubit) {
    // Group slots by date
    final slotsByDate = <String, List<AvailableSlot>>{};
    for (final slot in slots) {
      final dateKey = slot.formattedDate;
      if (!slotsByDate.containsKey(dateKey)) {
        slotsByDate[dateKey] = [];
      }
      slotsByDate[dateKey]!.add(slot);
    }

    return Expanded(
      child: ListView.builder(
        itemCount: slotsByDate.length,
        itemBuilder: (context, index) {
          final date = slotsByDate.keys.elementAt(index);
          final dateSlots = slotsByDate[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
              ),

              // Slots for this date
              ...dateSlots.map((slot) {
                final isSelected = _selectedSlot == slot;

                return Card(
                  elevation: 2,
                  color: isSelected ? Colors.blue[50] : Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: isSelected ? Colors.blue : Colors.grey,
                    ),
                    title: Text(
                      slot.formattedTime,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      '${slot.duration.inMinutes} minutes • All ${taskCubit.selectedCollaborators.length} collaborators available',
                      style: TextStyle(
                        color: isSelected ? Colors.blue[600] : Colors.grey[600],
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedSlot = slot;
                      });
                      taskCubit.selectSlot(slot);
                      
                      // Notify parent page to update validation
                      if (widget.onSlotSelected != null) {
                        widget.onSlotSelected!();
                      }
                    },
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}