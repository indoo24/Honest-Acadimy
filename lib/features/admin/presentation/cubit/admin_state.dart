import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/coaches/domain/entities/coach_profile.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

enum AdminStatus { initial, loading, loaded, failure }

class AdminState extends Equatable {
  const AdminState({
    required this.status,
    this.bookings = const [],
    this.courts = const [],
    this.coaches = const [],
    this.selectedDate,
    this.message,
  });

  const AdminState.initial() : this(status: AdminStatus.initial);

  final AdminStatus status;
  final List<Booking> bookings;
  final List<Court> courts;
  final List<CoachProfile> coaches;
  final DateTime? selectedDate;
  final String? message;

  /// Bookings grouped by courtId.
  Map<String, List<Booking>> get bookingsByCourt {
    final map = <String, List<Booking>>{};
    for (final booking in bookings) {
      map.putIfAbsent(booking.courtId, () => []).add(booking);
    }
    return map;
  }

  /// Bookings grouped by coachId (excluding cancelled).
  Map<String, List<Booking>> get bookingsByCoach {
    final map = <String, List<Booking>>{};
    for (final booking in bookings) {
      if (booking.status == BookingStatus.cancelled) continue;
      map.putIfAbsent(booking.coachId, () => []).add(booking);
    }
    return map;
  }

  int get pendingCount =>
      bookings.where((b) => b.status == BookingStatus.pending).length;

  int get confirmedCount =>
      bookings.where((b) => b.status == BookingStatus.confirmed).length;

  AdminState copyWith({
    AdminStatus? status,
    List<Booking>? bookings,
    List<Court>? courts,
    List<CoachProfile>? coaches,
    DateTime? selectedDate,
    String? message,
  }) {
    return AdminState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      courts: courts ?? this.courts,
      coaches: coaches ?? this.coaches,
      selectedDate: selectedDate ?? this.selectedDate,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    bookings,
    courts,
    coaches,
    selectedDate,
    message,
  ];
}