import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository) : super(const BookingState.initial());

  final BookingRepository _repository;

  Future<void> reserve({
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
  }) async {
    emit(state.copyWith(status: BookingActionStatus.loading));
    try {
      debugPrint('CUBIT COACH ID: $coachId');
      debugPrint('CUBIT COACH NAME: $coachName');
      final booking = await _repository.reserveSlot(
        coachId: coachId,
        coachName: coachName,
        court: court,
        slot: slot,
        bookedByUserId: bookedByUserId,
      );
      emit(
        state.copyWith(
          status: BookingActionStatus.success,
          latestBooking: booking,
          history: [booking, ...state.history],
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: BookingActionStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> loadHistory(String userId) async {
    emit(state.copyWith(status: BookingActionStatus.loading));
    try {
      final history = await _repository.getUserBookings(userId);
      emit(
        state.copyWith(status: BookingActionStatus.success, history: history),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: BookingActionStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
