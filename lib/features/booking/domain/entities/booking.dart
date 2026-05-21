import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.courtId,
    required this.courtName,
    required this.coachName,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.amount,
    required this.qrPayload,
    required this.createdAt,
    this.phoneNumber,
    this.playerAge,
  });

  final String id;
  final String userId;
  final String userName;
  final String courtId;
  final String courtName;
  final String coachName;
  final DateTime startsAt;
  final DateTime endsAt;
  final BookingStatus status;
  final double amount;
  final String qrPayload;
  final DateTime createdAt;
  final String? phoneNumber;
  final int? playerAge;

  @override
  List<Object?> get props => [
    id,
    userId,
    userName,
    courtId,
    courtName,
    coachName,
    startsAt,
    endsAt,
    status,
    amount,
    qrPayload,
    createdAt,
    phoneNumber,
    playerAge,
  ];
}
