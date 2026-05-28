import 'package:equatable/equatable.dart';

enum SlotStatus { available, reserved, pending, past }

class BookingSlot extends Equatable {
  const BookingSlot({
    required this.id,
    required this.courtId,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    this.bookingId,
    this.coachId,
    this.coachName,
    this.bookedByUserId,
  });

  final String id;
  final String courtId;
  final DateTime startsAt;
  final DateTime endsAt;
  final SlotStatus status;
  final String? bookingId;
  final String? coachId;
  final String? coachName;
  final String? bookedByUserId;

  bool get canBook => status == SlotStatus.available;

  @override
  List<Object?> get props => [
    id,
    courtId,
    startsAt,
    endsAt,
    status,
    bookingId,
    coachId,
    coachName,
    bookedByUserId,
  ];
}
