import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/entities/court_availability.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
import 'package:honset_app/features/courts/presentation/cubit/court_details_state.dart';

/// Manages the state for the court details page with standard auto-generated slots.
class CourtDetailsCubit extends Cubit<CourtDetailsState> {
  CourtDetailsCubit({
    required Court court,
    required DateTime selectedDate,
    required FirestoreBookingDataSource bookingDataSource,
    required CourtAvailabilityRepository availabilityRepository,
  })  : _bookingDataSource = bookingDataSource,
        _availabilityRepository = availabilityRepository,
        super(CourtDetailsState.initial(
          court: court,
          selectedDate: selectedDate,
        ));

  final FirestoreBookingDataSource _bookingDataSource;
  final CourtAvailabilityRepository _availabilityRepository;

  /// Loads existing bookings and court availability for the selected date.
  Future<void> loadBookingsForDate([DateTime? date]) async {
    final targetDate = date ?? state.selectedDate;
    emit(state.copyWith(
      status: CourtDetailsStatus.loading,
      selectedDate: targetDate,
      clearSelectedSlot: true,
      clearErrorMessage: true,
      generatedSlots: [],
    ));

    try {
      final results = await Future.wait([
        _bookingDataSource.getActiveBookingsForCourt(
          courtId: state.court.id,
          date: targetDate,
        ),
        _availabilityRepository.getAvailabilityByCourtId(state.court.id),
      ]);

      final bookings = results[0] as List<Booking>;
      final availability = results[1] as CourtAvailability?;

      if (isClosed) return;

      final generatedSlots = _generateSlots(
        targetDate: targetDate,
        availability: availability,
        existingBookings: bookings,
        courtId: state.court.id,
      );

      emit(state.copyWith(
        status: CourtDetailsStatus.loaded,
        existingBookings: bookings,
        availability: availability,
        generatedSlots: generatedSlots,
        clearErrorMessage: true,
      ));
    } on Object catch (error) {
      if (isClosed) return;
      emit(state.copyWith(
        status: CourtDetailsStatus.failure,
        errorMessage: error.toString(),
      ));
    }
  }

  void selectSlot(BookingSlot slot) {
    if (!slot.canBook) return;
    emit(state.copyWith(selectedSlot: slot));
  }

  List<BookingSlot> _generateSlots({
    required DateTime targetDate,
    required CourtAvailability? availability,
    required List<Booking> existingBookings,
    required String courtId,
  }) {
    if (availability == null) return [];

    final slots = <BookingSlot>[];
    final now = DateTime.now();

    // Start at exactly 11:00 AM
    var currentStart = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      11,
      0,
    );

    final endOfDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      availability.endHour,
      0,
    );

    while (currentStart.isBefore(endOfDay)) {
      final currentEnd = currentStart.add(const Duration(minutes: 45));

      // Stop if the next 45-min slot extends beyond closing time
      if (currentEnd.isAfter(endOfDay)) {
        break;
      }

      SlotStatus slotStatus = SlotStatus.available;

      if (currentStart.isBefore(now)) {
        slotStatus = SlotStatus.past;
      } else {
        // Check for overlap with existing bookings
        final isOverlapping = existingBookings.any((booking) {
          // overlap condition: max(start1, start2) < min(end1, end2)
          final overlapStart = currentStart.isAfter(booking.startsAt) ? currentStart : booking.startsAt;
          final overlapEnd = currentEnd.isBefore(booking.endsAt) ? currentEnd : booking.endsAt;
          return overlapStart.isBefore(overlapEnd);
        });

        if (isOverlapping) {
          slotStatus = SlotStatus.reserved;
        }
      }

      slots.add(
        BookingSlot(
          id: '${courtId}_${currentStart.millisecondsSinceEpoch}',
          courtId: courtId,
          startsAt: currentStart,
          endsAt: currentEnd,
          status: slotStatus,
        ),
      );

      // Increment by 45 minutes
      currentStart = currentEnd;
    }

    return slots;
  }
}
