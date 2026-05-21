import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._bookingRepository, this._courtRepository)
    : super(const AdminState.initial());

  final BookingRepository _bookingRepository;
  final CourtRepository _courtRepository;

  Future<void> loadDailyOverview({DateTime? date}) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final courts = await _courtRepository.getCourts();
      final bookings = await _bookingRepository.getDailyBookings(
        date ?? DateTime.now(),
      );
      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          bookings: bookings,
          courts: courts,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: AdminStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> addManualBooking({
    required String courtId,
    required String memberName,
    required DateTime date,
    required int hour,
  }) async {
    emit(state.copyWith(status: AdminStatus.loading));
    try {
      final court = await _courtRepository.getCourtById(courtId);
      final slots = await _bookingRepository.getSlots(
        date: date,
        courtId: courtId,
      );
      final slot = slots.firstWhere(
        (item) =>
            item.startsAt.hour == hour && item.status == SlotStatus.available,
      );
      await _bookingRepository.reserveSlot(
        userId: 'admin-manual-${memberName.hashCode}',
        userName: memberName.trim().isEmpty
            ? 'Walk-in Member'
            : memberName.trim(),
        court: court,
        slot: slot,
      );
      await loadDailyOverview(date: date);
    } on Object catch (error) {
      emit(
        state.copyWith(status: AdminStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    await _bookingRepository.cancelBooking(bookingId);
    await loadDailyOverview();
  }
}
