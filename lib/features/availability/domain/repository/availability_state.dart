part of 'availability_cubit.dart';

abstract class AvailabilityState {
  const AvailabilityState();
}

class AvailabilityInitial extends AvailabilityState {
  const AvailabilityInitial();
}

class AvailabilityLoading extends AvailabilityState {
  const AvailabilityLoading();
}

class AvailabilityLoaded extends AvailabilityState {
  final List<Availability> availabilities;
  const AvailabilityLoaded(this.availabilities);
}

class AvailabilityError extends AvailabilityState {
  final String message;
  const AvailabilityError(this.message);
}

class AvailabilityAdding extends AvailabilityState {
  const AvailabilityAdding();
}

class AvailabilityAdded extends AvailabilityState {
  final Availability availability;
  const AvailabilityAdded(this.availability);
}

class AvailabilityDeleting extends AvailabilityState {
  const AvailabilityDeleting();
}

class AvailabilityDeleted extends AvailabilityState {
  const AvailabilityDeleted();
}