import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/booking/data/models/booking_model.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class FirestoreBookingDataSource {
  FirestoreBookingDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  static const List<String> _activeStatuses = [
    'confirmed',
    'pending_payment',
    'pending_payment_review',
  ];

  Query<Map<String, dynamic>> _adminDailyBookingsQuery(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('bookings')
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: _activeStatuses)
        .orderBy('startsAt');
  }

  Future<List<BookingModel>> getActiveBookingsForCourt({
    required String courtId,
    required DateTime date,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _firestore
        .collection('bookings')
        .where('courtId', isEqualTo: courtId)
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: _activeStatuses)
        .orderBy('startsAt')
        .get();
    debugPrint(
      '[FirestoreBookingDataSource] getActiveBookingsForCourt($courtId, $start) -> ${snapshot.docs.length}',
    );
    return snapshot.docs.map(BookingModel.fromFirestore).toList();
  }

  Stream<List<BookingModel>> watchActiveBookingsForCourt({
    required String courtId,
    required DateTime date,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('bookings')
        .where('courtId', isEqualTo: courtId)
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: _activeStatuses)
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '[FirestoreBookingDataSource] watchActiveBookingsForCourt($courtId, $start) -> ${snapshot.docs.length}',
          );
          return snapshot.docs.map(BookingModel.fromFirestore).toList();
        });
  }

  Future<List<BookingModel>> getActiveBookingsForDay(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _firestore
        .collection('bookings')
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: _activeStatuses)
        .orderBy('startsAt')
        .get();
    debugPrint(
      '[FirestoreBookingDataSource] getActiveBookingsForDay($start) -> ${snapshot.docs.length}',
    );
    return snapshot.docs.map(BookingModel.fromFirestore).toList();
  }

  Future<BookingModel> reserveSlot({
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
    String? paymentMethod,
  }) async {
    if (slot.endsAt.isBefore(DateTime.now())) {
      throw StateError('Cannot book a slot in the past');
    }
    final bookingRef = _firestore.collection('bookings').doc();
    final booking = BookingModel(
      id: bookingRef.id,
      courtId: court.id,
      courtName: court.name,
      coachId: coachId,
      coachName: coachName,
      startsAt: slot.startsAt,
      endsAt: slot.endsAt,
      status: BookingStatus.pending_payment,
      amount: court.pricePerHour,
      qrPayload: 'HONSET:${bookingRef.id}:${slot.startsAt.toIso8601String()}',
      createdAt: DateTime.now(),
      bookedByUserId: bookedByUserId,
      paymentMethod: paymentMethod,
    );

    final conflictQuery = _firestore
        .collection('bookings')
        .where('courtId', isEqualTo: court.id)
        .where('startsAt', isEqualTo: Timestamp.fromDate(slot.startsAt))
        .where('status', whereIn: _activeStatuses)
        .limit(1);
    final conflicts = await conflictQuery.get();
    if (conflicts.docs.isNotEmpty) {
      throw StateError('Slot is no longer available');
    }
    await bookingRef.set(booking.toMap());
    debugPrint('[FirestoreBookingDataSource] reserveSlot -> ${bookingRef.id}');
    return booking;
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('bookedByUserId', isEqualTo: userId)
          .orderBy('startsAt', descending: true)
          .get();
      debugPrint(
        '[FirestoreBookingDataSource] getUserBookings($userId) via bookedByUserId -> ${snapshot.docs.length}',
      );
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map(BookingModel.fromFirestore).toList();
      }
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirestoreBookingDataSource] getUserBookings via bookedByUserId failed: ${e.code} ${e.message}',
      );
    }

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('startsAt', descending: true)
          .get();
      debugPrint(
        '[FirestoreBookingDataSource] getUserBookings($userId) via userId -> ${snapshot.docs.length}',
      );
      return snapshot.docs.map(BookingModel.fromFirestore).toList();
    } on FirebaseException catch (e) {
      debugPrint(
        '[FirestoreBookingDataSource] getUserBookings via userId failed: ${e.code} ${e.message}',
      );
      debugPrint(
        '[FirestoreBookingDataSource] Falling back to fetching all bookings and filtering in-memory',
      );
      final allDocs = await _firestore.collection('bookings').get();
      final matching = allDocs.docs
          .where(
            (doc) =>
                doc.data()['bookedByUserId'] == userId ||
                doc.data()['userId'] == userId,
          )
          .toList();
      matching.sort(
        (a, b) =>
            (b.data()['startsAt'] as Timestamp?)?.toDate().compareTo(
                  (a.data()['startsAt'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                ) ??
            0,
      );
      debugPrint(
        '[FirestoreBookingDataSource] getUserBookings($userId) filtered in-memory -> ${matching.length}',
      );
      return matching.map(BookingModel.fromFirestore).toList();
    }
  }

  Future<List<BookingModel>> getDailyBookings(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final snapshot = await _adminDailyBookingsQuery(date).get();
    debugPrint(
      '[FirestoreBookingDataSource] getDailyBookings($start) -> ${snapshot.docs.length}',
    );
    if (snapshot.docs.isEmpty) {
      final anyBooking = await _firestore.collection('bookings').limit(1).get();
      if (anyBooking.docs.isEmpty) {
        debugPrint('[FirestoreBookingDataSource] WARNING: bookings collection is EMPTY');
      } else {
        debugPrint(
          '[FirestoreBookingDataSource] INFO: bookings collection has documents, but none for date $start. '
          'Check the startsAt field values.',
        );
        final sample = anyBooking.docs.first.data();
        debugPrint('[FirestoreBookingDataSource] Sample booking field: $sample');
      }
    }
    return snapshot.docs.map(BookingModel.fromFirestore).toList();
  }

  Stream<List<BookingModel>> watchDailyBookings(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    return _adminDailyBookingsQuery(date).snapshots().map((snapshot) {
      debugPrint(
        '[FirestoreBookingDataSource] watchDailyBookings -> ${snapshot.docs.length}',
      );
      if (snapshot.docs.isEmpty) {
        debugPrint(
          '[FirestoreBookingDataSource] WARNING: No bookings streamed for $start',
        );
      }
      return snapshot.docs.map(BookingModel.fromFirestore).toList();
    });
  }

  Future<void> confirmBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    final bookingSnap = await bookingRef.get();
    final data = bookingSnap.data();
    if (data == null) throw StateError('Booking not found: $bookingId');

    await bookingRef.update({
      'status': BookingStatus.confirmed.name,
      'paymentConfirmed': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[FirestoreBookingDataSource] confirmBooking($bookingId)');
  }

  Future<void> rejectBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    final bookingSnap = await bookingRef.get();
    final data = bookingSnap.data();
    if (data == null) throw StateError('Booking not found: $bookingId');

    await bookingRef.update({
      'status': BookingStatus.rejected.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[FirestoreBookingDataSource] rejectBooking($bookingId)');
  }

  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);

    await bookingRef.update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('[FirestoreBookingDataSource] cancelBooking($bookingId)');
  }
}
