import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/entities/court_availability.dart';
import 'package:honset_app/features/booking/domain/repositories/court_availability_repository.dart';
import 'package:honset_app/features/booking/domain/usecases/generate_slots.dart';
import 'package:honset_app/features/coaches/domain/repositories/coach_repository.dart';
import 'package:honset_app/features/courts/domain/entities/court.dart';
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

  // ── Cached data so date changes don't re-fetch ──
  List<Court> _cachedCourts = const [];
  Map<String, CourtAvailability> _availabilityByCourt = const {};
  bool _isInitialised = false;
  bool _isLoading = false;

  // ── Public API ──

  /// Initial entry point — fetches all data from Firestore and subscribes
  /// to the courts stream. Safe to call multiple times (no-ops after first).
  Future<void> loadDashboard({DateTime? date}) async {
    if (_isLoading) return; // Prevent overlapping calls.

    final selectedDate = date ?? state.selectedDate;

    if (_isInitialised && date != null) {
      // Only the date changed — reuse cached data.
      _regenerateSlots(selectedDate);
      return;
    }

    _isLoading = true;
    emit(
      state.copyWith(status: CourtsStatus.loading, selectedDate: selectedDate),
    );

    try {
      // Parallel fetch: courts, coaches, availabilities.
      final results = await Future.wait([
        _courtRepository.getCourts(),
        _coachRepository.getCoaches(),
        _availabilityRepository.getAllAvailabilities(),
      ]);

      final courts = results[0] as List<Court>;
      final availabilities = results[2] as List<CourtAvailability>;

      // Cache for date-only refreshes.
      _cachedCourts = courts;
      _availabilityByCourt = {
        for (final a in availabilities)
          if (a.isActive) a.courtId: a,
      };

      final slotsByCourt = _buildSlots(courts, selectedDate);

      if (kDebugMode) {
        debugPrint('[HOME] Dashboard loaded: ${courts.length} courts, '
            '${slotsByCourt.length} with slots');
      }

      emit(
        state.copyWith(
          status: CourtsStatus.loaded,
          courts: courts,
          slotsByCourt: slotsByCourt,
        ),
      );

      // Subscribe to real-time court updates — only once.
      _subscribeToCourts();
      _isInitialised = true;
    } on Object catch (error) {
      emit(
        state.copyWith(
          status: CourtsStatus.failure,
          message: error.toString(),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  /// Changes the selected date and regenerates slots from cached data.
  /// No Firestore calls.
  void selectDate(DateTime date) {
    if (!_isInitialised) {
      loadDashboard(date: date);
      return;
    }
    _regenerateSlots(date);
  }

  /// Force refresh — clears cache and re-fetches everything.
  Future<void> refresh() async {
    _isInitialised = false;
    _isLoading = false;
    await loadDashboard();
  }

  // ── Private helpers ──

  void _regenerateSlots(DateTime date) {
    final slotsByCourt = _buildSlots(_cachedCourts, date);
    emit(
      state.copyWith(
        status: CourtsStatus.loaded,
        selectedDate: date,
        slotsByCourt: slotsByCourt,
      ),
    );
  }

  Map<String, List<BookingSlot>> _buildSlots(
    List<Court> courts,
    DateTime date,
  ) {
    final slotsByCourt = <String, List<BookingSlot>>{};
    for (final court in courts) {
      final availability = _availabilityByCourt[court.id];
      if (availability == null) {
        slotsByCourt[court.id] = const [];
        continue;
      }
      slotsByCourt[court.id] = _slotGenerator.generate(
        date: date,
        availability: availability,
        bookings: const [],
      );
    }
    return slotsByCourt;
  }

  void _subscribeToCourts() {
    // Only subscribe once.
    if (_courtsSubscription != null) return;

    if (kDebugMode) {
      debugPrint('[HOME] Subscribing to courts stream');
    }
    _courtsSubscription = _courtRepository.watchCourts().listen(
      (updatedCourts) {
        if (isClosed) return;
        _cachedCourts = updatedCourts;
        // Regenerate slots with updated courts + current date.
        final slotsByCourt = _buildSlots(updatedCourts, state.selectedDate);
        emit(state.copyWith(
          courts: updatedCourts,
          slotsByCourt: slotsByCourt,
        ));
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
  }

  @override
  Future<void> close() {
    _courtsSubscription?.cancel();
    return super.close();
  }
}
