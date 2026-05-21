import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_state.dart';

class CourtsCubit extends Cubit<CourtsState> {
  CourtsCubit(this._courtRepository, this._bookingRepository)
    : super(CourtsState.initial());

  final CourtRepository _courtRepository;
  final BookingRepository _bookingRepository;

  Future<void> loadDashboard({DateTime? date}) async {
    final selectedDate = date ?? state.selectedDate;
    emit(
      state.copyWith(status: CourtsStatus.loading, selectedDate: selectedDate),
    );
    try {
      final courts = await _courtRepository.getCourts();
      final slotsByCourt = <String, List>{};
      for (final court in courts) {
        slotsByCourt[court.id] = await _bookingRepository.getSlots(
          date: selectedDate,
          courtId: court.id,
        );
      }
      emit(
        state.copyWith(
          status: CourtsStatus.loaded,
          courts: courts,
          slotsByCourt: slotsByCourt.map(
            (key, value) => MapEntry(key, value.cast()),
          ),
        ),
      );
    } on Object catch (error) {
      emit(
        state.copyWith(status: CourtsStatus.failure, message: error.toString()),
      );
    }
  }
}
