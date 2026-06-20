import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';

enum BookingActionStatus { initial, loading, success, failure }

enum BookingLastAction { none, reserve, cancel, reschedule }

class BookingState extends Equatable {
  const BookingState({
    required this.status,
    this.latestBooking,
    this.history = const [],
    this.message,
    this.lastAction = BookingLastAction.none,
  });

  const BookingState.initial() : this(status: BookingActionStatus.initial);

  final BookingActionStatus status;
  final Booking? latestBooking;
  final List<Booking> history;
  final String? message;
  final BookingLastAction lastAction;

  BookingState copyWith({
    BookingActionStatus? status,
    Booking? latestBooking,
    List<Booking>? history,
    String? message,
    BookingLastAction? lastAction,
  }) {
    return BookingState(
      status: status ?? this.status,
      latestBooking: latestBooking ?? this.latestBooking,
      history: history ?? this.history,
      message: message,
      lastAction: lastAction ?? this.lastAction,
    );
  }

  @override
  List<Object?> get props => [status, latestBooking, history, message, lastAction];
}
