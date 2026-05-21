import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

abstract class BookingRepository {
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  });

  Future<Booking> reserveSlot({
    required String userId,
    required String userName,
    required Court court,
    required BookingSlot slot,
    String? phoneNumber,
    int? playerAge,
  });

  Future<List<Booking>> getUserBookings(String userId);

  Future<List<Booking>> getDailyBookings(DateTime date);

  Future<void> cancelBooking(String bookingId);
}
