import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/entities/court_availability.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

enum CourtDetailsStatus { initial, loading, loaded, failure }

class CourtDetailsState extends Equatable {
  const CourtDetailsState({
    required this.status,
    required this.court,
    required this.selectedDate,
    this.existingBookings = const [],
    this.availability,
    this.generatedSlots = const [],
    this.selectedSlot,
    this.errorMessage,
  });

  factory CourtDetailsState.initial({
    required Court court,
    required DateTime selectedDate,
  }) {
    return CourtDetailsState(
      status: CourtDetailsStatus.initial,
      court: court,
      selectedDate: selectedDate,
    );
  }

  final CourtDetailsStatus status;
  final Court court;
  final DateTime selectedDate;
  final List<Booking> existingBookings;
  final CourtAvailability? availability;
  final List<BookingSlot> generatedSlots;
  final BookingSlot? selectedSlot;
  final String? errorMessage;

  bool get canBook => selectedSlot != null && selectedSlot!.canBook;

  /// Only the blocking (active) bookings for display purposes.
  List<Booking> get activeBookings => existingBookings
      .where(
        (b) =>
            b.status == BookingStatus.pendingPayment ||
            b.status == BookingStatus.pendingPaymentReview ||
            b.status == BookingStatus.confirmed,
      )
      .toList()
    ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

  double get totalPrice {
    if (selectedSlot == null) return 0;
    // 45 minutes = 0.75 hours
    return court.pricePerHour ;
  }

  CourtDetailsState copyWith({
    CourtDetailsStatus? status,
    Court? court,
    DateTime? selectedDate,
    List<Booking>? existingBookings,
    CourtAvailability? availability,
    List<BookingSlot>? generatedSlots,
    BookingSlot? selectedSlot,
    String? errorMessage,
    bool clearSelectedSlot = false,
    bool clearErrorMessage = false,
  }) {
    return CourtDetailsState(
      status: status ?? this.status,
      court: court ?? this.court,
      selectedDate: selectedDate ?? this.selectedDate,
      existingBookings: existingBookings ?? this.existingBookings,
      availability: availability ?? this.availability,
      generatedSlots: generatedSlots ?? this.generatedSlots,
      selectedSlot: clearSelectedSlot ? null : (selectedSlot ?? this.selectedSlot),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        court,
        selectedDate,
        existingBookings,
        availability,
        generatedSlots,
        selectedSlot,
        errorMessage,
      ];
}
