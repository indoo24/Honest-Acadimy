import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

abstract class BookingRepository {
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  });

  Future<Booking> reserveSlot({
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
  });

  Future<List<Booking>> getUserBookings(String userId);

  Future<List<Booking>> getDailyBookings(DateTime date);

  /// Real-time stream of all bookings for a given day.
  Stream<List<Booking>> watchDailyBookings(DateTime date);

  Future<void> confirmBooking(String bookingId);

  Future<void> rejectBooking(String bookingId);

  Future<void> cancelBooking(String bookingId);
}
