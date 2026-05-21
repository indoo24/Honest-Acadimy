import 'package:honset_app/features/booking/data/datasources/firestore_booking_data_source.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/courts/data/datasources/demo_club_data.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({
    required FirestoreBookingDataSource? remoteDataSource,
    required bool firebaseEnabled,
  }) : _remoteDataSource = remoteDataSource,
       _firebaseEnabled = firebaseEnabled;

  final FirestoreBookingDataSource? _remoteDataSource;
  final bool _firebaseEnabled;
  final List<Booking> _localBookings = [];

  @override
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  }) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        final slots = await _remoteDataSource.getSlots(
          date: date,
          courtId: courtId,
        );
        if (slots.isNotEmpty) return slots;
      } on Object {
        return _mergeLocalSlots(date, courtId);
      }
    }
    return _mergeLocalSlots(date, courtId);
  }

  @override
  Future<Booking> reserveSlot({
    required String userId,
    required String userName,
    required Court court,
    required BookingSlot slot,
    String? phoneNumber,
    int? playerAge,
  }) async {
    if (!slot.canBook) throw StateError('This slot is not available');
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.reserveSlot(
          userId: userId,
          userName: userName,
          court: court,
          slot: slot,
          phoneNumber: phoneNumber,
          playerAge: playerAge,
        );
      } on Object {
        return _createLocalBooking(
          userId,
          userName,
          court,
          slot,
          phoneNumber,
          playerAge,
        );
      }
    }
    return _createLocalBooking(
      userId,
      userName,
      court,
      slot,
      phoneNumber,
      playerAge,
    );
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.getUserBookings(userId);
      } on Object {
        return [..._localBookings, ...DemoClubData.bookingsFor(userId)];
      }
    }
    return [..._localBookings, ...DemoClubData.bookingsFor(userId)];
  }

  @override
  Future<List<Booking>> getDailyBookings(DateTime date) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.getDailyBookings(date);
      } on Object {
        return _demoDailyBookings(date);
      }
    }
    return _demoDailyBookings(date);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      await _remoteDataSource.cancelBooking(bookingId);
      return;
    }
    final index = _localBookings.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (index != -1) {
      final booking = _localBookings[index];
      _localBookings[index] = Booking(
        id: booking.id,
        userId: booking.userId,
        userName: booking.userName,
        courtId: booking.courtId,
        courtName: booking.courtName,
        coachName: booking.coachName,
        startsAt: booking.startsAt,
        endsAt: booking.endsAt,
        status: BookingStatus.cancelled,
        amount: booking.amount,
        qrPayload: booking.qrPayload,
        createdAt: booking.createdAt,
        phoneNumber: booking.phoneNumber,
        playerAge: booking.playerAge,
      );
    }
  }

  List<BookingSlot> _mergeLocalSlots(DateTime date, String courtId) {
    final slots = DemoClubData.slotsFor(date, courtId);
    final bookedIds = _localBookings
        .where(
          (booking) =>
              booking.courtId == courtId &&
              booking.startsAt.year == date.year &&
              booking.startsAt.month == date.month &&
              booking.startsAt.day == date.day &&
              booking.status != BookingStatus.cancelled,
        )
        .map((booking) => booking.startsAt.millisecondsSinceEpoch)
        .toSet();
    return slots.map((slot) {
      if (!bookedIds.contains(slot.startsAt.millisecondsSinceEpoch)) {
        return slot;
      }
      return BookingSlot(
        id: slot.id,
        courtId: slot.courtId,
        startsAt: slot.startsAt,
        endsAt: slot.endsAt,
        status: SlotStatus.reserved,
        bookingId: 'local',
      );
    }).toList();
  }

  Booking _createLocalBooking(
    String userId,
    String userName,
    Court court,
    BookingSlot slot,
    String? phoneNumber,
    int? playerAge,
  ) {
    final id = 'BK-${DateTime.now().millisecondsSinceEpoch}';
    final booking = Booking(
      id: id,
      userId: userId,
      userName: userName,
      courtId: court.id,
      courtName: court.name,
      coachName: court.coach.name,
      startsAt: slot.startsAt,
      endsAt: slot.endsAt,
      status: BookingStatus.confirmed,
      amount: court.hourlyRate,
      qrPayload: 'HONSET:$id:${slot.startsAt.toIso8601String()}',
      createdAt: DateTime.now(),
      phoneNumber: phoneNumber,
      playerAge: playerAge,
    );
    _localBookings.add(booking);
    return booking;
  }

  List<Booking> _demoDailyBookings(DateTime date) {
    return [
          ...DemoClubData.bookingsFor(DemoClubData.demoUser.id),
          ..._localBookings,
        ]
        .where(
          (booking) =>
              booking.startsAt.year == date.year &&
              booking.startsAt.month == date.month &&
              booking.startsAt.day == date.day,
        )
        .toList();
  }
}
