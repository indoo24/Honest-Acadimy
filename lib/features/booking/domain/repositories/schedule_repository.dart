import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';

abstract class ScheduleRepository {
  Future<List<BookingSlot>> getSlots({
    required DateTime date,
    required String courtId,
  });

  Stream<List<BookingSlot>> watchSlots({
    required DateTime date,
    required String courtId,
  });
}
