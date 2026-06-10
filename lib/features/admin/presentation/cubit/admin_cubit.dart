import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';

import 'package:honset_app/shared/repositories/notification_repository.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(this._bookingRepository, this._notificationRepository) : super(const AdminState.initial());

  final BookingRepository _bookingRepository;
  final NotificationRepository _notificationRepository;

  StreamSubscription<List<Booking>>? _bookingSubscription;

  Future<void> loadDailyOverview({DateTime? date}) async {
    final targetDate = (date ?? state.selectedDate ?? DateTime.now()).dateOnly;
    emit(
      state.copyWith(
        status: AdminStatus.loading,
        selectedDate: targetDate,
        message: null,
      ),
    );

    try {
      await _bookingSubscription?.cancel();
      _bookingSubscription = _bookingRepository.watchDailyBookings(targetDate).listen(
        (bookings) {
          if (!isClosed) {
            emit(
              state.copyWith(
                status: AdminStatus.loaded,
                bookings: bookings,
                selectedDate: targetDate,
                message: null,
              ),
            );
          }
        },
        onError: (Object error) {
          if (!isClosed) {
            emit(
              state.copyWith(
                status: AdminStatus.failure,
                message: error.toString(),
              ),
            );
          }
        },
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: AdminStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> selectDate(DateTime date) {
    return loadDailyOverview(date: date);
  }

  Future<void> confirmBooking(String bookingId) async {
    try {
      await _bookingRepository.confirmBooking(bookingId);
      final booking = state.bookings.firstWhere((b) => b.id == bookingId);
      if (booking.bookedByUserId != null) {
        await _notificationRepository.sendNotification(
          receiverId: booking.bookedByUserId!,
          title: 'Booking confirmed',
          body: '${booking.courtName} at ${booking.startsAt.hour}:00',
          type: 'booking_confirmed',
          bookingId: bookingId,
        );
      }
    } on Object catch (error) {
      emit(
        state.copyWith(status: AdminStatus.failure, message: error.toString()),
      );
    }
  }

  Future<void> rejectBooking(String bookingId) async {
    try {
      await _bookingRepository.rejectBooking(bookingId);
      final booking = state.bookings.firstWhere((b) => b.id == bookingId);
      if (booking.bookedByUserId != null) {
        await _notificationRepository.sendNotification(
          receiverId: booking.bookedByUserId!,
          title: 'Booking rejected',
          body: '${booking.courtName} at ${booking.startsAt.hour}:00',
          type: 'booking_rejected',
          bookingId: bookingId,
        );
      }
    } on Object catch (error) {
      emit(
        state.copyWith(status: AdminStatus.failure, message: error.toString()),
      );
    }
  }

  @override
  Future<void> close() async {
    await _bookingSubscription?.cancel();
    return super.close();
  }
}
