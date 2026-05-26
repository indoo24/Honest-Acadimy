import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({required FirestoreBookingDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FirestoreBookingDataSource _remoteDataSource;

  @override
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  }) async {
    return _remoteDataSource.getSlots(date: date, courtId: courtId);
  }

  @override
  Future<Booking> reserveSlot({
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
  }) async {
    if (!slot.canBook) throw StateError('This slot is not available');
    return _remoteDataSource.reserveSlot(
      coachId: coachId,
      coachName: coachName,
      court: court,
      slot: slot,
      bookedByUserId: bookedByUserId,
    );
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    return _remoteDataSource.getUserBookings(userId);
  }

  @override
  Future<List<Booking>> getDailyBookings(DateTime date) async {
    return _remoteDataSource.getDailyBookings(date);
  }

  @override
  Stream<List<Booking>> watchDailyBookings(DateTime date) {
    return _remoteDataSource.watchDailyBookings(date);
  }

  @override
  Future<void> confirmBooking(String bookingId) async {
    await _remoteDataSource.confirmBooking(bookingId);
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    await _remoteDataSource.rejectBooking(bookingId);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _remoteDataSource.cancelBooking(bookingId);
  }
}