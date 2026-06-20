import 'package:flutter/foundation.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/court_availability.dart';

/// Generates [BookingSlot] objects for a given [date] based on the
/// [CourtAvailability] rules. The slots are created between [startHour] and
/// [endHour] with a configurable [slotDurationMinutes] and respect any
/// defined break periods.
class SlotGenerator {
  const SlotGenerator();

  List<BookingSlot> generate({
    required DateTime date,
    required CourtAvailability availability,
    required List<Booking> bookings,
    DateTime? now,
  }) {
    if (!availability.isActive) return const [];

    // ---------- Day-of-week check ----------
    const weekdayMap = {
      1: 'monday',
      2: 'tuesday',
      3: 'wednesday',
      4: 'thursday',
      5: 'friday',
      6: 'saturday',
      7: 'sunday',
    };
    final weekdayName = weekdayMap[date.weekday] ?? '';
    final allowedDays = availability.workingDays
        .map((day) => day.toLowerCase().trim())
        .toSet();
    if (!allowedDays.contains(weekdayName)) {
      if (kDebugMode) {
        debugPrint('[SLOTS] ${availability.courtId}: $weekdayName not in working days');
      }
      return const [];
    }

    // ---------- Time range ----------
    final start = DateTime(date.year, date.month, date.day, availability.startHour);
    final end = DateTime(date.year, date.month, date.day, availability.endHour);
    if (!end.isAfter(start)) return const [];

    final duration = Duration(minutes: availability.slotDurationMinutes);
    final activeBookings = bookings.where(_isBlockingBooking).toList();
    final slots = <BookingSlot>[];
    final nowTime = now ?? DateTime.now();

    var cursor = start;
    while (cursor.isBefore(end)) {
      final slotEnd = cursor.add(duration);
      if (slotEnd.isAfter(end)) break;

      final inBreak = availability.breaks.any((b) {
        final breakStart = DateTime(date.year, date.month, date.day, b.startHour);
        final breakEnd = DateTime(date.year, date.month, date.day, b.endHour);
        return cursor.isBefore(breakEnd) && slotEnd.isAfter(breakStart);
      });

      if (!inBreak) {
        final booking = _findBooking(activeBookings, cursor, slotEnd);
        final isPast = slotEnd.isBefore(nowTime);
        slots.add(
          BookingSlot(
            id: '${availability.courtId}_${cursor.millisecondsSinceEpoch}',
            courtId: availability.courtId,
            startsAt: cursor,
            endsAt: slotEnd,
            status: _resolveStatus(isPast: isPast, booking: booking),
            bookingId: booking?.id,
            coachId: booking?.coachId,
            coachName: booking?.coachName,
            bookedByUserId: booking?.bookedByUserId,
          ),
        );
      }
      cursor = slotEnd;
    }

    if (kDebugMode) {
      debugPrint('[SLOTS] ${availability.courtId}: ${slots.length} slots generated for $weekdayName');
    }

    return slots;
  }

  bool _isBlockingBooking(Booking booking) {
    return booking.status == BookingStatus.pendingPayment ||
        booking.status == BookingStatus.pendingPaymentReview ||
        booking.status == BookingStatus.confirmed;
  }

  Booking? _findBooking(
    List<Booking> bookings,
    DateTime slotStart,
    DateTime slotEnd,
  ) {
    for (final booking in bookings) {
      if (booking.startsAt.isBefore(slotEnd) &&
          booking.endsAt.isAfter(slotStart)) {
        return booking;
      }
    }
    return null;
  }

  SlotStatus _resolveStatus({required bool isPast, Booking? booking}) {
    if (isPast) return SlotStatus.past;
    if (booking == null) return SlotStatus.available;
    if (booking.status == BookingStatus.confirmed) return SlotStatus.reserved;
    return SlotStatus.pending;
  }
}
