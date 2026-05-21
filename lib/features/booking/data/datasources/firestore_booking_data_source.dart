import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<BookingModel> reserveSlot({
    required String userId,
    required String userName,
    required Court court,
    required BookingSlot slot,
    String? phoneNumber,
    int? playerAge,
  }) async {
    final bookingRef = _firestore.collection('bookings').doc();
    final scheduleRef = _firestore.collection('schedules').doc(slot.id);
    final booking = BookingModel(
      id: bookingRef.id,
      userId: userId,
      userName: userName,
      courtId: court.id,
      courtName: court.name,
      coachName: court.coach.name,
      startsAt: slot.startsAt,
      endsAt: slot.endsAt,
      status: BookingStatus.confirmed,
      amount: court.hourlyRate,
      qrPayload: 'HONSET:${bookingRef.id}:${slot.startsAt.toIso8601String()}',
      createdAt: DateTime.now(),
      phoneNumber: phoneNumber,
      playerAge: playerAge,
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
        'status': SlotStatus.reserved.name,
        'bookingId': bookingRef.id,
      }, SetOptions(merge: true));
    });
    return booking;
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
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

  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': BookingStatus.cancelled.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
