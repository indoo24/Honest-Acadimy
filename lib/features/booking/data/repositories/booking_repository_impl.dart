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
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
  }) async {
    if (!slot.canBook) throw StateError('This slot is not available');
    if (_firebaseEnabled && _remoteDataSource != null) {
      try {
        return await _remoteDataSource.reserveSlot(
          coachId: coachId,
          coachName: coachName,
          court: court,
          slot: slot,
          bookedByUserId: bookedByUserId,
        );
      } on Object {
        return _createLocalBooking(
          coachId,
          coachName,
          court,
          slot,
          bookedByUserId,
        );
      }
    }
    return _createLocalBooking(
      coachId,
      coachName,
      court,
      slot,
      bookedByUserId,
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
  Stream<List<Booking>> watchDailyBookings(DateTime date) {
    if (_firebaseEnabled && _remoteDataSource != null) {
      return _remoteDataSource.watchDailyBookings(date);
    }
    // Fallback: emit demo data as a single-event stream
    return Stream.value(_demoDailyBookings(date));
  }

  @override
  Future<void> confirmBooking(String bookingId) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      await _remoteDataSource.confirmBooking(bookingId);
      return;
    }
    _updateLocalBookingStatus(bookingId, BookingStatus.confirmed);
  }

  @override
  Future<void> rejectBooking(String bookingId) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      await _remoteDataSource.rejectBooking(bookingId);
      return;
    }
    _updateLocalBookingStatus(bookingId, BookingStatus.cancelled);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    if (_firebaseEnabled && _remoteDataSource != null) {
      await _remoteDataSource.cancelBooking(bookingId);
      return;
    }
    _updateLocalBookingStatus(bookingId, BookingStatus.cancelled);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  void _updateLocalBookingStatus(String bookingId, BookingStatus newStatus) {
    final index = _localBookings.indexWhere(
      (booking) => booking.id == bookingId,
    );
    if (index != -1) {
      final booking = _localBookings[index];
      _localBookings[index] = Booking(
        id: booking.id,
        courtId: booking.courtId,
        courtName: booking.courtName,
        coachId: booking.coachId,
        coachName: booking.coachName,
        startsAt: booking.startsAt,
        endsAt: booking.endsAt,
        status: newStatus,
        amount: booking.amount,
        qrPayload: booking.qrPayload,
        createdAt: booking.createdAt,
        bookedByUserId: booking.bookedByUserId,
      );
    }
  }

  List<BookingSlot> _mergeLocalSlots(DateTime date, String courtId) {
    final slots = DemoClubData.slotsFor(date, courtId);
    final localBookings = _localBookings
        .where(
          (booking) =>
              booking.courtId == courtId &&
              booking.startsAt.year == date.year &&
              booking.startsAt.month == date.month &&
              booking.startsAt.day == date.day &&
              booking.status != BookingStatus.cancelled,
        )
        .toList();
    final bookedIds = localBookings
        .map((booking) => booking.startsAt.millisecondsSinceEpoch)
        .toSet();
    return slots.map((slot) {
      if (!bookedIds.contains(slot.startsAt.millisecondsSinceEpoch)) {
        return slot;
      }
      final booking = localBookings.firstWhere(
        (item) =>
            item.startsAt.millisecondsSinceEpoch ==
            slot.startsAt.millisecondsSinceEpoch,
      );
      return BookingSlot(
        id: slot.id,
        courtId: slot.courtId,
        startsAt: slot.startsAt,
        endsAt: slot.endsAt,
        status: SlotStatus.reserved,
        bookingId: 'local',
        coachId: booking.coachId,
        coachName: booking.coachName,
        bookedByUserId: booking.bookedByUserId,
      );
    }).toList();
  }

  Booking _createLocalBooking(
    String coachId,
    String coachName,
    Court court,
    BookingSlot slot,
    String? bookedByUserId,
  ) {
    final id = 'BK-${DateTime.now().millisecondsSinceEpoch}';
    final booking = Booking(
      id: id,
      courtId: court.id,
      courtName: court.name,
      coachId: coachId,
      coachName: coachName,
      startsAt: slot.startsAt,
      endsAt: slot.endsAt,
      status: BookingStatus.pending, // starts as pending
      amount: court.hourlyRate,
      qrPayload: 'HONSET:$id:${slot.startsAt.toIso8601String()}',
      createdAt: DateTime.now(),
      bookedByUserId: bookedByUserId,
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
