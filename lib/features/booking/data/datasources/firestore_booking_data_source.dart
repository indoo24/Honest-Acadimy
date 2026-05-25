import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/booking/data/models/booking_model.dart';
import 'package:honset_app/features/booking/data/models/booking_slot_model.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class FirestoreBookingDataSource {
  FirestoreBookingDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Future<List<BookingSlotModel>> getSlots({
    required DateTime date,
    required String courtId,
  }) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _firestore
        .collection('schedules')
        .where('courtId', isEqualTo: courtId)
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('startsAt')
        .get();
    return snapshot.docs.map(BookingSlotModel.fromFirestore).toList();
  }

  /// Reserve a slot — booking starts as [BookingStatus.pending].
  /// Admin must confirm before it becomes [BookingStatus.confirmed].
  Future<BookingModel> reserveSlot({
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
  }) async {
    final bookingRef = _firestore.collection('bookings').doc();
    final scheduleRef = _firestore.collection('schedules').doc(slot.id);
    final booking = BookingModel(
      id: bookingRef.id,
      courtId: court.id,
      courtName: court.name,
      coachId: coachId,
      coachName: coachName,
      startsAt: slot.startsAt,
      endsAt: slot.endsAt,
      status: BookingStatus.pending, // always starts as pending
      amount: court.hourlyRate,
      qrPayload: 'HONSET:${bookingRef.id}:${slot.startsAt.toIso8601String()}',
      createdAt: DateTime.now(),
      bookedByUserId: bookedByUserId,
    );

    await _firestore.runTransaction((transaction) async {
      final schedule = await transaction.get(scheduleRef);
      final currentStatus = schedule.data()?['status'] as String?;
      if (currentStatus != null && currentStatus != SlotStatus.available.name) {
        throw StateError('Slot is no longer available');
      }
      transaction.set(bookingRef, booking.toMap());
      transaction.set(scheduleRef, {
        'courtId': court.id,
        'startsAt': Timestamp.fromDate(slot.startsAt),
        'endsAt': Timestamp.fromDate(slot.endsAt),
        'status': SlotStatus.pending.name, // slot is pending until admin confirms
        'bookingId': bookingRef.id,
        'coachId': coachId,
        'coachName': coachName,
        'bookedByUserId': bookedByUserId,
      }, SetOptions(merge: true));
    });
    return booking;
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('bookedByUserId', isEqualTo: userId)
        .orderBy('startsAt', descending: true)
        .get();
    return snapshot.docs.map(BookingModel.fromFirestore).toList();
  }

  Future<List<BookingModel>> getDailyBookings(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snapshot = await _firestore
        .collection('bookings')
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('startsAt')
        .get();
    return snapshot.docs.map(BookingModel.fromFirestore).toList();
  }

  /// Real-time stream of all bookings for a given day.
  Stream<List<BookingModel>> watchDailyBookings(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('bookings')
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '[FirestoreBookingDataSource] watchDailyBookings -> ${snapshot.docs.length}',
          );
          return snapshot.docs.map(BookingModel.fromFirestore).toList();
        });
  }

  /// Admin confirms a pending booking → status becomes confirmed.
  /// Also updates the schedule slot to reserved.
  Future<void> confirmBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    final bookingSnap = await bookingRef.get();
    final data = bookingSnap.data();
    if (data == null) throw StateError('Booking not found');

    final scheduleQuery = await _firestore
        .collection('schedules')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    final batch = _firestore.batch();
    batch.update(bookingRef, {
      'status': BookingStatus.confirmed.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (scheduleQuery.docs.isNotEmpty) {
      batch.update(scheduleQuery.docs.first.reference, {
        'status': SlotStatus.reserved.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Admin rejects a pending booking → status becomes cancelled.
  /// Frees up the schedule slot back to available.
  Future<void> rejectBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    final bookingSnap = await bookingRef.get();
    final data = bookingSnap.data();
    if (data == null) throw StateError('Booking not found');

    final scheduleQuery = await _firestore
        .collection('schedules')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    final batch = _firestore.batch();
    batch.update(bookingRef, {
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (scheduleQuery.docs.isNotEmpty) {
      batch.update(scheduleQuery.docs.first.reference, {
        'status': SlotStatus.available.name,
        'bookingId': FieldValue.delete(),
        'coachId': FieldValue.delete(),
        'coachName': FieldValue.delete(),
        'bookedByUserId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// Admin cancels a confirmed booking → frees the slot.
  Future<void> cancelBooking(String bookingId) async {
    final bookingRef = _firestore.collection('bookings').doc(bookingId);
    final scheduleQuery = await _firestore
        .collection('schedules')
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();

    final batch = _firestore.batch();
    batch.update(bookingRef, {
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    if (scheduleQuery.docs.isNotEmpty) {
      batch.update(scheduleQuery.docs.first.reference, {
        'status': SlotStatus.available.name,
        'bookingId': FieldValue.delete(),
        'coachId': FieldValue.delete(),
        'coachName': FieldValue.delete(),
        'bookedByUserId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
