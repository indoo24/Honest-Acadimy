import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';

enum BookingActionStatus { initial, loading, success, failure }

class BookingState extends Equatable {
  const BookingState({
    required this.status,
    this.latestBooking,
    this.history = const [],
    this.message,
  });

  const BookingState.initial() : this(status: BookingActionStatus.initial);

  final BookingActionStatus status;
  final Booking? latestBooking;
  final List<Booking> history;
  final String? message;

  BookingState copyWith({
    BookingActionStatus? status,
    Booking? latestBooking,
    List<Booking>? history,
    String? message,
  }) {
    return BookingState(
      status: status ?? this.status,
      latestBooking: latestBooking ?? this.latestBooking,
      history: history ?? this.history,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, latestBooking, history, message];
}
