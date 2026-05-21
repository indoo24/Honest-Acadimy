import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

enum AdminStatus { initial, loading, loaded, failure }

class AdminState extends Equatable {
  const AdminState({
    required this.status,
    this.bookings = const [],
    this.courts = const [],
    this.message,
  });

  const AdminState.initial() : this(status: AdminStatus.initial);

  final AdminStatus status;
  final List<Booking> bookings;
  final List<Court> courts;
  final String? message;

  double get revenue => bookings
      .where((booking) => booking.status != BookingStatus.cancelled)
      .fold(0, (total, booking) => total + booking.amount);

  int get confirmedCount => bookings
      .where((booking) => booking.status == BookingStatus.confirmed)
      .length;

  AdminState copyWith({
    AdminStatus? status,
    List<Booking>? bookings,
    List<Court>? courts,
    String? message,
  }) {
    return AdminState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      courts: courts ?? this.courts,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, bookings, courts, message];
}
