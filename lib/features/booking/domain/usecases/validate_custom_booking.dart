import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/court_availability.dart';

/// Pure validation logic for custom time-range bookings.
///
/// Checks chronological order, minimum duration, working hours,
/// break periods, and overlap with existing bookings.
class ValidateCustomBooking {
  const ValidateCustomBooking();

  static const int minimumDurationMinutes = 30;

  BookingValidationResult validate({
    required DateTime startsAt,
    required DateTime endsAt,
    required CourtAvailability availability,
    required List<Booking> existingBookings,
    required double pricePerHour,
  }) {
    // 1. Chronological order
    if (!endsAt.isAfter(startsAt)) {
      return const BookingValidationResult.invalid(
        'End time must be after start time.',
      );
    }

    // 2. Minimum duration
    final durationMinutes = endsAt.difference(startsAt).inMinutes;
    if (durationMinutes < minimumDurationMinutes) {
      return BookingValidationResult.invalid(
        'Minimum booking duration is $minimumDurationMinutes minutes.',
      );
    }

    // 3. Working hours
    final dayStart = DateTime(
      startsAt.year,
      startsAt.month,
      startsAt.day,
      availability.startHour,
    );
    final dayEnd = DateTime(
      startsAt.year,
      startsAt.month,
      startsAt.day,
      availability.endHour,
    );
    if (startsAt.isBefore(dayStart) || endsAt.isAfter(dayEnd)) {
      return BookingValidationResult.invalid(
        'Booking must be within operating hours '
        '(${_formatHour(availability.startHour)} – ${_formatHour(availability.endHour)}).',
      );
    }

    // 4. Break periods
    for (final breakPeriod in availability.breaks) {
      final breakStart = DateTime(
        startsAt.year,
        startsAt.month,
        startsAt.day,
        breakPeriod.startHour,
      );
      final breakEnd = DateTime(
        startsAt.year,
        startsAt.month,
        startsAt.day,
        breakPeriod.endHour,
      );
      if (startsAt.isBefore(breakEnd) && endsAt.isAfter(breakStart)) {
        return BookingValidationResult.invalid(
          'Selected time overlaps a break period '
          '(${_formatHour(breakPeriod.startHour)} – ${_formatHour(breakPeriod.endHour)}).',
        );
      }
    }

    // 5. Overlap with existing bookings
    for (final booking in existingBookings) {
      if (!_isBlockingBooking(booking)) continue;
      if (startsAt.isBefore(booking.endsAt) &&
          endsAt.isAfter(booking.startsAt)) {
        return const BookingValidationResult.invalid(
          'Selected time overlaps with an existing booking.',
        );
      }
    }

    // All checks passed
    final totalPrice = (pricePerHour / 60) * durationMinutes;
    return BookingValidationResult.valid(
      durationMinutes: durationMinutes,
      totalPrice: totalPrice,
    );
  }

  bool _isBlockingBooking(Booking booking) {
    return booking.status == BookingStatus.pendingPayment ||
        booking.status == BookingStatus.pendingPaymentReview ||
        booking.status == BookingStatus.confirmed;
  }

  String _formatHour(int hour) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:00 $period';
  }
}

/// Result of a booking validation check.
sealed class BookingValidationResult extends Equatable {
  const BookingValidationResult();

  const factory BookingValidationResult.valid({
    required int durationMinutes,
    required double totalPrice,
  }) = BookingValidationValid;

  const factory BookingValidationResult.invalid(String errorMessage) =
      BookingValidationInvalid;
}

class BookingValidationValid extends BookingValidationResult {
  const BookingValidationValid({
    required this.durationMinutes,
    required this.totalPrice,
  });

  final int durationMinutes;
  final double totalPrice;

  @override
  List<Object?> get props => [durationMinutes, totalPrice];
}

class BookingValidationInvalid extends BookingValidationResult {
  const BookingValidationInvalid(this.errorMessage);

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
