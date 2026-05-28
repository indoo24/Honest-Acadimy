part of 'slot_generator_cubit.dart';

abstract class SlotGeneratorState extends Equatable {
  const SlotGeneratorState();
  @override
  List<Object?> get props => [];
}

class SlotGeneratorInitial extends SlotGeneratorState {
  const SlotGeneratorInitial();
}

class SlotGeneratorLoading extends SlotGeneratorState {
  const SlotGeneratorLoading();
}

class SlotGeneratorLoaded extends SlotGeneratorState {
  final List<BookingSlot> slots;
  const SlotGeneratorLoaded({required this.slots});
  @override
  List<Object?> get props => [slots];
}

class SlotGeneratorError extends SlotGeneratorState {
  final String message;
  const SlotGeneratorError(this.message);
  @override
  List<Object?> get props => [message];
}

