import 'package:flutter/foundation.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
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
    if (kDebugMode) {
      // ---------- DEBUG LOGGING START ----------
      debugPrint('=== Slot Generation Debug ===');
      debugPrint('[AVAIL] courtId: ${availability.courtId}');
      debugPrint('[AVAIL] startHour: ${availability.startHour}');
      debugPrint('[AVAIL] endHour: ${availability.endHour}');
      debugPrint(
        '[AVAIL] slotDurationMinutes: ${availability.slotDurationMinutes}',
      );
      debugPrint('[AVAIL] workingDays: ${availability.workingDays}');
      debugPrint('[AVAIL] breaks: ${availability.breaks}');
      if (availability.startHour >= availability.endHour) {
        debugPrint(
          '[WARN] Invalid hour range: startHour (${availability.startHour}) >= endHour (${availability.endHour})',
        );
      }
      // ---------- DEBUG LOGGING END ------------
    }

    if (!availability.isActive) return [];

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
    final isDayAllowed = allowedDays.contains(weekdayName);
    debugPrint('[DATE] weekday: $weekdayName (allowed: $isDayAllowed)');
    if (!isDayAllowed) {
      debugPrint('[SKIP] Weekday not allowed, returning empty slot list');
      return [];
    }

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      availability.startHour,
    );
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      availability.endHour,
    );
    if (!end.isAfter(start)) return [];

    final duration = Duration(minutes: availability.slotDurationMinutes);
    final activeBookings = bookings.where(_isBlockingBooking).toList();
    final slots = <BookingSlot>[];
    final nowTime = now ?? DateTime.now();

    var cursor = start;
    int generatedCount = 0;
    while (cursor.isBefore(end)) {
      final slotEnd = cursor.add(duration);
      if (slotEnd.isAfter(end)) break;

      final inBreak = availability.breaks.any((b) {
        final breakStart = DateTime(date.year, date.month, date.day, b.startHour);
        final breakEnd = DateTime(date.year, date.month, date.day, b.endHour);
        return cursor.isBefore(breakEnd) && slotEnd.isAfter(breakStart);
      });

      final hourLabel = '${cursor.hour.toString().padLeft(2, '0')}:00';
      debugPrint('[SLOT] Evaluating hour $hourLabel (inBreak: $inBreak)');

      if (!inBreak) {
        final booking = _findBooking(activeBookings, cursor, slotEnd);
        final isPast = slotEnd.isBefore(nowTime);
        final excludedByBooking = booking != null;
        debugPrint('[SLOT] excludedByBooking: $excludedByBooking');
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
        generatedCount++;
      } else {
        debugPrint('[SLOT] Skipped due to break');
      }
      cursor = slotEnd;
    }
    debugPrint('[RESULT] Generated slot count: $generatedCount');

    return slots;
  }

  bool _isBlockingBooking(Booking booking) {
    return booking.status == BookingStatus.pending_payment ||
        booking.status == BookingStatus.pending_payment_review ||
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

