import 'package:equatable/equatable.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';

enum AdminStatus { initial, loading, loaded, failure }

class AdminState extends Equatable {
  const AdminState({
    required this.status,
    this.bookings = const [],
    this.selectedDate,
    this.message,
  });

  const AdminState.initial() : this(status: AdminStatus.initial);

  final AdminStatus status;
  final List<Booking> bookings;
  final DateTime? selectedDate;
  final String? message;

  List<Booking> get confirmedBookings => bookings
      .where((booking) => booking.status == BookingStatus.confirmed)
      .toList();

  List<Booking> get pendingBookings => bookings
      .where(
        (booking) =>
            booking.status == BookingStatus.pending_payment ||
            booking.status == BookingStatus.pending_payment_review,
      )
      .toList();

  bool get hasBookings => bookings.isNotEmpty;

  bool get hasPendingBookings => pendingBookings.isNotEmpty;

  bool get hasConfirmedBookings => confirmedBookings.isNotEmpty;

  int get pendingCount => pendingBookings.length;

  int get confirmedCount => confirmedBookings.length;

  String get selectedDateLabel => selectedDate == null
      ? ''
      : '${selectedDate!.shortDay}, ${selectedDate!.monthName} ${selectedDate!.dayNumber}';

  String get selectedDateHeadline => selectedDate == null
      ? ''
      : '${selectedDate!.monthName} ${selectedDate!.dayNumber}';

  bool isSelectedDate(DateTime date) {
    final targetDate = selectedDate;
    if (targetDate == null) return false;
    return targetDate.year == date.year &&
        targetDate.month == date.month &&
        targetDate.day == date.day;
  }

  AdminState copyWith({
    AdminStatus? status,
    List<Booking>? bookings,
    DateTime? selectedDate,
    String? message,
  }) {
    return AdminState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      selectedDate: selectedDate ?? this.selectedDate,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    selectedDate,
    message,
  ];
}
