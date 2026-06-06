import 'package:equatable/equatable.dart';

enum CoachSlotStatus { available, reserved, unavailable }

class CoachAvailabilitySlot extends Equatable {
  const CoachAvailabilitySlot({
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.courtId,
  });

  final DateTime startsAt;
  final DateTime endsAt;
  final CoachSlotStatus status;
  final String? courtId;

  bool get isAvailable => status == CoachSlotStatus.available;

  @override
  List<Object?> get props => [startsAt, endsAt, status, courtId];
}
