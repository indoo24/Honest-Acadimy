import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/booking/presentation/cubit/booking_state.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';

import 'package:honset_app/core/utils/date_time_extensions.dart';
import 'package:honset_app/shared/repositories/notification_repository.dart';
import 'package:honset_app/features/booking/domain/entities/booking.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit(this._repository, this._notificationRepository) : super(const BookingState.initial());

  final BookingRepository _repository;
  final NotificationRepository _notificationRepository;

  Future<void> reserve({
    required String coachId,
    required String coachName,
    required Court court,
    required BookingSlot slot,
    String? bookedByUserId,
    String? paymentMethod,
  }) async {
    emit(state.copyWith(status: BookingActionStatus.loading, lastAction: BookingLastAction.reserve));
    try {
      debugPrint('CUBIT COACH ID: $coachId');
      debugPrint('CUBIT COACH NAME: $coachName');
      final booking = await _repository.reserveSlot(
        coachId: coachId,
        coachName: coachName,
        court: court,
        slot: slot,
        bookedByUserId: bookedByUserId,
        paymentMethod: paymentMethod,
      );

      if (booking.status == BookingStatus.pendingPayment || booking.status == BookingStatus.pendingPaymentReview) {
        await _notificationRepository.notifyAdmins(
          title: 'New Pending Booking! 🎾',
          body: 'Coach ${booking.coachName} requested ${booking.courtName} on ${booking.startsAt.readableDate}.',
          bookingId: booking.id,
        );
      }

      emit(
        state.copyWith(
          status: BookingActionStatus.success,
          latestBooking: booking,
          history: [booking, ...state.history],
          lastAction: BookingLastAction.reserve,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: BookingActionStatus.failure,
          message: error.toString(),
          lastAction: BookingLastAction.reserve,
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

  Future<void> cancelBooking({
    required String bookingId,
    required String coachName,
  }) async {
    emit(state.copyWith(status: BookingActionStatus.loading, lastAction: BookingLastAction.cancel));
    try {
      await _repository.cancelBooking(bookingId);

      await _notificationRepository.notifyAdmins(
        title: 'Booking Cancelled ❌',
        body: 'Coach $coachName has cancelled their booking.',
        bookingId: bookingId,
      );

      // Update the local history list to reflect the cancellation.
      final updatedHistory = state.history.map((b) {
        if (b.id == bookingId) {
          return Booking(
            id: b.id,
            courtId: b.courtId,
            courtName: b.courtName,
            coachId: b.coachId,
            coachName: b.coachName,
            startsAt: b.startsAt,
            endsAt: b.endsAt,
            status: BookingStatus.cancelled,
            amount: b.amount,
            qrPayload: b.qrPayload,
            createdAt: b.createdAt,
            bookedByUserId: b.bookedByUserId,
            paymentMethod: b.paymentMethod,
            paymentConfirmed: b.paymentConfirmed,
          );
        }
        return b;
      }).toList();

      emit(
        state.copyWith(
          status: BookingActionStatus.success,
          history: updatedHistory,
          lastAction: BookingLastAction.cancel,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: BookingActionStatus.failure,
          message: error.toString(),
          lastAction: BookingLastAction.cancel,
        ),
      );
    }
  }

  Future<void> rescheduleBooking({
    required String bookingId,
    required String coachName,
    required DateTime newStart,
    required DateTime newEnd,
  }) async {
    emit(state.copyWith(status: BookingActionStatus.loading, lastAction: BookingLastAction.reschedule));
    try {
      await _repository.rescheduleBooking(bookingId, newStart, newEnd);

      await _notificationRepository.notifyAdmins(
        title: 'Booking Rescheduled 📅',
        body: 'Coach $coachName requested a time change for their booking.',
        bookingId: bookingId,
      );

      // Update the local history list to reflect the reschedule.
      final updatedHistory = state.history.map((b) {
        if (b.id == bookingId) {
          return Booking(
            id: b.id,
            courtId: b.courtId,
            courtName: b.courtName,
            coachId: b.coachId,
            coachName: b.coachName,
            startsAt: newStart,
            endsAt: newEnd,
            status: BookingStatus.pendingPaymentReview,
            amount: b.amount,
            qrPayload: b.qrPayload,
            createdAt: b.createdAt,
            bookedByUserId: b.bookedByUserId,
            paymentMethod: b.paymentMethod,
            paymentConfirmed: false,
          );
        }
        return b;
      }).toList();

      emit(
        state.copyWith(
          status: BookingActionStatus.success,
          history: updatedHistory,
          lastAction: BookingLastAction.reschedule,
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: BookingActionStatus.failure,
          message: error.toString(),
          lastAction: BookingLastAction.reschedule,
        ),
      );
    }
  }
}
