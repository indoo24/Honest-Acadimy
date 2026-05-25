import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/admin/presentation/cubit/admin_state.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';

class AdminCubit extends Cubit<AdminState> {
  AdminCubit(
    this._bookingRepository,
    this._courtRepository,
    this._coachRepository,
  ) : super(const AdminState.initial());

  final BookingRepository _bookingRepository;
  final CourtRepository _courtRepository;
  final CoachRepository _coachRepository;

  StreamSubscription<dynamic>? _bookingSubscription;

  /// Load courts & coaches once, then subscribe to real-time booking stream.
  Future<void> loadDailyOverview({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    emit(state.copyWith(status: AdminStatus.loading, selectedDate: targetDate));

    try {
      final courts = await _courtRepository.getCourts();
      final coaches = await _coachRepository.getCoaches();

      emit(
        state.copyWith(
          status: AdminStatus.loaded,
          courts: courts,
          coaches: coaches,
          selectedDate: targetDate,
        ),
      );

      // Cancel any previous subscription before starting a new one.
      await _bookingSubscription?.cancel();
      _bookingSubscription = _bookingRepository
          .watchDailyBookings(targetDate)
          .listen(
            (bookings) {
              if (!isClosed) {
                emit(
                  state.copyWith(
                    status: AdminStatus.loaded,
                    bookings: bookings,
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

  /// Admin confirms a pending booking.
  Future<void> confirmBooking(String bookingId) async {
    try {
      await _bookingRepository.confirmBooking(bookingId);
      if (!_isFirebaseStream) await _reloadBookings();
    } on Object catch (error) {
      emit(state.copyWith(status: AdminStatus.failure, message: error.toString()));
    }
  }

  /// Admin rejects a pending booking.
  Future<void> rejectBooking(String bookingId) async {
    try {
      await _bookingRepository.rejectBooking(bookingId);
      if (!_isFirebaseStream) await _reloadBookings();
    } on Object catch (error) {
      emit(state.copyWith(status: AdminStatus.failure, message: error.toString()));
    }
  }

  /// Admin cancels a confirmed booking.
  Future<void> cancelBooking(String bookingId) async {
    try {
      await _bookingRepository.cancelBooking(bookingId);
      if (!_isFirebaseStream) await _reloadBookings();
    } on Object catch (error) {
      emit(state.copyWith(status: AdminStatus.failure, message: error.toString()));
    }
  }

  /// Admin manually adds a booking (starts as pending).
  Future<void> addManualBooking({
    required String courtId,
    required String coachId,
    required String coachName,
    required DateTime date,
    required int hour,
    String? bookedByUserId,
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
        coachId: coachId,
        coachName: coachName,
        court: court,
        slot: slot,
        bookedByUserId: bookedByUserId,
      );
      emit(state.copyWith(status: AdminStatus.loaded));
    } on Object catch (error) {
      emit(
        state.copyWith(status: AdminStatus.failure, message: error.toString()),
      );
    }
  }

  // ── private helpers ───────────────────────────────────────────────────────

  /// True when we have an active Firestore stream (not a single-value fallback).
  bool get _isFirebaseStream => _bookingSubscription != null;

  Future<void> _reloadBookings() async {
    final date = state.selectedDate ?? DateTime.now();
    final bookings = await _bookingRepository.getDailyBookings(date);
    if (!isClosed) {
      emit(state.copyWith(status: AdminStatus.loaded, bookings: bookings));
    }
  }

  @override
  Future<void> close() async {
    await _bookingSubscription?.cancel();
    return super.close();
  }
}