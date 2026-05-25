import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/booking/data/models/booking_slot_model.dart';

class FirestoreScheduleDataSource {
  FirestoreScheduleDataSource(this._firestore);

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
    debugPrint(
      '[FirestoreScheduleDataSource] getSlots($courtId) -> ${snapshot.docs.length}',
    );
    return snapshot.docs.map(BookingSlotModel.fromFirestore).toList();
  }

  Stream<List<BookingSlotModel>> watchSlots({
    required DateTime date,
    required String courtId,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _firestore
        .collection('schedules')
        .where('courtId', isEqualTo: courtId)
        .where('startsAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('startsAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('startsAt')
        .snapshots()
        .map((snapshot) {
          debugPrint(
            '[FirestoreScheduleDataSource] watchSlots($courtId) -> ${snapshot.docs.length}',
          );
          return snapshot.docs.map(BookingSlotModel.fromFirestore).toList();
        });
  }
}
