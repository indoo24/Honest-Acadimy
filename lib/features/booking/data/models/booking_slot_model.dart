import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';

class BookingSlotModel extends BookingSlot {
  const BookingSlotModel({
    required super.id,
    required super.courtId,
    required super.startsAt,
    required super.endsAt,
    required super.status,
    super.bookingId,
  });

  factory BookingSlotModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final status = data['status'] as String? ?? 'available';
    return BookingSlotModel(
      id: doc.id,
      courtId: data['courtId'] as String? ?? '',
      startsAt: (data['startsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endsAt: (data['endsAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: SlotStatus.values.firstWhere(
        (value) => value.name == status,
        orElse: () => SlotStatus.available,
      ),
      bookingId: data['bookingId'] as String?,
    );
  }
}
