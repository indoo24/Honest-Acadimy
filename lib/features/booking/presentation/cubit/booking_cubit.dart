import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository) : super(const BookingState.initial());

  final BookingRepository _repository;

  Future<void> reserve({
    required String userId,
    required String userName,
    required Court court,
    required BookingSlot slot,
    String? phoneNumber,
    int? playerAge,
  }) async {
    emit(state.copyWith(status: BookingActionStatus.loading));
    try {
      final booking = await _repository.reserveSlot(
        userId: userId,
        userName: userName,
        court: court,
        slot: slot,
        phoneNumber: phoneNumber,
        playerAge: playerAge,
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
