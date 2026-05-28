import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_state.dart';

class CourtsCubit extends Cubit<CourtsState> {
  CourtsCubit(this._courtRepository, this._bookingRepository)
      : super(CourtsState.initial());

  final CourtRepository _courtRepository;
  final BookingRepository _bookingRepository;
  StreamSubscription<dynamic>? _courtsSubscription;

  Future<void> loadDashboard({DateTime? date}) async {
    final selectedDate = date ?? state.selectedDate;
    emit(
      state.copyWith(status: CourtsStatus.loading, selectedDate: selectedDate),
    );
    try {
      final courts = await _courtRepository.getCourts();
      final slotsByCourt = await _bookingRepository.getSlotsForCourts(
        date: selectedDate,
        courtIds: courts.map((court) => court.id).toList(),
      );
      emit(
        state.copyWith(
          status: CourtsStatus.loaded,
          courts: courts,
          slotsByCourt: slotsByCourt,
        ),
      );
      // Subscribe to real-time court updates
      _courtsSubscription?.cancel();
      _courtsSubscription = _courtRepository.watchCourts().listen(
        (updatedCourts) {
          if (!isClosed) {
            emit(state.copyWith(courts: updatedCourts));
          }
        },
        onError: (Object error) {
          if (!isClosed) {
            emit(
              state.copyWith(
                status: CourtsStatus.failure,
                message: error.toString(),
              ),
            );
          }
        },
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: CourtsStatus.failure, message: error.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _courtsSubscription?.cancel();
    return super.close();
  }
}