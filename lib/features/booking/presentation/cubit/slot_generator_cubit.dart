import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:honset_app/features/booking/domain/entities/booking_slot.dart';
import 'package:honset_app/features/booking/domain/repositories/booking_repository.dart';

part 'slot_generator_state.dart';

/// Cubit responsible for providing generated slots for a given court and date.
class SlotGeneratorCubit extends Cubit<SlotGeneratorState> {
  SlotGeneratorCubit({
    required BookingRepository bookingRepository,
  })  : _bookingRepository = bookingRepository,
        super(const SlotGeneratorInitial());

  final BookingRepository _bookingRepository;

  /// Loads the availability for [courtId] and generates slots for [date].
  Future<void> loadSlots({required String courtId, required DateTime date}) async {
    emit(const SlotGeneratorLoading());
    try {
      final slots = await _bookingRepository.getSlots(
        date: date,
        courtId: courtId,
      );
      emit(SlotGeneratorLoaded(slots: slots));
    } catch (e) {
      emit(SlotGeneratorError(e.toString()));
    }
  }
}

