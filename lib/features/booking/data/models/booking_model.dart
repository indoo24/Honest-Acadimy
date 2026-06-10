import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.courtId,
    required super.courtName,
    required super.coachId,
    required super.coachName,
    required super.startsAt,
    required super.endsAt,
    required super.status,
    required super.amount,
    required super.qrPayload,
    required super.createdAt,
    super.bookedByUserId,
    super.paymentMethod,
    super.paymentConfirmed,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final status = data['status'] as String? ?? 'pendingPayment';
    debugPrint(
      '[BOOKING FIRESTORE READ]\ncoachId=${data['coachId']}\ncoachName=${data['coachName']}',
    );
    return BookingModel(
      id: doc.id,
      courtId: data['courtId'] as String? ?? '',
      courtName: data['courtName'] as String? ?? 'Court',
      coachId: data['coachId'] as String? ?? '',
      coachName: data['coachName'] as String? ?? 'Coach',
      startsAt: (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endsAt: (data['endsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: BookingStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => BookingStatus.pendingPayment,
      ),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      qrPayload: data['qrPayload'] as String? ?? doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      bookedByUserId:
          data['bookedByUserId'] as String? ?? data['userId'] as String?,
      paymentMethod: data['paymentMethod'] as String?,
      paymentConfirmed: data['paymentConfirmed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'courtId': courtId,
      'courtName': courtName,
      'coachId': coachId,
      'coachName': coachName,
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': status.name,
      'amount': amount,
      'qrPayload': qrPayload,
      'bookedByUserId': bookedByUserId,
      'paymentMethod': paymentMethod,
      'paymentConfirmed': paymentConfirmed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
