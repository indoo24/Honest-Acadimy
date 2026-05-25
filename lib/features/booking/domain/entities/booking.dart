import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.courtId,
    required this.courtName,
    required this.coachId,
    required this.coachName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.amount,
    required this.qrPayload,
    required this.createdAt,
    this.bookedByUserId,
  });

  final String id;
  final String courtId;
  final String courtName;
  final String coachId;
  final String coachName;
  final DateTime startsAt;
  final DateTime endsAt;
  final BookingStatus status;
  final double amount;
  final String qrPayload;
  final DateTime createdAt;
  final String? bookedByUserId;

  @override
  List<Object?> get props => [
    id,
    courtId,
    courtName,
    coachId,
    coachName,
    startsAt,
    endsAt,
    status,
    amount,
    qrPayload,
    createdAt,
    bookedByUserId,
  ];
}
