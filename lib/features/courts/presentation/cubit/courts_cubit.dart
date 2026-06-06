import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/domain/usecases/generate_slots.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';
import 'package:honset_app/features/courts/domain/repositories/court_repository.dart';
import 'package:honset_app/features/courts/presentation/cubit/courts_state.dart';

class CourtsCubit extends Cubit<CourtsState> {
  CourtsCubit(
    this._courtRepository,
    this._availabilityRepository,
    this._coachRepository,
    this._slotGenerator,
  ) : super(CourtsState.initial());

  final CourtRepository _courtRepository;
  final CourtAvailabilityRepository _availabilityRepository;
  final CoachRepository _coachRepository;
  final SlotGenerator _slotGenerator;
  StreamSubscription<dynamic>? _courtsSubscription;

  Future<void> loadDashboard({DateTime? date}) async {
    final selectedDate = date ?? state.selectedDate;
    emit(
      state.copyWith(status: CourtsStatus.loading, selectedDate: selectedDate),
    );
    try {
      debugPrint('[HOME QUERY] courts.getCourts()');
      final courts = await _courtRepository.getCourts();

      debugPrint('[HOME QUERY] coaches.getCoaches()');
      final coaches = await _coachRepository.getCoaches();
      debugPrint('[HOME QUERY] coaches.getCoaches() -> ${coaches.length}');

      debugPrint('[HOME QUERY] courtAvailability.getAllAvailabilities()');
      final availabilities = await _availabilityRepository
          .getAllAvailabilities();
      final availabilityByCourt = {
        for (final availability in availabilities)
          if (availability.isActive) availability.courtId: availability,
      };

      final slotsByCourt = <String, List<BookingSlot>>{};
      for (final court in courts) {
        final availability = availabilityByCourt[court.id];
        if (availability == null) {
          slotsByCourt[court.id] = const [];
          continue;
        }
        slotsByCourt[court.id] = _slotGenerator.generate(
          date: selectedDate,
          availability: availability,
          bookings: const [],
        );
      }
      debugPrint(
        '[HOME QUERY] generated slots from courtAvailability only for ${slotsByCourt.length} courts',
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
      debugPrint('[HOME QUERY] courts.watchCourts() subscribe');
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
