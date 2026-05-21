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
  });

  final String id;
  final String courtId;
  final DateTime startsAt;
  final DateTime endsAt;
  final SlotStatus status;
  final String? bookingId;

  bool get canBook => status == SlotStatus.available;

  @override
  List<Object?> get props => [id, courtId, startsAt, endsAt, status, bookingId];
}
