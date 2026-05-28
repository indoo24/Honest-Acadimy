import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/domain/usecases/generate_slots.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    required FirestoreBookingDataSource remoteDataSource,
    required CourtAvailabilityRepository availabilityRepository,
    required SlotGenerator slotGenerator,
  })  : _remoteDataSource = remoteDataSource,
        _availabilityRepository = availabilityRepository,
        _slotGenerator = slotGenerator;

  final FirestoreBookingDataSource _remoteDataSource;
  final CourtAvailabilityRepository _availabilityRepository;
  final SlotGenerator _slotGenerator;

  @override
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  }) async {
    final availability =
        await _availabilityRepository.getAvailabilityByCourtId(courtId);
    if (availability == null) return [];
    final bookings = await _remoteDataSource.getActiveBookingsForCourt(
      courtId: courtId,
      date: date,
    );
    return _slotGenerator.generate(
      date: date,
      availability: availability,
      bookings: bookings,
    );
  }

  @override
  Stream<List<BookingSlot>> watchSlots({
    required DateTime date,
    required String courtId,
  }) async* {
    final availability =
        await _availabilityRepository.getAvailabilityByCourtId(courtId);
    if (availability == null) {
      yield [];
      return;
    }
    yield* _remoteDataSource
        .watchActiveBookingsForCourt(courtId: courtId, date: date)
        .map(
          (bookings) => _slotGenerator.generate(
            date: date,
            availability: availability,
            bookings: bookings,
          ),
        );
  }

  @override
  Future<Map<String, List<BookingSlot>>> getSlotsForCourts({
    required DateTime date,
    required List<String> courtIds,
  }) async {
    if (courtIds.isEmpty) return {};
    final availabilities = await _availabilityRepository.getAllAvailabilities();
    final availabilityMap = {
      for (final availability in availabilities)
        if (availability.isActive) availability.courtId: availability,
    };
    final bookings = await _remoteDataSource.getActiveBookingsForDay(date);
    final bookingsByCourt = <String, List<Booking>>{};
    for (final booking in bookings) {
        bookingsByCourt
          .putIfAbsent(booking.courtId, () => <Booking>[])
          .add(booking);
    }

    final slotsByCourt = <String, List<BookingSlot>>{};
    for (final courtId in courtIds) {
      final availability = availabilityMap[courtId];
      if (availability == null) {
        slotsByCourt[courtId] = const [];
        continue;
      }
      slotsByCourt[courtId] = _slotGenerator.generate(
        date: date,
        availability: availability,
        bookings: bookingsByCourt[courtId] ?? const [],
      );
    }
    return slotsByCourt;
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