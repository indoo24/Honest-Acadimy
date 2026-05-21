import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.courtId,
    required super.courtName,
    required super.coachName,
    required super.startsAt,
    required super.endsAt,
    required super.status,
    required super.amount,
    required super.qrPayload,
    required super.createdAt,
    super.phoneNumber,
    super.playerAge,
  });

  factory BookingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final status = data['status'] as String? ?? 'pending';
    return BookingModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Club Member',
      courtId: data['courtId'] as String? ?? '',
      courtName: data['courtName'] as String? ?? 'Court',
      coachName: data['coachName'] as String? ?? 'Coach',
      startsAt: (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endsAt: (data['endsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: BookingStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => BookingStatus.pending,
      ),
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      qrPayload: data['qrPayload'] as String? ?? doc.id,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: data['phoneNumber'] as String?,
      playerAge: (data['playerAge'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'courtId': courtId,
      'courtName': courtName,
      'coachName': coachName,
      'startsAt': Timestamp.fromDate(startsAt),
      'endsAt': Timestamp.fromDate(endsAt),
      'status': status.name,
      'amount': amount,
      'qrPayload': qrPayload,
      'phoneNumber': phoneNumber,
      'playerAge': playerAge,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
